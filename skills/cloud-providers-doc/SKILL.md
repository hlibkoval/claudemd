---
name: cloud-providers-doc
description: Complete documentation for using Claude Code with cloud providers -- Amazon Bedrock (AWS credentials, IAM policies, Guardrails, inference profiles, modelOverrides, cross-region config), Google Vertex AI (GCP setup, regional and global endpoints, 1M context window, VERTEX_REGION_* overrides), Microsoft Foundry (Azure setup, API key and Entra ID auth, RBAC), enterprise deployment overview (comparing Teams/Enterprise/Console/Bedrock/Vertex/Foundry on billing/auth/regions/features, best practices for organizations, proxy and gateway config), and LLM gateway configuration (gateway requirements for Anthropic/Bedrock/Vertex API formats, LiteLLM setup with unified and pass-through endpoints, authentication methods including apiKeyHelper and ANTHROPIC_AUTH_TOKEN). Load when discussing Bedrock, Vertex AI, Microsoft Foundry, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, AWS_REGION, CLOUD_ML_REGION, ANTHROPIC_VERTEX_PROJECT_ID, ANTHROPIC_FOUNDRY_RESOURCE, ANTHROPIC_FOUNDRY_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_BASE_URL, LLM gateway, LiteLLM, cloud provider setup, enterprise deployment, third-party integrations, inference profiles, modelOverrides, pin model versions, AWS Guardrails, corporate proxy, HTTPS_PROXY, or any cloud-provider-related topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for using Claude Code with cloud providers -- Amazon Bedrock, Google Vertex AI, Microsoft Foundry, enterprise deployment options, and LLM gateway configuration.

## Quick Reference

### Provider Enablement

| Provider | Enable variable | Required variables |
|:---------|:---------------|:-------------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

When using any cloud provider, `/login` and `/logout` are disabled -- authentication is handled through provider credentials.

### Authentication Methods

| Provider | Methods |
|:---------|:--------|
| Bedrock | AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN`), SSO profile (`AWS_PROFILE`), `aws login`, Bedrock API keys (`AWS_BEARER_TOKEN_BEDROCK`) |
| Vertex AI | Standard Google Cloud auth (`gcloud auth`), `ANTHROPIC_VERTEX_PROJECT_ID` overrides gcloud project |
| Foundry | API key (`ANTHROPIC_FOUNDRY_API_KEY`), or Microsoft Entra ID via Azure SDK default credential chain (`az login`) |

### Model Pinning (All Providers)

Pin specific model versions to prevent breakage when Anthropic releases new models:

| Variable | Bedrock example | Vertex AI example | Foundry example |
|:---------|:---------------|:-----------------|:---------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |

Additional model variables: `ANTHROPIC_MODEL` (primary model override), `ANTHROPIC_DEFAULT_HAIKU_MODEL` (small/fast model).

### Default Models (When Not Pinned)

| Provider | Primary model | Small/fast model |
|:---------|:-------------|:----------------|
| Bedrock | `global.anthropic.claude-sonnet-4-6` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-6` | `claude-haiku-4-5@20251001` |

### Bedrock-Specific Configuration

| Setting | Purpose |
|:--------|:--------|
| `AWS_REGION` | Required. Not read from `.aws` config |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching (not available in all regions) |
| `modelOverrides` (settings) | Map model versions to specific inference profile ARNs |
| `awsAuthRefresh` (settings) | Command to refresh AWS credentials (e.g., `aws sso login --profile myprofile`) |
| `awsCredentialExport` (settings) | Command that outputs JSON credentials directly |
| `ANTHROPIC_CUSTOM_HEADERS` | Set Guardrail headers (e.g., `X-Amzn-Bedrock-GuardrailIdentifier`) |

**Bedrock IAM permissions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile, application-inference-profile, and foundation-model resources.

### Vertex AI-Specific Configuration

| Setting | Purpose |
|:--------|:--------|
| `CLOUD_ML_REGION` | Region or `global` for global endpoint |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | Override region for Haiku when using global endpoint |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | Override region for Opus |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | Override region for Sonnet |

**Vertex AI IAM:** `roles/aiplatform.user` role (needs `aiplatform.endpoints.predict`).

**1M context window:** Supported for Claude Opus 4.6, Sonnet 4.6, Sonnet 4.5, and Sonnet 4. Append `[1m]` to the pinned model ID to enable.

### Foundry-Specific Configuration

| Setting | Purpose |
|:--------|:--------|
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key (omit for Entra ID auth) |

**Foundry RBAC:** `Azure AI User` or `Cognitive Services User` roles. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

### Enterprise Deployment Comparison

| Feature | Teams/Enterprise | Console | Bedrock | Vertex AI | Foundry |
|:--------|:----------------|:--------|:--------|:----------|:--------|
| Best for | Most orgs (recommended) | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Seat-based / Contact Sales | PAYG | PAYG (AWS) | PAYG (GCP) | PAYG (Azure) |
| Auth | Claude.ai SSO/email | API key | API key / AWS creds | GCP creds | API key / Entra ID |
| Includes Claude web | Yes | No | No | No | No |

### Proxy and Gateway Configuration

| Provider | Corporate proxy | LLM gateway base URL | Skip auth variable |
|:---------|:---------------|:--------------------|:-------------------|
| Bedrock | `HTTPS_PROXY` | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `HTTPS_PROXY` | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `HTTPS_PROXY` | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Anthropic API | `HTTPS_PROXY` | `ANTHROPIC_BASE_URL` | N/A |

### LLM Gateway Requirements

The gateway must expose at least one of these API formats:

| Format | Endpoints | Must forward |
|:-------|:----------|:------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

Every request includes `X-Claude-Code-Session-Id` header for session aggregation.

### LiteLLM Integration

| Mode | Environment variables |
|:-----|:---------------------|
| Unified (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` + `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` + `CLAUDE_CODE_USE_VERTEX=1` + `CLOUD_ML_REGION` + `ANTHROPIC_VERTEX_PROJECT_ID` |

**Authentication:** Static key via `ANTHROPIC_AUTH_TOKEN`, or dynamic key via `apiKeyHelper` setting with optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval.

When using Anthropic Messages format with Bedrock or Vertex backend, set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- AWS setup, credential configuration (CLI, env vars, SSO, Bedrock API keys), advanced credential refresh (awsAuthRefresh, awsCredentialExport), model pinning with inference profile IDs, modelOverrides for mapping versions to ARNs, IAM policy with required permissions, AWS Guardrails configuration, troubleshooting region and throughput issues
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- GCP setup, enabling Vertex AI API, requesting model access, authentication, regional and global endpoint configuration, per-model region overrides (VERTEX_REGION_*), model pinning, 1M token context window support, IAM roles, troubleshooting quota/404/429 errors
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- Azure setup, provisioning Foundry resources, API key and Entra ID authentication, model pinning, Azure RBAC configuration with required permissions, troubleshooting credential errors
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) -- Comparison of Teams/Enterprise/Console/Bedrock/Vertex/Foundry on billing, regions, caching, auth, cost tracking, enterprise features; proxy and gateway configuration per provider; best practices for organizations (documentation, deployment, model pinning, security, MCP)
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) -- Gateway requirements (API formats, required headers/fields), model selection, LiteLLM setup (authentication methods, unified endpoint, provider-specific pass-through endpoints for Anthropic/Bedrock/Vertex)

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
