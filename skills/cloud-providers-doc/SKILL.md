---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock (setup wizard, IAM, model pinning, Mantle endpoint, Guardrails, service tiers), Google Vertex AI (setup wizard, credentials, region config, MCP tool search), Microsoft Foundry (Azure setup, RBAC, Entra ID), Claude Platform on AWS (SigV4 and API key auth, workspace config), LLM gateway configuration (LiteLLM, gateway requirements, model discovery), and enterprise deployment overview (deployment comparison, proxy/gateway setup, org best practices).
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Auth |
| :--- | :--- | :--- | :--- |
| Claude for Teams/Enterprise | Most organizations (recommended) | Per seat / Contact sales | Claude.ai SSO or email |
| Anthropic Console | Individual developers | PAYG | API key |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| Claude Platform on AWS | AWS Marketplace billing with Claude API features | PAYG through AWS Marketplace | API key or AWS credentials |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Entra ID |

Teams/Enterprise is the only option that includes Claude on the web. All options support prompt caching by default.

---

### Amazon Bedrock

#### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK=1` | Enable Bedrock integration |
| `AWS_REGION` | Required; not read from `.aws` config |
| `AWS_PROFILE` | Use a specific AWS profile |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` | Access key credentials |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key (simpler, no full AWS creds needed) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override endpoint (for custom gateways) |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` for service tier |
| `ANTHROPIC_CUSTOM_HEADERS` | Add Guardrail headers or other custom headers |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Region override for small/fast (Haiku) model |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Use 1-hour cache TTL (higher billing rate) |

#### Model pinning (Bedrock)

| Variable | Example value |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

Default when nothing is pinned: `us.anthropic.claude-sonnet-4-5-20250929-v1:0` for both primary and small/fast.

Pin using cross-region inference profile IDs (`us.` prefix). Haiku defaults to the primary model on Bedrock; set `ANTHROPIC_DEFAULT_HAIKU_MODEL` explicitly to use it for background tasks.

#### Advanced credential config (`settings.json`)

| Setting | Trigger | Use case |
| :--- | :--- | :--- |
| `awsAuthRefresh` | Only when credentials are expired or Bedrock returns a credential error | SSO login, browser-based flows that modify `.aws` |
| `awsCredentialExport` | On every session start and credential reload | Cross-account credentials, returns JSON `{"Credentials": {"AccessKeyId": ..., "SecretAccessKey": ..., "SessionToken": ...}}` |

#### IAM required actions

```
bedrock:InvokeModel
bedrock:InvokeModelWithResponseStream
bedrock:ListInferenceProfiles
bedrock:GetInferenceProfile
aws-marketplace:ViewSubscriptions
aws-marketplace:Subscribe
```

#### Mantle endpoint (Bedrock)

Mantle uses the native Anthropic API shape over AWS auth. Requires Claude Code v2.1.94+.

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side auth (for gateways that inject AWS credentials) |

Model IDs on Mantle use `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route requests to whichever endpoint supports each model ID. Run `/status` to confirm: shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`.

#### 1M token context window (Bedrock)

Opus 4.7, Opus 4.6, and Sonnet 4.6 support 1M context on Bedrock. Append `[1m]` to a manually pinned model ID to enable it.

#### AWS Guardrails

Set `ANTHROPIC_CUSTOM_HEADERS` with newline-separated headers:
```
X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1
```

---

### Google Vertex AI

#### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX=1` | Enable Vertex AI integration |
| `CLOUD_ML_REGION` | `global`, a multi-region (`eu`, `us`), or a specific region (`us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID (overridden by `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, or credential file) |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint URL |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Region override for Haiku when `CLOUD_ML_REGION=global` |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Region override for Sonnet 4.6 when `CLOUD_ML_REGION=global` |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Use 1-hour cache TTL |
| `ENABLE_TOOL_SEARCH=true` | Enable MCP tool search (supported for Sonnet 4.5+ and Opus 4.5+ only) |

Wizard available via `/setup-vertex`. Requires Claude Code v2.1.98+.

#### Model pinning (Vertex)

| Variable | Example value |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `claude-haiku-4-5@20251001` |

Default when nothing is pinned: `claude-sonnet-4-5@20250929` for both primary and small/fast.

#### IAM required permission

`aiplatform.endpoints.predict` — included in the `roles/aiplatform.user` role.

#### Credential refresh (`gcpAuthRefresh`)

```json
{
  "gcpAuthRefresh": "gcloud auth application-default login",
  "env": { "ANTHROPIC_VERTEX_PROJECT_ID": "your-project-id" }
}
```

Runs when credentials are expired or cannot be loaded. Times out after 3 minutes.

#### 1M token context window (Vertex)

Opus 4.7, Opus 4.6, and Sonnet 4.6 support 1M context on Vertex. Append `[1m]` to a manually pinned model ID.

---

### Microsoft Foundry

#### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Microsoft Foundry integration |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth; if unset, uses Azure SDK DefaultAzureCredential chain |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` | Skip client-side auth (for gateways) |
| `ENABLE_PROMPT_CACHING_1H=1` | Use 1-hour cache TTL |

No interactive setup wizard for Foundry — environment variables are the only configuration path.

#### Model pinning (Foundry)

| Variable | Example value |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `claude-haiku-4-5` |

Haiku defaults to the primary model; set explicitly to use it for background tasks.

#### Azure RBAC

`Azure AI User` or `Cognitive Services User` roles are sufficient. Minimum custom permission: `Microsoft.CognitiveServices/accounts/providers/*` (data action).

---

### Claude Platform on AWS

Anthropic-operated Claude API with AWS auth and AWS Marketplace billing. Uses same models/features as the direct Claude API on the same release schedule. Requires an active AWS Marketplace subscription and a workspace ID.

#### Key environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | Enable Claude Platform on AWS |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required on every request (sent as `anthropic-workspace-id` header) |
| `AWS_REGION` | Region; base URL computed as `https://aws-external-anthropic.{region}.api.aws` |
| `ANTHROPIC_AWS_BASE_URL` | Override URL (for proxies/gateways) |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` | Skip client-side auth (for gateways) |
| `ENABLE_PROMPT_CACHING_1H=1` | Use 1-hour cache TTL |

Bedrock and Foundry take precedence in provider routing — unset `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` if also present.

#### Model pinning (Claude Platform on AWS)

Uses same model IDs as direct Claude API (e.g., `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5`). Aliases resolve to latest available in the workspace.

---

### LLM Gateway Configuration

An LLM gateway sits between Claude Code and the cloud provider for centralized auth, usage tracking, cost controls, audit logging, and model routing.

#### Gateway API format requirements

The gateway must expose one of:

| Format | Required endpoints | Must preserve |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

When using Anthropic Messages format with Bedrock or Vertex, you may need `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

#### Request headers sent by Claude Code

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier for aggregating API requests |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier for per-agent cost attribution |
| `X-Claude-Code-Parent-Agent-Id` | ID of the spawning agent (for nested agent cost attribution) |

Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the attribution block prepended to the system prompt (useful for gateways with their own prompt cache keyed on the full request body).

#### Gateway model discovery

Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query the gateway's `/v1/models` endpoint at startup and add returned models to the `/model` picker. Requires Claude Code v2.1.129+. Only applies to Anthropic Messages format when `ANTHROPIC_BASE_URL` is set to a non-Anthropic host. Results are cached to `~/.claude/cache/gateway-models.json`.

#### LiteLLM setup (key variables)

| Endpoint type | Variables to set |
| :--- | :--- |
| Unified (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL=...`, `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` |

Auth: use `ANTHROPIC_AUTH_TOKEN` (sent as `Authorization` bearer) or `apiKeyHelper` in `settings.json` for dynamic/rotating keys.

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Do not install these versions.

---

### General Tips

- Run `/status` in Claude Code to confirm the active provider, workspace ID, region, and base URL override.
- **Always pin model versions** when deploying to multiple users via `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, and `ANTHROPIC_DEFAULT_HAIKU_MODEL`. Without pinning, aliases resolve to the latest version which may not be available in your account yet.
- Use `modelOverrides` in `settings.json` to map individual model versions to specific application inference profile ARNs (Bedrock).
- Corporate proxy: `HTTPS_PROXY` or `HTTP_PROXY` env vars. LLM gateway: provider-specific `*_BASE_URL` env var.

## Full Documentation

For the complete official documentation, see the reference files:

- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — deployment option comparison, proxy/gateway config, org best practices
- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — setup wizard, IAM, credential refresh, model pinning, Mantle endpoint, Guardrails, service tiers, troubleshooting
- [Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and API key auth, workspace config, proxy routing, Agent SDK usage
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — setup wizard, credential options, region config, model pinning, MCP tool search, troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, API key and Entra ID auth, RBAC, model pinning
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — gateway API requirements, request headers, model discovery, LiteLLM setup

## Sources

- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
