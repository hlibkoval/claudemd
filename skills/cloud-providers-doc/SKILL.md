---
name: cloud-providers-doc
description: Complete documentation for deploying Claude Code through cloud providers and LLM gateways -- Amazon Bedrock (AWS credentials, IAM policy, cross-region inference profiles, model pinning, Guardrails, awsAuthRefresh/awsCredentialExport, modelOverrides, Bedrock API keys, CLAUDE_CODE_USE_BEDROCK), Google Vertex AI (GCP credentials, IAM roles, global/regional endpoints, VERTEX_REGION_* overrides, 1M context window, CLAUDE_CODE_USE_VERTEX, CLOUD_ML_REGION, ANTHROPIC_VERTEX_PROJECT_ID), Microsoft Foundry (Azure credentials, Entra ID, API key auth, RBAC, CLAUDE_CODE_USE_FOUNDRY, ANTHROPIC_FOUNDRY_RESOURCE), enterprise deployment overview (Teams vs Enterprise vs Console vs cloud providers comparison, proxy/gateway config, best practices, CLAUDE.md org-wide, model version pinning), LLM gateway configuration (gateway requirements, API formats Anthropic Messages/Bedrock InvokeModel/Vertex rawPredict, LiteLLM setup, unified endpoint, pass-through endpoints, ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, apiKeyHelper, ANTHROPIC_AUTH_TOKEN). Load when discussing Bedrock setup, Vertex AI setup, Microsoft Foundry setup, Azure AI, cloud provider deployment, third-party integrations for Claude Code, LLM gateway, LiteLLM, proxy configuration, corporate proxy, HTTPS_PROXY, enterprise deployment, model pinning ANTHROPIC_DEFAULT_*_MODEL, cross-region inference, IAM permissions for Claude Code, AWS credentials for Claude Code, GCP credentials for Claude Code, Azure credentials for Claude Code, CLAUDE_CODE_USE_BEDROCK, CLAUDE_CODE_USE_VERTEX, CLAUDE_CODE_USE_FOUNDRY, ANTHROPIC_BASE_URL, ANTHROPIC_BEDROCK_BASE_URL, ANTHROPIC_VERTEX_BASE_URL, apiKeyHelper, ANTHROPIC_AUTH_TOKEN, awsAuthRefresh, awsCredentialExport, or any cloud provider / gateway topic for Claude Code.
user-invocable: false
---

# Cloud Providers & LLM Gateway Documentation

This skill provides the complete official documentation for deploying Claude Code through Amazon Bedrock, Google Vertex AI, Microsoft Foundry, and LLM gateways.

## Quick Reference

### Provider Activation

| Provider | Enable Variable | Required Config |
|:---------|:----------------|:----------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

All three providers disable `/login` and `/logout` commands since authentication is handled through provider credentials.

### Authentication Methods

#### Amazon Bedrock

| Method | Setup |
|:-------|:------|
| AWS CLI | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>` + `AWS_PROFILE` |
| AWS Management Console | `aws login` |
| Bedrock API keys | `AWS_BEARER_TOKEN_BEDROCK` |

**Automatic credential refresh** (in settings file):

| Setting | Purpose |
|:--------|:--------|
| `awsAuthRefresh` | Command that modifies `.aws` directory (e.g., `aws sso login --profile myprofile`). Output shown to user. |
| `awsCredentialExport` | Command that returns JSON with `Credentials.AccessKeyId`, `SecretAccessKey`, `SessionToken`. Output captured silently. |

#### Google Vertex AI

Uses standard Google Cloud authentication (`gcloud auth`). The project ID from `ANTHROPIC_VERTEX_PROJECT_ID` is used automatically. Override with `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or `GOOGLE_APPLICATION_CREDENTIALS`.

#### Microsoft Foundry

| Method | Setup |
|:-------|:------|
| API key | `ANTHROPIC_FOUNDRY_API_KEY` |
| Microsoft Entra ID | Azure SDK default credential chain (falls back when no API key set). Use `az login` locally. |

### Model Pinning

Pin specific model versions to prevent breakage when Anthropic releases new models.

| Variable | Purpose |
|:---------|:--------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus version |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet version |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku version |
| `ANTHROPIC_MODEL` | Override the primary model |

#### Default Models by Provider

| Provider | Primary Model | Small/Fast Model |
|:---------|:--------------|:-----------------|
| Bedrock | `global.anthropic.claude-sonnet-4-6` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI | `claude-sonnet-4-6` | `claude-haiku-4-5@20251001` |

#### Bedrock Model ID Formats

- Cross-region inference profile: `us.anthropic.claude-sonnet-4-6` (with `us.` prefix)
- Application inference profile ARN: `arn:aws:bedrock:<region>:<account-id>:application-inference-profile/<id>`

Use `modelOverrides` in settings to map multiple versions of the same family to distinct application inference profile ARNs, enabling users to switch between them in `/model`.

### Vertex AI Region Configuration

Vertex AI supports both global and regional endpoints. When `CLOUD_ML_REGION=global`, use per-model region overrides for models that do not support global endpoints:

| Variable | Example |
|:---------|:--------|
| `VERTEX_REGION_CLAUDE_3_5_HAIKU` | `us-east5` |
| `VERTEX_REGION_CLAUDE_3_5_SONNET` | `us-east5` |
| `VERTEX_REGION_CLAUDE_3_7_SONNET` | `us-east5` |
| `VERTEX_REGION_CLAUDE_4_0_OPUS` | `europe-west1` |
| `VERTEX_REGION_CLAUDE_4_0_SONNET` | `us-east5` |
| `VERTEX_REGION_CLAUDE_4_1_OPUS` | `europe-west1` |

Vertex AI supports the 1M token context window for Opus 4.6, Sonnet 4.6, Sonnet 4.5, and Sonnet 4. Append `[1m]` to the pinned model ID to enable.

### IAM / RBAC Permissions

| Provider | Required Permissions |
|:---------|:--------------------|
| Bedrock | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile/application-inference-profile/foundation-model resources |
| Vertex AI | `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`) |
| Foundry | `Azure AI User` or `Cognitive Services User` role; custom: `Microsoft.CognitiveServices/accounts/providers/*` dataAction |

### Proxy & Gateway Configuration

| Config Type | Variable | Purpose |
|:------------|:---------|:--------|
| Corporate proxy | `HTTPS_PROXY` / `HTTP_PROXY` | Route traffic through proxy for security/compliance |
| Anthropic API gateway | `ANTHROPIC_BASE_URL` | Override Anthropic Messages endpoint |
| Bedrock gateway | `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| Vertex AI gateway | `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex AI endpoint |
| Skip Bedrock auth | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | When gateway handles AWS auth |
| Skip Vertex auth | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | When gateway handles GCP auth |
| Skip Foundry auth | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` | When gateway handles Azure auth |

Use `/status` to verify proxy and gateway configuration.

### LLM Gateway Requirements

The gateway must expose at least one of these API formats:

| Format | Endpoints | Must Forward |
|:-------|:----------|:-------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

When using the Anthropic Messages format with Bedrock or Vertex, you may need `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

### LiteLLM Configuration

| Endpoint Type | Variable | Value |
|:--------------|:---------|:------|
| Unified (recommended) | `ANTHROPIC_BASE_URL` | `https://litellm-server:4000` |
| Anthropic pass-through | `ANTHROPIC_BASE_URL` | `https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL` | `https://litellm-server:4000/bedrock` (+ `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1`) |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL` | `https://litellm-server:4000/vertex_ai/v1` (+ `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID`) |

**Authentication for gateways:**

| Method | Config |
|:-------|:-------|
| Static API key | `ANTHROPIC_AUTH_TOKEN` env var (sent as `Authorization` header) |
| Dynamic key | `apiKeyHelper` setting pointing to a script; refresh interval via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |

`apiKeyHelper` has lower precedence than `ANTHROPIC_AUTH_TOKEN` or `ANTHROPIC_API_KEY`.

### AWS Guardrails

Configure Amazon Bedrock Guardrails via custom headers in settings:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

Enable Cross-Region inference on the Guardrail if using cross-region inference profiles.

### Enterprise Deployment Comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Bedrock | Vertex AI | Foundry |
|:--------|:------------------------|:------------------|:--------|:----------|:--------|
| Best for | Most organizations | Individual devs | AWS-native | GCP-native | Azure-native |
| Auth | SSO or email | API key | API key / AWS creds | GCP creds | API key / Entra ID |
| Cost tracking | Usage dashboard | Usage dashboard | AWS Cost Explorer | GCP Billing | Azure Cost Management |
| Includes Claude on web | Yes | No | No | No | No |

### Enterprise Best Practices

- Deploy `CLAUDE.md` files organization-wide (e.g., `/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS) and per-repository
- Create a "one click" installation flow for Claude Code
- Start new users with codebase Q&A and smaller tasks before agentic workflows
- Pin model versions for all cloud provider deployments
- Configure managed permissions via security settings
- Set up MCP servers centrally and check `.mcp.json` into the codebase

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- prerequisites, AWS credential setup (CLI, env vars, SSO, console, Bedrock API keys), advanced credential refresh (awsAuthRefresh, awsCredentialExport), enabling Bedrock (CLAUDE_CODE_USE_BEDROCK, AWS_REGION), model pinning (ANTHROPIC_DEFAULT_*_MODEL, inference profile IDs, application inference profile ARNs, modelOverrides for multiple versions), IAM policy (InvokeModel, InvokeModelWithResponseStream, ListInferenceProfiles), AWS Guardrails (custom headers), troubleshooting (region issues, on-demand throughput), Bedrock uses Invoke API not Converse API
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) -- prerequisites, enabling Vertex AI API, requesting model access in Model Garden, GCP authentication, enabling Vertex (CLAUDE_CODE_USE_VERTEX, CLOUD_ML_REGION, ANTHROPIC_VERTEX_PROJECT_ID), global vs regional endpoints, per-model region overrides (VERTEX_REGION_*), model pinning, 1M token context window (append [1m] to model ID), IAM roles (aiplatform.user), troubleshooting (quota, 404 model not found, 429 rate limits)
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- prerequisites, provisioning Foundry resource, Azure credentials (API key via ANTHROPIC_FOUNDRY_API_KEY, Entra ID default credential chain), enabling Foundry (CLAUDE_CODE_USE_FOUNDRY, ANTHROPIC_FOUNDRY_RESOURCE, ANTHROPIC_FOUNDRY_BASE_URL), model pinning, Azure RBAC (Azure AI User, Cognitive Services User, custom role with dataActions), troubleshooting (credential chain errors)
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) -- deployment options comparison table (Teams/Enterprise vs Console vs Bedrock vs Vertex vs Foundry: billing, regions, caching, auth, cost tracking, enterprise features), proxy and gateway configuration (corporate proxy HTTPS_PROXY, LLM gateway per provider with ANTHROPIC_*_BASE_URL and CLAUDE_CODE_SKIP_*_AUTH), best practices (CLAUDE.md deployment, simplified install, guided usage, model pinning, security policies, MCP integrations)
- [LLM gateway configuration](references/claude-code-llm-gateway.md) -- gateway requirements (API formats: Anthropic Messages, Bedrock InvokeModel, Vertex rawPredict; required headers/body fields), model selection with custom names, LiteLLM setup (static API key ANTHROPIC_AUTH_TOKEN, dynamic key apiKeyHelper with CLAUDE_CODE_API_KEY_HELPER_TTL_MS, unified endpoint, provider-specific pass-through endpoints for Anthropic/Bedrock/Vertex)

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
