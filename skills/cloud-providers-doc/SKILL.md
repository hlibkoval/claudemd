---
name: cloud-providers-doc
description: Complete documentation for deploying Claude Code through cloud providers -- Amazon Bedrock, Google Vertex AI, and Microsoft Foundry. Covers setup, authentication (AWS credentials, GCP credentials, Azure API key, Microsoft Entra ID), environment variables (CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY), IAM/RBAC configuration, model version pinning (ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL, ANTHROPIC_MODEL, modelOverrides), region configuration (AWS_REGION, CLOUD_ML_REGION, VERTEX_REGION_CLAUDE_*), credential refresh (awsAuthRefresh, awsCredentialExport), 1M token context window, AWS Guardrails, inference profiles, application inference profile ARNs, LLM gateway configuration (ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL), LiteLLM proxy setup, corporate proxy (HTTPS_PROXY), gateway authentication (ANTHROPIC_AUTH_TOKEN, apiKeyHelper), skip auth flags (CLAUDE_CODE_SKIP_BEDROCK_AUTH, CLAUDE_CODE_SKIP_VERTEX_AUTH, CLAUDE_CODE_SKIP_FOUNDRY_AUTH), enterprise deployment comparison, best practices for organizations (CLAUDE.md, model pinning, security policies, MCP), and troubleshooting. Load when discussing Bedrock, Vertex AI, Microsoft Foundry, cloud provider setup, third-party integrations, LLM gateways, LiteLLM, enterprise deployment, model pinning, cross-region inference, inference profiles, or any cloud-provider-related topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, Microsoft Foundry, and LLM gateways.

## Quick Reference

### Provider Enable Flags

| Provider | Environment Variable | Value |
|:---------|:---------------------|:------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK` | `1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX` | `1` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY` | `1` |

### Region Configuration

| Provider | Variable | Example |
|:---------|:---------|:--------|
| Bedrock | `AWS_REGION` (required) | `us-east-1` |
| Bedrock (small model) | `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | `us-west-2` |
| Vertex AI | `CLOUD_ML_REGION` | `global` |
| Vertex AI (per-model) | `VERTEX_REGION_CLAUDE_*` | `us-east5` |
| Foundry | N/A (set via resource name) | -- |

### Authentication Methods

| Provider | Methods |
|:---------|:--------|
| Bedrock | AWS CLI, env vars (access key), SSO profile, `aws login`, Bedrock API keys (`AWS_BEARER_TOKEN_BEDROCK`) |
| Vertex AI | `gcloud` CLI / Google Cloud default credentials |
| Foundry | API key (`ANTHROPIC_FOUNDRY_API_KEY`) or Microsoft Entra ID (Azure SDK default credential chain) |

### Resource Configuration

| Provider | Variable | Purpose |
|:---------|:---------|:--------|
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | Custom endpoint override |
| Vertex AI | `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID (required) |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | Custom endpoint override |
| Foundry | `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name (required) |
| Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |

### Model Pinning

Pin specific model versions for every deployment to prevent breakage when new models are released.

| Variable | Purpose | Bedrock Example | Vertex AI Example | Foundry Example |
|:---------|:--------|:----------------|:------------------|:----------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opus version | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sonnet version | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Haiku version | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |
| `ANTHROPIC_MODEL` | Override primary model | `global.anthropic.claude-sonnet-4-6` | `claude-opus-4-6` | -- |

**Default models (no pinning):**

| Provider | Primary Model | Small/Fast Model |
|:---------|:-------------|:-----------------|
| Bedrock | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-5@20250929` | `claude-haiku-4-5@20251001` |

**1M context window:** Append `[1m]` to the model ID to enable the extended context window (supported on Opus 4.6, Sonnet 4.6, Sonnet 4.5, Sonnet 4 on Vertex; Opus 4.6 and Sonnet 4.6 on Bedrock).

**Per-version model overrides (Bedrock):** Use `modelOverrides` in settings to map multiple model versions to distinct application inference profile ARNs:

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod"
  }
}
```

### IAM / RBAC Permissions

| Provider | Role / Actions |
|:---------|:---------------|
| Bedrock | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` |
| Vertex AI | `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`) |
| Foundry | `Azure AI User` or `Cognitive Services User` role; custom: `Microsoft.CognitiveServices/accounts/providers/*` |

### AWS Credential Refresh

| Setting | Purpose |
|:--------|:--------|
| `awsAuthRefresh` | Command that modifies `.aws` directory (e.g., `aws sso login --profile myprofile`); output shown to user |
| `awsCredentialExport` | Command that outputs JSON with `Credentials.AccessKeyId`, `SecretAccessKey`, `SessionToken`; output captured silently |

### AWS Guardrails

Set custom headers in settings to enable Bedrock Guardrails:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### LLM Gateway Configuration

Gateways sit between Claude Code and the provider for centralized auth, usage tracking, and routing.

**Base URL variables:**

| Variable | Format |
|:---------|:-------|
| `ANTHROPIC_BASE_URL` | Anthropic Messages API format |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock InvokeModel format |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex rawPredict format |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry format |

**Skip auth flags** (when gateway handles authentication):

| Variable | Provider |
|:---------|:---------|
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Bedrock |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Vertex AI |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Foundry |

**Gateway API requirements:** Must forward `anthropic-beta` and `anthropic-version` headers (Messages/Vertex) or preserve `anthropic_beta`/`anthropic_version` body fields (Bedrock).

**Request headers sent by Claude Code:**

| Header | Description |
|:-------|:------------|
| `X-Claude-Code-Session-Id` | Unique session identifier for aggregating requests |

### LiteLLM Proxy

| Endpoint Type | Configuration |
|:-------------|:--------------|
| Unified (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Claude pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` + `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` + `CLAUDE_CODE_USE_VERTEX=1` |

**Authentication:**
- Static: `ANTHROPIC_AUTH_TOKEN=sk-litellm-static-key`
- Dynamic: `apiKeyHelper` setting pointing to a script; refresh interval via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`

### Enterprise Deployment Comparison

| Feature | Teams/Enterprise | Anthropic Console | Bedrock | Vertex AI | Foundry |
|:--------|:----------------|:------------------|:--------|:----------|:--------|
| Best for | Most orgs | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Per-seat / contact sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO/email | API key | API key / AWS creds | GCP creds | API key / Entra ID |
| Includes Claude on web | Yes | No | No | No | No |

### Corporate Proxy

Route traffic through a corporate proxy by setting `HTTPS_PROXY` or `HTTP_PROXY`:

```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```

### Common Notes

- `/login` and `/logout` are disabled when using any cloud provider (auth is handled externally)
- `DISABLE_PROMPT_CACHING=1` disables prompt caching if needed
- Use `/status` to verify proxy and gateway configuration

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- Setup, AWS credentials, IAM policy, model pinning, inference profiles, guardrails, and troubleshooting for Bedrock
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- Setup, GCP credentials, IAM roles, model pinning, region configuration, and troubleshooting for Vertex AI
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- Setup, Azure credentials, RBAC configuration, model pinning, and troubleshooting for Foundry
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) -- Deployment comparison, proxy/gateway configuration, and organizational best practices
- [LLM gateway configuration](references/claude-code-llm-gateway.md) -- Gateway requirements, API formats, LiteLLM setup, and authentication methods

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
