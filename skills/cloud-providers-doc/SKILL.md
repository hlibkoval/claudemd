---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry — as well as LLM gateway configuration and an enterprise deployment overview.

## Quick Reference

### Deployment options comparison

| Option | Best for | Billing | Auth |
| :----- | :------- | :------ | :--- |
| Claude for Teams/Enterprise | Most organizations (recommended) | Per-seat / contact sales | Claude.ai SSO or email |
| Anthropic Console | Individual developers | PAYG | API key |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | API key or AWS credentials |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

### Enable each provider (required env vars)

| Provider | Key variables |
| :------- | :------------ |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| Mantle (Bedrock) | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_…`, `AWS_REGION=us-east-1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=your-project-id` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |

### Model-pinning env vars (all third-party providers)

| Variable | Default alias resolves to |
| :------- | :------------------------ |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | Built-in default for provider |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Opus 4.6 (Bedrock/Vertex/Foundry); Opus 4.7 (Claude Platform on AWS) |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Built-in default for provider |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Primary model (Haiku may not be enabled in all accounts) |
| `ANTHROPIC_MODEL` | Override the primary model directly |

Pin models before team rollouts. Without pinning, aliases can lag the newest release or point to models not yet enabled in your account. Append `[1m]` to a pinned model ID to enable the 1M token context window (Opus 4.6+, Sonnet 4.6).

### Amazon Bedrock — key details

**AWS credential options:** AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), SSO profile (`AWS_PROFILE`), or Bedrock API key (`AWS_BEARER_TOKEN_BEDROCK`).

**Auto credential refresh settings (in `settings.json`):**

| Setting | When it runs |
| :------ | :----------- |
| `awsAuthRefresh` | Only when credentials are detected as expired |
| `awsCredentialExport` | On every session start and credential reload; must output `{"Credentials": {"AccessKeyId", "SecretAccessKey", "SessionToken"}}` |

**Bedrock-specific env vars:**

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override the Bedrock endpoint URL |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Region override for the Haiku-class model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL (billed higher) |

**Guardrails:** Set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**IAM actions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`.

**Mantle endpoint:** Bedrock endpoint using the native Anthropic API shape. Model IDs use `anthropic.` prefix (e.g. `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run both endpoints simultaneously.

### Claude Platform on AWS — key details

Anthropic-operated Claude API with AWS authentication and AWS Marketplace billing. Same models and features as direct Claude API.

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS` | Enable this provider |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required; sent as `anthropic-workspace-id` header |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `ANTHROPIC_AWS_BASE_URL` | Override base URL (for proxies) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip SigV4 signing (for gateways that sign themselves) |

Provider priority: Bedrock and Foundry take precedence; unset those if set when using this provider.

### Google Vertex AI — key details

**Credential refresh:** Use `gcpAuthRefresh` setting (e.g. `"gcloud auth application-default login"`). Runs on expired/unloadable credentials. Supports X.509 Workload Identity Federation via `GOOGLE_APPLICATION_CREDENTIALS`.

**Project ID resolution order:** `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` / credential file → `ANTHROPIC_VERTEX_PROJECT_ID` → gcloud config or attached service account.

**Region configuration:** Set `CLOUD_ML_REGION` to `global`, a multi-region (`eu`, `us`), or a specific region (`us-east5`). For models not supporting global endpoints, use per-model region overrides: `VERTEX_REGION_CLAUDE_HAIKU_4_5`, `VERTEX_REGION_CLAUDE_4_6_SONNET`, etc.

**IAM:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

**MCP tool search:** Disabled by default on Vertex AI. Set `ENABLE_TOOL_SEARCH=true` for Claude Sonnet 4.5+ and Opus 4.5+.

**Startup model checks** (v2.1.98+): Claude Code verifies model accessibility at startup and falls back to the previous version if the default is unavailable.

### Microsoft Foundry — key details

No interactive setup wizard — all configuration is via env vars.

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable this provider |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Your Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL alternative to resource name |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth; omit to use Microsoft Entra ID (default credential chain) |

**RBAC roles:** `Azure AI User` or `Cognitive Services User` (built-in), or custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

**No startup model checks on Foundry** — requests fail when the default model is unavailable; always pin model versions.

### LLM gateway configuration

**Required API formats** (gateway must expose at least one):

| Format | Endpoints | Must forward |
| :----- | :-------- | :----------- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**Request headers sent by Claude Code:**

| Header | Purpose |
| :----- | :------ |
| `X-Claude-Code-Session-Id` | Aggregate requests per session |
| `X-Claude-Code-Agent-Id` | Attribute cost to parallel subagents |
| `X-Claude-Code-Parent-Agent-Id` | Attribute cost across nested agents |

**Gateway model discovery:** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and populate the `/model` picker. Requires v2.1.129+. Only models with IDs starting with `claude` or `anthropic` are added.

**LiteLLM quick-start:**

| Use case | Variable |
| :------- | :------ |
| Unified Anthropic format | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=…/bedrock`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=…/vertex_ai/v1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL=…`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` |

**Auth skip variables (for gateways that inject auth server-side):**

`CLAUDE_CODE_SKIP_BEDROCK_AUTH`, `CLAUDE_CODE_SKIP_VERTEX_AUTH`, `CLAUDE_CODE_SKIP_FOUNDRY_AUTH`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH`, `CLAUDE_CODE_SKIP_MANTLE_AUTH`.

### Corporate proxy (all providers)

Set `HTTPS_PROXY=https://proxy.example.com:8080` alongside the provider env vars. Use `/status` to verify the resolved provider and configuration.

### Best practices for org deployments

- Pin model versions before team rollouts (`ANTHROPIC_DEFAULT_*_MODEL`)
- Create a dedicated AWS account / GCP project / Azure resource for cost isolation
- Deploy `CLAUDE.md` files at org level and repo level for shared context
- Check `.mcp.json` into source control for shared MCP server configuration
- Configure managed permissions (security policy) that cannot be overridden locally

## Full Documentation

For the complete official documentation, see the reference files:

- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Compare deployment options, proxy/gateway configuration patterns, org best practices
- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Prerequisites, sign-in wizard, manual setup, IAM, model pinning, Mantle endpoint, Guardrails, troubleshooting
- [Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and API-key auth, workspace setup, Agent SDK integration, proxy routing
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex setup wizard, region configuration, credential refresh, IAM, startup model checks
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, Entra ID auth, RBAC, model pinning
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway requirements, LiteLLM setup, model discovery, auth skip variables

## Sources

- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
