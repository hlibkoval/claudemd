---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment comparison. Covers authentication, model pinning, IAM/RBAC, region configuration, proxy/gateway setup, and troubleshooting.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for configuring Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment options comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | Individual developers | AWS-native deployments | GCP-native deployments | Azure-native deployments |
| Billing | $150/seat (Teams) or contact sales (Enterprise) | PAYG | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team management, SSO, usage monitoring | None | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |

### Enable key environment variables per provider

| Provider | Enable variable | Required config |
| :--- | :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION=us-east-1` |
| Amazon Bedrock (Mantle) | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION=us-east-1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=<id>` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE=<resource>` |

### Model pinning environment variables (all providers)

Always pin model versions for team/enterprise deployments. Without pinning, aliases resolve to the latest version which may not be available in your account.

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override the `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override the `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override the `haiku` alias |
| `ANTHROPIC_MODEL` | Override the primary model directly |

### Amazon Bedrock

**Wizard login**: run `claude`, select "3rd-party platform" → "Amazon Bedrock". Run `/setup-bedrock` to reopen.

**AWS credential methods**: AWS CLI (`aws configure`), access key env vars, SSO profile (`AWS_PROFILE`), Bedrock API key (`AWS_BEARER_TOKEN_BEDROCK`).

**Advanced credential refresh settings**:

| Setting | Use | Notes |
| :--- | :--- | :--- |
| `awsAuthRefresh` | Commands that update `.aws/` dir (SSO flows) | Output shown to user; no interactive input |
| `awsCredentialExport` | Commands that must return credentials directly | Output captured silently; must emit `{"Credentials": {"AccessKeyId": ..., "SecretAccessKey": ..., "SessionToken": ...}}` |

**Required IAM actions**: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`, `aws-marketplace:ViewSubscriptions`, `aws-marketplace:Subscribe`.

**Default Bedrock model IDs** (when no pinning set):

| Model type | Default value |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**Bedrock-specific env vars**:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint (custom gateways) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Set to `default`, `flex`, or `priority` |
| `ANTHROPIC_CUSTOM_HEADERS` | Add guardrail headers (newline-separated) |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip SigV4 auth for gateway setups |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

**Mantle endpoint env vars**:

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override default Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy setups |

**1M token context**: Append `[1m]` to the model ID when pinning manually. Supported on Opus 4.7, Opus 4.6, Sonnet 4.6.

**Per-version ARN overrides** (`modelOverrides` in settings file):
```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Google Vertex AI

**Wizard login**: run `claude`, select "3rd-party platform" → "Google Vertex AI". Run `/setup-vertex` to reopen. Requires Claude Code v2.1.98+.

**Region config**: set `CLOUD_ML_REGION` to `global`, a multi-region (`eu`, `us`), or a specific region (`us-east5`). Use `VERTEX_REGION_CLAUDE_*` variables to override per-model when `CLOUD_ML_REGION=global`.

**IAM**: assign `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

**Default Vertex model IDs**:

| Model type | Default value |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**Vertex-specific env vars**:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `CLOUD_ML_REGION` | Region or `global` |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override (example) |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override (example) |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth for gateway setups |
| `ENABLE_TOOL_SEARCH` | Set to `true` to opt in to MCP tool search (off by default on Vertex) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

**1M token context**: Append `[1m]` to the model ID when pinning manually. Supported on Opus 4.7, Opus 4.6, Sonnet 4.6.

### Microsoft Foundry

**Setup steps**:
1. Create resource in [Microsoft Foundry portal](https://ai.azure.com/), create model deployments.
2. Authenticate: set `ANTHROPIC_FOUNDRY_API_KEY` (API key auth) or use `az login` (Entra ID via default credential chain when key is absent).
3. Set `CLAUDE_CODE_USE_FOUNDRY=1` and `ANTHROPIC_FOUNDRY_RESOURCE=<resource-name>`.
4. Pin model versions using `ANTHROPIC_DEFAULT_*_MODEL` vars.

**RBAC**: `Azure AI User` or `Cognitive Services User` roles work. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` data action.

**Foundry-specific env vars**:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Override with full base URL |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key (omit for Entra ID auth) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth for gateway setups |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

### LLM Gateway configuration

**Requirements**: gateway must expose one of these API formats:
- Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens` (must forward `anthropic-beta`, `anthropic-version` headers)
- Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream` (must preserve `anthropic_beta`, `anthropic_version` body fields)
- Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` (must forward `anthropic-beta`, `anthropic-version` headers)

**Gateway override env vars**:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_BASE_URL` | Anthropic Messages format gateway |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock pass-through gateway |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex pass-through gateway |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry pass-through gateway |
| `ANTHROPIC_AUTH_TOKEN` | Bearer token for gateway auth |
| `ANTHROPIC_API_KEY` | `x-api-key` header when no auth token set |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Token refresh interval (ms) |
| `CLAUDE_CODE_ATTRIBUTION_HEADER` | Set to `0` to omit attribution block from system prompt |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | Set to `1` when using Anthropic Messages format with Bedrock/Vertex |

**Gateway model discovery**: when `ANTHROPIC_BASE_URL` points at an Anthropic Messages gateway, Claude Code v2.1.126+ queries `/v1/models` at startup and adds returned models to `/model` picker (labeled "From gateway"). Results cached to `~/.claude/cache/gateway-models.json`.

**LiteLLM auth** (`apiKeyHelper` for dynamic/rotating keys):
```json
{ "apiKeyHelper": "~/bin/get-litellm-key.sh" }
```

### Corporate proxy configuration

Set `HTTPS_PROXY` (or `HTTP_PROXY`) to route all provider traffic through your corporate proxy:
```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```

Use `/status` in Claude Code to verify provider and proxy configuration.

### Startup model checks

All three providers (Bedrock, Vertex, Foundry) perform model availability checks at startup. If the pinned model is older than the current default and the newer one is available, Claude Code prompts you to update the pin. If no pin is set and the default is unavailable, Claude Code falls back to the previous version for that session (not persisted).

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, login wizard, manual setup, credential methods, credential auto-refresh, model pinning, IAM policy, 1M context, service tiers, Guardrails, Mantle endpoint, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, login wizard, region configuration, manual setup, credential config, model pinning, IAM, 1M context, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, resource provisioning, Azure credential methods, environment variable setup, model pinning, RBAC configuration, troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements, request headers, model selection, model discovery, LiteLLM setup, authentication methods, provider-specific pass-through endpoints
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment options comparison table, proxy vs gateway configuration, per-provider proxy and gateway examples, best practices for organizations

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
