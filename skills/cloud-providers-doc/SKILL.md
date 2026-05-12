---
name: cloud-providers-doc
description: Complete official documentation for running Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, Claude Platform on AWS, LLM gateways, and enterprise deployment overview.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for configuring Claude Code to run through cloud providers and enterprise infrastructure.

## Quick Reference

### Provider Comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most orgs (recommended) | Individual devs | AWS-native | AWS Marketplace billing + Claude API features | GCP-native | Azure-native |
| Billing | Seat-based / contact sales | PAYG | PAYG via AWS | PAYG via AWS Marketplace | PAYG via GCP | PAYG via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | API key or AWS credentials | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No | No |

### Enable env vars (one per provider)

| Provider | Key env vars |
| :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| Amazon Bedrock Mantle | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_...`, `AWS_REGION=us-east-1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |

Provider priority when multiple are set: Bedrock and Foundry take precedence over Claude Platform on AWS.

### Pin model versions (all cloud providers)

Always pin models before rolling out to a team. Unset `ANTHROPIC_DEFAULT_*` env vars fall back to aliases that resolve to the latest version which may not be enabled in your account yet.

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'         # Vertex/Foundry/Claude-on-AWS
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

For Bedrock use cross-region inference profile IDs:
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

Use `ANTHROPIC_MODEL` to override the primary model; use `modelOverrides` in settings for per-version ARN routing.

1M context: append `[1m]` to a model ID when pinning manually. Supported on Opus 4.7, Opus 4.6, Sonnet 4.6 (Bedrock and Vertex).

### Amazon Bedrock

**Login wizard:** `claude` → 3rd-party platform → Amazon Bedrock. Re-open with `/setup-bedrock`.

**AWS credential options:**

| Option | Command / env var |
| :--- | :--- |
| AWS CLI | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile NAME` + `AWS_PROFILE=NAME` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

**Auto-refresh credentials** — set in settings.json:
```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

Use `awsCredentialExport` (instead of `awsAuthRefresh`) only when you cannot modify `.aws` and must return JSON credentials directly.

**Required IAM actions:**
- `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`
- `aws-marketplace:ViewSubscriptions`, `aws-marketplace:Subscribe` (conditional)

**Bedrock Mantle endpoint** (requires v2.1.94+, uses native Anthropic API shape over AWS creds):
```bash
export CLAUDE_CODE_USE_MANTLE=1
export AWS_REGION=us-east-1
```
Model IDs use `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Run both providers with `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` together. Skip auth for gateways: `CLAUDE_CODE_SKIP_MANTLE_AUTH=1`.

**Mantle env vars:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip SigV4 for proxy/gateway setups |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |

**Service tiers:** `ANTHROPIC_BEDROCK_SERVICE_TIER=default|flex|priority`

**Guardrails:** set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**Startup model checks** (v2.1.94+): verifies model accessibility; prompts to update stale pins; falls back to previous version when latest is unavailable.

### Google Vertex AI

**Login wizard:** `claude` → 3rd-party platform → Google Vertex AI (requires v2.1.98+). Re-open with `/setup-vertex`.

**Prerequisites:** GCP project with Vertex AI API enabled, model access approved in Model Garden (may take 24–48 hours).

**Credential options:** Application Default Credentials (`gcloud auth application-default login`), service account key file (`GOOGLE_APPLICATION_CREDENTIALS`), X.509 certificate-based Workload Identity Federation (v2.1.121+).

**Auto-refresh credentials:**
```json
{
  "gcpAuthRefresh": "gcloud auth application-default login",
  "env": { "ANTHROPIC_VERTEX_PROJECT_ID": "your-project-id" }
}
```

**Region configuration:** set `CLOUD_ML_REGION` to `global`, `eu`, `us`, or a specific region such as `us-east5`. Use `VERTEX_REGION_CLAUDE_*` variables to route specific models to regions that support them when using `CLOUD_ML_REGION=global`.

**Required IAM role:** `roles/aiplatform.user` (grants `aiplatform.endpoints.predict`).

**MCP tool search** is disabled by default on Vertex (endpoint rejects the beta header). Do not set `ENABLE_TOOL_SEARCH=true`.

**Startup model checks** (v2.1.98+): same behavior as Bedrock.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication and AWS Marketplace billing. Same models/features as direct Claude API.

**Authentication options:**
- **SigV4** (AWS credentials): standard credential chain; configure `awsAuthRefresh` for SSO expiry.
- **Workspace API key:** `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` (takes precedence over SigV4; generated in AWS Console under Claude Platform on AWS → API keys).

**Required env vars:**
```bash
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export AWS_REGION=us-east-1
```

Base URL computed as `https://aws-external-anthropic.{region}.api.aws`. Override with `ANTHROPIC_AWS_BASE_URL`.

**Route through a gateway:**
```bash
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export ANTHROPIC_AWS_BASE_URL=https://anthropic-proxy.example.com
export CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1  # if gateway handles SigV4
```

**IAM permissions:** see [IAM action reference](https://platform.claude.com/docs/en/api/claude-platform-on-aws-iam-actions).

**Note:** `/login` and `/logout` are disabled; authentication runs through AWS credentials or workspace API key.

### Microsoft Foundry

**Prerequisites:** Azure subscription with Microsoft Foundry access, RBAC permissions, resource with Claude deployments.

**Authentication options:**
- **API key:** `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` (from Endpoints and keys in portal)
- **Microsoft Entra ID:** automatic via Azure SDK default credential chain when API key is not set; use `az login` locally.

**Required env vars:**
```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}
# Or: export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Required RBAC:** `Azure AI User` or `Cognitive Services User` role (or custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction).

**Note:** `/login` and `/logout` are disabled.

### LLM Gateway

Gateways sit between Claude Code and model providers for centralized auth, usage tracking, cost control, and audit logging.

**Gateway API format requirements (must expose at least one):**
1. Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens` — must forward `anthropic-beta`, `anthropic-version` headers
2. Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream` — must preserve `anthropic_beta`, `anthropic_version` body fields
3. Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` — must forward `anthropic-beta`, `anthropic-version` headers

**Request headers Claude Code sends to gateways:**

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent identifier (subagents only) |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent identifier (nested agents only) |

**Authentication to gateway:**
- Static API key: `ANTHROPIC_AUTH_TOKEN=sk-litellm-static-key`
- Dynamic key helper: `apiKeyHelper` setting + `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`

**LiteLLM endpoint config:**

| Endpoint type | Env vars |
| :--- | :--- |
| Unified (Anthropic format, recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=...` |
| Claude Platform on AWS pass-through | `ANTHROPIC_AWS_BASE_URL=...`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` |

**Gateway model discovery** (Anthropic Messages format only, requires v2.1.129+): set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`. Results cached to `~/.claude/cache/gateway-models.json`.

**Attribution header:** Claude Code prepends an attribution block to system prompts. Omit it with `CLAUDE_CODE_ATTRIBUTION_HEADER=0` if your gateway caches on the full request body.

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with malware. Do not use these versions.

### Proxy configuration

| Provider | Corporate proxy env var | LLM gateway env var |
| :--- | :--- | :--- |
| Amazon Bedrock | `HTTPS_PROXY` | `ANTHROPIC_BEDROCK_BASE_URL` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Google Vertex AI | `HTTPS_PROXY` | `ANTHROPIC_VERTEX_BASE_URL` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `HTTPS_PROXY` | `ANTHROPIC_FOUNDRY_BASE_URL` + `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

Run `/status` inside Claude Code to verify the resolved provider, region, workspace ID, and auth settings.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — setup wizard, manual configuration, AWS credential options, IAM policy, Bedrock Mantle, service tiers, Guardrails, startup model checks, and troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and workspace API key auth, Agent SDK integration, corporate proxy setup, and troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — setup wizard, manual configuration, GCP credentials, region configuration, IAM, startup model checks, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — API key and Entra ID authentication, resource setup, RBAC configuration, and troubleshooting
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — gateway requirements, LiteLLM setup, authentication methods, model discovery, and provider pass-through endpoints
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — provider comparison table, proxy and gateway setup per provider, and best practices for organizations

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
