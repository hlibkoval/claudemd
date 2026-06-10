---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment options comparison

| Option | Best for | Auth | Billing |
| :--- | :--- | :--- | :--- |
| Claude for Teams/Enterprise | Most organizations (recommended) | Claude.ai SSO or email | Per-seat or contact sales |
| Anthropic Console | Individual developers | API key | PAYG |
| Amazon Bedrock | AWS-native deployments | API key or AWS credentials | PAYG through AWS |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | SigV4 or workspace API key | PAYG through AWS Marketplace |
| Google Vertex AI | GCP-native deployments | GCP credentials | PAYG through GCP |
| Microsoft Foundry | Azure-native deployments | API key or Entra ID | PAYG through Azure |

### Enable a cloud provider

| Provider | Required env vars |
| :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| Amazon Bedrock (Mantle endpoint) | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_…`, `AWS_REGION=us-east-1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |

### Pin model versions (cloud providers)

Always pin for team deployments — unset aliases may resolve to a lagging default or an unavailable model.

```bash
# Amazon Bedrock (cross-region inference profile IDs)
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'

# Google Vertex AI
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'

# Microsoft Foundry (use deployment names from your Azure resource)
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'

# Claude Platform on AWS (same IDs as direct Claude API)
export ANTHROPIC_DEFAULT_FABLE_MODEL=claude-fable-5
export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-7
export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6
export ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5
```

Append `[1m]` to a model ID to opt into the 1M token context window (Bedrock and Vertex; Opus 4.6+ and Sonnet 4.6).

### Bedrock-specific env vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock Invoke API |
| `AWS_REGION` | Required; not read from `.aws` config |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint URL |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side SigV4 for Mantle |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL (higher cost) |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key (no full AWS credentials needed) |
| `awsAuthRefresh` (settings) | Command to refresh expired AWS credentials |
| `awsCredentialExport` (settings) | Command to export cross-account credentials as JSON |

#### Bedrock IAM policy (minimum)

Actions required: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`.

#### AWS Guardrails

Set in `env` block of settings: `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

### Vertex AI-specific env vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex AI |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`, `us`), or specific region |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint URL |
| `VERTEX_REGION_CLAUDE_*` | Per-model region override when using `global` |
| `ENABLE_TOOL_SEARCH` | Enable MCP tool search (Sonnet 4.5+ and Opus 4.5+ only) |
| `gcpAuthRefresh` (settings) | Command to refresh expired GCP credentials |

Vertex AI IAM: `roles/aiplatform.user` (or custom role with `aiplatform.endpoints.predict`).

### Microsoft Foundry-specific env vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL override |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth (omit to use Entra ID) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip client-side auth for gateway setups |

Azure RBAC: `Azure AI User` or `Cognitive Services User` role (or custom with `Microsoft.CognitiveServices/accounts/providers/*` data action).

### Claude Platform on AWS-specific env vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS` | Enable Claude Platform on AWS |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Workspace ID (required on every request) |
| `AWS_REGION` | Determines base URL |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `ANTHROPIC_AWS_BASE_URL` | Override endpoint URL for proxies/gateways |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip SigV4 signing for gateway setups |

### LLM gateway

Gateway must expose one of: Anthropic Messages API, Bedrock InvokeModel, or Vertex rawPredict format, and forward `anthropic-beta` / `anthropic-version` headers (or body fields).

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_BASE_URL` | Anthropic Messages format gateway |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock pass-through gateway |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex pass-through gateway |
| `ANTHROPIC_AWS_BASE_URL` | Claude Platform on AWS pass-through gateway |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip AWS SigV4 for Bedrock gateway |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth for Vertex gateway |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip SigV4 for AWS platform gateway |
| `ANTHROPIC_AUTH_TOKEN` | Bearer token for gateway auth |
| `apiKeyHelper` (settings) | Script that prints a dynamic API key |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Token refresh interval in ms |
| `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY` | Query `/v1/models` on startup to populate `/model` picker |
| `CLAUDE_CODE_ATTRIBUTION_HEADER` | Set to `0` to omit system-prompt attribution block |

Request headers sent by Claude Code to gateways: `X-Claude-Code-Session-Id`, `X-Claude-Code-Agent-Id`, `X-Claude-Code-Parent-Agent-Id`.

### Interactive setup wizards

| Command | Provider |
| :--- | :--- |
| `/setup-bedrock` | Re-run Bedrock setup wizard |
| `/setup-vertex` | Re-run Vertex AI setup wizard |
| `/status` | Show resolved provider, region, workspace, and auth config |

### Corporate proxy

Set `HTTPS_PROXY` (or `HTTP_PROXY`) for all providers. Can be combined with a provider-specific base URL override.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Setup wizard, manual setup, IAM policy, Mantle endpoint, AWS Guardrails, startup model checks, and troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — Anthropic-operated Claude API with AWS auth and AWS Marketplace billing
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Setup wizard, manual setup, IAM, region configuration, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Provisioning, authentication (API key or Entra ID), RBAC, and troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Compare all deployment options, proxy/gateway configuration per provider, and organization best practices
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway requirements, LiteLLM setup, authentication methods, and model discovery

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
