---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through third-party cloud providers and LLM gateways, including Amazon Bedrock, Google Vertex AI, Microsoft Foundry, Claude Platform on AWS, and LiteLLM-compatible gateways.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations | Individual developers | AWS-native | AWS Marketplace billing + Claude API features | GCP-native | Azure-native |
| Billing | Per-seat or contact sales | PAYG | PAYG via AWS | PAYG via AWS Marketplace | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO | API key | API key or AWS credentials | API key or AWS SigV4 | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No | No |
| Enterprise features | SSO, team mgmt, usage monitoring | None | IAM, CloudTrail | IAM, CloudTrail | IAM, Cloud Audit Logs | RBAC, Azure Monitor |

### Enable Variables by Provider

| Provider | Required env vars |
| :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION` |
| Bedrock Mantle endpoint | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` |

### Model Pinning Variables (all providers)

| Variable | Alias it pins |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | `fable` |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `opus` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `sonnet` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `haiku` |
| `ANTHROPIC_MODEL` | Primary model override |

**Always pin model versions for multi-user deployments.** Without pinning, aliases resolve to Claude Code's built-in default per provider, which can lag new releases or be unavailable in your account.

### Amazon Bedrock

**Setup wizard:** `claude` → login → 3rd-party platform → Amazon Bedrock. Reopen with `/setup-bedrock`.

**Credential options (manual setup):**

| Option | Method |
| :--- | :--- |
| A | `aws configure` (AWS CLI) |
| B | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN` |
| C | `aws sso login --profile=<name>` + `AWS_PROFILE` |
| D | `aws login` (AWS Management Console) |
| E | `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API key) |

**Credential refresh settings:**

| Setting | Trigger | Use for |
| :--- | :--- | :--- |
| `awsAuthRefresh` | On expired/failed credentials | SSO browser flows; modifies `.aws` directory |
| `awsCredentialExport` | On every credential load | Cross-account credentials; outputs JSON with `Credentials.AccessKeyId/SecretAccessKey/SessionToken/Expiration` |

**Bedrock-specific env vars:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | AWS region for Haiku-class model |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL (billed at higher rate) |

**Bedrock Mantle endpoint vars:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth (for gateway setups) |

**modelOverrides:** Map model version names to application inference profile ARNs in your settings file to let users switch between versions in `/model`.

**IAM permissions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`.

**Notes:**
- Region resolution order: `AWS_REGION` → `AWS_DEFAULT_REGION` → active AWS profile → `us-east-1`
- `/logout` is unavailable on Bedrock (auth is via AWS credentials)
- WebSearch tool is not available on Bedrock
- Opus 4.6+ and Sonnet 4.6 support the 1M token context window; append `[1m]` to model IDs to enable
- GovCloud regions: use the `us-gov.` prefix on inference profile IDs

### Google Vertex AI

**Setup wizard:** `claude` → login → 3rd-party platform → Google Vertex AI (requires v2.1.98+). Reopen with `/setup-vertex`.

**Credential refresh:** `gcpAuthRefresh` setting runs when credentials are expired. Times out after 3 minutes.

**Region options:** `CLOUD_ML_REGION=global`, multi-region (`eu`, `us`), or specific region (`us-east5`).

**Per-model region overrides:** `VERTEX_REGION_CLAUDE_<MODEL_NAME>` for models that don't support global endpoints.

**Vertex-specific env vars:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID (lower precedence than `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, `GOOGLE_APPLICATION_CREDENTIALS`) |
| `ENABLE_TOOL_SEARCH` | Enable MCP tool search (Sonnet 4.5+ and Opus 4.5+ only) |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |

**IAM:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

**Notes:**
- MCP tool search is disabled by default on Vertex AI; set `ENABLE_TOOL_SEARCH=true` for Sonnet 4.5+ and Opus 4.5+
- Opus 4.6+ and Sonnet 4.6 support the 1M token context window; append `[1m]` to model IDs to enable
- `/logout` is unavailable on Vertex AI

### Microsoft Foundry

**No setup wizard.** Configure entirely via environment variables.

**Auth options:** `ANTHROPIC_FOUNDRY_API_KEY` (API key) or Microsoft Entra ID default credential chain (when key not set).

**RBAC roles:** `Azure AI User` or `Cognitive Services User` (or a custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataActions).

**Notes:**
- No startup model check on Foundry — requests fail immediately if model is unavailable. Always pin model versions.
- `/logout` is unavailable on Foundry.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication and AWS Marketplace billing. Same models and features as the direct Claude API.

**Auth options:**

| Option | How |
| :--- | :--- |
| SigV4 | Standard AWS credential chain; configure `awsAuthRefresh` for SSO expiry |
| Workspace API key | `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` — takes precedence over SigV4 |

**Required env vars:** `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION`.

**Base URL:** computed as `https://aws-external-anthropic.{region}.api.aws`. Override with `ANTHROPIC_AWS_BASE_URL`.

**Notes:**
- `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` take precedence over Claude Platform on AWS if set. Unset them.
- AWS Marketplace subscription creates a new Anthropic organization separate from any pre-existing Claude Console account.
- `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` skips SigV4 signing (for gateways that sign themselves).
- Agent SDK: set the same env vars before calling `query()`.

### LLM Gateway Configuration

**Required API formats** (gateway must expose at least one):

| Format | Endpoints |
| :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` — must forward `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` — must preserve `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` — must forward `anthropic-beta`, `anthropic-version` headers |

**Gateway request headers Claude Code sends:**

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Aggregate all requests from a session |
| `X-Claude-Code-Agent-Id` | Attribute cost to individual parallel subagents |
| `X-Claude-Code-Parent-Agent-Id` | Attribute cost across nested agents |

**Gateway model discovery:** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup (Anthropic Messages format only; requires v2.1.129+). Results cached to `~/.claude/cache/gateway-models.json`.

**Auth to gateway:**

| Setting | Usage |
| :--- | :--- |
| `ANTHROPIC_AUTH_TOKEN` | Sent as `Authorization` bearer token |
| `ANTHROPIC_API_KEY` | Sent as `x-api-key` header when no auth token set |
| `apiKeyHelper` | Shell script returning a dynamic key; configure `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval |
| `ANTHROPIC_CUSTOM_HEADERS` | Additional headers appended to every request |

**Base URL overrides per provider:**

| Variable | Provider |
| :--- | :--- |
| `ANTHROPIC_BASE_URL` | Direct Claude API / Anthropic Messages format |
| `ANTHROPIC_BEDROCK_BASE_URL` | Amazon Bedrock |
| `ANTHROPIC_VERTEX_BASE_URL` | Google Vertex AI |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Microsoft Foundry |
| `ANTHROPIC_AWS_BASE_URL` | Claude Platform on AWS |

**Skip auth vars** (when gateway handles auth):

| Variable | Provider |
| :--- | :--- |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Bedrock |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Vertex AI |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Foundry |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Claude Platform on AWS |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Bedrock Mantle |

**Attribution header:** Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the attribution block prepended to system prompts (helps gateway prompt caching keyed on full request body).

**LiteLLM warning:** PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Do not install them.

### Proxy Configuration

| Proxy type | Variable | When to use |
| :--- | :--- | :--- |
| Corporate HTTP/HTTPS proxy | `HTTPS_PROXY` or `HTTP_PROXY` | Route all outbound traffic through org proxy |
| LLM gateway | Provider-specific `*_BASE_URL` | Centralized auth, usage tracking, rate limits |

Use `/status` to verify resolved provider, region, and gateway configuration.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock setup wizard, manual setup, IAM policy, credential refresh, model pinning, Mantle endpoint, Guardrails, 1M context, service tiers, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace subscription, SigV4 and API key auth, workspace config, Agent SDK usage, proxy routing
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex setup wizard, credential chain, region config, model pinning, IAM, 1M context, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, API key and Entra ID auth, model pinning, RBAC, troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Deployment option comparison table, proxy and gateway overview, organization best practices
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, request headers, model discovery, LiteLLM setup, auth methods, provider-specific pass-through endpoints

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
