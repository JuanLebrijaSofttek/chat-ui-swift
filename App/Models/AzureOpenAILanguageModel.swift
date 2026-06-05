import Foundation
import HuggingChatKit

/// Wraps OpenAILanguageModel for Azure OpenAI deployments.
///
/// Azure requires an `api-key` header (not `Authorization: Bearer`) and an
/// `api-version` query parameter. This wrapper intercepts all requests via
/// a custom URLProtocol to rewrite those headers automatically.
struct AzureOpenAILanguageModel: LanguageModel {
    typealias UnavailableReason = Never

    var availability: Availability<Never> { .available }

    private let inner: OpenAILanguageModel

    init(endpoint: URL, apiKey: String, deployment: String, apiVersion: String = "2024-12-01-preview") {
        AzureURLProtocol.apiKey = apiKey
        AzureURLProtocol.apiVersion = apiVersion

        let config = URLSessionConfiguration.default
        config.protocolClasses = [AzureURLProtocol.self]
        let session = URLSession(configuration: config)

        // baseURL must end with "/" so OpenAILanguageModel appends "chat/completions" cleanly
        var base = endpoint
        if !base.path.hasSuffix("/") {
            base = base.appendingPathComponent("")
        }

        self.inner = OpenAILanguageModel(
            baseURL: base,
            apiKey: apiKey,
            model: deployment,
            session: session
        )
    }

    func respond<Content>(
        within session: LanguageModelSession,
        to prompt: Prompt,
        generating type: Content.Type,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions
    ) async throws -> LanguageModelSession.Response<Content> where Content: Generable {
        try await inner.respond(
            within: session,
            to: prompt,
            generating: type,
            includeSchemaInPrompt: includeSchemaInPrompt,
            options: options
        )
    }

    func streamResponse<Content>(
        within session: LanguageModelSession,
        to prompt: Prompt,
        generating type: Content.Type,
        includeSchemaInPrompt: Bool,
        options: GenerationOptions
    ) -> sending LanguageModelSession.ResponseStream<Content> where Content: Generable {
        inner.streamResponse(
            within: session,
            to: prompt,
            generating: type,
            includeSchemaInPrompt: includeSchemaInPrompt,
            options: options
        )
    }
}

// MARK: - URLProtocol that rewrites Azure auth headers

private final class AzureURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var apiKey: String = ""
    nonisolated(unsafe) static var apiVersion: String = "2024-12-01-preview"

    // A plain URLSession (no custom protocols) used for the actual request
    private static let innerSession: URLSession = {
        let cfg = URLSessionConfiguration.default
        // Explicitly clear protocolClasses so AzureURLProtocol is not registered here
        cfg.protocolClasses = []
        return URLSession(configuration: cfg)
    }()

    private var innerTask: URLSessionDataTask?
    private var delegateHolder: DataDelegate?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        var req = request
        // Replace Bearer auth with Azure api-key header
        req.setValue(nil, forHTTPHeaderField: "Authorization")
        req.setValue(AzureURLProtocol.apiKey, forHTTPHeaderField: "api-key")
        // Inject api-version query parameter
        if var comps = URLComponents(url: req.url!, resolvingAgainstBaseURL: false) {
            var items = comps.queryItems ?? []
            items.removeAll { $0.name == "api-version" }
            items.append(URLQueryItem(name: "api-version", value: AzureURLProtocol.apiVersion))
            comps.queryItems = items
            req.url = comps.url
        }

        let delegate = DataDelegate(proto: self)
        delegateHolder = delegate
        let delegateSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: delegate,
            delegateQueue: nil
        )
        innerTask = delegateSession.dataTask(with: req)
        innerTask?.resume()
    }

    override func stopLoading() {
        innerTask?.cancel()
        innerTask = nil
        delegateHolder = nil
    }
}

private final class DataDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
    weak var proto: AzureURLProtocol?

    init(proto: AzureURLProtocol) {
        self.proto = proto
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {
        proto?.client?.urlProtocol(proto!, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let proto else { return }
        proto.client?.urlProtocol(proto, didLoad: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let proto else { return }
        if let error {
            proto.client?.urlProtocol(proto, didFailWithError: error)
        } else {
            proto.client?.urlProtocolDidFinishLoading(proto)
        }
    }
}
