---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through cloud provider backends: Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry, LLM gateways, and the enterprise deployment overview.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Auth |
|:-------|:---------|:--------|:-----|
| Claude for Teams/Enterprise | Most organizations (recommended) | Per-seat or PAYG | Claude.ai SSO or email |
| Anthropic Console | Individual developers | PAYG | API key |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | API key or AWS credentials |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

### Enable a Provider: Key Environment Variables

| Provider | Required env vars |
|:---------|:------------------|
| **Amazon Bedrock** | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| **Bedrock (Mantle endpoint)** | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |
| **Claude Platform on AWS** | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_…`, `AWS_REGION=us-east-1` |
| **Google Vertex AI** | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID` |
| **Microsoft Foundry** | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |

Provider priority when multiple are set: Bedrock and Foundry take precedence over Claude Platform on AWS.

### Model Pinning (all cloud providers)

Always pin model versions for team deployments to prevent breakage when Anthropic releases updates:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='...'    # Provider-specific model ID
export ANTHROPIC_DEFAULT_SONNET_MODEL='...'  # Provider-specific model ID
export ANTHROPIC_DEFAULT_HAIKU_MODEL='...'   # Provider-specific model ID
```

Without pinning, aliases like `sonnet` resolve to the latest version, which may not yet be available in your account. On Bedrock and Vertex, the small/fast model defaults to the primary model when Haiku is not enabled.

### Bedrock-Specific Configuration

| Setting | Details |
|:--------|:--------|
| **IAM permissions** | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile` |
| **Model ID format** | Cross-region inference profiles: `us.anthropic.claude-sonnet-4-6` |
| **Application inference profiles** | Set via `modelOverrides` in settings.json; ARN format |
| **Prompt caching** | Enabled by default; 1-hour TTL with `ENABLE_PROMPT_CACHING_1H=1` |
| **Service tiers** | `ANTHROPIC_BEDROCK_SERVICE_TIER=default|flex|priority` |
| **Guardrails** | Set via `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers |
| **1M context window** | Supported for Opus 4.6+ and Sonnet 4.6; append `[1m]` to model ID |
| **Login wizard** | `claude` → 3rd-party platform → Amazon Bedrock; re-run with `/setup-bedrock` |
| **Converse API** | Not supported; uses InvokeModel API only |
| **WebSearch tool** | Not available on Bedrock |

#### Bedrock Credential Options

| Option | Method |
|:-------|:-------|
| A | `aws configure` (AWS CLI) |
| B | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` env vars |
| C | `aws sso login` + `AWS_PROFILE` env var |
| D | `aws login` (AWS Management Console) |
| E | `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API key) |

#### Bedrock Advanced Credential Settings

| Setting | Trigger | Use case |
|:--------|:--------|:---------|
| `awsAuthRefresh` | Only when credentials are detected as expired | SSO refresh, browser-based flows |
| `awsCredentialExport` | On every credential reload (even when valid) | Cross-account credentials not in default chain; outputs `{"Credentials": {…}}` JSON |

#### Mantle Endpoint (Bedrock native Anthropic API shape)

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override default Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy/gateway setups |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override AWS region for Haiku-class model |

Run both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` together to route Mantle-format model IDs to Mantle and all others to the Bedrock Invoke API. Use `/status` to confirm active provider.

### Claude Platform on AWS Configuration

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | Enable Claude Platform on AWS |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required; sent as `anthropic-workspace-id` header on every request |
| `AWS_REGION` | Region; base URL computed as `https://aws-external-anthropic.{region}.api.aws` |
| `ANTHROPIC_AWS_BASE_URL` | Override base URL (for proxy/gateway) |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip client-side auth for gateway setups |

- Auth: SigV4 via standard AWS credential chain, or `ANTHROPIC_AWS_API_KEY`
- Org note: AWS Marketplace subscription creates a new Anthropic org separate from any existing one
- Uses same model IDs as direct Claude API
- Agent SDK: reads the same env vars when spawning the Claude Code subprocess

### Vertex AI Configuration

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_VERTEX=1` | Enable Vertex AI |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`, `us`), or specific region (`us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID (also resolved from `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, credential file) |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint URL |
| `VERTEX_REGION_CLAUDE_*` | Per-model region overrides when using `global` endpoint |
| `gcpAuthRefresh` | Shell command to run when GCP credentials expire (set in settings.json) |
| `ENABLE_TOOL_SEARCH=true` | Enable MCP tool search (disabled by default on Vertex; requires Sonnet 4.5+ or Opus 4.5+) |

- IAM: `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`)
- Login wizard: `claude` → 3rd-party platform → Google Vertex AI; re-run with `/setup-vertex` (requires v2.1.98+)
- 1M context: Opus 4.6+ and Sonnet 4.6; append `[1m]` to model ID
- Model access approval may take 24–48 hours via Vertex AI Model Garden

### Microsoft Foundry Configuration

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Override full base URL |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth (omit to use Entra ID default credential chain) |

- RBAC: `Azure AI User` or `Cognitive Services User` roles
- No interactive setup wizard — env vars are the only configuration path
- Pin model versions to your deployment names created in the Foundry portal

### LLM Gateway Configuration

| Gateway format | Config variable | Skip auth var |
|:---------------|:----------------|:--------------|
| Anthropic API | `ANTHROPIC_BASE_URL` | — |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

**Gateway API format requirements:** must expose Anthropic Messages (`/v1/messages`) forwarding `anthropic-beta` and `anthropic-version` headers, Bedrock InvokeModel preserving `anthropic_beta`/`anthropic_version` body fields, or Vertex rawPredict (`:rawPredict`, `:streamRawPredict`).

**Claude Code request headers for gateways:**

| Header | Purpose |
|:-------|:--------|
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier (present for in-process subagents) |
| `X-Claude-Code-Parent-Agent-Id` | Spawning agent identifier (present for nested agents) |

**Gateway model discovery:** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and add results to `/model` picker (Anthropic Messages format only; requires v2.1.129+).

**LiteLLM auth options:**
- Static: `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` (sent as `Authorization` header)
- Dynamic: `apiKeyHelper` script + `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for token refresh
- Unified endpoint (recommended): `ANTHROPIC_BASE_URL=https://litellm-server:4000`

### Startup Model Checks

When any cloud provider is configured, Claude Code verifies model accessibility at startup (Bedrock: v2.1.94+; Vertex: v2.1.98+). If the pinned model is older and the newer version is available, it prompts you to update the pin. If the default model is unavailable, it falls back for the current session only (not persisted).

### Corporate Proxy

All providers support `HTTPS_PROXY` / `HTTP_PROXY` env vars for routing through a corporate proxy. Use alongside the provider-specific `BASE_URL` variables when both a proxy and a gateway are needed.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Setup wizard, credential options, IAM policy, model pinning, Mantle endpoint, Guardrails, service tiers, 1M context, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and workspace API key auth, workspace ID setup, proxy routing, Agent SDK integration
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Setup wizard, region configuration (global/multi-region/regional), IAM, model pinning, credential refresh, 1M context
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Resource provisioning, API key and Entra ID auth, RBAC, model pinning
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — Provider comparison table, proxy vs. gateway selection, best practices for org rollout
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, request headers, model discovery, LiteLLM setup, auth methods

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
