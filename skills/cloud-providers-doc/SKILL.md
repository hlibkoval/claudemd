---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock (setup, IAM, Mantle endpoint, model pinning, guardrails), Claude Platform on AWS (SigV4, workspace API keys), Google Vertex AI (setup, regions, IAM), Microsoft Foundry (setup, Entra ID), LLM gateway configuration (LiteLLM, pass-through endpoints, gateway model discovery), and enterprise deployment overview comparing all provider options.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | Individual developers | AWS-native | AWS Marketplace billing + Claude API features | GCP-native | Azure-native |
| Billing | Seat-based | PAYG | PAYG via AWS | PAYG via AWS Marketplace | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO | API key | API key or AWS credentials | API key or AWS credentials | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No | No |
| Enterprise features | SSO, RBAC, usage monitoring | None | IAM, CloudTrail | IAM, CloudTrail | IAM roles, Cloud Audit Logs | RBAC, Azure Monitor |

### Enable a Provider (Minimum Required Env Vars)

| Provider | Required env vars |
| :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| Amazon Bedrock (Mantle) | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_...`, `AWS_REGION=us-east-1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |

### Model Pinning (All Providers)

Pin model versions when deploying to multiple users. Without pinning, aliases resolve to the latest, which may not yet be enabled in your account.

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus model ID |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet model ID |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku model ID |
| `ANTHROPIC_MODEL` | Override primary model for session |

**Example Bedrock pin:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

**Example Vertex AI pin:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

**Example Foundry / Claude Platform on AWS pin:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

### Amazon Bedrock

#### Authentication Methods

| Method | How |
| :--- | :--- |
| AWS CLI | `aws configure` |
| Access key + secret | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile <name>` then `AWS_PROFILE=<name>` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

#### Advanced Credential Settings

| Setting | When to use |
| :--- | :--- |
| `awsAuthRefresh` | Command run when AWS credentials expire (e.g., `aws sso login --profile myprofile`). Modifies `.aws` directory. Output shown to user. |
| `awsCredentialExport` | Command run to return credentials directly as JSON (`{Credentials: {AccessKeyId, SecretAccessKey, SessionToken}}`). Use when you cannot modify `.aws`. |

#### Bedrock-Specific Env Vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock (set to `1`) |
| `AWS_REGION` | Required; Bedrock region (not read from `.aws` config) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint URL |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model only |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Service tier: `default`, `flex`, or `priority` |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip SigV4 signing (for gateways that handle auth) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL (billed at higher rate) |

#### Bedrock Default Models (when not pinned)

| Model type | Default ID |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | Same as primary (Haiku defaults to primary on Bedrock) |

#### Bedrock IAM Policy

Required actions: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`, `aws-marketplace:ViewSubscriptions`, `aws-marketplace:Subscribe`.

#### Bedrock Mantle Endpoint

Mantle is a Bedrock endpoint using the native Anthropic API shape (not the Bedrock Invoke API). Requires Claude Code v2.1.94+.

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth (for gateway proxies) |

Mantle model IDs use `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_MANTLE` to route each model ID to the correct endpoint.

#### AWS Guardrails

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

#### 1M Token Context Window (Bedrock)

Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6. Append `[1m]` to the model ID when pinning manually. The setup wizard (`/setup-bedrock`) offers this option during model pin.

#### modelOverrides (Bedrock)

Map specific model versions to application inference profile ARNs for the `/model` picker:

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

#### Bedrock Startup Model Checks (v2.1.94+)

At startup, Claude Code verifies models are accessible. If pinned model is older than default and newer is available, it prompts to update the pin. If not pinned and default is unavailable, it falls back to previous version for that session only.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication + AWS Marketplace billing. Same models/features as direct Claude API.

#### Authentication Methods

| Method | How |
| :--- | :--- |
| AWS credentials (SigV4) | Standard AWS credential chain (`AWS_PROFILE`, `~/.aws/credentials`, IAM role, etc.) |
| Workspace API key | `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` (takes precedence over SigV4) |

#### Required Env Vars

```bash
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export AWS_REGION=us-east-1
```

`ANTHROPIC_AWS_WORKSPACE_ID` is sent as `anthropic-workspace-id` on every request. Base URL is computed as `https://aws-external-anthropic.{region}.api.aws`. Override with `ANTHROPIC_AWS_BASE_URL`.

Note: If `CLAUDE_CODE_USE_BEDROCK` or `CLAUDE_CODE_USE_FOUNDRY` is also set, those take precedence over Claude Platform on AWS.

#### Gateway/Proxy

```bash
export CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1  # Gateway handles SigV4
export ANTHROPIC_AWS_BASE_URL=https://anthropic-proxy.example.com
```

#### Troubleshooting

| Error | Cause / Fix |
| :--- | :--- |
| `403 Forbidden` / `AccessDenied` | IAM principal lacks permission; check `aws-external-anthropic` actions |
| Missing-workspace error | `ANTHROPIC_AWS_WORKSPACE_ID` unset — required on every request |
| Requests go to `api.anthropic.com` | `CLAUDE_CODE_USE_ANTHROPIC_AWS` not set to `1`; check for `CLAUDE_CODE_USE_BEDROCK`/`CLAUDE_CODE_USE_FOUNDRY` taking precedence |

### Google Vertex AI

#### Setup Steps

1. Enable API: `gcloud services enable aiplatform.googleapis.com`
2. Request model access in Vertex AI Model Garden (may take 24–48 hours)
3. Configure credentials (Application Default Credentials, service account key, or Workload Identity Federation via X.509)
4. Set env vars and optionally pin models

#### Vertex-Specific Env Vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex AI (set to `1`) |
| `CLOUD_ML_REGION` | Region: `global`, `eu`, `us`, or specific region (e.g., `us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID (overridden by `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or `GOOGLE_APPLICATION_CREDENTIALS`) |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint URL |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth (for gateways) |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override when using `CLOUD_ML_REGION=global` |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override |
| `ENABLE_TOOL_SEARCH` | Set to `true` to enable MCP tool search (disabled by default on Vertex; supported for Sonnet 4.5+ and Opus 4.5+) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

#### Vertex Default Models (when not pinned)

| Model type | Default ID |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | Same as primary (Haiku defaults to primary on Vertex) |

#### Advanced Credential Refresh

```json
{
  "gcpAuthRefresh": "gcloud auth application-default login",
  "env": {
    "ANTHROPIC_VERTEX_PROJECT_ID": "your-project-id"
  }
}
```

Runs when GCP credentials are expired or cannot be loaded. Times out after 3 minutes.

#### IAM

`roles/aiplatform.user` provides the required `aiplatform.endpoints.predict` permission. Create a custom role for tighter control.

#### 1M Token Context Window (Vertex)

Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6. Append `[1m]` to model ID when pinning manually. The setup wizard (`/setup-vertex`, requires v2.1.98+) offers this option during model pin.

#### Vertex Troubleshooting

| Error | Fix |
| :--- | :--- |
| "Could not load the default credentials" | `gcloud auth application-default login` or set `GOOGLE_APPLICATION_CREDENTIALS` |
| Quota issues | Request increase via Cloud Console |
| 404 "model not found" | Confirm model is enabled in Model Garden; verify region supports the model |
| 429 errors | Check model is supported in chosen region; consider `CLOUD_ML_REGION=global` |

### Microsoft Foundry

#### Setup Steps

1. Create resource and deployments in [Microsoft Foundry portal](https://ai.azure.com/) (Opus, Sonnet, Haiku)
2. Configure auth (API key or Entra ID)
3. Set env vars and pin models

#### Authentication Methods

| Method | How |
| :--- | :--- |
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` |
| Microsoft Entra ID (default) | Azure SDK default credential chain; run `az login` for local use |

#### Foundry Env Vars

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Foundry (set to `1`) |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL override (`https://{resource}.services.ai.azure.com/anthropic`) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key (takes precedence over Entra ID auth) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth (for gateways) |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

Note: Foundry has no interactive setup wizard. Environment variables are the only configuration path.

#### RBAC

`Azure AI User` or `Cognitive Services User` roles include required permissions. Custom role minimum: `Microsoft.CognitiveServices/accounts/providers/*` data action.

### LLM Gateway Configuration

#### Gateway Requirements

Gateways must expose one of these API formats:

| Format | Required endpoints | Must preserve |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Forward headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Preserve body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Forward headers: `anthropic-beta`, `anthropic-version` |

Set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` when using Anthropic Messages format with Bedrock or Vertex backends.

#### Request Headers Added by Claude Code

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier (aggregate all requests per session) |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier (attribute cost to parallel agents) |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent identifier (attribute costs across nested agents) |

Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the attribution block prepended to system prompts (useful when gateway caches by full request body).

#### Gateway Model Discovery (v2.1.129+)

Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and add results to the `/model` picker. Only applies to Anthropic Messages format gateways (`ANTHROPIC_BASE_URL`). Models must have IDs beginning with `claude` or `anthropic`. Cached to `~/.claude/cache/gateway-models.json`.

#### LiteLLM Auth Methods

| Method | Config |
| :--- | :--- |
| Static API key | `ANTHROPIC_AUTH_TOKEN=sk-litellm-static-key` or in settings `env` block |
| Dynamic (rotating) key | `apiKeyHelper` setting pointing to a script; `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval |

#### LiteLLM Pass-through Endpoints

| Provider | Env vars |
| :--- | :--- |
| Anthropic (unified, recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic (pass-through) | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock via LiteLLM | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex AI via LiteLLM | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`, `ANTHROPIC_VERTEX_PROJECT_ID=...`, `CLOUD_ML_REGION=...` |
| Claude Platform on AWS via gateway | `ANTHROPIC_AWS_BASE_URL=...`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=...` |

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Remove and rotate credentials if installed.

### Corporate Proxy vs LLM Gateway

| Config | When to use | Env var |
| :--- | :--- | :--- |
| Corporate proxy | Route traffic through HTTP/HTTPS proxy for security/compliance | `HTTPS_PROXY` or `HTTP_PROXY` |
| LLM Gateway | Centralized auth, usage tracking, rate limiting, cost controls | `ANTHROPIC_BASE_URL`, `ANTHROPIC_BEDROCK_BASE_URL`, `ANTHROPIC_AWS_BASE_URL`, or `ANTHROPIC_VERTEX_BASE_URL` |

Use `/status` inside Claude Code to verify proxy/gateway configuration.

### Prompt Caching Across Providers

| Variable | Effect |
| :--- | :--- |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour TTL instead of 5-minute default (higher billing rate) |

Prompt caching is enabled by default on all providers. Not available in all Bedrock regions.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock setup wizard, manual configuration, IAM policy, Mantle endpoint, model pinning, guardrails, startup model checks, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 vs workspace API key auth, env vars, Agent SDK usage, proxy routing, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex setup wizard, manual configuration, region configuration, IAM, startup model checks, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Foundry resource provisioning, API key vs Entra ID auth, RBAC, model pinning
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements, LiteLLM setup, authentication methods, pass-through endpoints, gateway model discovery
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment option comparison table, proxy/gateway configuration per provider, enterprise best practices

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
