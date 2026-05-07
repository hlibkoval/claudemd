---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment overview including comparison table, authentication options, model pinning, IAM/RBAC configuration, and proxy/gateway setup.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through cloud providers and enterprise infrastructure.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | Individual developers | AWS-native | GCP-native | Azure-native |
| Billing | $150/seat (Teams) or Contact Sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team mgmt, SSO, usage monitoring | None | IAM, CloudTrail | IAM roles, Cloud Audit Logs | RBAC, Azure Monitor |

### Enable Variable per Provider

| Provider | Enable Variable |
| :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` |
| Amazon Bedrock Mantle endpoint | `CLAUDE_CODE_USE_MANTLE=1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` |

### Model Pinning Variables (All Providers)

| Variable | Controls |
| :--- | :--- |
| `ANTHROPIC_MODEL` | Primary (large) model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opus alias resolution |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sonnet alias resolution |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Haiku alias (small/fast model) |

Pin models before rolling out to multiple users. Without pinning, aliases resolve to the latest version, which may not yet be available in your account.

### Amazon Bedrock Setup

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock (set to `1`) |
| `AWS_REGION` | Required; Claude Code does not read `.aws` config for this |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint URL |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable |
| `ENABLE_PROMPT_CACHING_1H` | Set to `1` for 1-hour TTL (billed higher) |

**Authentication options (choose one):**
- `aws configure` (AWS CLI)
- `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN`
- `AWS_PROFILE` (SSO profile)
- `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API key — simpler, no full AWS credentials needed)

**Credential auto-refresh settings (in settings file):**
- `awsAuthRefresh`: command that modifies `.aws` directory (output shown to user); good for browser-based SSO
- `awsCredentialExport`: command that outputs `{"Credentials": {"AccessKeyId": ..., "SecretAccessKey": ..., "SessionToken": ...}}` silently

**Default Bedrock model IDs (when not pinned):**

| Model type | Default |
| :--- | :--- |
| Primary model | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast model | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**IAM permissions required:**
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`
- `bedrock:GetInferenceProfile`

**Bedrock Mantle endpoint variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip SigV4/x-api-key for gateway setups |

Mantle model IDs use `anthropic.` prefix without version suffix (e.g. `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run both endpoints side-by-side.

**1M context window:** Append `[1m]` to a manually pinned model ID. Supported on Opus 4.7, Opus 4.6, Sonnet 4.6.

**AWS Guardrails:** Set via `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**Setup wizard:** Run `claude`, choose `3rd-party platform` → `Amazon Bedrock`. Re-run with `/setup-bedrock`. Requires Claude Code v2.1.94+.

### Google Vertex AI Setup

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex AI (set to `1`) |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`, `us`), or specific region (`us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint URL |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override (when using `global`) |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override |
| `ENABLE_TOOL_SEARCH` | Set to `true` to opt in to MCP tool search (disabled by default on Vertex) |

**Default Vertex model IDs (when not pinned):**

| Model type | Default |
| :--- | :--- |
| Primary model | `claude-sonnet-4-5@20250929` |
| Small/fast model | `claude-haiku-4-5@20251001` |

**IAM role required:** `roles/aiplatform.user` (or custom role with `aiplatform.endpoints.predict`)

**Endpoint types:** global (`global`), multi-region (`eu`, `us`), or specific region. Not all models are available on all endpoint types — check Vertex AI Model Garden.

**Notes:**
- `/login` and `/logout` are disabled when Vertex is active
- MCP tool search is disabled by default; set `ENABLE_TOOL_SEARCH=true` to opt in
- Supports X.509 certificate-based Workload Identity Federation (v2.1.121+)
- 1M context window: append `[1m]` to model ID; supported on Opus 4.7, Opus 4.6, Sonnet 4.6

**Setup wizard:** Run `claude`, choose `3rd-party platform` → `Google Vertex AI`. Re-run with `/setup-vertex`. Requires Claude Code v2.1.98+.

### Microsoft Foundry Setup

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Foundry (set to `1`) |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth (omit to use Entra ID instead) |

**Authentication options:**
- API key: set `ANTHROPIC_FOUNDRY_API_KEY`
- Microsoft Entra ID: omit API key; uses Azure SDK default credential chain (`az login` locally)

**RBAC roles:** `Azure AI User` or `Cognitive Services User` include required permissions. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

**Notes:**
- `/login` and `/logout` are disabled when Foundry is active
- Create deployments with specific model versions (not "auto-update to latest") to avoid breakage

### LLM Gateway Configuration

**Required API formats (gateway must support at least one):**
1. Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens` — must forward `anthropic-beta` and `anthropic-version` headers
2. Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream` — must preserve `anthropic_beta` and `anthropic_version` body fields
3. Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` — must forward `anthropic-beta` and `anthropic-version` headers

**Gateway endpoint variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_BASE_URL` | Anthropic Messages format gateway |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock pass-through gateway |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex pass-through gateway |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry pass-through gateway |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip SigV4 when gateway handles AWS auth |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth when gateway handles it |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth when gateway handles it |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip Mantle auth for gateway setups |

**Auth to gateway:**
- Static key: `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization` bearer) or `ANTHROPIC_API_KEY`
- Dynamic key: `apiKeyHelper` setting + optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`
- `apiKeyHelper` has lower precedence than `ANTHROPIC_AUTH_TOKEN` or `ANTHROPIC_API_KEY`

**Gateway model discovery (Anthropic format only):** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and add results to the `/model` picker. Off by default. Results cached at `~/.claude/cache/gateway-models.json`. Requires v2.1.129+.

**Disable experimental betas with Anthropic format over Bedrock/Vertex:** Set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

**Attribution header:** Claude Code prepends a block to system prompts; set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit it if your gateway's prompt cache keys on the full request body.

**LiteLLM warning:** PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Rotate credentials if installed.

### Corporate Proxy Setup

Set `HTTPS_PROXY` or `HTTP_PROXY` for all providers. Combine with provider-specific variables:

```bash
# Example: Bedrock + proxy
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export HTTPS_PROXY='https://proxy.example.com:8080'
```

### Proxy and Gateway Comparison

| Concern | Corporate Proxy | LLM Gateway |
| :--- | :--- | :--- |
| Config variable | `HTTPS_PROXY` / `HTTP_PROXY` | `ANTHROPIC_*_BASE_URL` |
| Use case | Security monitoring, compliance | Centralized auth, cost tracking, rate limiting |
| Can be combined | Yes | Yes |

### Startup Model Checks

When Claude Code starts with Bedrock or Vertex configured, it checks model availability. If the pinned model is older than the current default and the newer version is accessible, Claude Code prompts you to update the pin. If no pin is set and the default is unavailable, it falls back to the previous version for the session only. The check requires v2.1.94+ (Bedrock) or v2.1.98+ (Vertex).

### modelOverrides Setting (Bedrock)

Map model version names to application inference profile ARNs in your settings file:

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Best Practices for Organizations

- Deploy `CLAUDE.md` files organization-wide (system directories) and per-repo (checked into source control)
- Pin model versions before rolling out to multiple users
- Configure managed security policies for what Claude Code can and cannot do
- Use MCP servers for integrations (ticket systems, error logs) — check `.mcp.json` into repos
- Create a "one click" install mechanism to grow adoption
- Use `/status` to verify provider and proxy configuration

## Full Documentation

For the complete official documentation, see the reference files:

- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment option comparison table, proxy vs. gateway guidance, best practices for organizations
- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — setup wizard, manual setup, credential options, auto-refresh, model pinning, IAM policy, Mantle endpoint, Guardrails, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — setup wizard, region configuration, manual setup, GCP auth, model pinning, IAM, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — provisioning, API key vs. Entra ID auth, model pinning, RBAC, troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway API requirements, request headers, model discovery, LiteLLM setup, auth methods, provider pass-through endpoints

## Sources

- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
