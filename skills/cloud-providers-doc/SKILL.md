---
name: cloud-providers-doc
description: Complete documentation for Claude Code cloud provider integrations -- Amazon Bedrock (AWS credentials, IAM policies, cross-region inference profiles, application inference profile ARNs, modelOverrides, Guardrails, credential refresh with awsAuthRefresh/awsCredentialExport, Bedrock API keys), Google Vertex AI (GCP credentials, Vertex AI API, global and regional endpoints, VERTEX_REGION_* overrides, IAM roles, 1M token context window), Microsoft Foundry (Azure credentials, Entra ID authentication, RBAC, API key and DefaultAzureCredential), enterprise deployment overview (Teams vs Enterprise vs Console vs cloud providers comparison, proxy and gateway configuration), LLM gateway configuration (gateway requirements, API format compatibility, Anthropic Messages / Bedrock InvokeModel / Vertex rawPredict, LiteLLM setup with unified and pass-through endpoints, apiKeyHelper, ANTHROPIC_AUTH_TOKEN, ANTHROPIC_BASE_URL), model pinning (ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL), proxy configuration (HTTPS_PROXY, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL), and CLAUDE_CODE_SKIP_*_AUTH flags. Load when discussing Bedrock, Vertex AI, Microsoft Foundry, Azure AI, cloud provider setup, enterprise deployment, LLM gateways, LiteLLM, proxy configuration, model pinning for cloud providers, cross-region inference, application inference profiles, AWS credentials for Claude Code, GCP credentials for Claude Code, Azure credentials for Claude Code, corporate proxy setup, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, or third-party API integrations with Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment configurations.

## Quick Reference

### Provider Comparison

| Feature | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
|:--------|:---------------|:-----------------|:------------------|
| Enable env var | `CLAUDE_CODE_USE_BEDROCK=1` | `CLAUDE_CODE_USE_VERTEX=1` | `CLAUDE_CODE_USE_FOUNDRY=1` |
| Region env var | `AWS_REGION` | `CLOUD_ML_REGION` | N/A (set via resource) |
| Project/resource | N/A | `ANTHROPIC_VERTEX_PROJECT_ID` | `ANTHROPIC_FOUNDRY_RESOURCE` |
| Auth methods | AWS SDK chain, SSO, access keys, Bedrock API keys | GCP default auth (`gcloud`) | API key, Microsoft Entra ID |
| IAM role/policy | Custom policy with `bedrock:InvokeModel*` | `roles/aiplatform.user` | `Azure AI User` or `Cognitive Services User` |
| Gateway base URL | `ANTHROPIC_BEDROCK_BASE_URL` | `ANTHROPIC_VERTEX_BASE_URL` | `ANTHROPIC_FOUNDRY_BASE_URL` |
| Skip auth flag | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Prompt caching | Enabled by default (not all regions) | Enabled by default | Enabled by default |

### Model Pinning Environment Variables

Pin specific model versions to prevent breakage when Anthropic releases new models:

| Variable | Purpose | Bedrock example | Vertex example | Foundry example |
|:---------|:--------|:----------------|:---------------|:----------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus family | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet family | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku family | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |
| `ANTHROPIC_MODEL` | Override primary model | inference profile ID or ARN | model ID | model ID |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override small/fast model | inference profile ID or ARN | model ID | model ID |

### Bedrock Defaults (no pinning)

| Model type | Default |
|:-----------|:--------|
| Primary | `global.anthropic.claude-sonnet-4-6` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

### Vertex AI Defaults (no pinning)

| Model type | Default |
|:-----------|:--------|
| Primary | `claude-sonnet-4-6` |
| Small/fast | `claude-haiku-4-5@20251001` |

### Bedrock Credential Methods

| Method | Setup |
|:-------|:------|
| AWS CLI | `aws configure` |
| Access keys | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>` then `AWS_PROFILE` |
| AWS login | `aws login` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK` |

### Bedrock Credential Refresh

| Setting | Purpose |
|:--------|:--------|
| `awsAuthRefresh` | Command that modifies `.aws` directory (SSO, browser-based flows) |
| `awsCredentialExport` | Command that returns JSON with `Credentials.{AccessKeyId, SecretAccessKey, SessionToken}` |

### Vertex AI Region Overrides

When using `CLOUD_ML_REGION=global`, override regions for models that lack global endpoint support:

| Variable | Model |
|:---------|:------|
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | Claude 3.5 Haiku |
| `VERTEX_REGION_CLAUDE_3_5_SONNET` | Claude 3.5 Sonnet |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | Claude 3.7 Sonnet |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | Claude 4.0 Opus |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | Claude 4.0 Sonnet |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | Claude 4.1 Opus |

### Foundry Authentication

| Method | Configuration |
|:-------|:-------------|
| API key | `ANTHROPIC_FOUNDRY_API_KEY` |
| Entra ID | Omit API key; uses Azure SDK default credential chain (`az login`) |
| Resource name | `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |
| Full base URL | `ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic` |

### Bedrock Model Overrides (`modelOverrides`)

Map specific model versions to application inference profile ARNs in settings:

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod",
    "claude-opus-4-5-20251101": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-45-prod"
  }
}
```

### Bedrock Guardrails

Set via `ANTHROPIC_CUSTOM_HEADERS` in settings:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### Proxy and Gateway Configuration

| Provider | Corporate proxy | LLM gateway base URL | Skip auth flag |
|:---------|:---------------|:---------------------|:---------------|
| Bedrock | `HTTPS_PROXY` | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `HTTPS_PROXY` | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `HTTPS_PROXY` | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Anthropic API | `HTTPS_PROXY` | `ANTHROPIC_BASE_URL` | N/A |

### LLM Gateway Requirements

The gateway must expose at least one of these API formats:

| Format | Endpoints | Must forward |
|:-------|:----------|:-------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

### LiteLLM Configuration

| Endpoint type | Base URL env var | Extra env vars |
|:--------------|:-----------------|:---------------|
| Unified (recommended) | `ANTHROPIC_BASE_URL=https://litellm:4000` | None |
| Anthropic pass-through | `ANTHROPIC_BASE_URL=https://litellm:4000/anthropic` | None |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm:4000/bedrock` | `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=https://litellm:4000/vertex_ai/v1` | `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |

### LiteLLM Authentication

| Method | Configuration |
|:-------|:-------------|
| Static API key | `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` (sent as `Authorization` header) |
| Dynamic key helper | `apiKeyHelper` in settings (script that outputs key); refresh via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |

### Enterprise Deployment Options

| Option | Best for | Auth | Billing |
|:-------|:---------|:-----|:--------|
| Claude for Teams | Smaller teams | Claude.ai SSO/email | $150/seat (Premium) + PAYG |
| Claude for Enterprise | Large orgs with compliance needs | SSO, domain capture | Contact Sales |
| Anthropic Console | Individual developers | API key | PAYG |
| Amazon Bedrock | AWS-native deployments | AWS credentials | PAYG through AWS |
| Google Vertex AI | GCP-native deployments | GCP credentials | PAYG through GCP |
| Microsoft Foundry | Azure-native deployments | API key / Entra ID | PAYG through Azure |

### IAM Permissions Summary

| Provider | Required permissions |
|:---------|:--------------------|
| Bedrock | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` |
| Vertex AI | `aiplatform.endpoints.predict` (included in `roles/aiplatform.user`) |
| Foundry | `Microsoft.CognitiveServices/accounts/providers/*` (included in `Azure AI User`) |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- setup, AWS credential methods (CLI, access keys, SSO, Bedrock API keys), credential refresh (awsAuthRefresh, awsCredentialExport), environment variables, model pinning with inference profile IDs and ARNs, modelOverrides for per-version ARN mapping, IAM policy, Guardrails configuration, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- setup, GCP authentication, environment variables, global vs regional endpoints, VERTEX_REGION_* overrides, model pinning, IAM configuration, 1M token context window, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- setup, API key and Entra ID authentication, environment variables, model pinning, Azure RBAC configuration, troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) -- comparing Teams/Enterprise/Console/Bedrock/Vertex/Foundry, proxy and gateway configuration per provider, corporate proxy setup, LLM gateway environment variables, best practices for organizations (documentation, model pinning, security policies, MCP)
- [LLM gateway configuration](references/claude-code-llm-gateway.md) -- gateway API format requirements, model selection, LiteLLM setup (unified and pass-through endpoints), authentication methods (static key, dynamic key helper), provider-specific pass-through configuration

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
