---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, enterprise deployment overview, and LLM gateway configuration.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers and LLM gateways.

## Quick Reference

### Provider comparison

| Feature              | Amazon Bedrock                  | Google Vertex AI                | Microsoft Foundry               |
| :------------------- | :------------------------------ | :------------------------------ | :------------------------------ |
| **Enable var**       | `CLAUDE_CODE_USE_BEDROCK=1`     | `CLAUDE_CODE_USE_VERTEX=1`      | `CLAUDE_CODE_USE_FOUNDRY=1`     |
| **Region var**       | `AWS_REGION`                    | `CLOUD_ML_REGION`               | N/A (set via resource name)     |
| **Project/resource** | N/A                             | `ANTHROPIC_VERTEX_PROJECT_ID`   | `ANTHROPIC_FOUNDRY_RESOURCE`    |
| **Base URL override**| `ANTHROPIC_BEDROCK_BASE_URL`    | `ANTHROPIC_VERTEX_BASE_URL`     | `ANTHROPIC_FOUNDRY_BASE_URL`    |
| **Skip auth var**    | `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | `CLAUDE_CODE_SKIP_VERTEX_AUTH`  | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` |
| **Auth methods**     | AWS CLI, env vars, SSO, Bedrock API key | `gcloud` ADC, service account key | API key, Microsoft Entra ID     |
| **Setup wizard**     | `/setup-bedrock`                | `/setup-vertex`                 | N/A                             |
| **Login wizard**     | Select 3rd-party > Bedrock      | Select 3rd-party > Vertex AI    | N/A                             |
| **IAM role/policy**  | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` | `roles/aiplatform.user` (`aiplatform.endpoints.predict`) | `Azure AI User` or `Cognitive Services User` |
| **1M context**       | Supported (Opus 4.7/4.6, Sonnet 4.6) | Supported (Opus 4.7/4.6, Sonnet 4.6) | Not documented                  |
| **Prompt caching**   | Enabled by default (not all regions) | Enabled by default              | Enabled by default              |
| **Billing**          | PAYG through AWS                | PAYG through GCP                | PAYG through Azure              |

### Model pinning environment variables

Pin specific model versions when deploying to multiple users. Without pinning, aliases resolve to the latest version which may not be available in your account.

| Variable                          | Purpose                                  |
| :-------------------------------- | :--------------------------------------- |
| `ANTHROPIC_MODEL`                 | Override the primary model entirely      |
| `ANTHROPIC_DEFAULT_OPUS_MODEL`    | Pin the `opus` alias to a specific version (defaults to Opus 4.6 on all providers) |
| `ANTHROPIC_DEFAULT_SONNET_MODEL`  | Pin the `sonnet` alias                   |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL`   | Pin the `haiku` alias (small/fast model) |

Example Bedrock model IDs: `us.anthropic.claude-opus-4-7`, `us.anthropic.claude-sonnet-4-6`, `us.anthropic.claude-haiku-4-5-20251001-v1:0`

Example Vertex model IDs: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5@20251001`

Example Foundry model IDs: `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`

### Default models when no pins are set

| Provider  | Primary model                              | Small/fast model                           |
| :-------- | :----------------------------------------- | :----------------------------------------- |
| Bedrock   | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-5@20250929`               | `claude-haiku-4-5@20251001`                |

### Bedrock credential options

| Method                | Setup                                                          |
| :-------------------- | :------------------------------------------------------------- |
| AWS CLI               | `aws configure`                                                |
| Access key env vars   | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile           | `aws sso login --profile=<name>` + `AWS_PROFILE`               |
| AWS Management Console| `aws login`                                                    |
| Bedrock API key       | `AWS_BEARER_TOKEN_BEDROCK`                                     |

Advanced: use `awsAuthRefresh` (runs command that modifies `.aws/`) or `awsCredentialExport` (returns JSON credentials) in settings for automatic credential refresh on expiry.

### Bedrock Mantle endpoint

Mantle serves Claude models through the native Anthropic API shape using AWS credentials. Requires Claude Code v2.1.94+.

| Variable                            | Purpose                                                  |
| :---------------------------------- | :------------------------------------------------------- |
| `CLAUDE_CODE_USE_MANTLE`            | Enable Mantle endpoint (`1` or `true`)                   |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override the default Mantle endpoint URL                  |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH`      | Skip client-side auth for gateway/proxy setups           |

Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route Mantle-format model IDs (prefixed `anthropic.`) to Mantle and everything else to the Bedrock Invoke API.

### Vertex AI region configuration

Vertex AI supports both `global` and regional endpoints. Set `CLOUD_ML_REGION=global` for global, or a specific region like `us-east5`. Per-model region overrides use `VERTEX_REGION_CLAUDE_*` variables (e.g., `VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5`).

### AWS Guardrails (Bedrock)

Configure via `ANTHROPIC_CUSTOM_HEADERS` in settings:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### Startup model checks

All providers (Bedrock v2.1.94+, Vertex v2.1.98+): Claude Code verifies models at startup. If a pinned version is outdated, it prompts to update. If an unpinned default is unavailable, it falls back to the previous version for the session (not persisted).

### LLM gateway configuration

Gateways proxy traffic between Claude Code and providers for centralized auth, usage tracking, cost controls, and audit logging.

**Required API format** (at least one): Anthropic Messages (`/v1/messages`), Bedrock InvokeModel (`/invoke`), or Vertex rawPredict (`:rawPredict`). Must forward `anthropic-beta` and `anthropic-version` headers/fields.

| Gateway use case       | Bedrock env vars                                                                  | Vertex env vars                                                                    | Foundry env vars                                                                   |
| :--------------------- | :-------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------- |
| Corporate proxy        | `HTTPS_PROXY=https://proxy:8080`                                                 | `HTTPS_PROXY=https://proxy:8080`                                                  | `HTTPS_PROXY=https://proxy:8080`                                                  |
| LLM gateway            | `ANTHROPIC_BEDROCK_BASE_URL` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`                  | `ANTHROPIC_VERTEX_BASE_URL` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`                     | `ANTHROPIC_FOUNDRY_BASE_URL` + `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1`                   |
| LiteLLM unified        | `ANTHROPIC_BASE_URL=https://litellm:4000`                                        | `ANTHROPIC_BASE_URL=https://litellm:4000`                                         | `ANTHROPIC_BASE_URL=https://litellm:4000`                                         |

**LiteLLM auth**: use `ANTHROPIC_AUTH_TOKEN` for static keys, or `apiKeyHelper` in settings for rotating/per-user keys (with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval).

### Enterprise best practices

- Pin model versions for all cloud provider deployments
- Invest in CLAUDE.md documentation at org, repo, and project levels
- Configure managed permissions via security settings
- Use MCP for integrations (ticket systems, error logs) with shared `.mcp.json`
- Use `/status` to verify proxy/gateway configuration

### 1M token context window

Append `[1m]` to a manually pinned model ID to enable. The setup wizards offer a 1M context option when pinning models.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — full setup guide for Bedrock including the login wizard, manual configuration, credential options (CLI, env vars, SSO, Bedrock API keys), advanced credential refresh, model pinning, IAM policy, Mantle endpoint, AWS Guardrails, 1M context, startup model checks, and troubleshooting.
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — full setup guide for Vertex AI including the login wizard, manual configuration, global and regional endpoints, per-model region overrides, model pinning, IAM permissions, 1M context, startup model checks, and troubleshooting.
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — full setup guide for Microsoft Foundry including resource provisioning, API key and Entra ID authentication, model pinning, Azure RBAC configuration, and troubleshooting.
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — comparison table of all deployment options (Teams/Enterprise, Console, Bedrock, Vertex, Foundry), proxy and gateway configuration per provider, and enterprise best practices for documentation, security, MCP, and model pinning.
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements (API format, headers), authentication methods (static keys, dynamic key helpers), LiteLLM setup (unified and pass-through endpoints), and provider-specific pass-through configuration.

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
