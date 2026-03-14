---
name: cloud-providers-doc
description: Complete documentation for using Claude Code with cloud providers and enterprise deployments -- Amazon Bedrock (setup, AWS credentials, IAM policy, Guardrails, inference profiles, model pinning, credential refresh), Google Vertex AI (setup, GCP credentials, IAM roles, global/regional endpoints, 1M context window, region overrides), Microsoft Foundry (setup, API key and Entra ID auth, Azure RBAC, resource configuration), enterprise deployment overview (comparing deployment options -- Teams/Enterprise/Console/Bedrock/Vertex/Foundry, billing, regions, authentication, cost tracking, enterprise features, best practices, CLAUDE.md for orgs, model version pinning), LLM gateway configuration (gateway requirements, API format compatibility -- Anthropic Messages/Bedrock InvokeModel/Vertex rawPredict, LiteLLM setup with static/dynamic API keys, unified and pass-through endpoints, provider-specific gateway routing), proxy configuration (HTTPS_PROXY, corporate proxy for Bedrock/Vertex/Foundry). Load when discussing Claude Code with AWS Bedrock, Google Vertex AI, Microsoft Foundry, Azure AI, cloud provider setup, enterprise deployment, LLM gateways, LiteLLM proxy, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, ANTHROPIC_FOUNDRY_BASE_URL, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, model pinning for cloud providers, inference profiles, cross-region inference, third-party integrations, corporate proxy configuration, API key helpers, ANTHROPIC_AUTH_TOKEN, apiKeyHelper, or deploying Claude Code across an organization.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for using Claude Code with cloud providers (Amazon Bedrock, Google Vertex AI, Microsoft Foundry), enterprise deployment options, and LLM gateway configuration.

## Quick Reference

### Provider Enable Flags

| Provider | Enable Variable | Required Config |
|:---------|:---------------|:----------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

When any cloud provider is enabled, `/login` and `/logout` are disabled -- authentication is handled through the provider's credential system.

### Authentication Methods

| Provider | Methods |
|:---------|:--------|
| Bedrock | AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`/`AWS_SESSION_TOKEN`), SSO profile (`AWS_PROFILE`), `aws login`, Bedrock API key (`AWS_BEARER_TOKEN_BEDROCK`) |
| Vertex AI | Google Cloud SDK (`gcloud`), application default credentials, `GOOGLE_APPLICATION_CREDENTIALS` |
| Foundry | API key (`ANTHROPIC_FOUNDRY_API_KEY`), Microsoft Entra ID (Azure SDK default credential chain via `az login`) |

### Model Pinning (All Providers)

Pin specific model versions to prevent breakage when Anthropic releases new models:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='<provider-specific-model-id>'
export ANTHROPIC_DEFAULT_SONNET_MODEL='<provider-specific-model-id>'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='<provider-specific-model-id>'
```

| Variable | Bedrock ID | Vertex AI ID | Foundry ID |
|:---------|:-----------|:-------------|:-----------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-6-v1` | `claude-opus-4-6` | `claude-opus-4-6` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |

Override specific models with `ANTHROPIC_MODEL` and `ANTHROPIC_SMALL_FAST_MODEL`. Use `modelOverrides` in settings to map individual model versions to specific inference profile ARNs.

### IAM / RBAC Requirements

| Provider | Required Permissions |
|:---------|:--------------------|
| Bedrock | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile/application-inference-profile/foundation-model resources |
| Vertex AI | `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`) |
| Foundry | `Azure AI User` or `Cognitive Services User` role (or custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction) |

### Credential Refresh (Bedrock)

Configure automatic credential refresh in settings:

| Setting | Purpose |
|:--------|:--------|
| `awsAuthRefresh` | Command that modifies `.aws` directory (e.g., `aws sso login --profile myprofile`). Output shown to user. |
| `awsCredentialExport` | Command that returns credentials as JSON. Output captured silently. Must return `{"Credentials": {"AccessKeyId", "SecretAccessKey", "SessionToken"}}`. |

### Vertex AI Region Overrides

When using `CLOUD_ML_REGION=global`, override regions for specific models that do not support the global endpoint:

| Variable | Model |
|:---------|:------|
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | Claude 3.5 Haiku |
| `VERTEX_REGION_CLAUDE_3_5_SONNET` | Claude 3.5 Sonnet |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | Claude 3.7 Sonnet |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | Claude 4.0 Opus |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | Claude 4.0 Sonnet |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | Claude 4.1 Opus |

Vertex AI supports 1M token context windows for Opus 4.6, Sonnet 4.6, Sonnet 4.5, and Sonnet 4 -- append `[1m]` to the model ID.

### Bedrock Guardrails

Set custom headers in settings to enable Amazon Bedrock Guardrails content filtering:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

Enable Cross-Region inference on the Guardrail if using cross-region inference profiles.

### Enterprise Deployment Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
|:--------|:---------------------------|:-----------------|:--------------|:----------------|:-----------------|
| Best for | Most organizations | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Per-seat / Contact Sales | PAYG | PAYG (AWS) | PAYG (GCP) | PAYG (Azure) |
| Auth | Claude.ai SSO/email | API key | API key / AWS creds | GCP creds | API key / Entra ID |
| Cost tracking | Usage dashboard | Usage dashboard | AWS Cost Explorer | GCP Billing | Azure Cost Mgmt |
| Includes web Claude | Yes | No | No | No | No |

### LLM Gateway Configuration

Gateways sit between Claude Code and the provider to handle auth, routing, usage tracking, and cost controls.

**Base URL variables:**

| Provider | Gateway URL Variable | Skip Auth Variable |
|:---------|:--------------------|:-------------------|
| Anthropic API | `ANTHROPIC_BASE_URL` | -- |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

**Gateway API format requirements** -- the gateway must expose at least one of:
- Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens` (forward `anthropic-beta`, `anthropic-version` headers)
- Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream` (preserve `anthropic_beta`, `anthropic_version` body fields)
- Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` (forward `anthropic-beta`, `anthropic-version` headers)

**Gateway authentication:**

| Method | Variable | Notes |
|:-------|:---------|:------|
| Static API key | `ANTHROPIC_AUTH_TOKEN` | Sent as `Authorization` header |
| Dynamic key helper | `apiKeyHelper` setting | Script that outputs a key; refresh interval via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |

`apiKeyHelper` has lower precedence than `ANTHROPIC_AUTH_TOKEN` or `ANTHROPIC_API_KEY`.

### Corporate Proxy

Route traffic through a corporate proxy by setting `HTTPS_PROXY` (or `HTTP_PROXY`) alongside the provider-specific variables. Works with all providers.

### Troubleshooting Quick Reference

| Provider | Issue | Solution |
|:---------|:------|:---------|
| Bedrock | Region errors | `aws bedrock list-inference-profiles --region your-region`, switch region, or use inference profiles |
| Bedrock | "on-demand throughput isn't supported" | Specify model as an inference profile ID |
| Vertex AI | 404 "model not found" | Confirm model enabled in Model Garden; check global endpoint support; use `VERTEX_REGION_*` overrides |
| Vertex AI | 429 rate limit | Ensure models supported in region; try `CLOUD_ML_REGION=global` |
| Foundry | "ChainedTokenCredential authentication failed" | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- prerequisites, AWS credential options (CLI/env vars/SSO/Bedrock API keys), credential refresh (awsAuthRefresh/awsCredentialExport), environment variables, model pinning with inference profiles and modelOverrides, IAM policy, Guardrails configuration, troubleshooting
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) -- prerequisites, enabling Vertex AI API, requesting model access, GCP authentication, environment variables, global vs regional endpoints with per-model region overrides, model pinning, IAM configuration, 1M token context window, troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- prerequisites, provisioning Foundry resource, API key and Entra ID authentication, environment variables, model pinning, Azure RBAC configuration, troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) -- comparing deployment options (Teams/Enterprise/Console/Bedrock/Vertex/Foundry), proxy and gateway configuration per provider, best practices for organizations (documentation, deployment, security, MCP, model pinning)
- [LLM gateway configuration](references/claude-code-llm-gateway.md) -- gateway requirements and API format compatibility, model selection, LiteLLM setup (static API key, dynamic key helper, unified endpoint, provider-specific pass-through endpoints for Anthropic/Bedrock/Vertex)

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
