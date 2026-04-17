---
name: cloud-providers-doc
description: Complete official documentation for using Claude Code with cloud providers — Amazon Bedrock (including Mantle), Google Vertex AI, Microsoft Foundry — plus enterprise deployment overview, proxy/gateway configuration, and LLM gateway setup (including LiteLLM).
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, Microsoft Foundry, and LLM gateways.

## Quick Reference

### Provider comparison

| Feature | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :------ | :------------- | :--------------- | :---------------- |
| **Enable env var** | `CLAUDE_CODE_USE_BEDROCK=1` | `CLAUDE_CODE_USE_VERTEX=1` | `CLAUDE_CODE_USE_FOUNDRY=1` |
| **Region var** | `AWS_REGION` | `CLOUD_ML_REGION` | N/A |
| **Project/resource var** | N/A | `ANTHROPIC_VERTEX_PROJECT_ID` | `ANTHROPIC_FOUNDRY_RESOURCE` |
| **Auth methods** | AWS CLI, env vars, SSO profile, Bedrock API key | `gcloud` ADC, service account key | API key, Microsoft Entra ID |
| **Setup wizard** | `/setup-bedrock` | `/setup-vertex` | N/A (manual only) |
| **Base URL override** | `ANTHROPIC_BEDROCK_BASE_URL` | `ANTHROPIC_VERTEX_BASE_URL` | `ANTHROPIC_FOUNDRY_BASE_URL` |
| **Skip auth (for gateways)** | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| **1M context window** | Opus 4.7, Opus 4.6, Sonnet 4.6 | Opus 4.7, Opus 4.6, Sonnet 4.6 | N/A |
| **Billing** | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| **Min CLI version** | v2.1.94 (model checks) | v2.1.98 (model checks + wizard) | N/A |

### Model pinning environment variables

Pin specific model versions when deploying to multiple users. Without pinning, aliases resolve to the latest version, which may not be available in your account when Anthropic releases an update.

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_MODEL` | Override the primary model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin the `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin the `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin the `haiku` alias |

Without `ANTHROPIC_DEFAULT_OPUS_MODEL`, the `opus` alias resolves to Opus 4.6 on all three providers. Set it to Opus 4.7 explicitly to use the latest.

Default models (no pinning):

| Provider | Primary model | Small/fast model |
| :------- | :------------ | :--------------- |
| Bedrock | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-5@20250929` | `claude-haiku-4-5@20251001` |
| Foundry | (use deployment names from Azure) | (use deployment names from Azure) |

### Amazon Bedrock quick setup

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

Credential options: `aws configure`, `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN`, `AWS_PROFILE` with SSO, `AWS_BEARER_TOKEN_BEDROCK` for Bedrock API keys.

Auto credential refresh settings (in settings.json):
- `awsAuthRefresh` -- command that modifies `.aws` (e.g., `aws sso login --profile myprofile`)
- `awsCredentialExport` -- command that outputs JSON credentials directly

IAM permissions needed: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile, application-inference-profile, and foundation-model resources. Also `aws-marketplace:ViewSubscriptions` and `aws-marketplace:Subscribe` (condition: CalledVia bedrock).

#### Bedrock Mantle endpoint

Mantle serves Claude models through the native Anthropic API shape instead of the Bedrock Invoke API. Requires v2.1.94+.

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle (`1` or `true`) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy setups |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku (shared with Bedrock) |

Mantle model IDs use the `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run both endpoints side by side.

#### AWS Guardrails

Set guardrail headers via `ANTHROPIC_CUSTOM_HEADERS` in settings:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

#### modelOverrides (Bedrock)

Map multiple model versions to distinct application inference profile ARNs in settings.json:

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Google Vertex AI quick setup

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

Supports both global and regional endpoints. Per-model region overrides via `VERTEX_REGION_CLAUDE_*` variables (e.g., `VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5`).

IAM: `roles/aiplatform.user` (needs `aiplatform.endpoints.predict`).

### Microsoft Foundry quick setup

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource
# API key auth:
export ANTHROPIC_FOUNDRY_API_KEY=your-key
# Or omit for Entra ID (DefaultAzureCredential chain)
```

Azure RBAC: `Azure AI User` or `Cognitive Services User` role. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` data action.

### Enterprise deployment overview

For most organizations, **Claude for Teams** ($150/seat Premium + PAYG) or **Claude for Enterprise** (contact sales) is recommended -- includes both Claude Code and Claude on the web with centralized billing.

Cloud provider deployments (Bedrock, Vertex, Foundry) are for organizations with specific infrastructure requirements. All three support PAYG billing, prompt caching (enabled by default), and enterprise features (IAM/RBAC, audit logging).

Best practices:
- Pin model versions for cloud providers
- Invest in CLAUDE.md documentation
- Configure managed permissions for security
- Use MCP for integrations (ticket systems, error logs)
- Create a "one click" install path to drive adoption

### Proxy and gateway configuration

| Scenario | Environment variables |
| :------- | :-------------------- |
| Corporate proxy (any provider) | `HTTPS_PROXY=https://proxy.example.com:8080` |
| Bedrock via LLM gateway | `ANTHROPIC_BEDROCK_BASE_URL=https://gateway/bedrock` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex via LLM gateway | `ANTHROPIC_VERTEX_BASE_URL=https://gateway/vertex` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry via LLM gateway | `ANTHROPIC_FOUNDRY_BASE_URL=https://gateway` + `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Direct API via LLM gateway | `ANTHROPIC_BASE_URL=https://gateway` |

### LLM gateway requirements

The gateway must expose at least one of:
- **Anthropic Messages**: `/v1/messages`, `/v1/messages/count_tokens` (forward `anthropic-beta`, `anthropic-version` headers)
- **Bedrock InvokeModel**: `/invoke`, `/invoke-with-response-stream` (preserve `anthropic_beta`, `anthropic_version` body fields)
- **Vertex rawPredict**: `:rawPredict`, `:streamRawPredict` (forward `anthropic-beta`, `anthropic-version` headers)

Claude Code sends `X-Claude-Code-Session-Id` on every request.

### LiteLLM setup

Authentication options:
- Static: `ANTHROPIC_AUTH_TOKEN=sk-litellm-key`
- Dynamic: `apiKeyHelper` in settings + optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`

Endpoint options:
- Unified (recommended): `ANTHROPIC_BASE_URL=https://litellm-server:4000`
- Anthropic pass-through: `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic`
- Bedrock pass-through: `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` + `CLAUDE_CODE_USE_BEDROCK=1`
- Vertex pass-through: `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` + `CLAUDE_CODE_USE_VERTEX=1`

### Startup model checks

All providers verify model accessibility at startup. If the pinned model is outdated and a newer version is available, Claude Code prompts to update. If no model is pinned and the default is unavailable, Claude Code falls back to the previous version for the session.

### Troubleshooting quick reference

| Problem | Fix |
| :------ | :-- |
| Bedrock region issues | `aws bedrock list-inference-profiles --region your-region`; use inference profile IDs |
| Bedrock "on-demand throughput isn't supported" | Use an inference profile ID |
| Bedrock SSO auth loop | Remove `awsAuthRefresh` from settings; run `aws sso login` manually |
| Bedrock Mantle 403 | Account not granted access to requested model; contact AWS |
| Bedrock Mantle 400 naming model | Model not served on Mantle; use Mantle-format ID or enable both endpoints |
| Vertex "model not found" 404 | Enable in Model Garden; check region support; use `VERTEX_REGION_*` overrides |
| Vertex 429 rate limits | Ensure models supported in selected region; try `CLOUD_ML_REGION=global` |
| Vertex quota issues | Request increase via Cloud Console |
| Foundry "ChainedTokenCredential failed" | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Full Bedrock setup (wizard and manual), AWS credential options (CLI, env vars, SSO, Bedrock API keys), auto credential refresh, model pinning, Mantle endpoint, IAM configuration, AWS Guardrails, modelOverrides, 1M context window, and troubleshooting.
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — Full Vertex AI setup (wizard and manual), GCP credentials, global and regional endpoints, per-model region overrides, model pinning, IAM permissions, 1M context window, and troubleshooting.
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Foundry setup, API key and Entra ID authentication, resource configuration, model pinning, Azure RBAC, and troubleshooting.
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Comparison of all deployment options (Teams/Enterprise, Console, Bedrock, Vertex, Foundry), proxy and gateway configuration per provider, and organizational best practices.
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, request headers, model selection, LiteLLM setup (static/dynamic auth, unified vs pass-through endpoints), and security advisory.

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
