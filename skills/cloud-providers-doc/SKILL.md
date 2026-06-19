---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through third-party cloud providers and LLM gateways — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry, and LLM gateway configuration.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | Individual developers | AWS-native deployments | AWS Marketplace billing with Claude API features | GCP-native deployments | Azure-native deployments |
| Billing | Per-seat or contact sales | Pay-as-you-go | Pay-as-you-go via AWS | Pay-as-you-go via AWS Marketplace | Pay-as-you-go via GCP | Pay-as-you-go via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| Includes Claude on web | Yes | No | No | No | No | No |
| Enterprise features | Team management, SSO, usage monitoring | None | IAM policies, CloudTrail | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |

### Enable Flags (mutually exclusive — unset others if switching)

| Provider | Enable var | Notes |
| :--- | :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | Also set `AWS_REGION` |
| Bedrock Mantle endpoint | `CLAUDE_CODE_USE_MANTLE=1` | Can combine with Bedrock |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | Bedrock/Foundry take precedence if also set |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | Also set `CLOUD_ML_REGION` and `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | Also set `ANTHROPIC_FOUNDRY_RESOURCE` |

### Model Pinning Variables (all providers)

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | Pin Fable-class model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus-class model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet-class model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku-class model |
| `ANTHROPIC_MODEL` | Override the active model directly |

Always pin model versions when deploying to multiple users. Without pinning, aliases like `sonnet` resolve to Claude Code's built-in default for that provider, which can lag the newest release.

### Amazon Bedrock

**Minimal setup:**
```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

**Credential options:** AWS CLI (`aws configure`), env vars (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`), SSO profile (`AWS_PROFILE`), or Bedrock API key (`AWS_BEARER_TOKEN_BEDROCK`).

**Advanced credential settings (settings.json):**

| Setting | Trigger | Use case |
| :--- | :--- | :--- |
| `awsAuthRefresh` | Only on expired credentials | SSO re-login, modifies `~/.aws` |
| `awsCredentialExport` | Every reload, even if valid | Must return `{"Credentials": {"AccessKeyId":…}}` JSON |

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `AWS_REGION` | Region (falls back to profile, then `us-east-1`) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override endpoint URL |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Region for Haiku-class model |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `ANTHROPIC_CUSTOM_HEADERS` | Add custom headers (e.g., Guardrails) |
| `DISABLE_PROMPT_CACHING` | Set `1` to disable |
| `ENABLE_PROMPT_CACHING_1H` | Set `1` for 1-hour TTL (higher cost) |

**Bedrock default models (when no pins set):**

| Model type | Default |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | Same as primary |

**IAM permissions required:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`.

**Mantle endpoint (native Anthropic API shape over Bedrock):**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle (`1` or `true`) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip SigV4 for gateway setups |

Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run both endpoints; Mantle-format model IDs (prefix `anthropic.`) route to Mantle, others to Bedrock. Run `/status` to confirm — shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`.

**AWS Guardrails:** Add via `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**1M token context:** Append `[1m]` to a manually pinned model ID; the setup wizard offers this option automatically.

**Wizard:** Run `claude` → select 3rd-party platform → Amazon Bedrock. Re-run with `/setup-bedrock`.

### Claude Platform on AWS

Anthropic-operated Claude API with AWS authentication and AWS Marketplace billing. Same models and release schedule as the direct Claude API.

**Minimal setup:**
```bash
export CLAUDE_CODE_USE_ANTHROPIC_AWS=1
export ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_01ABCDEFGHIJKLMN
export AWS_REGION=us-east-1
```

**Authentication options:**

| Method | How |
| :--- | :--- |
| AWS SigV4 | Standard AWS credential chain (env vars, `~/.aws/credentials`, IAM role) |
| Workspace API key | `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` (takes precedence over SigV4) |

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required on every request (workspace ID from AWS Console) |
| `AWS_REGION` | Used to compute base URL |
| `ANTHROPIC_AWS_BASE_URL` | Override endpoint (proxy / LLM gateway) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Set `1` if gateway adds SigV4 |
| `ANTHROPIC_AUTH_TOKEN` | Gateway token when proxy requires its own auth |

Default `opus` alias resolves to Opus 4.7 if `ANTHROPIC_DEFAULT_OPUS_MODEL` is unset. Run `/status` to confirm provider and workspace ID.

**Note:** Bedrock and Foundry take precedence in provider routing — unset `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` if switching to Claude Platform on AWS.

### Google Vertex AI

**Minimal setup:**
```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

**Region options:** `global`, multi-region (`eu`, `us`), or specific region (`us-east5`). Use `VERTEX_REGION_CLAUDE_*` variables to override per-model when using `global`.

**Credential options:** Application Default Credentials (`gcloud auth application-default login`), service account key file (`GOOGLE_APPLICATION_CREDENTIALS`), or X.509 Workload Identity Federation (v2.1.121+).

**Project ID resolution order:** `GCLOUD_PROJECT`, `GOOGLE_CLOUD_PROJECT`, credential file, `ANTHROPIC_VERTEX_PROJECT_ID`, then `gcloud` config.

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLOUD_ML_REGION` | Region / multi-region / `global` |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint URL |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth for gateway setups |
| `ENABLE_TOOL_SEARCH` | Set `true` to enable MCP tool search (Sonnet 4.5+ / Opus 4.5+ only) |
| `DISABLE_PROMPT_CACHING` | Set `1` to disable |
| `ENABLE_PROMPT_CACHING_1H` | Set `1` for 1-hour TTL |

**IAM:** `roles/aiplatform.user` or custom role with `aiplatform.endpoints.predict`.

**Vertex AI default models (when no pins set):**

| Model type | Default |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | Same as primary |

**1M token context:** Append `[1m]` to a manually pinned model ID.

**Wizard (v2.1.98+):** Run `claude` → select 3rd-party platform → Google Vertex AI. Re-run with `/setup-vertex`.

### Microsoft Foundry

**Minimal setup:**
```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=your-resource-name
```

**Authentication options:**

| Method | How |
| :--- | :--- |
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` |
| Microsoft Entra ID | Automatic via Azure SDK default credential chain when API key is not set; run `az login` for local dev |

**Key environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth for gateway setups |
| `ENABLE_PROMPT_CACHING_1H` | Set `1` for 1-hour TTL |

**Azure RBAC:** `Azure AI User` or `Cognitive Services User` built-in roles are sufficient.

Foundry has no interactive setup wizard and no startup model check — requests fail if the default model is unavailable. Always pin model IDs matching your Azure deployment names.

**Foundry default models (when no pins set):**

| Model type | Default |
| :--- | :--- |
| Primary | Built-in Foundry default (can lag newest release) |
| Small/fast | Same as primary |

### LLM Gateway Configuration

A gateway sits between Claude Code and a model provider. Claude Code supports three API formats:

| Format | Endpoints | Required pass-through |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

**Request headers Claude Code sends (useful for proxy logging):**

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent identifier (nested agents) |

**Base URL override variables:**

| Provider | Variable |
| :--- | :--- |
| Anthropic Messages | `ANTHROPIC_BASE_URL` |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` |

**Auth-skip variables (when gateway handles auth):**

| Provider | Variable |
| :--- | :--- |
| Bedrock | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Claude Platform on AWS | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Google Vertex AI | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Mantle | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |
| Microsoft Foundry | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

**Gateway model discovery (Anthropic Messages format only, v2.1.129+):**
Set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and populate the `/model` picker. Off by default. Results cached to `~/.claude/cache/gateway-models.json`.

**LiteLLM authentication:**
- Static key: `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` (sent as `Authorization` bearer)
- Dynamic key: configure `apiKeyHelper` in settings.json + optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`
- Unified endpoint (recommended): `ANTHROPIC_BASE_URL=https://litellm-server:4000`

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Do not use them.

**Attribution header:** Claude Code prepends a short block to the system prompt. Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit it if your gateway caches on the full request body.

### Proxy Configuration

Route traffic through a corporate proxy with `HTTPS_PROXY` or `HTTP_PROXY` environment variables. This is independent of and composable with LLM gateway configuration.

### Best Practices for Organizations

- Pin model versions before rolling out to teams on any third-party provider
- Deploy CLAUDE.md files at organization-wide system directories and repository roots
- Use MCP servers for integrations (tickets, error logs); commit `.mcp.json` to repos
- Configure managed security policies for organization-wide Claude Code behavior
- Create a "one-click" install flow to grow adoption
- Use `/status` to verify provider, region, and auth configuration

## Full Documentation

For the complete official documentation, see the reference files:

- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Deployment option comparison, proxy/gateway setup per provider, best practices
- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock setup wizard, manual config, IAM, Mantle endpoint, Guardrails, service tiers, troubleshooting
- [Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace billing, SigV4 and API key auth, Agent SDK usage, proxy routing
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex setup wizard, region config, credential options, IAM, troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, API key and Entra ID auth, RBAC, troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway requirements, API formats, LiteLLM setup, model discovery, auth patterns

## Sources

- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
