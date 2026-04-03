---
name: cloud-providers-doc
description: Complete documentation for deploying Claude Code through cloud providers -- Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment overview. Covers setup, authentication, IAM/RBAC configuration, model pinning, credential refresh, proxy and gateway configuration, LiteLLM integration, 1M context window, AWS Guardrails, troubleshooting, and deployment best practices. Load when discussing Bedrock, Vertex AI, Foundry, cloud provider setup, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, AWS credentials, GCP credentials, Azure credentials, model pinning, ANTHROPIC_DEFAULT_SONNET_MODEL, ANTHROPIC_DEFAULT_OPUS_MODEL, ANTHROPIC_DEFAULT_HAIKU_MODEL, inference profiles, LLM gateway, LiteLLM, ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL, enterprise deployment, third-party integrations, or any cloud-provider-related topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment options.

## Quick Reference

### Provider Comparison

| Feature | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
|:--------|:--------------|:-----------------|:------------------|
| Enable env var | `CLAUDE_CODE_USE_BEDROCK=1` | `CLAUDE_CODE_USE_VERTEX=1` | `CLAUDE_CODE_USE_FOUNDRY=1` |
| Region env var | `AWS_REGION` | `CLOUD_ML_REGION` | N/A (set via resource) |
| Project/resource | N/A | `ANTHROPIC_VERTEX_PROJECT_ID` | `ANTHROPIC_FOUNDRY_RESOURCE` |
| Base URL override | `ANTHROPIC_BEDROCK_BASE_URL` | `ANTHROPIC_VERTEX_BASE_URL` | `ANTHROPIC_FOUNDRY_BASE_URL` |
| Auth methods | AWS CLI, env vars, SSO, Bedrock API keys | GCP `gcloud` auth | API key, Microsoft Entra ID |
| IAM role/permission | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream` | `roles/aiplatform.user` | `Azure AI User` or `Cognitive Services User` |
| Skip auth for gateway | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| 1M context | Opus 4.6, Sonnet 4.6 | Opus 4.6, Sonnet 4.6, Sonnet 4.5, Sonnet 4 | -- |

### Model Pinning Environment Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_MODEL` | Override primary model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus version |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet version |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku version |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku (Bedrock) |

### Default Models (When Not Pinned)

| Provider | Primary model | Small/fast model |
|:---------|:-------------|:-----------------|
| Bedrock | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-5@20250929` | `claude-haiku-4-5@20251001` |

### Amazon Bedrock Setup

1. Submit use case details in the Bedrock console (one-time per account)
2. Configure AWS credentials (CLI, env vars, SSO, or Bedrock API keys)
3. Set `CLAUDE_CODE_USE_BEDROCK=1` and `AWS_REGION`
4. Pin model versions with `ANTHROPIC_DEFAULT_*_MODEL` env vars

**Credential refresh** -- configure `awsAuthRefresh` (for SSO/browser flows) or `awsCredentialExport` (for direct credential JSON) in settings to auto-refresh expired credentials.

**AWS Guardrails** -- set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**Model overrides** -- use `modelOverrides` in settings to map specific model versions to application inference profile ARNs for the `/model` picker.

### Google Vertex AI Setup

1. Enable Vertex AI API: `gcloud services enable aiplatform.googleapis.com`
2. Request model access in the Vertex AI Model Garden
3. Configure GCP credentials via `gcloud auth`
4. Set `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, and `ANTHROPIC_VERTEX_PROJECT_ID`
5. Pin model versions with `ANTHROPIC_DEFAULT_*_MODEL` env vars

**Regional overrides** -- use `VERTEX_REGION_CLAUDE_*` env vars to route specific models to regions that support them when using `CLOUD_ML_REGION=global`.

### Microsoft Foundry Setup

1. Create a Claude resource in the Microsoft Foundry portal
2. Create deployments for Claude models (Opus, Sonnet, Haiku)
3. Configure auth: API key (`ANTHROPIC_FOUNDRY_API_KEY`) or Microsoft Entra ID (Azure SDK default credential chain)
4. Set `CLAUDE_CODE_USE_FOUNDRY=1` and `ANTHROPIC_FOUNDRY_RESOURCE`
5. Pin model versions with `ANTHROPIC_DEFAULT_*_MODEL` env vars

### LLM Gateway Configuration

| API Format | Endpoints | Required forwarding |
|:-----------|:----------|:-------------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

**Authentication methods for gateways:**
- Static API key: `ANTHROPIC_AUTH_TOKEN`
- Dynamic key helper: `apiKeyHelper` setting + `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`

**LiteLLM endpoints:**
- Unified (recommended): `ANTHROPIC_BASE_URL=https://litellm-server:4000`
- Anthropic pass-through: `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic`
- Bedrock pass-through: `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock`
- Vertex pass-through: `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1`

### Proxy Configuration

| Provider | Proxy env var | Gateway env var |
|:---------|:-------------|:----------------|
| Bedrock | `HTTPS_PROXY` | `ANTHROPIC_BEDROCK_BASE_URL` |
| Vertex AI | `HTTPS_PROXY` | `ANTHROPIC_VERTEX_BASE_URL` |
| Foundry | `HTTPS_PROXY` | `ANTHROPIC_FOUNDRY_BASE_URL` |

### Enterprise Deployment Options

| Option | Best for | Authentication | Billing |
|:-------|:---------|:--------------|:--------|
| Claude for Teams | Small teams, quick start | Claude.ai SSO or email | $150/seat (Premium) + PAYG |
| Claude for Enterprise | Large orgs, compliance | SSO, domain capture | Contact Sales |
| Anthropic Console | Individual developers | API key | PAYG |
| Amazon Bedrock | AWS-native deployments | AWS credentials | PAYG through AWS |
| Google Vertex AI | GCP-native deployments | GCP credentials | PAYG through GCP |
| Microsoft Foundry | Azure-native deployments | API key or Entra ID | PAYG through Azure |

### Common Request Headers

| Header | Description |
|:-------|:-----------|
| `X-Claude-Code-Session-Id` | Unique session identifier for request aggregation |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- Setup, AWS credentials, IAM policy, model pinning, inference profiles, model overrides, Guardrails, 1M context, credential refresh, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- Setup, GCP credentials, IAM roles, model pinning, regional overrides, 1M context, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- Setup, Azure credentials, Entra ID authentication, RBAC configuration, model pinning, troubleshooting
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) -- Deployment comparison, proxy and gateway configuration, organization best practices
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) -- Gateway requirements, API formats, authentication, LiteLLM setup

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
