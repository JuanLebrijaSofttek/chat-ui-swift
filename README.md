# Chat UI Swift

A SwiftUI chat application showcasing 
[swift-huggingface](https://github.com/mattt/swift-huggingface) and 
[AnyLanguageModel](https://github.com/mattt/AnyLanguageModel).

<video src="https://github.com/user-attachments/assets/5adc7592-a101-4c57-b82f-2f6a26ef350a" controls muted loop>
  <p>Demo of Chat UI Swift showing conversations with Apple Intelligence and Hugging Face models</p>
</video>

> [!NOTE] 
> This project is in active development. 
> Features and APIs may change.

## Features

- [x] **Apple Intelligence** — Native integration with Apple Foundation Models (macOS 26+) for on-device AI
- [x] **Hugging Face Integration** — Connect to Hugging Face with OAuth 2.0 authentication
- [x] **Streaming Responses** — Real-time streaming of AI responses for a responsive user experience
- [x] **Chat Persistence** — Save and manage multiple conversations
- [ ] **MLX Model Support** — Download and run models locally using MLX
- [ ] **CoreML Integration** — Support for CoreML-optimized models
- [ ] **GGUF Format Support** — Load GGUF models from Hugging Face Hub
- [ ] **Model Downloads** — Browse and download models directly from Hugging Face
- [ ] **BYOK** — Bring your own API keys for other inference providers (OpenAI, Anthropic, etc.)

## Getting Started

### Prerequisites

- macOS 26 or later
- Xcode 26+

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/mattt/chat-ui-swift.git
cd chat-ui-swift
```

2. **Open in Xcode**

```bash
xed .
```

3. **Build and run**

Press <kbd>⌘</kbd><kbd>R</kbd> to build and run the application.

### Using Hugging Face Models

To use Hugging Face's Inference API:

1. Launch the app
2. Click the sign-in button in the sidebar
3. Authenticate with your Hugging Face account
4. Select a Hugging Face model from the model picker
5. Start chatting!

The app uses OAuth 2.0 to securely authenticate with Hugging Face. 
Your access token is stored securely in the Keychain and automatically refreshed when needed.

## Supported Models

The app supports multiple inference backends. Use the model picker in the message composer to switch between them.

### Hugging Face

Routed through [Hugging Face's Inference Router](https://huggingface.co/docs/api-inference) (`router.huggingface.co/v1`), which exposes an OpenAI-compatible API. Requires signing in with your Hugging Face account.

| Model | Size | Notes |
|---|---|---|
| Llama 3.3 Instruct | 70B | Requires HF PRO or pay-as-you-go credits |
| Llama 3.1 Instruct | 8B | May be covered by free tier |
| Qwen 2.5 Instruct | 72B | Requires HF PRO or pay-as-you-go credits |
| Mistral Instruct v0.3 | 7B | May be covered by free tier |
| Gemma 2 IT | 9B | May be covered by free tier |

**Pricing:** Hugging Face provides a small free monthly credit (~$0.10–$2 depending on account type). Larger models (70B+) typically require a [PRO subscription](https://huggingface.co/pricing) ($9/month) or pay-as-you-go credits. Usage is billed to the account of the logged-in user.

### OpenAI

Requires an OpenAI API key set in `App/Models/APIKeys.swift`. Billed to your OpenAI account.

| Model | Notes |
|---|---|
| GPT-4o | Most capable OpenAI model |
| GPT-4o mini | Faster and cheaper |

### Anthropic (Claude)

Requires an Anthropic API key set in `App/Models/APIKeys.swift`. Billed to your Anthropic account.

| Model | Notes |
|---|---|
| Claude Opus 4 | Most capable Claude model |
| Claude Sonnet 4 | Balanced capability and speed |
| Claude Haiku 4 | Fastest and most affordable |

### Azure OpenAI

Uses your Azure OpenAI resource endpoint and key, configured in `App/Models/APIKeys.swift`. Billed to your Azure subscription.

| Model | Notes |
|---|---|
| GPT-4.1 mini | Deployed via Azure OpenAI Service |

### Apple Intelligence

On-device inference via Apple's Foundation Models framework. Requires macOS 26 or iOS 26. Free — no account or API key needed.

## Related Projects

- https://github.com/huggingface/swift-chat
- https://github.com/huggingface/chat-ui

## License

This project is available under the MIT license. 
See the LICENSE file for more info.

## Legal

Hugging Face® is a registered trademark of Hugging Face, Inc.
