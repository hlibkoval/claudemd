---
name: cloud-providers-doc
description: Complete documentation for deploying Claude Code through cloud providers (Amazon Bedrock, Google Vertex AI, Microsoft Foundry) and LLM gateways. Covers sign-in wizards, manual setup, credentials, IAM/RBAC configuration, model pinning, 1M context, Mantle endpoint, proxy/gateway routing, and troubleshooting.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers and LLM gateways.

## Quick Reference

### Deployment options

| Provider | Enable flag | Auth | Best for |
| :--- | :--- | :--- | :--- |
| Anthropic Console | (default) | API key | Individual developers |
| Claude for Teams/Enterprise | (default) | Claude.ai SSO or email | Most organizations (recommended) |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | AWS creds, SSO profile, Bedrock API key | AWS-native deployments |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | GCP ADC, service account | GCP-native deployments |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | API key or Microsoft Entra ID | Azure-native deployments |

### Sign-in wizards (interactive setup)

- Run `claude`, choose **3rd-party platform**, then the provider. The wizard detects credentials, region/project, verifies model access, and writes everything to the `env` block of the user settings file.
- Re-run with `/setup-bedrock` or `/setup-vertex` to change credentials, region, or model pins.
- Vertex wizard requires Claude Code v2.1.98+; Bedrock startup model checks and Mantle require v2.1.94+.

### Amazon Bedrock

Core environment variables:

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1  # required; not read from ~/.aws config
# Optional overrides
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
export ANTHROPIC_BEDROCK_BASE_URL=https://bedrock-runtime.us-east-1.amazonaws.com
```

Credential options (default AWS SDK credential chain):
- `aws configure`
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`
- `AWS_PROFILE` after `aws sso login --profile=...`
- `aws login` (AWS Management Console credentials)
- `AWS_BEARER_TOKEN_BEDROCK` (Bedrock API key)

Advanced credential refresh (in settings file):

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

- `awsAuthRefresh` — runs commands that modify the `.aws` directory; output shown to user.
- `awsCredentialExport` — for setups that cannot modify `.aws`; must output JSON `{"Credentials": {"AccessKeyId": ..., "SecretAccessKey": ..., "SessionToken": ...}}`.

Model pinning (use inference profile IDs, typically with `us.` prefix):

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-6-v1'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

Bedrock defaults when no pins are set:

| Model type | Default |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

Map multiple versions to distinct ARNs via `modelOverrides` in settings (for application inference profiles exposed in the `/model` picker).

IAM policy requires: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on `inference-profile/*`, `application-inference-profile/*`, `foundation-model/*`, plus `aws-marketplace:ViewSubscriptions`/`Subscribe`.

`/login` and `/logout` are disabled when Bedrock is active. 1M context: append `[1m]` to the pinned model ID. Guardrails: set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion`.

### Bedrock Mantle endpoint

Mantle serves Claude through the native Anthropic API shape instead of the Bedrock Invoke API.

```bash
export CLAUDE_CODE_USE_MANTLE=1
export AWS_REGION=us-east-1
# Optional
export ANTHROPIC_BEDROCK_MANTLE_BASE_URL=https://your-gateway.example.com
export CLAUDE_CODE_SKIP_MANTLE_AUTH=1  # for gateways that inject credentials
```

- Mantle model IDs are prefixed `anthropic.` without version suffix (e.g., `anthropic.claude-haiku-4-5`).
- Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to route Mantle-format IDs to Mantle and other IDs to Invoke API.
- Surface Mantle models in the picker via `availableModels` in settings.
- `/status` shows `Amazon Bedrock (Mantle)` when active.

### Google Vertex AI

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global  # or a specific region
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
# Optional
export ANTHROPIC_VERTEX_BASE_URL=https://aiplatform.googleapis.com
export DISABLE_PROMPT_CACHING=1
# Per-model region overrides when using CLOUD_ML_REGION=global
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

Setup:
1. `gcloud services enable aiplatform.googleapis.com`
2. Request access in [Vertex AI Model Garden](https://console.cloud.google.com/vertex-ai/model-garden) (approval may take 24-48h).
3. Authenticate via gcloud ADC, service account key, or ambient credentials. Project comes from `ANTHROPIC_VERTEX_PROJECT_ID` or `GCLOUD_PROJECT`/`GOOGLE_CLOUD_PROJECT`/`GOOGLE_APPLICATION_CREDENTIALS`.

Pinning:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

Vertex defaults when no pins are set:

| Model type | Default |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

IAM: the `roles/aiplatform.user` role (needs `aiplatform.endpoints.predict`). `/login` and `/logout` disabled. Prompt caching supported automatically with `cache_control` ephemeral; disable with `DISABLE_PROMPT_CACHING=1`. 1M context: append `[1m]` to the pinned model ID.

### Microsoft Foundry

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}
# Or:
# export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

Authentication:
- **API key**: `export ANTHROPIC_FOUNDRY_API_KEY=your-key` (from Endpoints and keys in Foundry portal).
- **Microsoft Entra ID**: when `ANTHROPIC_FOUNDRY_API_KEY` is unset, Claude Code uses the Azure SDK default credential chain (e.g., `az login`).

Setup: create a Foundry resource in [ai.azure.com](https://ai.azure.com/), create deployments for Opus/Sonnet/Haiku, then pin:

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

Model values must match the deployment names. RBAC: `Azure AI User` and `Cognitive Services User` roles (custom roles need `Microsoft.CognitiveServices/accounts/providers/*` data action). `/login` and `/logout` disabled.

### Startup model checks (Bedrock and Vertex)

- If a pinned version is older than the current default and your account can invoke the newer version, Claude Code prompts to update the pin (writes to user settings and restarts). Declines are remembered until the next default change.
- If not pinned and the default is unavailable, Claude Code falls back to the previous version for the current session and shows a notice (not persisted).
- Bedrock skips pins that point to application inference profile ARNs.

### LLM gateways

LLM gateways sit between Claude Code and the provider for centralized auth, usage tracking, cost controls, audit logging, and provider-neutral routing.

Gateway must expose one of:

| API format | Endpoints | Must forward |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Headers `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Headers `anthropic-beta`, `anthropic-version` |

When using Anthropic Messages format over Bedrock/Vertex, may need `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

Every request includes `X-Claude-Code-Session-Id` so proxies can group requests without parsing the body.

Authentication options (LiteLLM example):

```bash
# Static key
export ANTHROPIC_AUTH_TOKEN=sk-litellm-static-key
```

```json
{ "apiKeyHelper": "~/bin/get-litellm-key.sh" }
```

```bash
export CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000
```

`apiKeyHelper` has lower precedence than `ANTHROPIC_AUTH_TOKEN` / `ANTHROPIC_API_KEY`. The value is sent as both `Authorization` and `X-Api-Key` headers.

Endpoint variables:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_BASE_URL` | Anthropic Messages endpoint (unified recommended) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock pass-through via gateway |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex pass-through via gateway |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry pass-through via gateway |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip client-side AWS auth (gateway handles it) |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip client-side GCP auth |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip client-side Azure auth |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for Mantle |

**LiteLLM safety warning**: LiteLLM PyPI 1.82.7 and 1.82.8 shipped credential-stealing malware. Do not install those versions; remove the package, rotate credentials, follow remediation in BerriAI/litellm#24518.

### Corporate proxies

Set `HTTPS_PROXY` / `HTTP_PROXY` to route all traffic (any provider) through a corporate proxy. Proxies and LLM gateways can be combined. Use `/status` to verify the configuration is active.

### Enterprise best practices

- **Pin model versions** for any third-party deployment to avoid breaking users when new models ship.
- Deploy CLAUDE.md files at organization-wide and repository levels so Claude Code knows your codebase.
- Use a "one click" install for custom dev environments.
- Start users with guided usage (Q&A, small bug fixes, planned changes).
- Configure managed security policies that cannot be overridden locally.
- Centralize MCP server configuration via a checked-in `.mcp.json`.

### Common troubleshooting

- **Bedrock SSO loop**: remove `awsAuthRefresh` and run `aws sso login` manually; corporate VPN/TLS inspection can interrupt the browser flow.
- **Bedrock region errors**: `aws bedrock list-inference-profiles --region <region>`; use inference profiles for cross-region access. Claude Code uses the Invoke API, not Converse.
- **Bedrock "on-demand throughput isn't supported"**: specify the model as an inference profile ID.
- **Mantle 403**: account lacks access to the requested model, contact AWS account team.
- **Mantle 400**: model is not served on Mantle; use a Mantle-format ID or enable both endpoints.
- **Vertex quota (429)**: request quota increase in Cloud Console, or switch to `CLOUD_ML_REGION=global`.
- **Vertex 404 model not found**: confirm enabled in Model Garden, check region access, verify global-endpoint support or use `VERTEX_REGION_<MODEL>`.
- **Foundry "Failed to get token from azureADTokenProvider"**: configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock setup, credentials, IAM, model pinning, Mantle endpoint, Guardrails, troubleshooting.
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex AI setup wizard, GCP credentials, region configuration, IAM, 1M context, troubleshooting.
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Foundry resource provisioning, API key vs Entra ID auth, Azure RBAC, model pinning.
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — Compare Teams/Enterprise, Console, and cloud providers; proxy and gateway examples; org-wide best practices.
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API requirements, authentication methods, unified vs pass-through endpoints, LiteLLM setup.

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
