---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers and LLM gateways — Amazon Bedrock (setup wizard, IAM, Mantle endpoint, Guardrails, service tiers, 1M context), Claude Platform on AWS (SigV4 and workspace API key auth, AWS Marketplace billing), Google Vertex AI (global/multi-region endpoints, gcpAuthRefresh, model pinning), Microsoft Foundry (Entra ID and API key auth, RBAC), LLM gateway configuration (requirements, LiteLLM, gateway model discovery, pass-through endpoints), and enterprise deployment overview (compare options, proxy/gateway setup, best practices).
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers, LLM gateways, and enterprise configurations.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Auth |
| :--- | :--- | :--- | :--- |
| Claude for Teams/Enterprise | Most organizations (recommended) | Seat-based or contact sales | Claude.ai SSO or email |
| Anthropic Console | Individual developers | PAYG | API key |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | AWS SigV4 or workspace API key |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

All options include prompt caching enabled by default. Only Teams/Enterprise includes Claude on the web.

### Enable Environment Variable (per provider)

| Provider | Enable variable | Required additional vars |
| :--- | :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Bedrock Mantle | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` (or `ANTHROPIC_FOUNDRY_BASE_URL`) |

### Model Pinning (all third-party providers)

Pin model versions for team deployments to prevent breakage when Anthropic releases updates. Without pinning, aliases resolve to the latest version which may not yet be enabled in your account.

| Variable | Bedrock example | Vertex example | Foundry/AWS example |
| :--- | :--- | :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-7` | `claude-opus-4-7` | `claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |

On Bedrock and Vertex AI, the small/fast model (Haiku) defaults to the primary model if not explicitly pinned (Haiku may not be enabled in every account/region).

Append `[1m]` to any Opus 4.7, Opus 4.6, or Sonnet 4.6 model ID to enable the 1M token context window (supported on all three cloud providers).

### Amazon Bedrock Setup

**Wizard (interactive):** Run `claude`, select "3rd-party platform" → "Amazon Bedrock". Re-run with `/setup-bedrock`.

**Manual credential options:**
- AWS CLI: `aws configure`
- Access key env vars: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
- SSO profile: `aws sso login --profile <name>` + `AWS_PROFILE=<name>`
- Bedrock API key: `AWS_BEARER_TOKEN_BEDROCK=<key>`

**Auto credential refresh:**
- `awsAuthRefresh`: runs when credentials expire (browser SSO flows)
- `awsCredentialExport`: runs at session start and on each reload, must output JSON with `Credentials.{AccessKeyId, SecretAccessKey, SessionToken}`

**Bedrock-specific vars:**
- `ANTHROPIC_BEDROCK_BASE_URL` — override endpoint URL
- `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` — separate region for Haiku-class model
- `ANTHROPIC_BEDROCK_SERVICE_TIER` — `default`, `flex`, or `priority`
- `ANTHROPIC_CUSTOM_HEADERS` — inject Guardrail headers (newline-separated)
- `DISABLE_PROMPT_CACHING=1` — disable caching; `ENABLE_PROMPT_CACHING_1H=1` — 1-hour TTL

**IAM permissions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`

**modelOverrides** (settings file): map model versions to application inference profile ARNs for the `/model` picker.

### Bedrock Mantle Endpoint

Mantle serves Claude via the native Anthropic API shape (not Bedrock Invoke API). Requires Claude Code v2.1.94+.

```
CLAUDE_CODE_USE_MANTLE=1
AWS_REGION=us-east-1
```

Model IDs use `anthropic.` prefix without version suffix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route requests to both endpoints — Mantle-format IDs go to Mantle, others go to Bedrock Invoke. `/status` shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`.

Mantle-specific vars: `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` (override URL), `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` (for gateway proxy setups).

### Claude Platform on AWS

Anthropic-operated API with AWS authentication and AWS Marketplace billing. Uses the same models/features as the direct Claude API.

```
CLAUDE_CODE_USE_ANTHROPIC_AWS=1
ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
AWS_REGION=us-east-1
```

Auth options:
- **SigV4 (option A):** Standard AWS credential chain (env vars, `~/.aws/credentials`, IAM roles, SSO)
- **Workspace API key (option B):** `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` — takes precedence over SigV4

Workspace ID is required on every request (`anthropic-workspace-id` header). Use `awsAuthRefresh` for SSO credential refresh. Gateway: `ANTHROPIC_AWS_BASE_URL`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`. Bedrock and Foundry take provider precedence over Claude Platform on AWS.

### Google Vertex AI Setup

**Wizard:** Run `claude`, select "3rd-party platform" → "Google Vertex AI". Re-run with `/setup-vertex`. Requires Claude Code v2.1.98+.

**Manual setup:**
1. `gcloud services enable aiplatform.googleapis.com`
2. Request Claude model access in Vertex AI Model Garden (may take 24–48 hours)
3. Set: `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global` (or `us`, `eu`, or specific region), `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID`

Region options: `global`, multi-region (`eu`, `us`), or specific region (e.g., `us-east5`). Use per-model region overrides `VERTEX_REGION_CLAUDE_*` when `CLOUD_ML_REGION=global` but a model doesn't support global endpoints.

Project ID precedence: `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` / `GOOGLE_APPLICATION_CREDENTIALS` file > `ANTHROPIC_VERTEX_PROJECT_ID` > gcloud config.

`gcpAuthRefresh` setting: auto-refresh GCP credentials (browser-based flows, 3-minute timeout).

**IAM:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`). MCP tool search disabled by default on Vertex; set `ENABLE_TOOL_SEARCH=true` for Sonnet 4.5+ and Opus 4.5+.

### Microsoft Foundry Setup

No interactive setup wizard — environment variables only.

```
CLAUDE_CODE_USE_FOUNDRY=1
ANTHROPIC_FOUNDRY_RESOURCE={resource}   # or ANTHROPIC_FOUNDRY_BASE_URL
```

Auth options:
- **API key:** `ANTHROPIC_FOUNDRY_API_KEY=<key>` (from Endpoints and keys section in Foundry portal)
- **Entra ID:** Default when `ANTHROPIC_FOUNDRY_API_KEY` is not set (uses Azure SDK default credential chain)

RBAC: `Azure AI User` or `Cognitive Services User` roles provide required permissions. Gateway: `ANTHROPIC_FOUNDRY_BASE_URL`, `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1`.

### LLM Gateway Configuration

Gateway must expose at least one of:
- **Anthropic Messages:** `/v1/messages`, `/v1/messages/count_tokens` — must forward `anthropic-beta`, `anthropic-version` headers
- **Bedrock InvokeModel:** `/invoke`, `/invoke-with-response-stream` — must preserve `anthropic_beta`, `anthropic_version` body fields
- **Vertex rawPredict:** `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` — must forward `anthropic-beta`, `anthropic-version` headers

When using Anthropic Messages format with Bedrock/Vertex backends, set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` if needed.

**Gateway model discovery:** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and add results to `/model` picker. Only applies to Anthropic Messages format. Requires v2.1.129+.

**Request headers Claude Code sends:**
- `X-Claude-Code-Session-Id` — unique session identifier
- `X-Claude-Code-Agent-Id` — subagent identifier (parallel cost attribution)
- `X-Claude-Code-Parent-Agent-Id` — parent agent identifier (nested agents)

**LiteLLM configuration:**
- Unified endpoint (recommended): `ANTHROPIC_BASE_URL=https://litellm-server:4000`
- Bedrock pass-through: `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1`
- Vertex pass-through: `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`
- Claude Platform on AWS pass-through: `ANTHROPIC_AWS_BASE_URL=...`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`
- Auth: static `ANTHROPIC_AUTH_TOKEN`, or dynamic via `apiKeyHelper` script + `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware — avoid them.

### Corporate Proxy Setup

Set `HTTPS_PROXY` or `HTTP_PROXY` for each provider. Use alongside cloud provider env vars. Verify with `/status`.

### Enterprise Best Practices

- Deploy CLAUDE.md at organization level (`/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS) and repository level
- Pin model versions for all cloud provider deployments
- Configure MCP servers centrally via `.mcp.json` checked into the codebase
- Set managed permissions in [security settings](/en/security) for org-wide Claude Code policy
- Use `/status` to verify provider, model, region, and auth configuration at any time

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — setup wizard, credential methods, IAM policy, Mantle endpoint, Guardrails, service tiers, startup model checks, 1M context, troubleshooting
- [Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and workspace API key auth, AWS Marketplace billing, Agent SDK usage, proxy/gateway routing, troubleshooting
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — setup wizard, global/multi-region/regional endpoints, credential config, gcpAuthRefresh, IAM, 1M context, troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — API key and Entra ID auth, Azure RBAC, model pinning, no-wizard setup, troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway API format requirements, request headers, model discovery, LiteLLM setup, pass-through endpoints, auth methods
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — compare deployment options, proxy/gateway setup per provider, enterprise best practices

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
