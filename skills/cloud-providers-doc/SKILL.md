---
name: cloud-providers-doc
description: Complete documentation for deploying Claude Code through cloud providers -- Amazon Bedrock, Google Vertex AI, Microsoft Foundry, enterprise deployment overview, and LLM gateway configuration. Covers setup, authentication (AWS credentials, GCP credentials, Azure API keys, Entra ID), environment variables (CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY), IAM/RBAC configuration, model pinning (ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL), model overrides (modelOverrides), 1M token context window, prompt caching, credential refresh (awsAuthRefresh, awsCredentialExport), Bedrock API keys (AWS_BEARER_TOKEN_BEDROCK), AWS Guardrails, proxy and gateway configuration (HTTPS_PROXY, ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL), LLM gateway requirements and API formats, LiteLLM setup (unified endpoint, pass-through endpoints, apiKeyHelper, ANTHROPIC_AUTH_TOKEN), skip-auth flags (CLAUDE_CODE_SKIP_BEDROCK_AUTH, CLAUDE_CODE_SKIP_VERTEX_AUTH, CLAUDE_CODE_SKIP_FOUNDRY_AUTH), Vertex AI global and regional endpoints (CLOUD_ML_REGION, VERTEX_REGION_CLAUDE_*), deployment comparison, enterprise best practices, and troubleshooting for each provider. Load when discussing Bedrock, Vertex AI, Microsoft Foundry, Azure, AWS, GCP, cloud provider setup, LLM gateway, LiteLLM, third-party integrations, enterprise deployment, model pinning, cross-region inference, inference profiles, proxy configuration, corporate proxy, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL, awsAuthRefresh, AWS_BEARER_TOKEN_BEDROCK, Bedrock API keys, or any cloud-provider-related topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
|:--------|:----------------------|:-----------------|:---------------|:----------------|:-----------------|
| Best for | Most orgs (recommended) | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Per-seat / contact sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO/email | API key | API key or AWS creds | GCP credentials | API key or Entra ID |
| Prompt caching | Default on | Default on | Default on | Default on | Default on |

### Provider Enable Variables

| Provider | Enable Variable | Required Region Variable |
|:---------|:---------------|:------------------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | -- |

### Amazon Bedrock Setup

| Variable | Required | Description |
|:---------|:---------|:-----------|
| `CLAUDE_CODE_USE_BEDROCK` | Yes | Set to `1` to enable |
| `AWS_REGION` | Yes | AWS region (e.g., `us-east-1`) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | No | Override region for Haiku |
| `ANTHROPIC_BEDROCK_BASE_URL` | No | Custom endpoint URL |
| `AWS_BEARER_TOKEN_BEDROCK` | No | Bedrock API key (simpler auth, no full AWS creds needed) |

**Authentication options:** AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN`), SSO profile (`AWS_PROFILE`), `aws login`, or Bedrock API keys (`AWS_BEARER_TOKEN_BEDROCK`).

**Credential refresh:** Configure `awsAuthRefresh` (for commands that modify `.aws/`) or `awsCredentialExport` (for commands that return JSON credentials directly) in settings.

**IAM permissions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile, application-inference-profile, and foundation-model resources. Plus `aws-marketplace:ViewSubscriptions` and `aws-marketplace:Subscribe` (conditioned on Bedrock caller).

**AWS Guardrails:** Set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers in settings `env`.

### Google Vertex AI Setup

| Variable | Required | Description |
|:---------|:---------|:-----------|
| `CLAUDE_CODE_USE_VERTEX` | Yes | Set to `1` to enable |
| `CLOUD_ML_REGION` | Yes | Region or `global` |
| `ANTHROPIC_VERTEX_PROJECT_ID` | Yes | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | No | Custom endpoint URL |
| `DISABLE_PROMPT_CACHING` | No | Set to `1` to disable |
| `VERTEX_REGION_CLAUDE_*` | No | Per-model region overrides |

**Authentication:** Standard Google Cloud auth via `gcloud`. Project ID from `ANTHROPIC_VERTEX_PROJECT_ID`; override with `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or `GOOGLE_APPLICATION_CREDENTIALS`.

**IAM permissions:** `roles/aiplatform.user` role (includes `aiplatform.endpoints.predict`).

**Regional endpoints:** When `CLOUD_ML_REGION=global`, use `VERTEX_REGION_CLAUDE_HAIKU_4_5`, `VERTEX_REGION_CLAUDE_4_6_SONNET`, etc., for models that do not support global endpoints.

### Microsoft Foundry Setup

| Variable | Required | Description |
|:---------|:---------|:-----------|
| `CLAUDE_CODE_USE_FOUNDRY` | Yes | Set to `1` to enable |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Yes* | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | No* | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | No | API key (omit for Entra ID auth) |

*One of `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` is required.

**Authentication:** API key (`ANTHROPIC_FOUNDRY_API_KEY`) or Microsoft Entra ID (Azure SDK default credential chain, e.g., `az login`).

**RBAC permissions:** `Azure AI User` or `Cognitive Services User` role. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` data action.

### Model Pinning (All Providers)

| Variable | Bedrock Default | Vertex AI Default |
|:---------|:---------------|:-----------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` |
| `ANTHROPIC_MODEL` | Override primary model | Override primary model |

Pin specific versions to prevent breakage when Anthropic releases new models. Append `[1m]` to the model ID to enable the 1M token context window.

**Per-version overrides (Bedrock):** Use `modelOverrides` in settings to map specific model versions to application inference profile ARNs:

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod"
  }
}
```

### LLM Gateway Configuration

| Gateway Endpoint Variable | Provider |
|:--------------------------|:---------|
| `ANTHROPIC_BASE_URL` | Anthropic API (or unified LiteLLM) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex AI |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Microsoft Foundry |

**Skip-auth flags** (when gateway handles authentication):

| Variable | Provider |
|:---------|:---------|
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | Bedrock |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | Vertex AI |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` | Microsoft Foundry |

**Gateway API format requirements** -- must expose at least one of:
- Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens`
- Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream`
- Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict`

**Request headers:** All requests include `X-Claude-Code-Session-Id` for session tracking.

### LiteLLM Integration

| Approach | Configuration |
|:---------|:-------------|
| Unified endpoint (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` + `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` + `CLAUDE_CODE_USE_VERTEX=1` |

**Authentication:** Static key via `ANTHROPIC_AUTH_TOKEN`, or dynamic key via `apiKeyHelper` setting with optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval.

### Corporate Proxy

Set `HTTPS_PROXY` (or `HTTP_PROXY`) to route traffic through a corporate proxy. Works with all providers.

### Common Troubleshooting

| Problem | Solution |
|:--------|:--------|
| Bedrock SSO auth loop | Remove `awsAuthRefresh` setting; run `aws sso login` manually before starting |
| Bedrock region issues | Check `aws bedrock list-inference-profiles --region your-region`; use inference profile IDs |
| Bedrock "on-demand throughput isn't supported" | Use an inference profile ID instead of a base model ID |
| Vertex 404 "model not found" | Confirm model enabled in Model Garden; check region support; use `VERTEX_REGION_CLAUDE_*` overrides |
| Vertex 429 errors | Ensure models supported in region; consider `CLOUD_ML_REGION=global` |
| Foundry "ChainedTokenCredential authentication failed" | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |
| `/login` and `/logout` disabled | Expected when using any third-party provider |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- Setup, AWS credentials, IAM policy, model pinning, inference profiles, modelOverrides, credential refresh, Bedrock API keys, Guardrails, 1M context, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- Setup, GCP credentials, IAM roles, model pinning, global vs regional endpoints, per-model region overrides, 1M context, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- Setup, Azure credentials, API key and Entra ID auth, RBAC configuration, model pinning, troubleshooting
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) -- Deployment comparison table, proxy and gateway configuration per provider, enterprise best practices, CLAUDE.md recommendations
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) -- Gateway requirements, API format specs, LiteLLM setup (unified and pass-through endpoints), authentication methods, apiKeyHelper

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
