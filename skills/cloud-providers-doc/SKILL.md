---
name: cloud-providers-doc
description: Complete documentation for Claude Code cloud provider integrations -- Amazon Bedrock (AWS credentials, IAM policy, Guardrails, credential refresh, Bedrock API keys, cross-region inference profiles, modelOverrides, ANTHROPIC_BEDROCK_BASE_URL), Google Vertex AI (GCP credentials, IAM roles, global/regional endpoints, VERTEX_REGION_CLAUDE_* overrides, 1M context window, ANTHROPIC_VERTEX_BASE_URL), Microsoft Foundry (Azure Entra ID, API key auth, RBAC, ANTHROPIC_FOUNDRY_RESOURCE, ANTHROPIC_FOUNDRY_BASE_URL), enterprise deployment overview (Teams vs Enterprise vs Console vs cloud providers comparison, proxy and gateway configuration, best practices), and LLM gateway configuration (gateway requirements, API format compatibility, LiteLLM setup, apiKeyHelper, ANTHROPIC_AUTH_TOKEN, pass-through endpoints, CLAUDE_CODE_SKIP_*_AUTH). Load when discussing Bedrock, Vertex AI, Microsoft Foundry, Azure, AWS, GCP, cloud provider setup, LLM gateways, LiteLLM, enterprise deployment, model pinning for cloud providers, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, corporate proxies, HTTPS_PROXY, or any cloud provider integration topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for Claude Code cloud provider integrations -- Amazon Bedrock, Google Vertex AI, Microsoft Foundry, enterprise deployment overview, and LLM gateway configuration.

## Quick Reference

### Provider Comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
|:--------|:----------------------|:-----------------|:---------------|:----------------|:-----------------|
| Best for | Most organizations | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Per-seat / Contact Sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO/email | API key | API key or AWS creds | GCP credentials | API key or Entra ID |
| Prompt caching | Default on | Default on | Default on | Default on | Default on |
| Enterprise features | Team mgmt, SSO, usage | None | IAM, CloudTrail | IAM, Cloud Audit | RBAC, Azure Monitor |

### Provider Enable Variables

| Provider | Enable Variable | Region Variable | Base URL Override |
|:---------|:---------------|:----------------|:-----------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` (required) | `ANTHROPIC_BEDROCK_BASE_URL` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION` (e.g., `global`) | `ANTHROPIC_VERTEX_BASE_URL` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | N/A | `ANTHROPIC_FOUNDRY_BASE_URL` |

### Model Pinning Variables

Pin specific model versions to prevent breakage when new models release:

| Variable | Bedrock Example | Vertex AI Example | Foundry Example |
|:---------|:---------------|:-----------------|:---------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |

Override primary model: `ANTHROPIC_MODEL`. Override small/fast model region (Bedrock): `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION`.

### Amazon Bedrock

**Credential methods:** AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN`), SSO profile (`AWS_PROFILE`), `aws login`, or Bedrock API keys (`AWS_BEARER_TOKEN_BEDROCK`).

**Auto credential refresh settings (in settings file):**
- `awsAuthRefresh` -- runs command that modifies `.aws` directory (e.g., `aws sso login --profile myprofile`)
- `awsCredentialExport` -- runs command that outputs JSON with `Credentials.AccessKeyId`, `SecretAccessKey`, `SessionToken`

**IAM actions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`.

**Model overrides:** Use `modelOverrides` setting to map specific model versions to application inference profile ARNs:

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod"
  }
}
```

**Guardrails:** Set via `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion`.

**Default models (no pinning):** Primary = `global.anthropic.claude-sonnet-4-6`, Small/fast = `us.anthropic.claude-haiku-4-5-20251001-v1:0`.

### Google Vertex AI

**Required env vars:** `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION` (e.g., `global`), `ANTHROPIC_VERTEX_PROJECT_ID`.

**Per-model region overrides (when using global endpoint):** `VERTEX_REGION_CLAUDE_HAIKU_4_5`, `VERTEX_REGION_CLAUDE_4_6_SONNET`, etc.

**IAM role:** `roles/aiplatform.user` (needs `aiplatform.endpoints.predict`).

**1M context window:** Supported on Opus 4.6, Sonnet 4.6, Sonnet 4.5, Sonnet 4. Append `[1m]` to model ID.

**Default models (no pinning):** Primary = `claude-sonnet-4-6`, Small/fast = `claude-haiku-4-5@20251001`.

### Microsoft Foundry

**Required env vars:** `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` (or `ANTHROPIC_FOUNDRY_BASE_URL`).

**Auth methods:** API key (`ANTHROPIC_FOUNDRY_API_KEY`) or Microsoft Entra ID (Azure SDK default credential chain, e.g., `az login`).

**RBAC roles:** `Azure AI User` or `Cognitive Services User`. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` data action.

### LLM Gateway Configuration

**Supported API formats:**
- Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens`
- Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream`
- Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict`

**Skip auth variables (when gateway handles auth):** `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1`.

**Auth for gateways:** `ANTHROPIC_AUTH_TOKEN` (static key) or `apiKeyHelper` (dynamic script). Helper TTL: `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

**Session header:** Every request includes `X-Claude-Code-Session-Id`.

### Proxy and Gateway Setup

| Provider | Corporate Proxy | LLM Gateway |
|:---------|:---------------|:------------|
| Bedrock | `HTTPS_PROXY` + standard Bedrock vars | `ANTHROPIC_BEDROCK_BASE_URL` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `HTTPS_PROXY` + standard Vertex vars | `ANTHROPIC_VERTEX_BASE_URL` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `HTTPS_PROXY` + standard Foundry vars | `ANTHROPIC_FOUNDRY_BASE_URL` + `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

### LiteLLM Endpoints

| Method | Env Var | Value |
|:-------|:--------|:------|
| Unified (recommended) | `ANTHROPIC_BASE_URL` | `https://litellm-server:4000` |
| Claude pass-through | `ANTHROPIC_BASE_URL` | `https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL` | `https://litellm-server:4000/bedrock` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL` | `https://litellm-server:4000/vertex_ai/v1` |

### Common Notes

- `/login` and `/logout` commands are disabled for all cloud providers (auth handled by provider credentials).
- Disable prompt caching: `DISABLE_PROMPT_CACHING=1`.
- Use `/status` to verify proxy and gateway configuration.
- Bedrock uses Invoke API only (not Converse API).
- `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` may be needed when using Anthropic Messages format with Bedrock/Vertex via gateway.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- Setup, AWS credentials, IAM policy, Guardrails, model pinning, and troubleshooting for Bedrock
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- Setup, GCP credentials, IAM roles, global/regional endpoints, 1M context, and troubleshooting for Vertex AI
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- Setup, Azure credentials, RBAC configuration, and troubleshooting for Microsoft Foundry
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) -- Deployment option comparison, proxy/gateway configuration, and best practices for organizations
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) -- Gateway requirements, authentication methods, LiteLLM setup, and provider-specific endpoints

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
