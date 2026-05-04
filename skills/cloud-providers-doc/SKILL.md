---
name: cloud-providers-doc
description: Complete official documentation for running Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment options including IAM, model pinning, authentication, and proxy configuration.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for connecting Claude Code to cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Seat-based / Contact Sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS creds | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team mgmt, SSO, monitoring | None | IAM, CloudTrail | IAM, Cloud Audit Logs | RBAC, Azure Monitor |

### Enable a Cloud Provider

```bash
# Amazon Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# Google Vertex AI
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID

# Microsoft Foundry
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource-name
```

Run `claude` and use the login wizard: select **3rd-party platform**, then choose your provider. Or run `/setup-bedrock` / `/setup-vertex` any time to reopen the wizard.

---

## Amazon Bedrock

### Authentication Options

| Option | How |
| :--- | :--- |
| AWS CLI profile | `aws configure` or `export AWS_PROFILE=name` |
| Access key + secret | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO | `aws sso login --profile=<name>` then `export AWS_PROFILE=name` |
| Bedrock API key | `export AWS_BEARER_TOKEN_BEDROCK=your-key` |

### Automatic Credential Refresh (settings file)

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

- `awsAuthRefresh` — runs a command (e.g. browser SSO) when credentials expire; output shown to user
- `awsCredentialExport` — silently returns JSON `{ "Credentials": { "AccessKeyId", "SecretAccessKey", "SessionToken" } }` when `.aws` cannot be modified

### Required Environment Variables

| Variable | Required | Purpose |
| :--- | :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK` | Yes | Enable Bedrock integration (set to `1`) |
| `AWS_REGION` | Yes | AWS region (not read from `.aws` config) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | No | Region override for Haiku-class model |
| `ANTHROPIC_BEDROCK_BASE_URL` | No | Override Bedrock endpoint URL |
| `DISABLE_PROMPT_CACHING` | No | Disable prompt caching (`1`) |
| `ENABLE_PROMPT_CACHING_1H` | No | Request 1-hour cache TTL instead of 5-minute |

### Pin Model Versions (Bedrock)

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

Defaults when not pinned: primary `us.anthropic.claude-sonnet-4-5-20250929-v1:0`, small/fast `us.anthropic.claude-haiku-4-5-20251001-v1:0`.

Use `modelOverrides` in settings to map model versions to application inference profile ARNs:

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Bedrock IAM Policy (minimum)

```json
{
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
      "bedrock:ListInferenceProfiles",
      "bedrock:GetInferenceProfile"
    ],
    "Resource": [
      "arn:aws:bedrock:*:*:inference-profile/*",
      "arn:aws:bedrock:*:*:application-inference-profile/*",
      "arn:aws:bedrock:*:*:foundation-model/*"
    ]
  }]
}
```

### Bedrock-Specific Features

**1M token context window:** Opus 4.7, Opus 4.6, and Sonnet 4.6 support it. Append `[1m]` to a manually pinned model ID to enable.

**Service tiers:**
```bash
export ANTHROPIC_BEDROCK_SERVICE_TIER=priority  # default | flex | priority
```

**AWS Guardrails (content filtering):**
```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

**Mantle endpoint** (native Anthropic API shape over Bedrock):
```bash
export CLAUDE_CODE_USE_MANTLE=1
export AWS_REGION=us-east-1
```

Mantle model IDs use `anthropic.` prefix without version suffix (e.g. `anthropic.claude-haiku-4-5`). Use `CLAUDE_CODE_USE_BEDROCK=1` alongside `CLAUDE_CODE_USE_MANTLE=1` to route requests to both endpoints.

| Mantle Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint (`1` or `true`) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip SigV4 auth (for gateway setups) |

### Bedrock Troubleshooting

- SSO browser loop: remove `awsAuthRefresh` from settings; authenticate manually with `aws sso login`
- Region issues: `aws bedrock list-inference-profiles --region your-region`; use `export AWS_REGION=us-east-1`
- "On-demand throughput isn't supported": use an inference profile ID (with `us.` prefix)
- Claude Code uses Bedrock Invoke API only — Converse API is not supported

---

## Google Vertex AI

### Prerequisites

- GCP project with Vertex AI API enabled
- Claude models enabled in [Vertex AI Model Garden](https://console.cloud.google.com/vertex-ai/model-garden)
- Wizard requires Claude Code v2.1.98+

### Required Environment Variables

| Variable | Required | Purpose |
| :--- | :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX` | Yes | Enable Vertex AI integration (`1`) |
| `CLOUD_ML_REGION` | Yes | `global`, multi-region (`eu`, `us`), or specific region |
| `ANTHROPIC_VERTEX_PROJECT_ID` | Yes | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | No | Override Vertex endpoint URL |
| `DISABLE_PROMPT_CACHING` | No | Disable prompt caching (`1`) |
| `ENABLE_PROMPT_CACHING_1H` | No | Request 1-hour cache TTL |
| `ENABLE_TOOL_SEARCH` | No | Opt in to MCP tool search (disabled by default on Vertex) |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | No | Per-model region override when `CLOUD_ML_REGION=global` |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | No | Per-model region override when `CLOUD_ML_REGION=global` |

### Authentication

Claude Code uses the [Application Default Credentials](https://cloud.google.com/docs/authentication) chain. Supports X.509 certificate-based Workload Identity Federation (Claude Code v2.1.121+) via `GOOGLE_APPLICATION_CREDENTIALS`.

```bash
gcloud auth application-default login
```

### Pin Model Versions (Vertex)

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

Defaults when not pinned: primary `claude-sonnet-4-5@20250929`, small/fast `claude-haiku-4-5@20251001`.

### IAM Configuration

Role `roles/aiplatform.user` provides required permissions:
- `aiplatform.endpoints.predict` — model invocation and token counting

### 1M Token Context Window

Opus 4.7, Opus 4.6, and Sonnet 4.6 support it on Vertex. Append `[1m]` to a manually pinned model ID to enable.

### Vertex Troubleshooting

- Quota issues: [Cloud Console quotas](https://cloud.google.com/docs/quotas/view-manage)
- 404 "model not found": confirm model is Enabled in Model Garden; check region support
- 429 errors: switch to `CLOUD_ML_REGION=global` for better availability
- Models unavailable on `global`: use `VERTEX_REGION_<MODEL_NAME>` per-model region overrides

---

## Microsoft Foundry

### Setup Steps

1. Create resource in [Microsoft Foundry portal](https://ai.azure.com/) (note resource name)
2. Create Claude deployments (Opus, Sonnet, Haiku) within that resource
3. Configure authentication (API key or Entra ID)

### Authentication Options

```bash
# Option A: API key
export ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key

# Option B: Entra ID (when API key not set — uses Azure default credential chain)
az login
```

### Required Environment Variables

| Variable | Required | Purpose |
| :--- | :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY` | Yes | Enable Foundry integration (`1`) |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Yes* | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Yes* | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | No | API key auth (omit for Entra ID) |
| `ENABLE_PROMPT_CACHING_1H` | No | Request 1-hour cache TTL |

*Either `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` is required.

### Pin Model Versions (Foundry)

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

Model IDs must match the deployment names created in the Foundry portal.

### Azure RBAC

Default roles `Azure AI User` and `Cognitive Services User` include all required permissions. Custom role minimum:

```json
{
  "permissions": [{ "dataActions": ["Microsoft.CognitiveServices/accounts/providers/*"] }]
}
```

### Foundry Troubleshooting

- "Failed to get token from azureADTokenProvider": set `ANTHROPIC_FOUNDRY_API_KEY` or configure Entra ID

---

## LLM Gateway Configuration

### Gateway Requirements

The gateway must expose one of:

| API Format | Endpoints | Requirements |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Forward `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Preserve `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Forward `anthropic-beta`, `anthropic-version` headers |

**Note:** When using Anthropic Messages format with a Bedrock or Vertex backend, set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

Claude Code sends `X-Claude-Code-Session-Id` on every request for session aggregation without body parsing.

### Model Discovery

When `ANTHROPIC_BASE_URL` points to a gateway (Anthropic Messages format), Claude Code queries `/v1/models` at startup and adds returned models to the `/model` picker (labeled "From gateway"). Requires Claude Code v2.1.126+. Results cached to `~/.claude/cache/gateway-models.json`.

### LiteLLM Configuration

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware — do not use them.

```bash
# Unified endpoint (recommended)
export ANTHROPIC_BASE_URL=https://litellm-server:4000

# Bedrock pass-through
export CLAUDE_CODE_USE_BEDROCK=1
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1

# Vertex pass-through
export CLAUDE_CODE_USE_VERTEX=1
export ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
export ANTHROPIC_VERTEX_PROJECT_ID=your-project-id
export CLOUD_ML_REGION=us-east5
```

### Authentication to Gateway

```bash
# Static key (sent as Authorization header)
export ANTHROPIC_AUTH_TOKEN=sk-my-gateway-key

# Dynamic key via helper script
# In settings.json:
# { "apiKeyHelper": "~/bin/get-key.sh", ... }
export CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000  # refresh every hour
```

---

## Corporate Proxy Configuration

Combine with any provider by setting proxy environment variables:

```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```

For Foundry with a gateway that injects Azure auth server-side:
```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_BASE_URL='https://your-llm-gateway.com'
export CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1
```

Use `/status` inside Claude Code to verify provider and proxy configuration.

---

## Enterprise Deployment Best Practices

- **Pin model versions** on Bedrock, Vertex, and Foundry before rolling out — aliases like `sonnet` resolve to the latest version which may not yet be enabled in your account
- **Deploy CLAUDE.md files** at org-wide system paths (macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`) and in repository roots
- **Use managed permissions** to lock down what Claude Code can do across all users
- **Use MCP for integrations** — configure `.mcp.json` centrally so all users benefit
- **Create a dedicated cloud account/project** for Claude Code to simplify cost tracking

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — setup wizard, manual configuration, IAM, credential refresh, model pinning, Mantle endpoint, Guardrails, service tiers, 1M context window, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — setup wizard, region configuration, manual setup, IAM, model pinning, 1M context window, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — provisioning, API key and Entra ID auth, model pinning, RBAC, troubleshooting
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — gateway requirements, model discovery, LiteLLM setup, authentication methods
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — deployment option comparison, proxy and gateway configuration per provider, enterprise best practices

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
