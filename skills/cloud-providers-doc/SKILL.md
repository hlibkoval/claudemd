---
name: cloud-providers-doc
description: Complete official documentation for running Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment comparison.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for configuring Claude Code through third-party cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | $150/seat or contact sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS creds | GCP credentials | API key or Entra ID |
| Includes Claude web | Yes | No | No | No | No |
| Enable variable | *(default)* | *(default)* | `CLAUDE_CODE_USE_BEDROCK=1` | `CLAUDE_CODE_USE_VERTEX=1` | `CLAUDE_CODE_USE_FOUNDRY=1` |

### Amazon Bedrock — Setup

**Login wizard:** `claude` → 3rd-party platform → Amazon Bedrock. Re-run at any time with `/setup-bedrock`.

**Manual environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK=1` | Enable Bedrock integration |
| `AWS_REGION=us-east-1` | Required; not read from `.aws` config |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override endpoint for custom gateways |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour cache TTL (higher cost) |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Service tier: `default`, `flex`, or `priority` |
| `ANTHROPIC_CUSTOM_HEADERS` | Inject custom headers (e.g. Guardrails) |

**AWS credential methods:** `aws configure`, access key env vars, SSO profile, `aws login`, or `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API keys).

**Auto credential refresh (settings file):**
```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```
Use `awsCredentialExport` only when you cannot modify `.aws` — output must be JSON with `Credentials.AccessKeyId/SecretAccessKey/SessionToken`.

**Pin model versions (required for team deployments):**

| Variable | Example value |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

Default models (no pinning): primary = `us.anthropic.claude-sonnet-4-5-20250929-v1:0`, small/fast = `us.anthropic.claude-haiku-4-5-20251001-v1:0`.

Append `[1m]` to a model ID to enable the 1M token context window (Opus 4.7/4.6, Sonnet 4.6).

**Required IAM permissions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`.

**AWS Guardrails config (settings file):**
```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### Amazon Bedrock — Mantle Endpoint

Mantle serves Claude via the native Anthropic API shape (not InvokeModel). Requires Claude Code v2.1.94+.

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side auth (for gateway proxies) |

Mantle model IDs use `anthropic.` prefix without version suffix (e.g. `anthropic.claude-haiku-4-5`).

Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to use both endpoints simultaneously — Mantle-format IDs route to Mantle, others go to Invoke API.

Run `/status` to confirm: shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`.

### Google Vertex AI — Setup

**Login wizard:** `claude` → 3rd-party platform → Google Vertex AI. Re-run with `/setup-vertex`. Requires Claude Code v2.1.98+.

**Manual environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX=1` | Enable Vertex AI integration |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`, `us`), or specific region (`us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint for custom gateways |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour cache TTL (higher cost) |
| `ENABLE_TOOL_SEARCH=true` | Enable MCP tool search (disabled by default on Vertex) |

Project ID precedence: `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` / credential file > `ANTHROPIC_VERTEX_PROJECT_ID` > `gcloud` config / attached service account.

Per-model region overrides when using `CLOUD_ML_REGION=global`:
```bash
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

**Auto credential refresh (settings file):**
```json
{
  "gcpAuthRefresh": "gcloud auth application-default login",
  "env": { "ANTHROPIC_VERTEX_PROJECT_ID": "your-project-id" }
}
```
Refresh command times out after 3 minutes. If set in project settings (`.claude/settings.json`), runs only after workspace trust prompt.

**Pin model versions:**

| Variable | Example value |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `claude-haiku-4-5@20251001` |

Default models: primary = `claude-sonnet-4-5@20250929`, small/fast = `claude-haiku-4-5@20251001`.

**Required IAM role:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

Append `[1m]` to a model ID to enable the 1M token context window (Opus 4.7/4.6, Sonnet 4.6).

### Microsoft Foundry — Setup

**Manual environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Microsoft Foundry integration |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key (omit to use Entra ID / default Azure credential chain) |

Authentication: set `ANTHROPIC_FOUNDRY_API_KEY` for API key auth, or omit it to use the Azure SDK default credential chain (including `az login` for local dev).

**Pin model versions (match to your Azure deployment names):**

| Variable | Example value |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `claude-haiku-4-5` |

**Required RBAC:** `Azure AI User` or `Cognitive Services User` role. Minimum custom permission: `Microsoft.CognitiveServices/accounts/providers/*` (dataAction).

### LLM Gateway Configuration

Gateways must expose one of these API formats and forward required headers/fields:

| API Format | Endpoints | Must forward |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**Session header:** `X-Claude-Code-Session-Id` — unique per session, useful for aggregating requests without parsing bodies.

**Gateway auth options:**

| Method | Setting | Header sent |
| :--- | :--- | :--- |
| Static key | `ANTHROPIC_AUTH_TOKEN` | `Authorization: Bearer ...` |
| Dynamic key | `apiKeyHelper` script in settings | `Authorization` + `X-Api-Key` |
| Refresh interval | `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | *(controls helper cache TTL)* |

**Gateway model discovery** (Anthropic Messages format only, requires v2.1.129+):
```bash
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1
```
Queries `/v1/models` at startup; results cached to `~/.claude/cache/gateway-models.json`.

**Provider-specific base URL variables:**

| Provider | Variable |
| :--- | :--- |
| Anthropic Messages | `ANTHROPIC_BASE_URL` |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` |
| Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` |

**Skip client-side auth for gateway pass-through:**

| Provider | Skip-auth variable |
| :--- | :--- |
| Bedrock | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Mantle | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |

Set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` when using Anthropic Messages format with a Bedrock or Vertex backend to avoid feature detection mismatches.

Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the attribution block prepended to system prompts (useful when gateway has its own prompt cache keyed on the full request body).

### Startup Model Checks

When Claude Code starts with Bedrock (v2.1.94+) or Vertex (v2.1.98+) configured, it verifies model accessibility:
- If pinned model is older than default and newer is available → prompts to update pin
- If no pin and default is unavailable → falls back to previous version for session only

Application inference profile ARN pins are skipped from upgrade prompts.

### Corporate Proxy

Route provider traffic through a proxy:
```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```
Works with all providers. Use alongside provider-specific env vars.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, sign-in wizard, manual setup, IAM config, Mantle endpoint, service tiers, Guardrails, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, sign-in wizard, manual setup, region config, IAM config, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, setup, Azure RBAC config, troubleshooting
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — gateway requirements, model selection, LiteLLM setup, authentication methods
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — deployment comparison table, proxy/gateway config, best practices for organizations

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
