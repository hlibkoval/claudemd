---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry — plus LLM gateway configuration and a deployment options comparison.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Best for** | Most organizations (recommended) | Individual developers | AWS-native deployments | AWS Marketplace billing with Claude API features | GCP-native deployments | Azure-native deployments |
| **Billing** | Per-seat or contact sales | PAYG | PAYG through AWS | PAYG through AWS Marketplace | PAYG through GCP | PAYG through Azure |
| **Authentication** | Claude.ai SSO or email | API key | API key or AWS credentials | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| **Cost tracking** | Usage dashboard | Usage dashboard | AWS Cost Explorer | AWS Cost Explorer | GCP Billing | Azure Cost Management |
| **Includes Claude on web** | Yes | No | No | No | No | No |
| **Enterprise features** | Team management, SSO, usage monitoring | None | IAM policies, CloudTrail | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |
| **Prompt caching** | Enabled by default | Enabled by default | Enabled by default | Enabled by default | Enabled by default | Enabled by default |

### Enable a Provider — Key Environment Variables

| Provider | Required env vars | Enable flag |
| :--- | :--- | :--- |
| **Amazon Bedrock** | `AWS_REGION` (or AWS profile with region) | `CLAUDE_CODE_USE_BEDROCK=1` |
| **Bedrock Mantle endpoint** | `AWS_REGION` | `CLAUDE_CODE_USE_MANTLE=1` |
| **Claude Platform on AWS** | `ANTHROPIC_AWS_WORKSPACE_ID`, `AWS_REGION` | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` |
| **Google Vertex AI** | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` | `CLAUDE_CODE_USE_VERTEX=1` |
| **Microsoft Foundry** | `ANTHROPIC_FOUNDRY_RESOURCE` (or `ANTHROPIC_FOUNDRY_BASE_URL`) | `CLAUDE_CODE_USE_FOUNDRY=1` |

### Model Pinning — env vars by provider

**Always pin models for team deployments.** Without pinning, aliases resolve to Claude Code's built-in defaults for each provider, which can lag the newest release.

| Model alias | Bedrock env var + example ID | Vertex AI env var + example ID | Foundry env var + example ID | Claude Platform on AWS env var + example ID |
| :--- | :--- | :--- | :--- | :--- |
| `opus` | `ANTHROPIC_DEFAULT_OPUS_MODEL=us.anthropic.claude-opus-4-8` | `ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-8` | `ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-8` | `ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-7` |
| `sonnet` | `ANTHROPIC_DEFAULT_SONNET_MODEL=us.anthropic.claude-sonnet-4-6` | `ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6` | `ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6` | `ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6` |
| `haiku` | `ANTHROPIC_DEFAULT_HAIKU_MODEL=us.anthropic.claude-haiku-4-5-20251001-v1:0` | `ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5@20251001` | `ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5` | `ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5` |

Bedrock IDs use the `us.` cross-region inference prefix. GovCloud uses `us-gov.`. For application inference profile ARNs, use the full ARN as the value.

### Provider Default Models (when nothing is pinned)

| Provider | Primary model default | Small/fast model default |
| :--- | :--- | :--- |
| Amazon Bedrock | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` | Same as primary |
| Google Vertex AI | `claude-sonnet-4-5@20250929` | Same as primary |
| Microsoft Foundry | `claude-opus-4-6` (`opus` alias) | Same as primary |
| Claude Platform on AWS | `claude-opus-4-7` (`opus` alias) | Same as primary |

### Amazon Bedrock — Credential Setup

| Method | How |
| :--- | :--- |
| **AWS CLI** | `aws configure` |
| **Access key env vars** | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| **SSO profile** | `aws sso login --profile <name>`, then `export AWS_PROFILE=<name>` |
| **Bedrock API key** | `export AWS_BEARER_TOKEN_BEDROCK=your-bedrock-api-key` |

Region resolution order (v2.1.172+): `AWS_REGION` → `AWS_DEFAULT_REGION` → active AWS profile region → `us-east-1`.

**Credential refresh settings (in settings.json):**

| Setting | When it runs | Use for |
| :--- | :--- | :--- |
| `awsAuthRefresh` | When credentials are expired or Bedrock returns a credential error | SSO flows that modify `~/.aws` (browser-based) |
| `awsCredentialExport` | On session start and every credential reload, even if valid | Cross-account credentials that differ from the default chain; must output JSON with `Credentials.AccessKeyId/SecretAccessKey/SessionToken` |

### Amazon Bedrock — IAM Policy

Required actions: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, `bedrock:GetInferenceProfile`. Resource patterns: `arn:aws:bedrock:*:*:inference-profile/*`, `arn:aws:bedrock:*:*:application-inference-profile/*`, `arn:aws:bedrock:*:*:foundation-model/*`.

`bedrock:GetInferenceProfile` is optional but avoids an extra retry round-trip when resolving application inference profile ARNs.

### Amazon Bedrock — Additional Features

| Feature | Configuration |
| :--- | :--- |
| **Guardrails** | Add `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers via `ANTHROPIC_CUSTOM_HEADERS` in settings.json |
| **Service tiers** | `export ANTHROPIC_BEDROCK_SERVICE_TIER=priority` (values: `default`, `flex`, `priority`) |
| **1M token context** | Select a 1M model variant; or append `[1m]` to a manually pinned model ID |
| **Prompt cache TTL** | Default 5 min; set `ENABLE_PROMPT_CACHING_1H=1` for 1-hour TTL (higher billing rate) |
| **Disable caching** | `export DISABLE_PROMPT_CACHING=1` |
| **Custom endpoint** | `export ANTHROPIC_BEDROCK_BASE_URL=https://...` |
| **Override Haiku region** | `export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2` |

### Bedrock Mantle Endpoint

Mantle serves Claude models via the native Anthropic API shape, using the same AWS credentials as Bedrock. Requires Claude Code v2.1.94+.

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable the Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override the default Mantle URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side auth (for gateway setups) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override AWS region for the small/fast model |

Mantle model IDs use `anthropic.` prefix without a version suffix (e.g., `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route across both endpoints simultaneously. `/status` shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`.

### modelOverrides — Map Model Versions to Inference Profile ARNs

When you need multiple versions of the same family in the `/model` picker, each routed to a distinct application inference profile, use `modelOverrides` in settings.json instead of env vars:

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod",
    "claude-opus-4-6": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-46-prod"
  }
}
```

### Google Vertex AI — Credential Setup

| Method | How |
| :--- | :--- |
| **Application Default Credentials** | `gcloud auth application-default login` |
| **Service account key** | `export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json` |
| **X.509 WIF** | Set `GOOGLE_APPLICATION_CREDENTIALS` to credential config file (v2.1.121+) |

Project ID resolution order: `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` / credential file → `ANTHROPIC_VERTEX_PROJECT_ID` → `gcloud` config or attached service account.

Credential refresh: set `gcpAuthRefresh` in settings.json (e.g., `"gcpAuthRefresh": "gcloud auth application-default login"`).

### Google Vertex AI — Region Configuration

`CLOUD_ML_REGION` accepts: `global`, multi-region (`eu`, `us`), or a specific region (`us-east5`). For models that don't support global endpoints, set per-model region overrides:

```bash
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

See the env-vars reference for the full list of `VERTEX_REGION_CLAUDE_*` variables.

MCP tool search is disabled by default on Vertex AI. Set `ENABLE_TOOL_SEARCH=true` to enable it for Claude Sonnet 4.5+ and Claude Opus 4.5+.

### Google Vertex AI — IAM

Required role: `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

### Microsoft Foundry — Setup

1. Create a resource in [Microsoft Foundry portal](https://ai.azure.com/), create Claude deployments (Opus, Sonnet, Haiku).
2. Auth: set `ANTHROPIC_FOUNDRY_API_KEY=your-api-key` (Option A), or omit it to use Entra ID via `az login` (Option B).
3. Set `CLAUDE_CODE_USE_FOUNDRY=1` and `ANTHROPIC_FOUNDRY_RESOURCE=your-resource-name`.
4. Pin models to match your deployment names (see model pinning table above).

No interactive setup wizard — env vars are the only configuration path.

Required RBAC: `Azure AI User` or `Cognitive Services User` (or a custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction).

### Claude Platform on AWS — Setup

Claude Platform on AWS is the Anthropic-operated Claude API with AWS auth and AWS Marketplace billing. Requests reach Anthropic's API directly (same models and features as the direct Claude API).

1. Subscribe through AWS Marketplace; provision a workspace; obtain the workspace ID.
2. Auth: AWS credentials with SigV4 (Option A), or set `ANTHROPIC_AWS_API_KEY=sk-ant-xxxxx` (Option B).
3. Set `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID=wrkspc_...`, `AWS_REGION=us-east-1`.
4. Pin model versions (see model pinning table above). Note: `ANTHROPIC_DEFAULT_FABLE_MODEL` is also available.

Base URL is computed from `AWS_REGION`: `https://aws-external-anthropic.{region}.api.aws`. Override with `ANTHROPIC_AWS_BASE_URL`.

Note: `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_FOUNDRY` take precedence over Claude Platform on AWS in provider routing — unset them if set.

For gateway/proxy routing: set `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` to let the gateway add SigV4 headers.

### Proxy and Gateway Configuration

**Corporate proxy** — use `HTTPS_PROXY` / `HTTP_PROXY` for outbound network compliance.

**LLM gateway** — override the endpoint URL per provider:

| Provider | Base URL env var | Skip-auth env var |
| :--- | :--- | :--- |
| Claude API / Anthropic | `ANTHROPIC_BASE_URL` | — |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Bedrock Mantle | `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |

### LLM Gateway Requirements

The gateway must expose one of: Anthropic Messages API (`/v1/messages`, `/v1/messages/count_tokens`), Bedrock InvokeModel (`/invoke`, `/invoke-with-response-stream`), or Vertex rawPredict (`:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict`).

Gateways must forward `anthropic-beta` and `anthropic-version` headers (Anthropic + Vertex formats) or preserve `anthropic_beta` and `anthropic_version` body fields (Bedrock format).

**Claude Code request headers sent to gateways:**

| Header | Description |
| :--- | :--- |
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate that issued the request (present for in-process subagents) |
| `X-Claude-Code-Parent-Agent-Id` | ID of the spawning agent (present for nested agents) |

Set `CLAUDE_CODE_ATTRIBUTION_HEADER=0` to omit the attribution block from the system prompt (useful when the gateway implements its own prompt cache keyed on the full body).

**Gateway model discovery** (Anthropic Messages format only, v2.1.129+): set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query the gateway's `/v1/models` at startup and add returned models to the `/model` picker.

### LiteLLM — Configuration Methods

| Method | Use when |
| :--- | :--- |
| Static API key (`ANTHROPIC_AUTH_TOKEN=sk-litellm-...`) | Simple fixed-key setup |
| `apiKeyHelper` script in settings.json + `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Rotating keys or per-user auth |
| Unified endpoint (`ANTHROPIC_BASE_URL=https://litellm-server:4000`) | Recommended; supports load balancing, fallbacks, cost tracking |
| Provider pass-through: Bedrock (`ANTHROPIC_BEDROCK_BASE_URL=...` + `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` + `CLAUDE_CODE_USE_BEDROCK=1`) | Bedrock-specific routing |
| Provider pass-through: Vertex (`ANTHROPIC_VERTEX_BASE_URL=...` + `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` + `CLAUDE_CODE_USE_VERTEX=1`) | Vertex-specific routing |

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Do not install these versions; rotate all credentials if affected.

### Startup Model Checks

When Claude Code starts with Bedrock or Vertex AI configured (v2.1.94+ for Bedrock, v2.1.98+ for Vertex), it verifies the intended models are accessible. If a pinned model is outdated but a newer version is available, Claude Code prompts to update the pin. If the default model is unavailable and no pin is set, Claude Code falls back to the previous version for the current session (not persisted). Microsoft Foundry has no startup model check — requests fail immediately if the default is unavailable.

### Troubleshooting Quick Reference

| Symptom | Provider | Fix |
| :--- | :--- | :--- |
| "Could not load the default credentials" | Vertex AI | Run `gcloud auth application-default login` or set `GOOGLE_APPLICATION_CREDENTIALS` |
| "model not found" 404 | Vertex AI | Confirm model is Enabled in Model Garden; check region availability; use `VERTEX_REGION_<MODEL>` for models that don't support global endpoints |
| 429 errors | Vertex AI | Switch to `CLOUD_ML_REGION=global`; ensure both models supported in selected region |
| "on-demand throughput isn't supported" | Bedrock | Use an inference profile ID instead of a foundation model ID |
| Browser tabs spawning repeatedly (SSO) | Bedrock | Remove `awsAuthRefresh` setting; run `aws sso login` manually before starting Claude Code |
| `403 Forbidden` / `AccessDenied` | Claude Platform on AWS | IAM principal lacks `aws-external-anthropic` actions, or workspace API key is stale |
| Missing-workspace error | Claude Platform on AWS | `ANTHROPIC_AWS_WORKSPACE_ID` is unset or empty |
| Requests go to `api.anthropic.com` | Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS` unset or falsy; or `CLAUDE_CODE_USE_BEDROCK`/`FOUNDRY` takes precedence |
| "Failed to get token from azureADTokenProvider" | Foundry | Configure Entra ID in environment, or set `ANTHROPIC_FOUNDRY_API_KEY` |
| Mantle shows wrong status | Bedrock (Mantle) | Confirm `CLAUDE_CODE_USE_MANTLE` is exported to the shell; `403` = model not granted; `400` = model not on Mantle |

Use `/status` inside Claude Code to confirm the resolved provider, region, workspace ID, and any URL overrides.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Prerequisites, Bedrock wizard, manual setup, IAM policy, credential refresh settings, Mantle endpoint, Guardrails, service tiers, 1M context window, model pinning, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace subscription, SigV4 and API key auth, workspace configuration, model pinning, Agent SDK usage, proxy routing, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Prerequisites, Vertex wizard, manual setup, region configuration, GCP credentials, IAM, model pinning, 1M context window, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Prerequisites, provisioning a Foundry resource, API key and Entra ID auth, environment variables, Azure RBAC, model pinning, troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Deployment options comparison, corporate proxy vs. LLM gateway configuration per provider, best practices for organizations
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API format requirements, request headers, gateway model discovery, LiteLLM setup (static key, dynamic key helper, unified and pass-through endpoints)

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
