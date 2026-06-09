---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through third-party cloud providers — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry — plus enterprise deployment comparison, proxy/gateway configuration, and LLM gateway setup.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Auth | Includes Claude on web |
|:-------|:---------|:--------|:-----|:-----------------------|
| Claude for Teams/Enterprise | Most organizations (recommended) | Per-seat / contact sales | Claude.ai SSO or email | Yes |
| Anthropic Console | Individual developers | PAYG | API key | No |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials | No |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | API key or AWS credentials | No |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials | No |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID | No |

### Enable Variables by Provider

| Provider | Enable variable | Key additional variables |
|:---------|:----------------|:------------------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION`, `AWS_PROFILE` / `AWS_ACCESS_KEY_ID` |
| Bedrock (Mantle endpoint) | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

### Model Pinning Variables (all providers)

| Variable | Default alias it controls | Example Bedrock value | Example Vertex/Foundry value |
|:---------|:--------------------------|:----------------------|:-----------------------------|
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `opus` | `us.anthropic.claude-opus-4-8` | `claude-opus-4-8` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `sonnet` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `haiku` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` |
| `ANTHROPIC_MODEL` | primary (overrides sonnet alias) | any model ID | any model ID |

Pin model versions before team rollouts. Without pinning, aliases resolve to Claude Code's built-in provider default, which can lag the newest release. Append `[1m]` to a model ID to enable the 1M token context window (Opus 4.6+, Sonnet 4.6).

### Amazon Bedrock — Key Details

**Authentication options:**

| Method | How |
|:-------|:----|
| AWS CLI config | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `AWS_PROFILE=<name>` after `aws sso login` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=<key>` |

**Advanced credential refresh settings (in settings.json):**

| Setting | When it runs | Use for |
|:--------|:-------------|:--------|
| `awsAuthRefresh` | When credentials expire / Bedrock returns credential error | Browser-based SSO flows; modifying `.aws` directory |
| `awsCredentialExport` | At session start and each credential reload | Cross-account credentials; must output `{"Credentials": {"AccessKeyId": …, "SecretAccessKey": …, "SessionToken": …}}` |

**Required IAM actions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`

**Service tiers:** Set `ANTHROPIC_BEDROCK_SERVICE_TIER` to `default`, `flex`, or `priority`.

**Guardrails:** Set headers via `ANTHROPIC_CUSTOM_HEADERS` in settings `env` block: `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion`.

**Prompt caching:** Enabled by default. `DISABLE_PROMPT_CACHING=1` to disable; `ENABLE_PROMPT_CACHING_1H=1` for 1-hour TTL (higher billing rate).

**Not available on Bedrock:** `/logout` command, WebSearch tool.

### Amazon Bedrock — Mantle Endpoint

Mantle serves Claude via the native Anthropic API shape (not the Bedrock Invoke API). Requires Claude Code v2.1.94+.

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side auth (for gateways that inject credentials) |

Mantle model IDs use `anthropic.` prefix without version suffix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route each request to whichever endpoint serves its model. `/status` shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`.

**`modelOverrides` for multiple inference profile ARNs (Bedrock):**
```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Claude Platform on AWS — Key Details

Anthropic-operated Claude API with AWS auth and AWS Marketplace billing. Uses the same models/features as the direct Claude API.

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | Enable this provider |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required workspace ID (sent as `anthropic-workspace-id` header) |
| `AWS_REGION` | Required; base URL computed from region |
| `ANTHROPIC_AWS_BASE_URL` | Override base URL for proxy/gateway |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` | Skip client-side auth (gateway signs requests) |

`CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` take precedence if also set — unset them when using Claude Platform on AWS.

### Google Vertex AI — Key Details

**Required setup:** Enable Vertex AI API (`aiplatform.googleapis.com`), request Claude model access in Model Garden (can take 24–48 hours), grant `roles/aiplatform.user` (or custom role with `aiplatform.endpoints.predict`).

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_VERTEX=1` | Enable Vertex AI |
| `CLOUD_ML_REGION` | Region, multi-region (`eu`, `us`), or `global` |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint URL |
| `VERTEX_REGION_CLAUDE_*` | Per-model region overrides when using `global` |
| `gcpAuthRefresh` (settings.json) | Command to refresh expired GCP credentials |
| `ENABLE_TOOL_SEARCH=true` | Enable MCP tool search (Sonnet 4.5+, Opus 4.5+ on Vertex only) |

`ANTHROPIC_VERTEX_PROJECT_ID` is overridden by `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or `GOOGLE_APPLICATION_CREDENTIALS` project if those are set. `/logout` is unavailable on Vertex.

### Microsoft Foundry — Key Details

**No interactive setup wizard.** Configure via environment variables only.

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth (if not set, uses Entra ID default credential chain) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` | Skip client-side auth (gateway handles Azure auth) |

**RBAC:** `Azure AI User` or `Cognitive Services User` roles suffice. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` dataAction. No startup model check — requests fail without pinned models if the default is unavailable.

### LLM Gateway Configuration

**Gateway API format requirements** (must expose at least one):

| Format | Endpoints | Must forward |
|:-------|:----------|:-------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**Request headers sent by Claude Code (useful for proxy attribution):**

| Header | Description |
|:-------|:------------|
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier (parallel agents) |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent ID for nested agents |

**Gateway base URL variables by provider:**

| Provider | Base URL variable | Skip-auth variable |
|:---------|:------------------|:-------------------|
| Anthropic API | `ANTHROPIC_BASE_URL` | N/A |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Mantle | `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |

**Gateway model discovery (Anthropic Messages format only):** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and populate the `/model` picker. Requires Claude Code v2.1.129+. Results cached to `~/.claude/cache/gateway-models.json`.

**`apiKeyHelper` for rotating keys:**
```json
{ "apiKeyHelper": "~/bin/get-litellm-key.sh" }
```
Set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval (milliseconds). Value sent as `Authorization` and `X-Api-Key`. Lower precedence than `ANTHROPIC_AUTH_TOKEN` or `ANTHROPIC_API_KEY`.

**LiteLLM security warning:** PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware — do not install. Rotate credentials if already installed.

**LiteLLM pass-through endpoint variables:**

| Provider via LiteLLM | Variable |
|:---------------------|:---------|
| Anthropic API (unified) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic API (pass-through) | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` + `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` + `CLAUDE_CODE_USE_VERTEX=1` |

**Attribution header:** Claude Code prepends a short attribution block to system prompts; the Anthropic API strips it before processing. Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit it if your gateway implements its own prompt cache keyed on full request body.

**Startup model checks (Bedrock and Vertex):** At startup Claude Code verifies model accessibility; falls back to previous version if default is unavailable. Bedrock requires v2.1.94+, Vertex requires v2.1.98+. Foundry has no startup check.

**Verify provider in-session:** Run `/status` to confirm which provider is active, the resolved model, workspace/project, region, and any auth-skip flags.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Prerequisites, login wizard, manual setup, IAM configuration, credential refresh, model pinning, startup checks, Mantle endpoint, service tiers, guardrails, and troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace subscription, SigV4 vs API key auth, workspace ID setup, proxy routing, Agent SDK usage, and troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Prerequisites, login wizard, manual setup, region configuration (global/multi-region/regional), IAM, model pinning, startup checks, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, API key vs Entra ID auth, environment variable setup, RBAC configuration, and troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Deployment option comparison, proxy and gateway configuration examples per provider, best practices for organizations
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, request headers, model discovery, LiteLLM setup, authentication methods, and provider-specific pass-through examples

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
