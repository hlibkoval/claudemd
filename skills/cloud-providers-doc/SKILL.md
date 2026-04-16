---
name: cloud-providers-doc
description: Complete official documentation for running Claude Code through third-party cloud providers — Amazon Bedrock (Invoke API and Mantle), Google Vertex AI, Microsoft Foundry, and LLM gateways such as LiteLLM — including setup, IAM/RBAC, model pinning, and proxy routing.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers and LLM gateways.

## Quick Reference

### Deployment options at a glance

| Provider | Enable var | Auth | Setup wizard |
|---|---|---|---|
| Anthropic (default) | none | API key / Claude.ai SSO | `claude` login |
| Amazon Bedrock (Invoke API) | `CLAUDE_CODE_USE_BEDROCK=1` | AWS credentials or Bedrock API key | `/setup-bedrock` |
| Amazon Bedrock (Mantle) | `CLAUDE_CODE_USE_MANTLE=1` | AWS credentials (same as Bedrock) | via `/setup-bedrock` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | GCP Application Default Credentials | `/setup-vertex` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | Azure API key or Entra ID | (manual) |

When any of these providers is active, `/login` and `/logout` are disabled — authentication is handled by the cloud SDK's credential chain.

### Amazon Bedrock — environment variables

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock Invoke API (`1` or `true`) |
| `AWS_REGION` | **Required**. Not read from `.aws` config |
| `AWS_PROFILE` | Use a named profile from `~/.aws/` |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` | Explicit credentials |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key (simpler than full AWS creds) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint (gateways) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip client-side SigV4 when a gateway handles auth |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching if the region doesn't support it |

**Bedrock defaults (no pinning):**

| Model type | Default |
|---|---|
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**Pinning example:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-6-v1'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

**Credential refresh settings** (in Claude Code settings file):

| Setting | Purpose |
|---|---|
| `awsAuthRefresh` | Command that modifies `.aws/` (e.g. `aws sso login --profile myprofile`). Output shown to user; no interactive input |
| `awsCredentialExport` | Command that prints `{"Credentials": {"AccessKeyId", "SecretAccessKey", "SessionToken"}}` JSON. Output captured silently |

Claude Code runs these automatically when credentials expire. For multiple versions of the same family, use `modelOverrides` in settings to map `claude-opus-4-6`, `claude-opus-4-5-…`, etc., to distinct application inference profile ARNs.

**Required IAM actions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, plus `aws-marketplace:ViewSubscriptions` / `Subscribe` conditioned on `aws:CalledViaLast = bedrock.amazonaws.com`.

**1M context window:** append `[1m]` to the pinned model ID (Opus 4.6 and Sonnet 4.6 only). Claude Code enables the extended context automatically.

### Bedrock Mantle

Mantle is a Bedrock endpoint that speaks the native Anthropic API shape (not the Invoke API). Requires Claude Code v2.1.94+.

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy setups |

Mantle model IDs are prefixed `anthropic.` with no version suffix (e.g. `anthropic.claude-haiku-4-5`). Inference profile IDs (`us.anthropic.…`) do **not** work on Mantle. Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run them side-by-side — model IDs matching the Mantle format route to Mantle; others go to the Invoke API. `/status` shows `Amazon Bedrock (Mantle)` or `Amazon Bedrock + Amazon Bedrock (Mantle)`. To surface a Mantle model in `/model`, list it in `availableModels` in settings.

**Mantle errors:**

| Status | Meaning |
|---|---|
| `403` | Account not granted access to that model — contact AWS account team |
| `400` with model ID | Model is not served on Mantle (wrong lineup) |

### Google Vertex AI — environment variables

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex integration |
| `CLOUD_ML_REGION` | Region, or `global` for global endpoint |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` / `GOOGLE_APPLICATION_CREDENTIALS` | Override project / service-account key |
| `ANTHROPIC_VERTEX_BASE_URL` | Override endpoint (gateways) |
| `VERTEX_REGION_CLAUDE_*` (e.g. `VERTEX_REGION_CLAUDE_HAIKU_4_5`, `VERTEX_REGION_CLAUDE_4_6_SONNET`) | Per-model region override when `CLOUD_ML_REGION=global` but a model doesn't support the global endpoint |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip client-side auth when a gateway handles GCP auth |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |

Wizard requires Claude Code v2.1.98+. Enable the API with `gcloud services enable aiplatform.googleapis.com` and request access in the Model Garden (24-48h approval).

**Vertex defaults:**

| Model type | Default |
|---|---|
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**Pinning example:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

**Required IAM:** `roles/aiplatform.user` (covers `aiplatform.endpoints.predict`). Prompt caching is automatic via `cache_control` ephemeral flag.

**1M context window:** Opus 4.6, Sonnet 4.6, Sonnet 4.5, and Sonnet 4. Append `[1m]` to the pinned model ID.

**Troubleshooting:** 404 "model not found" on `global` means the model doesn't support the global endpoint — either pick a supported model or set a `VERTEX_REGION_<MODEL>` override. 429s on regional endpoints often mean switching to `CLOUD_ML_REGION=global` will help.

### Microsoft Foundry — environment variables

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL alternative to `…RESOURCE` |
| `ANTHROPIC_FOUNDRY_API_KEY` | API-key auth. When unset, uses the Azure SDK default credential chain (Entra ID via `az login`, etc.) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip client-side auth when a gateway handles Azure auth |

Create a Foundry resource in `ai.azure.com`, deploy Opus/Sonnet/Haiku, then pin model variables to the deployment names:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

**Required RBAC:** `Azure AI User` + `Cognitive Services User` built-in roles, or a custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

**"ChainedTokenCredential authentication failed":** run `az login` or set `ANTHROPIC_FOUNDRY_API_KEY`.

### Startup model checks (Bedrock and Vertex)

When Claude Code starts, it verifies configured models are accessible:

- Pinned model **older** than current default, and newer is available: prompts to update the pin; accepting rewrites user settings and restarts. Declining is remembered until next default change. Pins pointing at an application inference profile ARN are skipped (Bedrock).
- Not pinned and current default **unavailable**: falls back to the previous version for the session only (not persisted), shows a notice. Enable the model or pin a version to make it permanent.

Requires Claude Code v2.1.94+ (Bedrock) / v2.1.98+ (Vertex).

### Pin-model variables (all third-party providers)

`ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_MODEL` (primary model override). See `/en/model-config` for the full list.

### Proxy and gateway routing

Two orthogonal mechanisms that can be combined:

| Mechanism | Variable(s) | Use case |
|---|---|---|
| Corporate proxy | `HTTP_PROXY`, `HTTPS_PROXY` | All outbound via HTTP(S) proxy |
| LLM gateway | `ANTHROPIC_BASE_URL`, `ANTHROPIC_BEDROCK_BASE_URL`, `ANTHROPIC_VERTEX_BASE_URL`, `ANTHROPIC_BEDROCK_MANTLE_BASE_URL`, `ANTHROPIC_FOUNDRY_BASE_URL` | Centralize auth / tracking / routing |

Pair a gateway with `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_SKIP_MANTLE_AUTH=1`, or `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` when the gateway injects provider credentials server-side. Verify with `/status`.

### LLM gateway requirements

A gateway must expose **at least one** of these API formats and forward specific header/body fields:

| API format | Path | Must forward |
|---|---|---|
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers: `anthropic-beta`, `anthropic-version` |

Claude Code adds `X-Claude-Code-Session-Id` on every request so gateways can aggregate by session without parsing the body. When using the Anthropic Messages format in front of Bedrock/Vertex, set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` if features misbehave.

### LiteLLM integration

| Setup | Variables |
|---|---|
| Unified (Anthropic format, recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=…/bedrock`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=…/vertex_ai/v1`, `ANTHROPIC_VERTEX_PROJECT_ID`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=us-east5` |

**Auth:** `ANTHROPIC_AUTH_TOKEN` (static, sent as `Authorization`). For rotating keys, use `apiKeyHelper` (a command that prints the token) with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval; sent as both `Authorization` and `X-Api-Key`. `apiKeyHelper` has lower precedence than `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_API_KEY`.

**Security note:** LiteLLM PyPI versions **1.82.7 and 1.82.8** were compromised with credential-stealing malware. Do not install them; rotate credentials if already installed. LiteLLM is not endorsed, maintained, or audited by Anthropic.

### Deployment option comparison

| | Claude Teams/Enterprise | Anthropic Console | Bedrock | Vertex AI | Foundry |
|---|---|---|---|---|---|
| Best for | Most orgs (recommended) | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Teams $150/seat or PAYG; Enterprise: contact sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Auth | Claude.ai SSO / email | API key | API key or AWS creds | GCP creds | API key or Entra ID |
| Cost tracking | Usage dashboard | Usage dashboard | AWS Cost Explorer | GCP Billing | Azure Cost Mgmt |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team mgmt, SSO, monitoring | None | IAM, CloudTrail | IAM, Cloud Audit Logs | RBAC, Azure Monitor |

All providers have prompt caching enabled by default.

### Organization best practices

- **Pin model versions** on any cloud provider before rolling out to multiple users.
- **Deploy CLAUDE.md** org-wide (e.g. `/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS) and per-repo.
- **Configure managed policy settings** for permissions that local config cannot override.
- **Centralize MCP config** (`.mcp.json` in source control) so everyone gets the same integrations.
- **Dedicated cloud account/project** for Claude Code simplifies cost tracking and access control.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock prerequisites, `/setup-bedrock` wizard, manual setup, IAM, credential refresh, model pinning, inference profiles, startup checks, Mantle endpoint, Guardrails, and troubleshooting.
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex prerequisites, `/setup-vertex` wizard, API enablement, Model Garden access, global vs regional endpoints, IAM, startup checks, and troubleshooting.
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Foundry resource provisioning, API key vs Entra ID auth, model deployment pinning, Azure RBAC, and troubleshooting.
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Compare deployment options, corporate proxy vs LLM gateway setup per provider, and rollout best practices.
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API-format requirements, headers, model selection, LiteLLM unified and pass-through endpoints, static vs dynamic API-key auth.

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview (third-party integrations): https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
