---
name: cloud-providers-doc
description: Documentation for running Claude Code through cloud providers (Amazon Bedrock, Google Vertex AI, Microsoft Foundry), enterprise deployment options, LLM gateway configuration, and corporate proxy setups.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through third-party cloud providers (Amazon Bedrock, Google Vertex AI, Microsoft Foundry) and configuring LLM gateways and enterprise routing.

## Quick Reference

### Provider enable flags

| Provider | Enable variable | Required companion variables |
| :--- | :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Bedrock Mantle | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` (or `ANTHROPIC_FOUNDRY_BASE_URL`) |

### Authentication options by provider

| Provider | Methods |
| :--- | :--- |
| Bedrock | AWS profile from `~/.aws`, Bedrock API key (`AWS_BEARER_TOKEN_BEDROCK`), access key + secret, environment credentials, SSO via `awsAuthRefresh` |
| Vertex AI | Application Default Credentials via `gcloud`, service account key file, environment credentials |
| Foundry | API key (`ANTHROPIC_FOUNDRY_API_KEY`) or Microsoft Entra ID via `DefaultAzureCredential` (e.g. `az login`) |

### Login wizards / slash commands

| Wizard | Slash command | Min Claude Code version |
| :--- | :--- | :--- |
| Bedrock setup | `/setup-bedrock` | v2.1.94 (also required for Mantle and startup model checks) |
| Vertex AI setup | `/setup-vertex` | v2.1.98 |
| Foundry | (no wizard, env-var based) | n/a |

The wizards are launched by running `claude`, choosing **3rd-party platform**, then the provider. They write results to the `env` block of your user settings file. When using any cloud provider, `/login` and `/logout` are disabled.

### Model pinning environment variables

All three providers honor the same pinning variables (values are provider-specific):

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus-class model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet-class model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku-class small/fast model |
| `ANTHROPIC_MODEL` | Override the active primary model |

Pin specific versions before rolling out to multiple users — without pins, `sonnet`/`opus`/`haiku` aliases resolve to the latest version, which may not be enabled in your account. Append `[1m]` to a model ID to enable the 1M token context window (Bedrock and Vertex AI).

### Provider-specific model ID formats

| Provider | Example model ID |
| :--- | :--- |
| Bedrock (inference profile) | `us.anthropic.claude-opus-4-6-v1` |
| Bedrock (application inference profile ARN) | `arn:aws:bedrock:us-east-2:ACCT:application-inference-profile/...` |
| Bedrock Mantle | `anthropic.claude-haiku-4-5` (no version suffix) |
| Vertex AI | `claude-opus-4-6`, `claude-haiku-4-5@20251001` |
| Foundry | Matches the Azure deployment name (e.g. `claude-sonnet-4-6`) |

Default models when no pins are set: Bedrock primary `us.anthropic.claude-sonnet-4-5-20250929-v1:0`, Vertex primary `claude-sonnet-4-5@20250929`. Both default small/fast to `claude-haiku-4-5@20251001` (Vertex format).

### Bedrock-specific environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK` | Enable Bedrock Invoke API |
| `CLAUDE_CODE_USE_MANTLE` | Enable the Mantle endpoint (native Anthropic API on Bedrock) |
| `AWS_REGION` | Required region (Claude Code does not read `.aws` config for this) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock Invoke endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip SigV4 signing (gateway handles auth) |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip Mantle client-side auth (gateway handles auth) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override Haiku-model region |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key auth |

Settings keys: `awsAuthRefresh` (runs a refresh command — used for `aws sso login` flows; output shown to user), `awsCredentialExport` (returns JSON credentials directly; output captured silently). `modelOverrides` maps individual versions to distinct application-inference-profile ARNs.

### Vertex AI-specific environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex |
| `CLOUD_ML_REGION` | Region (use `global` for global endpoints) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip GCP auth (gateway handles it) |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override (one var per model family) |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override |
| `DISABLE_PROMPT_CACHING` | Turn off prompt caching |

### Foundry-specific environment variables

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key auth (omit to use Entra ID `DefaultAzureCredential`) |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth (gateway handles it) |

### Required IAM / RBAC

| Provider | Required permissions |
| :--- | :--- |
| Bedrock | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`, plus `aws-marketplace:ViewSubscriptions` / `Subscribe` (gated to `bedrock.amazonaws.com`) |
| Vertex AI | `roles/aiplatform.user` (specifically `aiplatform.endpoints.predict`) |
| Foundry | `Azure AI User` + `Cognitive Services User` roles, or custom role with `Microsoft.CognitiveServices/accounts/providers/*` data action |

### LLM gateway requirements

A gateway must expose at least one of:

1. **Anthropic Messages** — `/v1/messages`, `/v1/messages/count_tokens`. Must forward `anthropic-beta` and `anthropic-version` headers.
2. **Bedrock Invoke** — `/invoke`, `/invoke-with-response-stream`. Must preserve `anthropic_beta`, `anthropic_version` body fields.
3. **Vertex rawPredict** — `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict`. Must forward `anthropic-beta` and `anthropic-version` headers.

Claude Code adds `X-Claude-Code-Session-Id` to every request so proxies can aggregate calls per session. When using Anthropic Messages format with Bedrock/Vertex, set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1`.

### Gateway base-URL variables

| Variable | Used for |
| :--- | :--- |
| `ANTHROPIC_BASE_URL` | Anthropic Messages format gateway (e.g. LiteLLM unified endpoint) |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock pass-through gateway |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex pass-through gateway |
| `ANTHROPIC_AUTH_TOKEN` | Static gateway auth token (sent as `Authorization`) |
| `apiKeyHelper` (settings) | Script that returns a rotating key; sent as `Authorization` and `X-Api-Key` |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Helper refresh interval in ms |

### Deployment option comparison

| Feature | Teams/Enterprise | Console | Bedrock | Vertex AI | Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most orgs | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | Per-seat or PAYG | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Auth | SSO/email | API key | API key or AWS creds | GCP creds | API key or Entra ID |
| Cost tracking | Usage dashboard | Usage dashboard | AWS Cost Explorer | GCP Billing | Azure Cost Management |
| Prompt caching | Default on | Default on | Default on | Default on | Default on |
| Includes Claude.ai | Yes | No | No | No | No |

### Common troubleshooting

- **Bedrock SSO loop** — corporate VPN / TLS proxy interrupts the SSO browser flow; remove `awsAuthRefresh` and run `aws sso login` manually.
- **Bedrock "on-demand throughput isn't supported"** — use an inference profile ID instead of a foundation-model ID. Claude Code uses the Invoke API, not Converse.
- **Mantle 403** — your AWS account is not granted access to the requested model; contact your AWS account team.
- **Mantle 400 with model ID** — model not served on Mantle; use a `anthropic.`-prefixed Mantle ID, or set both `CLAUDE_CODE_USE_BEDROCK` and `CLAUDE_CODE_USE_MANTLE` so Claude Code routes per request.
- **Vertex 404 "model not found"** — confirm model is enabled in Model Garden; if `CLOUD_ML_REGION=global`, set `VERTEX_REGION_<MODEL>` for models that don't support global endpoints.
- **Vertex 429** — switch to `CLOUD_ML_REGION=global` or ensure both primary and small/fast models are supported in the chosen region.
- **Foundry "ChainedTokenCredential authentication failed"** — set `ANTHROPIC_FOUNDRY_API_KEY` or configure Entra ID on the environment.
- **Verify provider is active** — run `/status`. Mantle shows `Amazon Bedrock (Mantle)`; combined mode shows `Amazon Bedrock + Amazon Bedrock (Mantle)`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Full Bedrock setup: wizard, manual env vars, IAM policy, model pinning, Mantle endpoint, Guardrails, troubleshooting.
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Full Vertex AI setup: wizard, GCP credentials, Vertex API enablement, region/global endpoint config, IAM, model pinning, troubleshooting.
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Full Foundry setup: provisioning, API key vs Entra ID auth, deployment names, RBAC, troubleshooting.
- [Enterprise deployment overview (third-party integrations)](references/claude-code-third-party-integrations.md) — Comparison matrix of deployment options, corporate-proxy and gateway examples per provider, organizational best practices.
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — Gateway API requirements, header forwarding rules, authentication patterns (`ANTHROPIC_AUTH_TOKEN`, `apiKeyHelper`), LiteLLM unified and pass-through endpoint setup.

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview (third-party integrations): https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
