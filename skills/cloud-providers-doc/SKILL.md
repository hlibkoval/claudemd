---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways, including Amazon Bedrock, Google Vertex AI, Microsoft Foundry, Claude Platform on AWS, and LiteLLM gateway configuration.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Auth |
|:-------|:---------|:--------|:-----|
| Claude for Teams/Enterprise | Most organizations (recommended) | Seat-based / contact sales | Claude.ai SSO or email |
| Anthropic Console | Individual developers | PAYG | API key |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | API key or AWS credentials |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

### Enable Variable per Provider

| Provider | Enable variable | Required companion vars |
|:---------|:----------------|:------------------------|
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Mantle (Bedrock endpoint) | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` |

Provider routing priority (when multiple vars set): Bedrock and Foundry take precedence over Claude Platform on AWS.

### Model Pinning (all cloud providers)

Pin specific model versions before rolling out to multiple users. Without pinning, aliases resolve to the latest version, which may not yet be enabled in your account.

```bash
# Bedrock (cross-region inference profile IDs with us. prefix)
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'

# Vertex AI / Foundry / Claude Platform on AWS (direct model IDs)
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

Haiku defaults to the primary model on Bedrock, Vertex, and Foundry because Haiku may not be enabled in every account or region. Set `ANTHROPIC_DEFAULT_HAIKU_MODEL` explicitly to use it for background tasks.

### Amazon Bedrock

**Quick setup (wizard):** Run `claude`, select "3rd-party platform" → "Amazon Bedrock". Re-run with `/setup-bedrock`.

**Manual env vars:**

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
# Optional: override small/fast model region
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
# Optional: custom endpoint
# export ANTHROPIC_BEDROCK_BASE_URL=https://bedrock-runtime.us-east-1.amazonaws.com
```

**AWS credential options:**

| Method | How |
|:-------|:----|
| AWS CLI | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile <name>`, then `AWS_PROFILE=<name>` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

**Advanced credential settings (settings.json):**

| Setting | When to use |
|:--------|:------------|
| `awsAuthRefresh` | Runs on credential expiry; use for SSO/browser-based flows |
| `awsCredentialExport` | Runs on every credential load; must output JSON `{Credentials: {AccessKeyId, SecretAccessKey, SessionToken}}`; use when cross-account credentials differ from the default chain |

**IAM permissions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile` (plus optional `aws-marketplace:ViewSubscriptions`, `aws-marketplace:Subscribe`).

**Bedrock-specific features:**

- **Service tiers:** `ANTHROPIC_BEDROCK_SERVICE_TIER=default|flex|priority`
- **Guardrails:** Set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion`
- **1M token context:** Append `[1m]` to a manually pinned model ID; wizard offers option when pinning
- **modelOverrides:** Map multiple versions of the same family to distinct application inference profile ARNs in settings.json

**Mantle endpoint (Bedrock, native Anthropic API shape):**

```bash
export CLAUDE_CODE_USE_MANTLE=1
export AWS_REGION=us-east-1
# Run both Invoke API and Mantle simultaneously:
export CLAUDE_CODE_USE_BEDROCK=1
export CLAUDE_CODE_USE_MANTLE=1
```

Mantle model IDs use `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Requires Claude Code v2.1.94+.

| Mantle variable | Purpose |
|:----------------|:--------|
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy/gateway setups |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |

### Google Vertex AI

**Quick setup (wizard):** Requires v2.1.98+. Run `claude`, select "3rd-party platform" → "Google Vertex AI". Re-run with `/setup-vertex`.

**Manual env vars:**

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global   # or multi-region (eu, us) or specific region (us-east5)
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
# Optional: per-model region overrides when using global endpoint
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

**Credential resolution order:** `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` / `GOOGLE_APPLICATION_CREDENTIALS` credential file → `ANTHROPIC_VERTEX_PROJECT_ID` → gcloud config / attached service account.

**gcpAuthRefresh:** Runs when credentials expire or cannot be loaded; use for browser-based ADC flows:

```json
{ "gcpAuthRefresh": "gcloud auth application-default login" }
```

**IAM:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

**MCP tool search:** Disabled by default on Vertex AI; set `ENABLE_TOOL_SEARCH=true` for Claude Sonnet 4.5+ or Opus 4.5+.

**1M token context:** Append `[1m]` to a manually pinned model ID; wizard offers option when pinning.

### Microsoft Foundry

**No interactive wizard** — configure through environment variables only.

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource-name
# Or provide the full URL:
# export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Auth options:**

| Method | How |
|:-------|:----|
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` (from Endpoints and keys in portal) |
| Microsoft Entra ID | Omit `ANTHROPIC_FOUNDRY_API_KEY`; uses Azure SDK default credential chain (`az login` locally) |

**RBAC:** `Azure AI User` or `Cognitive Services User` role; or custom role with `Microsoft.CognitiveServices/accounts/providers/*` data action.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication and AWS Marketplace billing. Uses same model IDs and features as the direct Claude API.

```bash
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export AWS_REGION=us-east-1
# Base URL is computed from AWS_REGION; override with:
# export ANTHROPIC_AWS_BASE_URL=https://aws-external-anthropic.{region}.api.aws
```

**Auth options:**

| Method | How |
|:-------|:----|
| SigV4 (AWS credentials) | Standard AWS credential chain; use `awsAuthRefresh` for SSO mid-session refresh |
| Workspace API key | `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` (takes precedence over SigV4) |

**Note:** Credentials from a separate Claude Console organization won't work here — use keys from the AWS-linked organization.

For gateway use, set `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` to skip client-side signing.

### Prompt Caching

| Provider | Default | Disable | 1-hour TTL |
|:---------|:--------|:--------|:-----------|
| All providers | Enabled | `DISABLE_PROMPT_CACHING=1` | `ENABLE_PROMPT_CACHING_1H=1` (billed at higher rate) |

Note: Prompt caching may not be available in all Bedrock regions. Check [supported models, regions, and limits](https://docs.aws.amazon.com/bedrock/latest/userguide/prompt-caching.html#prompt-caching-models).

### LLM Gateway Configuration

An LLM gateway must expose at least one of these API formats:

| Format | Endpoints | Must preserve |
|:-------|:----------|:--------------|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

**Per-provider gateway and skip-auth variables:**

| Provider | Base URL override | Skip auth var |
|:---------|:------------------|:--------------|
| Anthropic Messages | `ANTHROPIC_BASE_URL` | — |
| Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Mantle | `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |

**Request headers Claude Code sends to all gateways:**

| Header | Contains |
|:-------|:---------|
| `X-Claude-Code-Session-Id` | Unique session identifier (aggregate all requests from one session) |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier (present only for in-process subagents) |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent identifier (present only when spawned by another agent) |

Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the system prompt attribution block (useful when gateway implements its own prompt cache keyed on the full request body).

**Gateway model discovery (Anthropic Messages format only):** Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup. Requires v2.1.129+. Results cached at `~/.claude/cache/gateway-models.json`.

**LiteLLM auth options:**

| Method | Config |
|:-------|:-------|
| Static API key | `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` (sent as `Authorization` header) |
| Dynamic key helper | `apiKeyHelper` in settings.json pointing to a script; refresh with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with malware — do not use them.

### Startup Model Checks

On Bedrock (v2.1.94+) and Vertex AI (v2.1.98+), Claude Code verifies model accessibility at startup:
- If a pinned model is older than the current default and the newer version is available, Claude Code prompts to update the pin.
- If the current default is unavailable, Claude Code falls back to the previous version for the session (not persisted).

### Proxy Configuration (Corporate)

```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
# or HTTP_PROXY for HTTP traffic
```

Use `/status` to verify resolved provider, region, workspace, and gateway configuration.

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Setup wizard, manual env vars, AWS credential methods, IAM policy, model pinning, Mantle endpoint, service tiers, Guardrails, 1M context window, and troubleshooting
- [Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and workspace API key auth, env var configuration, Agent SDK usage, gateway routing, and troubleshooting
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — Setup wizard, manual env vars, GCP credential options, gcpAuthRefresh, IAM, model pinning, 1M context window, and troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Provisioning, API key vs. Entra ID auth, env var configuration, RBAC, and troubleshooting
- [Third-Party Integrations Overview](references/claude-code-third-party-integrations.md) — Deployment comparison table, proxy/gateway overview, best practices for organizations, and next steps
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, request headers, LiteLLM setup (static and dynamic auth), and provider-specific pass-through endpoints

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Third-Party Integrations Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
