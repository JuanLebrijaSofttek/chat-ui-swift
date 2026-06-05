enum Model: Hashable, Codable, Sendable {
    case system
    case mlx(String)
    case huggingFace(String)
    case openAI(String)
    case claude(String)
    case azure(String)
}

extension Model {
    var displayName: String {
        switch self {
        case .system:
            return "Apple Intelligence"
        case .mlx(let modelId):
            return modelId
        case .huggingFace(let model):
            return "HuggingFace: \(model)"
        case .openAI(let model):
            return "OpenAI: \(model)"
        case .claude(let model):
            return "Claude: \(model)"
        case .azure(let deployment):
            return "Azure: \(deployment)"
        }
    }

    var shortName: String {
        switch self {
        case .system:
            return "Apple Intelligence"
        case .mlx:
            return "MLX"
        case .huggingFace(let model):
            return model.split(separator: "/").last.map(String.init) ?? model
        case .openAI(let model):
            return model
        case .claude(let model):
            return model.split(separator: "-").prefix(2).joined(separator: "-")
        case .azure(let deployment):
            return "Azure/\(deployment)"
        }
    }
}
