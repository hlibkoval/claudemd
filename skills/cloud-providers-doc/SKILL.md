---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment options.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers and LLM gateways.

## Quick Reference

### Provider comparison

| Feature               | Amazon Bedrock               | Google Vertex AI            | Microsoft Foundry           |
| :-------------------- | :--------------------------- | :-------------------------- | :-------------------------- |
| **Enable env var**    | `CLAUDE_CODE_USE_BEDROCK=1`  | `CLAUDE_CODE_USE_VERTEX=1`  | `CLAUDE_CODE_USE_FOUNDRY=1` |
| **Region env var**    | `AWS_REGION`                 | `CLOUD_ML_REGION`           | n/a (set via resource)      |
| **Project/resource**  | n/a                          | `ANTHROPIC_VERTEX_PROJECT_ID` | `ANTHROPIC_FOUNDRY_RESOURCE` |
| **Auth methods**      | AWS CLI, env vars, SSO, Bedrock API key | `gcloud` ADC, service account | API key, Microsoft Entra ID |
| **Base URL override** | `ANTHROPIC_BEDROCK_BASE_URL` | `ANTHROPIC_VERTEX_BASE_URL` | `ANTHROPIC_FOUNDRY_BASE_URL` |
| **Skip auth (proxy)** | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| **Setup wizard**      | `/setup-bedrock`             | `/setup-vertex`             | n/a                         |
| **IAM role/policy**   | `bedrock:InvokeModel*`, `bedrock:ListInferenceProfiles` | `roles/aiplatform.user` | `Azure AI User` or `Cognitive Services User` |
| **1M context**        | Supported (append `[1m]`)    | Supported (append `[1m]`)   | n/a                         |

### Model pinning environment variables

Pin specific model versions to prevent breakage when Anthropic releases updates. These apply across all providers:

| Variable                          | Purpose                                  |
| :-------------------------------- | :--------------------------------------- |
| `ANTHROPIC_MODEL`                 | Override the primary model               |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`    | Pin Opus version (defaults to Opus 4.6)  |
| `ANTHROPIC_DEFAULT_SONNET_MODEL`  | Pin Sonnet version                       |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`   | Pin Haiku version                        |

Without pinning, aliases (`sonnet`, `opus`, `haiku`) resolve to the latest version. Set `ANTHROPIC_DEFAULT_OPUS_MODEL` to the Opus 4.7 ID to use the latest Opus model.

### Default models (no pinning)

| Provider         | Primary model                                  | Small/fast model                              |
| :--------------- | :--------------------------------------------- | :-------------------------------------------- |
| Bedrock          | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI        | `claude-sonnet-4-5@20250929`                   | `claude-haiku-4-5@20251001`                   |

### Bedrock credential options

| Method              | Configuration                                                                |
| :------------------ | :--------------------------------------------------------------------------- |
| AWS CLI             | `aws configure`                                                              |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`            |
| SSO profile         | `aws sso login --profile=<name>` then `AWS_PROFILE=<name>`                   |
| AWS login           | `aws login`                                                                  |
| Bedrock API key     | `AWS_BEARER_TOKEN_BEDROCK=<key>`                                             |

Advanced: `awsAuthRefresh` runs a command when credentials expire (e.g., `aws sso login --profile myprofile`). `awsCredentialExport` captures credentials from stdout as JSON.

### Bedrock Mantle endpoint

Mantle serves Claude models through the native Anthropic API shape over Bedrock infrastructure. Requires v2.1.94+.

| Variable                            | Purpose                                               |
| :---------------------------------- | :---------------------------------------------------- |
| `CLAUDE_CODE_USE_MANTLE`            | Enable Mantle endpoint (set to `1`)                   |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override default Mantle endpoint URL                  |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH`      | Skip client-side auth for gateway/proxy setups        |

Mantle model IDs use the `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route requests to both endpoints based on model ID format.

### Vertex AI region overrides

When using `CLOUD_ML_REGION=global`, override specific models that lack global support:

| Variable                          | Model targeted       |
| :-------------------------------- | :------------------- |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5`  | Claude Haiku 4.5     |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Claude Sonnet 4.6    |

### Bedrock Guardrails

Add guardrail headers in settings via `ANTHROPIC_CUSTOM_HEADERS`:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### Model overrides per version

Use `modelOverrides` in settings to map specific model versions to inference profile ARNs (Bedrock) so multiple versions appear in the `/model` picker:

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Startup model checks

Available in v2.1.94+ (Bedrock) and v2.1.98+ (Vertex). At startup, Claude Code verifies model access. If a pinned version is outdated, it prompts to update. If the current default is unavailable and no pin is set, it falls back to the previous version for the session.

### LLM gateway configuration

Gateways sit between Claude Code and the provider for centralized auth, usage tracking, rate limiting, and audit logging.

**Supported API formats**: Anthropic Messages (`/v1/messages`), Bedrock InvokeModel (`/invoke`), Vertex rawPredict (`:rawPredict`). The gateway must forward `anthropic-beta` and `anthropic-version` headers (or body fields for Bedrock).

**Authentication to gateways**:

| Method                  | Configuration                                              |
| :---------------------- | :--------------------------------------------------------- |
| Static API key          | `ANTHROPIC_AUTH_TOKEN=<key>`                               |
| Dynamic key helper      | `apiKeyHelper` in settings + `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |

**LiteLLM unified endpoint** (recommended): set `ANTHROPIC_BASE_URL=https://litellm-server:4000`. Pass-through endpoints also available per provider.

**Request headers**: every request includes `X-Claude-Code-Session-Id` for session-level aggregation.

### Enterprise deployment best practices

- **Claude for Teams/Enterprise** is recommended for most organizations (single subscription for Claude Code + web)
- Pin model versions for cloud providers to control rollout timing
- Invest in CLAUDE.md documentation at org, repo, and project levels
- Configure managed permissions via security policies
- Use MCP for integrations (ticket systems, error logs) with shared `.mcp.json`
- Use `/status` to verify proxy and gateway configuration

### Proxy configuration

Route traffic through corporate proxies with `HTTPS_PROXY` or `HTTP_PROXY` environment variables. Compatible with all providers.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — full setup guide for Bedrock including login wizard, manual configuration, AWS credential methods, SSO refresh, model pinning, IAM policy, 1M context window, Guardrails, Mantle endpoint, and troubleshooting.
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — full setup guide for Vertex AI including login wizard, region configuration (global and regional endpoints), GCP authentication, model pinning, IAM roles, 1M context window, and troubleshooting.
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — full setup guide for Microsoft Foundry including resource provisioning, API key and Entra ID authentication, model pinning, Azure RBAC, and troubleshooting.
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — comparison of all deployment options (Teams/Enterprise, Console, Bedrock, Vertex, Foundry), proxy and gateway configuration per provider, and organizational best practices.
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway API format requirements, authentication methods, LiteLLM setup (unified and pass-through endpoints), and request header details.

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
