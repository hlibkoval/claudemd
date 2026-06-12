---
name: cloud-providers-doc
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through third-party cloud providers — Amazon Bedrock, Claude Platform on AWS, Google Vertex AI, Microsoft Foundry — as well as the enterprise deployment overview and LLM gateway configuration.

## Quick Reference

### Deployment Options Comparison

| Feature | Claude for Teams/Enterprise | Amazon Bedrock | Claude Platform on AWS | Google Vertex AI | Microsoft Foundry |
| :------ | :-------------------------- | :------------- | :--------------------- | :--------------- | :---------------- |
| Best for | Most organizations (recommended) | AWS-native deployments | AWS Marketplace billing + Claude API features | GCP-native deployments | Azure-native deployments |
| Billing | Seat-based or PAYG | PAYG through AWS | PAYG through AWS Marketplace | PAYG through GCP | PAYG through Azure |
| Authentication | Claude.ai SSO or email | API key or AWS credentials | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| Includes Claude on web | Yes | No | No | No | No |

### Enable Variables by Provider

| Provider | Enable variable | Region variable | Project/Resource variable |
| :------- | :-------------- | :-------------- | :------------------------ |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` | — |
| Bedrock Mantle endpoint | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` | — |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | `AWS_REGION` | `ANTHROPIC_AWS_WORKSPACE_ID` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION` | `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | — | `ANTHROPIC_FOUNDRY_RESOURCE` |

Provider routing priority (highest first): Bedrock / Foundry > Claude Platform on AWS > Vertex AI > default Anthropic API.

### Model Pinning Variables (All Providers)

Always pin model versions before rolling out to multiple users.

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_DEFAULT_FABLE_MODEL` | Pin Fable-class model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus-class model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet-class model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku-class model (background tasks) |
| `ANTHROPIC_MODEL` | Override primary model directly |

On Bedrock and Vertex AI, Haiku defaults to the primary model if not pinned (Haiku may not be enabled in every account/project).

### Amazon Bedrock — Key Config

**Credential options** (standard AWS SDK credential chain):
- `aws configure` — AWS CLI profile
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN`
- `AWS_PROFILE` (SSO profile)
- `AWS_BEARER_TOKEN_BEDROCK` — Bedrock API key (no full AWS credentials needed)

**Advanced credential refresh** (in settings.json):

| Setting | When it runs |
| :------ | :----------- |
| `awsAuthRefresh` | Only when credentials are expired or Bedrock returns a credential error |
| `awsCredentialExport` | At session start and on each reload; must output `{"Credentials": {"AccessKeyId":…,"SecretAccessKey":…,"SessionToken":…}}` |

**Bedrock-specific variables**:

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | `default`, `flex`, or `priority` service tier |
| `ANTHROPIC_CUSTOM_HEADERS` | Pass Guardrail headers (`X-Amzn-Bedrock-GuardrailIdentifier`, etc.) |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override AWS region for Haiku-class model |
| `DISABLE_PROMPT_CACHING` / `ENABLE_PROMPT_CACHING_1H` | Cache control |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint (Anthropic API shape over Bedrock) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side SigV4 for Mantle (gateway/proxy use) |

**Bedrock default models** (when no pinning variables set):

| Type | Default |
| :--- | :------ |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | Same as primary |

**Mantle model ID format**: `anthropic.<model>` (e.g. `anthropic.claude-haiku-4-5`); inference profile IDs (`us.anthropic.*`) do not work on Mantle.

**IAM permissions required**:
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`
- `bedrock:GetInferenceProfile`

**1M context window**: Append `[1m]` to a manually pinned model ID to opt in. The wizard offers this automatically.

**AWS Guardrails**: Set `ANTHROPIC_CUSTOM_HEADERS` with `X-Amzn-Bedrock-GuardrailIdentifier` and `X-Amzn-Bedrock-GuardrailVersion` headers.

**Multi-model overrides** (map model versions to application inference profile ARNs via `modelOverrides` in settings.json when `ANTHROPIC_DEFAULT_*_MODEL` isn't flexible enough).

### Claude Platform on AWS — Key Config

Claude Platform on AWS is the Anthropic-operated API with AWS authentication and AWS Marketplace billing. Unlike Bedrock, requests reach Anthropic's infrastructure directly on the same release schedule as the direct Claude API.

**Authentication options**:
- **SigV4** (standard AWS credential chain) — set `AWS_PROFILE` or use attached IAM role
- **Workspace API key** — `ANTHROPIC_AWS_API_KEY=sk-ant-…` (takes precedence over SigV4)

**Required variables**:

| Variable | Purpose |
| :------- | :------ |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` | Enable Claude Platform on AWS |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Workspace ID from AWS Console (sent as `anthropic-workspace-id` header) |
| `AWS_REGION` | Region; base URL computed as `https://aws-external-anthropic.{region}.api.aws` |

**Optional variables**:

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_AWS_BASE_URL` | Override base URL (proxy/gateway) |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` | Skip client-side SigV4 (gateway handles auth) |
| `ANTHROPIC_AUTH_TOKEN` | Bearer token for gateway auth |

**IAM permission note**: Workspace must be in the AWS-linked Anthropic organization — credentials from a separate Claude Console organization won't work.

**Default models** (when no pinning variables set):

| Alias | Default |
| :---- | :------ |
| `opus` | `claude-opus-4-7` |
| `sonnet` | Claude Code's built-in default |

### Google Vertex AI — Key Config

**Required variables**:
```
CLAUDE_CODE_USE_VERTEX=1
CLOUD_ML_REGION=global        # or 'eu', 'us', or specific region like 'us-east5'
ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

**Authentication**: Uses Application Default Credentials (ADC). Run `gcloud auth application-default login` for local use; set `GOOGLE_APPLICATION_CREDENTIALS` for service account keys.

**Advanced credential refresh** (in settings.json): `gcpAuthRefresh` command runs when GCP credentials expire; times out after 3 minutes.

**Project ID resolution order**: `GCLOUD_PROJECT` / `GOOGLE_CLOUD_PROJECT` env vars or credential file → `ANTHROPIC_VERTEX_PROJECT_ID` → `gcloud` config / attached service account.

**Region-specific model routing** (when `CLOUD_ML_REGION=global`):
```
VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```
(Most model versions have a corresponding `VERTEX_REGION_CLAUDE_*` variable; see env-vars reference for the full list.)

**Optional variables**:

| Variable | Purpose |
| :------- | :------ |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `DISABLE_PROMPT_CACHING` / `ENABLE_PROMPT_CACHING_1H` | Cache control |
| `ENABLE_TOOL_SEARCH=true` | Enable MCP tool search on Sonnet 4.5+ and Opus 4.5+ |

**IAM**: `roles/aiplatform.user` or custom role with `aiplatform.endpoints.predict`.

**Default models** (when no pinning variables set):

| Type | Default |
| :--- | :------ |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | Same as primary |

**Setup wizard**: `/setup-vertex` (requires Claude Code v2.1.98+). **1M context window**: append `[1m]` to a manually pinned model ID.

### Microsoft Foundry — Key Config

**Required variables**:
```
CLAUDE_CODE_USE_FOUNDRY=1
ANTHROPIC_FOUNDRY_RESOURCE={azure-resource-name}
# Or: ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Authentication options**:
- **API key**: `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key`
- **Microsoft Entra ID**: When `ANTHROPIC_FOUNDRY_API_KEY` is unset, Claude Code uses the Azure SDK default credential chain. Run `az login` for local use.

**No interactive setup wizard** — environment variables are the only configuration path.

**Pin model versions** to the deployment names you created in Azure (required — no startup model check, so requests fail if the default is unavailable):
```
ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-8'
ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

**RBAC**: `Azure AI User` or `Cognitive Services User` roles; or custom role with `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

### LLM Gateway Configuration

LLM gateways proxy requests between Claude Code and model providers to centralize auth, usage tracking, cost controls, and audit logging.

**Gateway API format requirements** (must expose at least one):
- Anthropic Messages: `/v1/messages`, `/v1/messages/count_tokens` (forward `anthropic-beta`, `anthropic-version` headers)
- Bedrock InvokeModel: `/invoke`, `/invoke-with-response-stream` (preserve `anthropic_beta`, `anthropic_version` body fields)
- Vertex rawPredict: `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` (forward `anthropic-beta`, `anthropic-version` headers)

**Request headers Claude Code sends** (useful for gateway cost attribution):

| Header | Purpose |
| :----- | :------ |
| `X-Claude-Code-Session-Id` | Unique session identifier |
| `X-Claude-Code-Agent-Id` | Subagent/teammate identifier (parallel cost attribution) |
| `X-Claude-Code-Parent-Agent-Id` | Parent agent identifier (nested agent cost attribution) |

**Gateway endpoint variables by provider**:

| Provider | Base URL variable | Skip auth variable |
| :------- | :---------------- | :----------------- |
| Anthropic API | `ANTHROPIC_BASE_URL` | — |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Claude Platform on AWS | `ANTHROPIC_AWS_BASE_URL` | `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH=1` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `ANTHROPIC_FOUNDRY_BASE_URL` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

**Gateway model discovery** (Anthropic Messages format only): set `CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1` to query `/v1/models` at startup and populate the `/model` picker. Requires Claude Code v2.1.129+. Results cached to `~/.claude/cache/gateway-models.json`.

**LiteLLM** — security warning: PyPI versions 1.82.7 and 1.82.8 were compromised with malware; do not install them.

**LiteLLM authentication options**:
- Static key: `ANTHROPIC_AUTH_TOKEN=sk-litellm-…` (sent as `Authorization` header)
- Dynamic key helper: `apiKeyHelper` setting (script whose output becomes the token); control refresh with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`

**Unified LiteLLM endpoint** (recommended for load balancing and fallbacks): `ANTHROPIC_BASE_URL=https://litellm-server:4000`

### Corporate Proxy Setup

Set `HTTPS_PROXY` (or `HTTP_PROXY`) for all providers. Example for Bedrock:
```
CLAUDE_CODE_USE_BEDROCK=1
AWS_REGION=us-east-1
HTTPS_PROXY=https://proxy.example.com:8080
```

### Startup Model Checks

Bedrock (v2.1.94+) and Vertex AI (v2.1.98+) verify model availability at startup:
- If a pinned model is older than the current default and the newer version is available, Claude Code prompts to update the pin.
- If no model is pinned and the default is unavailable, Claude Code falls back to the previous version for the session (not persisted).
- Foundry has no startup model check — if the default is unavailable, requests fail immediately.

### Verify Config

Run `/status` in Claude Code to confirm the resolved provider, region, workspace ID, base URL overrides, and auth-skip settings.

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — Bedrock setup wizard, manual config, IAM, Mantle endpoint, AWS Guardrails, service tiers, 1M context, troubleshooting
- [Claude Code on Claude Platform on AWS](references/claude-code-claude-platform-on-aws.md) — AWS Marketplace-billed Anthropic API, SigV4 and API key auth, workspace setup, Agent SDK usage, proxy routing
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — Vertex AI setup wizard, region config, GCP credentials, IAM, 1M context, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure resource provisioning, Entra ID and API key auth, RBAC, model pinning
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — Provider comparison table, proxy and gateway setup, organization best practices
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — Gateway requirements, authentication methods, LiteLLM setup, model discovery, request headers

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Claude Platform on AWS: https://code.claude.com/docs/en/claude-platform-on-aws.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
