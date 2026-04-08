---
name: cloud-providers-doc
description: Complete documentation for deploying Claude Code through cloud providers -- Amazon Bedrock, Google Vertex AI, and Microsoft Foundry. Covers setup wizards, credential configuration (AWS CLI, SSO, env vars, Bedrock API keys, GCP auth, Azure API keys, Microsoft Entra ID), enabling each provider (CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY), region configuration (AWS_REGION, CLOUD_ML_REGION, global endpoints, per-model VERTEX_REGION_CLAUDE_* overrides), IAM/RBAC permissions and policies, model version pinning (ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL, ANTHROPIC_MODEL), modelOverrides for per-version inference profile ARNs, 1M token context window, AWS Guardrails, Mantle endpoint (CLAUDE_CODE_USE_MANTLE, ANTHROPIC_BEDROCK_MANTLE_BASE_URL, CLAUDE_CODE_SKIP_MANTLE_AUTH), prompt caching, credential auto-refresh (awsAuthRefresh, awsCredentialExport), enterprise deployment comparison, corporate proxy and LLM gateway configuration (HTTPS_PROXY, ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL, CLAUDE_CODE_SKIP_BEDROCK_AUTH, CLAUDE_CODE_SKIP_VERTEX_AUTH, CLAUDE_CODE_SKIP_FOUNDRY_AUTH), LiteLLM proxy setup (unified and pass-through endpoints, ANTHROPIC_AUTH_TOKEN, apiKeyHelper), gateway API format requirements, and troubleshooting for each provider. Load when discussing Bedrock, Vertex AI, Microsoft Foundry, cloud provider setup, AWS credentials, GCP credentials, Azure credentials, model pinning, inference profiles, Mantle, LLM gateway, LiteLLM, corporate proxy, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, CLAUDE_CODE_USE_MANTLE, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL, awsAuthRefresh, awsCredentialExport, modelOverrides, third-party integrations, enterprise deployment, or any cloud-provider-related topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, and Microsoft Foundry, including enterprise deployment patterns, LLM gateways, and proxy configuration.

## Quick Reference

### Provider Comparison

| Feature | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
|:--------|:---------------|:-----------------|:------------------|
| Enable var | `CLAUDE_CODE_USE_BEDROCK=1` | `CLAUDE_CODE_USE_VERTEX=1` | `CLAUDE_CODE_USE_FOUNDRY=1` |
| Region var | `AWS_REGION` | `CLOUD_ML_REGION` | N/A (set via resource) |
| Auth methods | AWS CLI, env vars, SSO, Bedrock API keys | `gcloud` / Application Default Credentials | API key, Microsoft Entra ID |
| IAM role | Custom policy (InvokeModel, InvokeModelWithResponseStream, ListInferenceProfiles) | `roles/aiplatform.user` | `Azure AI User` or `Cognitive Services User` |
| Billing | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| 1M context | Opus 4.6, Sonnet 4.6 | Opus 4.6, Sonnet 4.6, Sonnet 4.5, Sonnet 4 | -- |
| Prompt caching | Enabled by default (not all regions) | Enabled by default | Enabled by default |

### Enabling Each Provider

**Amazon Bedrock:**
```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

**Google Vertex AI:**
```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

**Microsoft Foundry:**
```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource
```

### Credential Configuration

#### Amazon Bedrock

| Method | How |
|:-------|:----|
| AWS CLI | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>` then `AWS_PROFILE=name` |
| AWS Management Console | `aws login` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |
| Auto-refresh (SSO) | `awsAuthRefresh` setting (runs on credential expiry) |
| Auto-refresh (custom) | `awsCredentialExport` setting (returns JSON credentials) |

#### Google Vertex AI

Standard Google Cloud authentication via `gcloud`. Claude Code uses `ANTHROPIC_VERTEX_PROJECT_ID` for the project. Override with `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or `GOOGLE_APPLICATION_CREDENTIALS`.

#### Microsoft Foundry

| Method | How |
|:-------|:----|
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-key` |
| Microsoft Entra ID | Omit API key; uses Azure SDK default credential chain (`az login`) |

### Model Pinning

Pin specific model versions to prevent breakage when Anthropic releases new models.

| Variable | Bedrock example | Vertex AI example | Foundry example |
|:---------|:---------------|:------------------|:----------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |
| `ANTHROPIC_MODEL` | Override primary model | Override primary model | Override primary model |

**Default models (no pinning):**

| Provider | Primary model | Small/fast model |
|:---------|:-------------|:-----------------|
| Bedrock | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-5@20250929` | `claude-haiku-4-5@20251001` |

### modelOverrides (Bedrock)

Map multiple model versions to distinct application inference profile ARNs:

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod",
    "claude-opus-4-5-20251101": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-45-prod"
  }
}
```

### 1M Token Context Window

Append `[1m]` to the pinned model ID to enable the 1M context window.

### Mantle Endpoint (Bedrock)

Mantle serves Claude models through the native Anthropic API shape on Bedrock. Requires Claude Code v2.1.94+.

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side auth (for gateway setups) |

- Model IDs use `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`)
- Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to use both endpoints
- `/status` shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`

### Vertex AI Region Overrides

When using `CLOUD_ML_REGION=global`, override regions for models that do not support global endpoints:

```bash
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

### AWS Guardrails

Configure Bedrock Guardrails via custom headers in settings:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### AWS Credential Auto-Refresh

| Setting | When to use | Behavior |
|:--------|:-----------|:---------|
| `awsAuthRefresh` | Commands that modify `.aws` directory (SSO, credential refresh) | Output displayed to user; no interactive input |
| `awsCredentialExport` | Must return credentials directly (cannot modify `.aws`) | Output captured silently; must return JSON with `Credentials` object |

### Proxy and Gateway Configuration

#### Corporate Proxy

Set `HTTPS_PROXY` (or `HTTP_PROXY`) to route traffic through a corporate proxy:

```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```

#### LLM Gateway

| Provider | Base URL variable | Skip auth variable |
|:---------|:-----------------|:-------------------|
| Anthropic API | `ANTHROPIC_BASE_URL` | -- |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

### LLM Gateway Requirements

The gateway must expose at least one API format:

| Format | Endpoints | Must forward |
|:-------|:----------|:-------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

Every request includes `X-Claude-Code-Session-Id` header for session aggregation.

### LiteLLM Setup

**Unified endpoint (recommended):**
```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
```

**Pass-through endpoints:**

| Provider | Configuration |
|:---------|:-------------|
| Claude API | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock` + `CLAUDE_CODE_USE_BEDROCK=1` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1` + `CLAUDE_CODE_USE_VERTEX=1` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |

**Authentication:** Set `ANTHROPIC_AUTH_TOKEN` for static key, or configure `apiKeyHelper` in settings for dynamic/rotating keys. Use `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval.

### Enterprise Deployment Best Practices

- Pin model versions for all cloud providers
- Invest in CLAUDE.md documentation at organization and repository levels
- Configure managed permissions via security settings
- Use MCP for integrations (ticket systems, error logs)
- Create "one click" installation for organizational adoption
- Use `/status` to verify proxy and gateway configuration

### IAM Policies

**Bedrock IAM actions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`

**Vertex AI permission:** `aiplatform.endpoints.predict` (included in `roles/aiplatform.user`)

**Foundry RBAC data action:** `Microsoft.CognitiveServices/accounts/providers/*` (included in `Azure AI User` or `Cognitive Services User`)

### Troubleshooting

| Provider | Issue | Solution |
|:---------|:------|:---------|
| Bedrock | SSO auth loop | Remove `awsAuthRefresh` setting; use manual `aws sso login` |
| Bedrock | Region issues | Check `aws bedrock list-inference-profiles --region your-region`; switch to supported region |
| Bedrock | "on-demand throughput isn't supported" | Use inference profile ID |
| Bedrock | Mantle 403 | Contact AWS account team to request model access |
| Bedrock | Mantle 400 naming model ID | Use Mantle-format ID (`anthropic.` prefix) or enable both endpoints |
| Vertex AI | Quota issues | Request increase via Cloud Console |
| Vertex AI | 404 model not found | Confirm model enabled in Model Garden; check region support; use `VERTEX_REGION_*` vars |
| Vertex AI | 429 errors | Ensure models supported in region; try `CLOUD_ML_REGION=global` |
| Foundry | "Failed to get token" | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- AWS setup, credentials, IAM, model pinning, Mantle endpoint, Guardrails, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- GCP setup, credentials, IAM, model pinning, region configuration, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- Azure setup, credentials, RBAC, model pinning, troubleshooting
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) -- Deployment comparison, proxy and gateway configuration, best practices
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) -- Gateway requirements, API formats, LiteLLM setup, authentication

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
