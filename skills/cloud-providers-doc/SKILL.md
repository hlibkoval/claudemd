---
name: cloud-providers-doc
description: Complete official documentation for running Claude Code through cloud providers — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment overview. Covers setup wizards, environment variables, IAM/RBAC configuration, model pinning, credential refresh, proxy routing, and troubleshooting for each provider.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through cloud providers and third-party infrastructure.

## Quick Reference

### Deployment Options Comparison

| Provider | Best for | Billing | Auth |
| :--- | :--- | :--- | :--- |
| **Claude for Teams/Enterprise** | Most organizations (recommended) | $150/seat or contact sales | Claude.ai SSO or email |
| **Anthropic Console** | Individual developers | PAYG | API key |
| **Amazon Bedrock** | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| **Claude Platform on AWS** | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | API key or AWS credentials |
| **Google Vertex AI** | GCP-native deployments | PAYG through GCP | GCP credentials |
| **Microsoft Foundry** | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

### Enable Variable per Provider

| Provider | Enable variable | Additional required vars |
| :--- | :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Bedrock Mantle | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` |

### Model Pinning Variables (All Providers)

Pin specific model versions when deploying to teams to prevent breakage when Anthropic releases updates.

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override the `opus` alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override the `sonnet` alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override the `haiku` alias |
| `ANTHROPIC_MODEL` | Set the primary model directly |

### Amazon Bedrock

**Setup wizard:** Run `claude`, select "3rd-party platform" → "Amazon Bedrock". Reopen anytime with `/setup-bedrock`.

**Credential options:** AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), SSO profile (`AWS_PROFILE`), or Bedrock API key (`AWS_BEARER_TOKEN_BEDROCK`).

**Credential refresh settings:**

| Setting | When it runs | Use for |
| :--- | :--- | :--- |
| `awsAuthRefresh` | Only when credentials are expired | SSO browser-based flows, modifying `.aws` |
| `awsCredentialExport` | On every credential reload | Cross-account credentials; must output `{"Credentials": {...}}` JSON |

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `AWS_REGION` | Required; not read from `.aws` config |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint (for gateways) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Service tier: `default`, `flex`, or `priority` |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL (billed higher) |

**Default Bedrock models (when not pinned):**

| Type | Default ID |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**IAM required actions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`

**AWS Guardrails:** Set in settings `env` as `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**Bedrock Mantle** (requires v2.1.94+): Uses Anthropic API shape instead of Bedrock Invoke API. Enable with `CLAUDE_CODE_USE_MANTLE=1`. Model IDs use `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Run both with `CLAUDE_CODE_USE_BEDROCK=1` + `CLAUDE_CODE_USE_MANTLE=1`.

| Mantle variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy setups |

**modelOverrides** in settings: Map model version strings to application inference profile ARNs for the `/model` picker.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication and AWS Marketplace billing. Same models/features as direct Claude API.

**Auth options:**
- Option A: SigV4 via standard AWS credential chain (`AWS_PROFILE`, IAM roles, etc.)
- Option B: Workspace API key (`ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx`)

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required; sent as `anthropic-workspace-id` header |
| `AWS_REGION` | Determines base URL: `https://aws-external-anthropic.{region}.api.aws` |
| `ANTHROPIC_AWS_BASE_URL` | Override endpoint URL |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip auth for gateway setups |

**Note:** `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` take precedence; unset them if also set.

**Troubleshoot:** Run `/status` to confirm provider and resolved config. `403` = missing IAM permission or stale API key. Missing workspace error = `ANTHROPIC_AWS_WORKSPACE_ID` not set. Still goes to `api.anthropic.com` = `CLAUDE_CODE_USE_ANTHROPIC_AWS` not truthy.

### Google Vertex AI

**Setup wizard:** Run `claude`, select "3rd-party platform" → "Google Vertex AI" (requires v2.1.98+). Reopen with `/setup-vertex`.

**Auth:** Application Default Credentials (`gcloud auth application-default login`), service account key (`GOOGLE_APPLICATION_CREDENTIALS`), or X.509 certificate-based Workload Identity Federation (v2.1.121+).

**Project ID resolution order:** `GCLOUD_PROJECT` or `GOOGLE_CLOUD_PROJECT` or credential file > `ANTHROPIC_VERTEX_PROJECT_ID` > gcloud config or attached service account.

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`, `us`), or specific region (`us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override when using global endpoint |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override when using global endpoint |
| `gcpAuthRefresh` (settings) | Command to run when GCP credentials expire |

**Default Vertex models (when not pinned):**

| Type | Default ID |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**IAM:** `roles/aiplatform.user` or custom role with `aiplatform.endpoints.predict`.

**Note:** MCP tool search is disabled by default on Vertex AI (endpoint rejects the beta header). Do not set `ENABLE_TOOL_SEARCH=true`.

**1M context window:** Append `[1m]` to a manually pinned model ID, or use the setup wizard.

### Microsoft Foundry

**Auth options:**
- Option A: API key (`ANTHROPIC_FOUNDRY_API_KEY`)
- Option B: Microsoft Entra ID (Azure SDK default credential chain via `az login`)

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Override full base URL |
| `ANTHROPIC_FOUNDRY_API_KEY` | Azure API key |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip auth for gateway setups |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

**RBAC:** Use `Azure AI User` or `Cognitive Services User` roles. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

### LLM Gateway

Gateways must expose at least one API format: Anthropic Messages (`/v1/messages`), Bedrock InvokeModel (`/invoke`), or Vertex rawPredict (`:rawPredict`). Must forward `anthropic-beta` and `anthropic-version` headers.

**Request headers Claude Code sends:**

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent identifier (nested agents) |

**Gateway model discovery** (requires v2.1.129+): Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and populate the `/model` picker. Only applies to Anthropic Messages format with `ANTHROPIC_BASE_URL` set.

**LiteLLM setup:**

| Endpoint type | Configuration |
| :--- | :--- |
| Unified (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Claude API pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL=...`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` |

**Auth for LiteLLM:** Static key via `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization` header), or dynamic key via `apiKeyHelper` in settings with optional TTL via `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Do not use these versions.

### Corporate Proxy Configuration

Set `HTTPS_PROXY` (or `HTTP_PROXY`) to route traffic through a corporate proxy. Works with all providers. To set it alongside a provider:

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
export HTTPS_PROXY='https://proxy.example.com:8080'
```

Use `/status` in Claude Code to verify proxy and gateway configuration is applied correctly.

### Startup Model Checks

Available for Bedrock (v2.1.94+) and Vertex (v2.1.98+). At startup, Claude Code verifies the configured models are accessible. If the pinned model is outdated and a newer one is available, Claude Code prompts to update the pin. If the default model is unavailable, it falls back to the previous version for the session (not persisted).

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock setup wizard, manual config, IAM policy, Mantle endpoint, service tiers, AWS Guardrails, credential refresh, troubleshooting
- [Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace subscription, SigV4 auth, workspace API keys, Agent SDK integration, gateway routing
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex setup wizard, manual config, region configuration, GCP IAM, credential refresh, model pinning, troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, API key and Entra ID auth, RBAC configuration, model pinning
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment comparison table, corporate proxy vs. LLM gateway, best practices for organizations
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements, API formats, LiteLLM configuration, auth methods, gateway model discovery

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
