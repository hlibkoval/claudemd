---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through third-party cloud providers — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry — and for configuring LLM gateways.

## Quick Reference

### Deployment Options Comparison

| Option | Best for | Billing | Auth |
| :--- | :--- | :--- | :--- |
| Claude for Teams/Enterprise | Most organizations (recommended) | Per-seat or contact sales | Claude.ai SSO or email |
| Anthropic Console | Individual developers | PAYG | API key |
| Amazon Bedrock | AWS-native deployments | PAYG through AWS | API key or AWS credentials |
| Claude Platform on AWS | AWS Marketplace billing + Claude API features | PAYG through AWS Marketplace | API key or AWS credentials (SigV4) |
| Google Vertex AI | GCP-native deployments | PAYG through GCP | GCP credentials |
| Microsoft Foundry | Azure-native deployments | PAYG through Azure | API key or Microsoft Entra ID |

### Enable a Provider: Key Environment Variables

**Amazon Bedrock**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK=1` | Enable Bedrock |
| `AWS_REGION` | AWS region (optional if set in profile) |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` | Static credentials |
| `AWS_PROFILE` | Use a named AWS profile |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key (simpler auth) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override endpoint URL |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Region override for Haiku-class model |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle endpoint (Anthropic API shape over Bedrock) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side auth for gateway setups |

**Claude Platform on AWS**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | Enable Claude Platform on AWS |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required workspace ID (`wrkspc_…`) |
| `AWS_REGION` | Region for endpoint URL |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key (takes precedence over SigV4) |
| `ANTHROPIC_AWS_BASE_URL` | Override endpoint URL |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` | Skip client-side auth for gateway setups |

**Google Vertex AI**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX=1` | Enable Vertex AI |
| `CLOUD_ML_REGION` | Region: `global`, `eu`, `us`, or specific region |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint URL |
| `VERTEX_REGION_CLAUDE_*` | Per-model region override when using global endpoint |
| `ENABLE_TOOL_SEARCH=true` | Enable MCP tool search (off by default on Vertex AI) |

**Microsoft Foundry**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth (omit to use Entra ID) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` | Skip client-side auth for gateway setups |

### Pin Model Versions (all providers)

Always pin models for team rollouts to control when users move to a new release.

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | Pin Fable alias |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus alias |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet alias |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku alias |
| `ANTHROPIC_MODEL` | Override the primary model directly |

Bedrock model IDs use inference profile format, e.g. `us.anthropic.claude-sonnet-4-6`. Vertex AI uses `claude-sonnet-4-6` or `claude-haiku-4-5@20251001`. Foundry and Claude Platform on AWS use the same IDs as the direct Claude API.

For GovCloud regions on Bedrock, use the `us-gov.` prefix. Append `[1m]` to a model ID to enable the 1M token context window (supported on Bedrock and Vertex AI for Opus 4.6+ and Sonnet 4.6).

### Advanced Credential Refresh

| Setting | Trigger | Effect |
| :--- | :--- | :--- |
| `awsAuthRefresh` (settings.json) | AWS credentials detected as expired | Runs the command, then retries (Bedrock + Claude Platform on AWS) |
| `awsCredentialExport` (settings.json) | Every credential reload | Captures JSON output with `Credentials` object; credentials cached until `Expiration` - 5 min |
| `gcpAuthRefresh` (settings.json) | GCP credentials expired or unloadable | Runs the command, then retries (Vertex AI) |

`awsCredentialExport` output must be JSON with shape: `{ "Credentials": { "AccessKeyId", "SecretAccessKey", "SessionToken", "Expiration" } }`.

### Proxy and Gateway Configuration

| Provider | Corporate proxy var | LLM gateway URL var | Skip auth var |
| :--- | :--- | :--- | :--- |
| Anthropic API | `HTTPS_PROXY` | `ANTHROPIC_BASE_URL` | n/a |
| Bedrock | `HTTPS_PROXY` | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Claude Platform on AWS | `HTTPS_PROXY` | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Vertex AI | `HTTPS_PROXY` | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `HTTPS_PROXY` | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

### LLM Gateway Requirements

A gateway must expose at least one of these API formats:

1. **Anthropic Messages**: `/v1/messages`, `/v1/messages/count_tokens` — must forward `anthropic-beta` and `anthropic-version` request headers
2. **Bedrock InvokeModel**: `/invoke`, `/invoke-with-response-stream` — must preserve `anthropic_beta` and `anthropic_version` body fields
3. **Vertex rawPredict**: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` — must forward `anthropic-beta` and `anthropic-version` request headers

Key request headers Claude Code sends to gateways:

| Header | Purpose |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Aggregate all requests from one session |
| `X-Claude-Code-Agent-Id` | Attribute cost to a subagent or teammate |
| `X-Claude-Code-Parent-Agent-Id` | Track nested agent hierarchy |

Gateway model discovery (Anthropic Messages format only): set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup. Results cached to `~/.claude/cache/gateway-models.json`. Requires Claude Code v2.1.129+.

### LiteLLM Quick Setup

```bash
# Unified Anthropic format endpoint (recommended)
export ANTHROPIC_BASE_URL=https://litellm-server:4000

# Bedrock pass-through
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_USE_BEDROCK=1

# Vertex AI pass-through
export ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
export CLAUDE_CODE_USE_VERTEX=1
```

Auth options: `ANTHROPIC_AUTH_TOKEN` (sent as bearer token) or `apiKeyHelper` in settings.json (a script that prints the key). Set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` to control refresh interval.

Warning: LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware — do not install those versions.

### IAM Permissions

**Bedrock minimum IAM policy actions:**
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`
- `bedrock:GetInferenceProfile`

**Vertex AI minimum IAM role:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`)

**Microsoft Foundry minimum RBAC:** `Azure AI User` or `Cognitive Services User` role; or a custom role with `Microsoft.CognitiveServices/accounts/providers/*` data action

**Claude Platform on AWS:** see IAM action reference at `https://platform.claude.com/docs/en/api/claude-platform-on-aws-iam-actions`

### Startup Wizard Commands

| Command | Provider | Min version |
| :--- | :--- | :--- |
| `/setup-bedrock` | Amazon Bedrock | any |
| `/setup-vertex` | Google Vertex AI | v2.1.98 |

Foundry has no interactive wizard — use environment variables only.

### Startup Model Checks

Bedrock (v2.1.94+) and Vertex AI (v2.1.98+) verify model availability at startup. If the default is unavailable, Claude Code falls back to the previous version for the session. If a pinned version is older than the current default and the newer version is accessible, Claude Code prompts you to update the pin. Foundry has no startup model check — requests fail immediately if the default is unavailable.

### Prompt Caching

Enabled by default on all providers. To disable: `DISABLE_PROMPT_CACHING=1`. To request a 1-hour TTL (billed at higher rate): `ENABLE_PROMPT_CACHING_1H=1`. Not available in all Bedrock regions — check supported models and regions in Bedrock documentation.

### Troubleshooting Quick Reference

| Symptom | Fix |
| :--- | :--- |
| Bedrock SSO loop (browser tabs spawn repeatedly) | Remove `awsAuthRefresh` from settings; log in manually before starting Claude Code |
| Bedrock region errors | `aws bedrock list-inference-profiles --region <region>`; use inference profile IDs |
| Bedrock "on-demand throughput not supported" | Use an inference profile ID instead of a foundation model ID |
| Vertex "Could not load default credentials" | `gcloud auth application-default login` or set `GOOGLE_APPLICATION_CREDENTIALS` |
| Vertex 404 "model not found" | Enable model in Model Garden; check region support; use `VERTEX_REGION_<MODEL>` vars |
| Vertex 429 | Both primary and small/fast model must be supported in the selected region; consider `global` |
| Foundry auth error `ChainedTokenCredential failed` | Configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY` |
| Claude Platform on AWS 403 | IAM principal lacks permission; rotate `ANTHROPIC_AWS_API_KEY` if set |
| Claude Platform on AWS missing-workspace error | Set `ANTHROPIC_AWS_WORKSPACE_ID` |
| Requests still go to `api.anthropic.com` | Confirm provider enable var is set; Bedrock and Foundry take precedence over Claude Platform on AWS |
| Mantle endpoint not active | Confirm `CLAUDE_CODE_USE_MANTLE` is exported; check `/status` |
| Mantle 403 | AWS account not granted access to the Mantle model — contact AWS account team |
| Mantle 400 naming model ID | Use Mantle-format IDs (`anthropic.claude-haiku-4-5`), not inference profile IDs |

Run `/status` inside Claude Code to confirm the resolved provider, region, workspace, and base URL.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — setup wizard, manual config, IAM policy, credential refresh, model pinning, Mantle endpoint, Guardrails, service tiers, 1M context window, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — SigV4 and API key auth, workspace setup, model pinning, Agent SDK usage, proxy/gateway routing
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — setup wizard, manual config, IAM, region/global/multi-region endpoints, credential refresh, model pinning, 1M context window, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — API key and Entra ID auth, Azure RBAC, model pinning, prompt caching, troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — compare all deployment options, proxy and gateway config patterns, org best practices
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway API format requirements, request headers, model discovery, LiteLLM setup, auth methods

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
