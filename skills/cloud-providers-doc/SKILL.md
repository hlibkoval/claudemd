---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment options comparison.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for connecting Claude Code to cloud model providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | Individual developers | AWS-native deployments | GCP-native deployments | Azure-native deployments |
| Billing | $150/seat (Teams) or Contact Sales | PAYG | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team mgmt, SSO, usage monitoring | None | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |

---

### Amazon Bedrock

**Enable flag:** `CLAUDE_CODE_USE_BEDROCK=1`

**Quick wizard:** Run `claude`, select **3rd-party platform** → **Amazon Bedrock**. Re-run with `/setup-bedrock`.

**Manual setup env vars:**

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1

# Optional: override region for small/fast model and Mantle
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2

# Optional: custom endpoint
export ANTHROPIC_BEDROCK_BASE_URL=https://...
```

**AWS credential options:**

| Method | How |
| :--- | :--- |
| AWS CLI | `aws configure` |
| Access key | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>` then `AWS_PROFILE=<name>` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

**Auto credential refresh** (for SSO / corporate IdP):

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

Use `awsCredentialExport` when you cannot modify `.aws` — command must print `{"Credentials": {"AccessKeyId": "...", "SecretAccessKey": "...", "SessionToken": "..."}}`.

**Default models (when no pinning):**

| Model type | Default |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**Model pinning env vars:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

**Application inference profile overrides** (multiple versions in `/model` picker):

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

**Service tiers:** `ANTHROPIC_BEDROCK_SERVICE_TIER=default|flex|priority`

**AWS Guardrails:**

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

**Required IAM permissions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`

**1M context window:** Opus 4.7, Opus 4.6, Sonnet 4.6 support it. Append `[1m]` to model ID when pinning manually.

**Mantle endpoint** (native Anthropic API shape via Bedrock):

```bash
export CLAUDE_CODE_USE_MANTLE=1
export AWS_REGION=us-east-1
# Optional: override endpoint
export ANTHROPIC_BEDROCK_MANTLE_BASE_URL=https://...
# For gateway setups that inject AWS auth server-side:
export CLAUDE_CODE_SKIP_MANTLE_AUTH=1
```

Run both Invoke API and Mantle by setting both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1`. Confirm active provider with `/status`.

---

### Google Vertex AI

**Enable flag:** `CLAUDE_CODE_USE_VERTEX=1`

**Quick wizard:** Run `claude`, select **3rd-party platform** → **Google Vertex AI**. Re-run with `/setup-vertex`. Requires Claude Code v2.1.98+.

**Setup steps:**

```bash
gcloud config set project YOUR-PROJECT-ID
gcloud services enable aiplatform.googleapis.com
```

Request Claude model access in [Vertex AI Model Garden](https://console.cloud.google.com/vertex-ai/model-garden) (may take 24-48 hours).

**Manual setup env vars:**

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global        # or "eu", "us", or a specific region like "us-east5"
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID

# Optional: custom endpoint
export ANTHROPIC_VERTEX_BASE_URL=https://...

# Per-model region overrides when using CLOUD_ML_REGION=global
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

**IAM role required:** `roles/aiplatform.user` (grants `aiplatform.endpoints.predict`)

**Default models (when no pinning):**

| Model type | Default |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**Model pinning env vars:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

**Notes:**
- MCP tool search is disabled by default on Vertex; set `ENABLE_TOOL_SEARCH=true` to opt in.
- Prompt caching enabled automatically; disable with `DISABLE_PROMPT_CACHING=1`.
- 1M context: Opus 4.7, Opus 4.6, Sonnet 4.6 supported. Append `[1m]` to model ID.

---

### Microsoft Foundry

**Enable flag:** `CLAUDE_CODE_USE_FOUNDRY=1`

**Setup steps:**
1. Create resource in [Microsoft Foundry portal](https://ai.azure.com/), note resource name.
2. Create Claude Opus, Sonnet, and Haiku deployments.

**Authentication options:**

| Method | How |
| :--- | :--- |
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-key` |
| Microsoft Entra ID | Omit `ANTHROPIC_FOUNDRY_API_KEY`; uses Azure SDK default credential chain (`az login`) |

**Manual setup env vars:**

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource-name
# Or provide a full base URL instead:
export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Model pinning env vars:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

**RBAC:** `Azure AI User` or `Cognitive Services User` roles are sufficient. For custom roles, grant `Microsoft.CognitiveServices/accounts/providers/*` data action.

---

### LLM Gateway Configuration

LLM gateways sit between Claude Code and model providers for centralized auth, usage tracking, cost controls, audit logging, and model routing.

**Gateway API format requirements** — must support at least one of:

| Format | Endpoints | Must forward |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**Request headers Claude Code sends:**

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier for aggregating requests |

Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the system-prompt attribution block if your gateway caches on full request body.

**LiteLLM — unified endpoint (recommended):**

```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
```

**LiteLLM — provider pass-through endpoints:**

```bash
# Bedrock
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_USE_BEDROCK=1

# Vertex AI
export ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=your-project-id
```

**Authentication via gateway:**

| Method | Config |
| :--- | :--- |
| Static key | `ANTHROPIC_AUTH_TOKEN=sk-your-key` |
| Dynamic / rotating key | `apiKeyHelper` setting pointing to a script; set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for TTL |

**Corporate proxy** — set for any provider:

```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```

**Skip client-side auth** (for gateways that inject credentials):

| Provider | Skip variable |
| :--- | :--- |
| Bedrock | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Mantle | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |

**Verify gateway/proxy config:** run `/status` inside Claude Code.

---

### Prompt Caching

Prompt caching is enabled by default on all providers. To request a 1-hour TTL (billed higher than the 5-minute default):

```bash
export ENABLE_PROMPT_CACHING_1H=1
```

To disable caching entirely:

```bash
export DISABLE_PROMPT_CACHING=1
```

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, Bedrock wizard, manual setup, IAM policy, credential refresh, model pinning, startup model checks, service tiers, Guardrails, Mantle endpoint, and troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, Vertex wizard, API setup, region configuration, IAM, model pinning, startup model checks, 1M context, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, resource provisioning, API key vs. Entra ID auth, model pinning, Azure RBAC, and troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment options comparison table, proxy and gateway configuration, and best practices for organizations
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway API format requirements, request headers, LiteLLM setup (unified and pass-through), authentication methods, and provider-specific endpoint config

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
