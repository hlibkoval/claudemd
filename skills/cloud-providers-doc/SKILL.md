---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through cloud providers: Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry, enterprise deployment comparison, and LLM gateway configuration.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
|:--------|:---------------------------|:-----------------|:--------------|:----------------------|:----------------|:-----------------|
| Best for | Most organizations | Individual developers | AWS-native | AWS Marketplace billing with Claude API features | GCP-native | Azure-native |
| Billing | Seat-based / Contact Sales | PAYG | PAYG via AWS | PAYG via AWS Marketplace | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO / email | API key | API key or AWS credentials | API key or AWS credentials | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No | No |
| Enterprise features | Team mgmt, SSO, monitoring | None | IAM, CloudTrail | IAM, CloudTrail | IAM, Cloud Audit Logs | RBAC, Azure Monitor |

### Provider Enable Variables

| Provider | Enable Variable | Required Additional Variables |
|:---------|:---------------|:------------------------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Amazon Bedrock (Mantle endpoint) | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

### Model Pinning Variables (all providers)

| Variable | Default alias resolves to |
|:---------|:--------------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Bedrock/Vertex: Opus 4.6; Foundry: Opus 4.6; Claude Platform on AWS: Opus 4.7 |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Provider's built-in default (lags latest release) |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | On Bedrock/Vertex/Foundry: defaults to primary model (Haiku may not be enabled) |
| `ANTHROPIC_MODEL` | Override the primary model for the session |

Always pin model versions before rolling out to teams. Without pinning, aliases can lag the newest release.

### Amazon Bedrock

**Credential methods:**
- `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN`
- `AWS_PROFILE` (SSO or named profile)
- `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API key — simplest, no full AWS credentials needed)
- IAM role attached to instance/container

**Advanced credential settings (settings.json):**

| Setting | Trigger | Use for |
|:--------|:--------|:--------|
| `awsAuthRefresh` | When credentials are detected as expired | Browser-based SSO flows; modifies `.aws` directory |
| `awsCredentialExport` | Every credential reload (even if valid) | Cross-account credentials not in default provider chain; must output `{"Credentials":{"AccessKeyId","SecretAccessKey","SessionToken"}}` |

**Key Bedrock variables:**

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock |
| `AWS_REGION` | Required; not read from `.aws` config |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `ANTHROPIC_CUSTOM_HEADERS` | Inject headers (e.g. Guardrails) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL (higher cost) |

**IAM permissions required:**
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`
- `bedrock:GetInferenceProfile` (avoids extra round-trip for ARN resolution)
- `aws-marketplace:ViewSubscriptions` + `aws-marketplace:Subscribe` (via Bedrock)

**Bedrock Mantle endpoint** (Claude Code v2.1.94+): Serves Claude through native Anthropic API shape using AWS credentials. Enable with `CLAUDE_CODE_USE_MANTLE=1`. Set both `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_MANTLE` to use both endpoints simultaneously. Use `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` when routing through a gateway.

**1M context window:** Append `[1m]` to a model ID when pinning manually. Also available via `/setup-bedrock` wizard.

**Startup wizard:** Run `claude` and select "3rd-party platform → Amazon Bedrock". Re-run with `/setup-bedrock`.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication. Same models and features as the direct Claude API. Billed through AWS Marketplace.

**Auth options:**

| Option | Variable | Notes |
|:-------|:---------|:------|
| SigV4 (AWS credentials) | Standard AWS credential chain | Set `AWS_PROFILE` or use IAM role |
| Workspace API key | `ANTHROPIC_AWS_API_KEY` | Sent as `x-api-key`; takes precedence over SigV4 |

**Required variables:**
- `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`
- `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01...`
- `AWS_REGION` (base URL computed as `https://aws-external-anthropic.{region}.api.aws`)

**Override base URL:** `ANTHROPIC_AWS_BASE_URL`

**Skip client auth (gateway):** `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`

Note: `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` take precedence over Claude Platform on AWS if also set.

### Google Vertex AI

**Required variables:**
- `CLAUDE_CODE_USE_VERTEX=1`
- `CLOUD_ML_REGION` — `global`, multi-region (`eu`, `us`), or specific region (e.g. `us-east5`)
- `ANTHROPIC_VERTEX_PROJECT_ID` — GCP project ID

**Auth:** Standard Application Default Credentials (`gcloud auth application-default login`), service account key, or X.509 certificate-based Workload Identity Federation. Set `GOOGLE_APPLICATION_CREDENTIALS` for a credential config file.

**Auto credential refresh (settings.json):** `gcpAuthRefresh` — runs when GCP credentials expire. Wizard: run `claude` → "3rd-party platform → Google Vertex AI", or `/setup-vertex` (requires v2.1.98+).

**Per-model region overrides (when `CLOUD_ML_REGION=global`):**
- `VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5`
- `VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1`
- (See env-vars reference for the full list)

**IAM:** `roles/aiplatform.user` includes the required `aiplatform.endpoints.predict` permission.

**1M context window:** Append `[1m]` to model ID. Available via setup wizard.

**MCP tool search:** Disabled by default on Vertex. Enable with `ENABLE_TOOL_SEARCH=true` for Sonnet 4.5+ / Opus 4.5+.

### Microsoft Foundry

**Required variables:**
- `CLAUDE_CODE_USE_FOUNDRY=1`
- `ANTHROPIC_FOUNDRY_RESOURCE={your-resource-name}` (or `ANTHROPIC_FOUNDRY_BASE_URL`)

**Auth options:**
- `ANTHROPIC_FOUNDRY_API_KEY` (API key from Foundry portal → Endpoints and keys)
- Microsoft Entra ID via Azure SDK default credential chain (used when API key is not set; run `az login` locally)

**RBAC:** `Azure AI User` or `Cognitive Services User` roles cover all required permissions.

**Note:** No interactive setup wizard; no startup model check — requests fail if the default model is unavailable. Always pin model versions.

### LLM Gateway Configuration

**Gateway API format requirements** (must implement at least one):
- Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens` — must forward `anthropic-beta`, `anthropic-version` headers
- Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream` — must preserve `anthropic_beta`, `anthropic_version` body fields
- Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` — must forward `anthropic-beta`, `anthropic-version` headers

**Request headers Claude Code sends to gateways:**

| Header | Purpose |
|:-------|:--------|
| `X-Claude-Code-Session-Id` | Unique per-session identifier for aggregating requests |
| `X-Claude-Code-Agent-Id` | Identifies the subagent making the request (present for subagents) |
| `X-Claude-Code-Parent-Agent-Id` | Identifies the spawning agent (present for nested agents) |

**Base URL overrides by provider:**

| Provider | Variable |
|:---------|:---------|
| Anthropic API | `ANTHROPIC_BASE_URL` |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` |
| Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` |

**Skip auth variables (when gateway handles auth):**

| Provider | Variable |
|:---------|:---------|
| Bedrock | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Claude Platform on AWS | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Foundry | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Mantle | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |

**Gateway model discovery** (Anthropic Messages format only, requires v2.1.129+): Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1`. Claude Code queries `/v1/models` at startup and adds results to the `/model` picker. Requires model IDs beginning with `claude` or `anthropic`. Cached to `~/.claude/cache/gateway-models.json`.

**Auth to gateway:** Set `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization` bearer token) or `ANTHROPIC_API_KEY` (sent as `x-api-key`). Use `apiKeyHelper` in settings for dynamic/rotating keys; configure TTL with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

**Attribution header:** Claude Code prepends a short block to the system prompt. Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit it if your gateway caches on the full request body.

### Corporate Proxy

Set `HTTPS_PROXY` or `HTTP_PROXY` environment variables to route traffic through an HTTP/HTTPS proxy. Works alongside any cloud provider. Use `/status` to verify configuration.

### Common Troubleshooting

| Symptom | Fix |
|:--------|:----|
| Bedrock: "on-demand throughput isn't supported" | Use an inference profile ID instead of a foundation model ID |
| Bedrock: region errors | `aws bedrock list-inference-profiles --region <region>`; switch to `us-east-1` |
| Bedrock: SSO browser loop | Remove `awsAuthRefresh` from settings; use `aws sso login` manually before starting Claude Code |
| Bedrock Mantle: `/status` not showing Mantle | Ensure `CLAUDE_CODE_USE_MANTLE` is exported in the shell; set in `env` block of settings.json |
| Bedrock Mantle: `400` naming model ID | That model is not on Mantle; use a Mantle-format ID (`anthropic.claude-*`) or enable both endpoints |
| Claude Platform on AWS: `403` on every request | IAM principal lacks permission; or stale `ANTHROPIC_AWS_API_KEY` — regenerate or unset |
| Claude Platform on AWS: missing-workspace error | `ANTHROPIC_AWS_WORKSPACE_ID` is unset; find it under Workspaces in the AWS Console |
| Claude Platform on AWS: requests still go to api.anthropic.com | `CLAUDE_CODE_USE_ANTHROPIC_AWS` is unset or `CLAUDE_CODE_USE_BEDROCK`/`CLAUDE_CODE_USE_FOUNDRY` override it |
| Vertex: "Could not load the default credentials" | Run `gcloud auth application-default login` or set `GOOGLE_APPLICATION_CREDENTIALS` |
| Vertex: model not found 404 | Confirm model is enabled in Model Garden; check location availability; use `VERTEX_REGION_*` for per-model region overrides |
| Vertex: 429 errors | Ensure primary and small/fast models are supported in the selected region; consider `CLOUD_ML_REGION=global` |
| Foundry: ChainedTokenCredential error | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Setup wizard, manual setup, IAM configuration, credential refresh, model pinning, inference profiles, Guardrails, Mantle endpoint, 1M context, service tiers, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and API key auth, workspace configuration, model pinning, Agent SDK usage, corporate proxy routing, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Setup wizard, manual setup, region configuration, IAM, model pinning, 1M context, MCP tool search, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Provisioning resources, API key and Entra ID auth, model pinning, RBAC configuration, troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Deployment options comparison, proxy and gateway configuration per provider, best practices for organizations
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway requirements, request headers, model discovery, LiteLLM setup, authentication methods, provider-specific pass-through endpoints

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
