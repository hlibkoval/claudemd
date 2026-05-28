---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Option | Best For | Auth | Billing | Enable Variable |
|:-------|:---------|:-----|:--------|:----------------|
| Claude for Teams/Enterprise | Most organizations (recommended) | Claude.ai SSO | Per-seat or enterprise | N/A (direct) |
| Anthropic Console | Individual developers | API key | PAYG | N/A (default) |
| Amazon Bedrock | AWS-native deployments | API key or AWS credentials | PAYG through AWS | `CLAUDE_CODE_USE_BEDROCK=1` |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | API key or AWS credentials (SigV4) | PAYG through AWS Marketplace | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` |
| Google Vertex AI | GCP-native deployments | GCP credentials | PAYG through GCP | `CLAUDE_CODE_USE_VERTEX=1` |
| Microsoft Foundry | Azure-native deployments | API key or Microsoft Entra ID | PAYG through Azure | `CLAUDE_CODE_USE_FOUNDRY=1` |

### Amazon Bedrock

**Required environment variables:**
```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

**Authentication options:**
- `aws configure` (AWS CLI)
- `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN`
- `AWS_PROFILE` (SSO profile)
- `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API key)

**Interactive setup:** Run `claude`, select "3rd-party platform" → "Amazon Bedrock". Re-run wizard anytime with `/setup-bedrock`.

**Key Bedrock-specific variables:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock |
| `AWS_REGION` | Required; not read from `.aws` config |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override endpoint or gateway URL |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for small/fast model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint (v2.1.94+) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for gateway setups |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip AWS auth (gateway handles it) |

**Credential refresh settings (in settings file):**
- `awsAuthRefresh`: command to refresh AWS credentials (runs on expiry)
- `awsCredentialExport`: command that outputs credentials JSON (runs on each reload)

**IAM permissions required:**
- `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`
- `aws-marketplace:ViewSubscriptions`, `aws-marketplace:Subscribe`

**Pinning model versions (recommended for team deployments):**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

Default if no pinning: `us.anthropic.claude-sonnet-4-5-20250929-v1:0` for both primary and small/fast model.

**Mantle endpoint** (v2.1.94+): Serves Claude via native Anthropic API shape using same AWS credentials. Model IDs use `anthropic.` prefix (e.g. `anthropic.claude-haiku-4-5`). Run alongside Invoke API by setting both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1`.

**AWS Guardrails** via `ANTHROPIC_CUSTOM_HEADERS`:
```json
{ "env": { "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: id\nX-Amzn-Bedrock-GuardrailVersion: 1" } }
```

**1M token context window:** Supported for Opus 4.7, Opus 4.6, Sonnet 4.6. Append `[1m]` to model ID for manual pin. Wizard offers 1M option.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS auth, IAM access control, and AWS Marketplace billing. Same models and release schedule as direct Claude API.

**Required environment variables:**
```bash
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export AWS_REGION=us-east-1
```

**Authentication options:**
- Option A: AWS credentials with SigV4 (standard AWS credential chain; use `awsAuthRefresh` for SSO expiry)
- Option B: `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` (takes precedence over SigV4)

**Key variables:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_ANTHROPIC_AWS` | Enable provider (opt-in; Bedrock/Foundry take precedence if set) |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required workspace ID (sent as `anthropic-workspace-id` header) |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (alternative to SigV4) |
| `ANTHROPIC_AWS_BASE_URL` | Override endpoint URL |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip SigV4 signing (for gateway that handles auth) |

Model IDs are the same as direct Claude API (e.g. `claude-opus-4-7`, `claude-sonnet-4-6`). Bedrock and Foundry take precedence over Claude Platform on AWS if also set.

### Google Vertex AI

**Required environment variables:**
```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global   # or 'eu', 'us', or specific region like 'us-east5'
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

**Interactive setup:** Run `claude`, select "3rd-party platform" → "Google Vertex AI" (requires v2.1.98+). Re-run with `/setup-vertex`.

**Key Vertex-specific variables:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex AI |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`/`us`), or specific region |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint URL |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth (for gateway) |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override when using global endpoint |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override when using global endpoint |
| `ENABLE_TOOL_SEARCH` | Enable MCP tool search (Sonnet 4.5+ and Opus 4.5+ only) |

**Credential refresh:** `gcpAuthRefresh` setting in settings file (e.g. `gcloud auth application-default login`). Also supports X.509 certificate-based Workload Identity Federation via `GOOGLE_APPLICATION_CREDENTIALS`.

**IAM:** `roles/aiplatform.user` or custom role with `aiplatform.endpoints.predict`.

**Pinning model versions:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

Default if no pinning: `claude-sonnet-4-5@20250929` for both primary and small/fast model.

**1M token context window:** Supported for Opus 4.7, Opus 4.6, Sonnet 4.6. Append `[1m]` to model ID.

**MCP tool search:** Disabled by default on Vertex AI. Set `ENABLE_TOOL_SEARCH=true` to enable (Sonnet 4.5+ and Opus 4.5+ only).

### Microsoft Foundry

**Required environment variables:**
```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}
# Or: export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Authentication options:**
- Option A: `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` (from Endpoints and keys in portal)
- Option B: Microsoft Entra ID via Azure SDK default credential chain (`az login`)

**Key variables:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Override endpoint URL |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth (for gateway) |

No interactive wizard — configure via environment variables only.

**RBAC:** `Azure AI User` or `Cognitive Services User` role, or custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

**Pinning model versions:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

Default if no pinning: primary model; Haiku defaults to primary because not every account has a Haiku deployment.

### LLM Gateway

A gateway must expose at least one of these API formats:

| Format | Endpoints | Must forward |
|:-------|:----------|:-------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**Request headers Claude Code sends to gateways:**

| Header | Description |
|:-------|:------------|
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier (when present) |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent ID for nested agents |

**Gateway configuration variables by provider:**

| Provider | Base URL variable | Auth-skip variable |
|:---------|:------------------|:-------------------|
| Anthropic Messages | `ANTHROPIC_BASE_URL` | — |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Mantle | `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |

**Gateway model discovery** (Anthropic Messages format only, v2.1.129+): Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and populate the `/model` picker. Results cached to `~/.claude/cache/gateway-models.json`.

**LiteLLM authentication:**
- Static key: `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` (sent as `Authorization` header)
- Dynamic key: `apiKeyHelper` setting pointing to a script; `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` sets refresh interval
- Lower precedence than `ANTHROPIC_AUTH_TOKEN` or `ANTHROPIC_API_KEY`

**Attribution header:** Claude Code prepends a short block to the system prompt for attribution. Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit it (useful when gateway implements its own prompt cache keyed on full request body).

### Common Prompt Caching Variables

| Variable | Effect |
|:---------|:-------|
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour TTL instead of 5-minute default (billed at higher rate) |

### Startup Model Checks (Bedrock and Vertex AI)

On startup, Claude Code (v2.1.94+ for Bedrock, v2.1.98+ for Vertex) verifies models are accessible:
- If pinned model is older than current default and newer is available: prompts to update pin
- If no pin and current default is unavailable: falls back to previous version for session (not persisted)

### Corporate Proxy

Route traffic through `HTTPS_PROXY` or `HTTP_PROXY` environment variables. Works alongside any provider. See [Enterprise network configuration](/en/network-config).

Use `/status` inside Claude Code to verify resolved provider, workspace ID, region, and base URL overrides.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Setup wizard, manual config, IAM, Mantle endpoint, Guardrails, 1M context, service tiers, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace billing + Anthropic API features, SigV4 and API key auth, proxy routing
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Setup wizard, GCP credentials, region config, IAM, 1M context, MCP tool search
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure setup, Entra ID and API key auth, RBAC, model pinning
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — Deployment comparison table, proxy/gateway config examples, best practices
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, LiteLLM setup, provider pass-through endpoints, model discovery

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
