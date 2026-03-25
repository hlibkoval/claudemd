---
name: cloud-providers-doc
description: Complete documentation for using Claude Code with cloud providers -- Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment options. Covers provider-specific setup (environment variables, credentials, IAM/RBAC configuration, model pinning), proxy and gateway configuration (ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, CLAUDE_CODE_SKIP_BEDROCK_AUTH, CLAUDE_CODE_SKIP_VERTEX_AUTH, CLAUDE_CODE_SKIP_FOUNDRY_AUTH), LiteLLM proxy setup (unified and pass-through endpoints, static and dynamic API key authentication), enterprise deployment comparison (Teams/Enterprise vs Console vs Bedrock vs Vertex vs Foundry -- billing, regions, authentication, cost tracking, enterprise features), credential refresh (awsAuthRefresh, awsCredentialExport), AWS Guardrails, Vertex AI 1M token context window, modelOverrides for per-version inference profile mapping, and organizational best practices. Load when discussing Claude Code with Bedrock, Vertex AI, Microsoft Foundry, Azure, AWS, GCP, cloud provider setup, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, LLM gateway, LiteLLM, ANTHROPIC_BASE_URL, corporate proxy, enterprise deployment, third-party integrations, model pinning for cloud providers, inference profiles, cross-region inference, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL, ANTHROPIC_FOUNDRY_RESOURCE, ANTHROPIC_FOUNDRY_API_KEY, AWS_BEARER_TOKEN_BEDROCK, awsAuthRefresh, awsCredentialExport, Bedrock API keys, Vertex region overrides, CLOUD_ML_REGION, ANTHROPIC_VERTEX_PROJECT_ID, AWS Guardrails, modelOverrides, or any cloud-provider-related topic for Claude Code.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for using Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Authentication |
|:-------|:---------|:--------|:---------------|
| **Claude for Teams/Enterprise** | Most organizations (recommended) | Per-seat + PAYG | Claude.ai SSO or email |
| **Anthropic Console** | Individual developers | PAYG | API key |
| **Amazon Bedrock** | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| **Google Vertex AI** | GCP-native deployments | PAYG through GCP | GCP credentials |
| **Microsoft Foundry** | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

### Provider Enable Variables

| Provider | Enable variable | Required config |
|:---------|:---------------|:----------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

### Credential Configuration by Provider

**Amazon Bedrock** -- uses AWS SDK default credential chain:

| Method | Variable(s) |
|:-------|:------------|
| AWS CLI | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `AWS_PROFILE` (after `aws sso login`) |
| AWS Management Console | `aws login` |
| Bedrock API keys | `AWS_BEARER_TOKEN_BEDROCK` |

**Google Vertex AI** -- uses standard Google Cloud authentication (`gcloud auth`).

**Microsoft Foundry** -- two options:

| Method | Variable |
|:-------|:---------|
| API key | `ANTHROPIC_FOUNDRY_API_KEY` |
| Microsoft Entra ID | Azure SDK default credential chain (auto when no API key set) |

### Credential Refresh (Bedrock)

| Setting | Purpose | Output |
|:--------|:--------|:-------|
| `awsAuthRefresh` | Commands that modify `.aws` directory (e.g., SSO login) | Output displayed to user |
| `awsCredentialExport` | Commands that directly return credentials | Must output JSON with `Credentials.{AccessKeyId, SecretAccessKey, SessionToken}` |

### Model Pinning Variables

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus family version |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet family version |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku family version |
| `ANTHROPIC_MODEL` | Override the primary model |

Pin specific model versions for every deployment to prevent breakage when Anthropic releases new models.

**Default models by provider** (when not pinned):

| Provider | Primary model | Small/fast model |
|:---------|:-------------|:-----------------|
| Bedrock | `global.anthropic.claude-sonnet-4-6` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-6` | `claude-haiku-4-5@20251001` |

**Per-version model overrides** (Bedrock): use the `modelOverrides` setting to map specific model versions to distinct application inference profile ARNs, allowing users to switch between versions in `/model` without bypassing inference profiles.

### Vertex AI Region Overrides

When using `CLOUD_ML_REGION=global`, override the region for specific models that do not support global endpoints:

| Variable | Model |
|:---------|:------|
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | Claude 3.5 Haiku |
| `VERTEX_REGION_CLAUDE_3_5_SONNET` | Claude 3.5 Sonnet |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | Claude 3.7 Sonnet |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | Claude 4.0 Opus |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | Claude 4.0 Sonnet |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | Claude 4.1 Opus |

### Vertex AI 1M Context Window

Append `[1m]` to the pinned model ID to enable the 1M token context window. Supported on Claude Opus 4.6, Sonnet 4.6, Sonnet 4.5, and Sonnet 4.

### AWS Guardrails

Configure via `ANTHROPIC_CUSTOM_HEADERS` in settings:
```
X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id
X-Amzn-Bedrock-GuardrailVersion: 1
```
Enable Cross-Region inference on the Guardrail when using cross-region inference profiles.

### IAM / RBAC Permissions

| Provider | Role / Actions |
|:---------|:---------------|
| **Bedrock** | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile/application-inference-profile/foundation-model resources |
| **Vertex AI** | `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`) |
| **Foundry** | `Azure AI User` or `Cognitive Services User` role; minimum data action: `Microsoft.CognitiveServices/accounts/providers/*` |

### Proxy and Gateway Configuration

| Provider | Gateway base URL variable | Skip-auth variable |
|:---------|:-------------------------|:-------------------|
| Anthropic API | `ANTHROPIC_BASE_URL` | -- |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

Corporate proxy: set `HTTPS_PROXY` or `HTTP_PROXY` environment variables.

### LLM Gateway Requirements

The gateway must expose at least one of these API formats:
- **Anthropic Messages**: `/v1/messages`, `/v1/messages/count_tokens` (forward `anthropic-beta`, `anthropic-version` headers)
- **Bedrock InvokeModel**: `/invoke`, `/invoke-with-response-stream` (preserve `anthropic_beta`, `anthropic_version` body fields)
- **Vertex rawPredict**: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` (forward `anthropic-beta`, `anthropic-version` headers)

### LiteLLM Configuration

| Endpoint type | Variable(s) |
|:-------------|:------------|
| Unified (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |

**Authentication**: set `ANTHROPIC_AUTH_TOKEN` for static keys, or use `apiKeyHelper` in settings for dynamic/rotating keys with optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval.

### Common Troubleshooting

| Issue | Solution |
|:------|:---------|
| Bedrock region issues | Check model availability: `aws bedrock list-inference-profiles --region your-region`; switch region; use inference profiles for cross-region access |
| Bedrock "on-demand throughput isn't supported" | Specify the model as an inference profile ID |
| Vertex "model not found" 404 | Confirm model enabled in Model Garden; verify region access; check global endpoint support |
| Vertex 429 errors | Ensure models supported in region; consider `CLOUD_ML_REGION=global` |
| Foundry auth failure | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- setup with AWS credentials (CLI, env vars, SSO, Bedrock API keys), enabling Bedrock integration, pinning model versions with cross-region inference profiles, modelOverrides for per-version ARN mapping, IAM policy configuration, credential refresh (awsAuthRefresh, awsCredentialExport), AWS Guardrails configuration, troubleshooting region and throughput issues
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- enabling Vertex AI API, requesting model access via Model Garden, GCP authentication, configuring Vertex integration with region and project ID, per-model region overrides for global endpoints, pinning model versions, IAM roles, 1M token context window, troubleshooting quota/404/429 errors
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- provisioning Foundry resources in Azure, API key and Microsoft Entra ID authentication, enabling Foundry integration, pinning model versions, Azure RBAC configuration, troubleshooting credential errors
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) -- comparing deployment options (Teams/Enterprise, Console, Bedrock, Vertex, Foundry) across billing, regions, caching, auth, cost tracking, and enterprise features; proxy and gateway configuration per provider; organizational best practices for documentation, deployment, security, MCP, and model pinning
- [LLM gateway configuration](references/claude-code-llm-gateway.md) -- gateway API format requirements (Anthropic Messages, Bedrock InvokeModel, Vertex rawPredict), model selection with custom gateway names, LiteLLM proxy setup (static API key, dynamic API key with helper, unified endpoint, provider-specific pass-through endpoints for Anthropic/Bedrock/Vertex)

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
