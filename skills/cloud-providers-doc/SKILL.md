---
name: cloud-providers-doc
description: Complete official documentation for Claude Code cloud provider integrations — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment overview.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for Claude Code cloud provider and enterprise deployment integrations.

## Quick Reference

### Deployment options comparison

| Feature | Claude for Teams/Enterprise | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | AWS-native deployments | GCP-native deployments | Azure-native deployments |
| Billing | Seat-based (Teams) or contact sales | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| Authentication | Claude.ai SSO or email | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| Cost tracking | Usage dashboard | AWS Cost Explorer | GCP Billing | Azure Cost Management |
| Includes Claude on web | Yes | No | No | No |
| Enterprise features | Team management, SSO, usage monitoring | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |

---

### Amazon Bedrock

**Enable Bedrock (manual setup):**

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
```

**Authentication options:**

| Option | Method |
| :--- | :--- |
| AWS CLI | `aws configure` |
| Access key | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>` then `export AWS_PROFILE=<name>` |
| Bedrock API key | `export AWS_BEARER_TOKEN_BEDROCK=your-key` |

**Wizard login:** Run `claude`, select **3rd-party platform** > **Amazon Bedrock**. Re-run wizard anytime with `/setup-bedrock`.

**Pin model versions (required for team deployments):**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

**Default models (no pinning set):**

| Model type | Default |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**Advanced Bedrock variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint URL |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint (native Anthropic API shape) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy setups |

**Mantle endpoint:** Uses model IDs prefixed `anthropic.` (e.g., `anthropic.claude-haiku-4-5`). Enable alongside Invoke API: set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1`.

**Required IAM actions:** `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles`

**AWS Guardrails:** Set via `ANTHROPIC_CUSTOM_HEADERS` in settings `env` block:
```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

**Credential auto-refresh config (settings file):**
- `awsAuthRefresh` — command that updates `.aws` directory (output shown to user, e.g. SSO browser flow)
- `awsCredentialExport` — command that outputs credentials JSON directly (output captured silently)

**1M token context:** Supported on Opus 4.7, Opus 4.6, Sonnet 4.6. Append `[1m]` to a manually pinned model ID.

---

### Google Vertex AI

**Enable Vertex AI (manual setup):**

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global   # or multi-region (eu, us) or specific region
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
```

**Wizard login:** Run `claude`, select **3rd-party platform** > **Google Vertex AI** (requires v2.1.98+). Re-run wizard anytime with `/setup-vertex`.

**Region configuration:** `CLOUD_ML_REGION` accepts `global`, multi-region (`eu`, `us`), or specific regions (`us-east5`). Use `VERTEX_REGION_CLAUDE_*` variables to override per-model when using `global`.

**Pin model versions:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

**Default models (no pinning set):**

| Model type | Default |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**Key variables:**

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint URL |
| `DISABLE_PROMPT_CACHING` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H` | Request 1-hour cache TTL |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override example |

**Required IAM role:** `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`)

**Model access:** Request in [Vertex AI Model Garden](https://console.cloud.google.com/vertex-ai/model-garden); may take 24-48 hours.

**1M token context:** Supported on Opus 4.7, Opus 4.6, Sonnet 4.6. Append `[1m]` to a manually pinned model ID.

---

### Microsoft Foundry

**Enable Microsoft Foundry:**

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}   # your resource name
# Or: export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Authentication options:**

| Option | Method |
| :--- | :--- |
| API key | `export ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` |
| Microsoft Entra ID | `az login` (used automatically when API key is not set) |

**Pin model versions:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

**Required RBAC:** `Azure AI User` or `Cognitive Services User` role (or custom role with `Microsoft.CognitiveServices/accounts/providers/*` data action).

**Setup steps:** Create resource in [Microsoft Foundry portal](https://ai.azure.com/), create deployments for each Claude model, configure environment variables.

---

### LLM Gateway

**When to use:** Centralized auth, usage tracking, cost controls, audit logging, or model routing across teams.

**Gateway API format requirements (must support one of):**

| Format | Endpoints | Must preserve |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**LiteLLM — unified endpoint (recommended):**

```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
```

**LiteLLM — provider-specific pass-through:**

| Provider | Variables |
| :--- | :--- |
| Anthropic API | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Google Vertex AI | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1` |

**Static API key auth:**

```bash
export ANTHROPIC_AUTH_TOKEN=sk-litellm-static-key
```

**Dynamic API key helper:**

```json
{
  "apiKeyHelper": "~/bin/get-litellm-key.sh",
  "CLAUDE_CODE_API_KEY_HELPER_TTL_MS": "3600000"
}
```

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware. Do not install these versions.

---

### Proxy and gateway configuration summary

| Provider | Corporate proxy variables | Gateway variables |
| :--- | :--- | :--- |
| Amazon Bedrock | `HTTPS_PROXY`, `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION` | `ANTHROPIC_BEDROCK_BASE_URL`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Google Vertex AI | `HTTPS_PROXY`, `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` | `ANTHROPIC_VERTEX_BASE_URL`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Microsoft Foundry | `HTTPS_PROXY`, `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE` | `ANTHROPIC_FOUNDRY_BASE_URL`, `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

Use `/status` inside Claude Code to verify provider and proxy configuration.

---

### Enterprise best practices

- **Pin model versions** for all cloud provider deployments using `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`
- **Startup model checks** (Bedrock v2.1.94+, Vertex v2.1.98+): Claude Code verifies model availability at startup and prompts to update stale pins
- **CLAUDE.md files**: Deploy at organization-wide system directories and per-repository roots; check into source control
- **MCP**: Centrally configure MCP servers; check `.mcp.json` into the codebase for all users
- **Dedicated accounts**: Use a dedicated AWS account / GCP project / Azure resource for cost tracking and access control

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, wizard login, manual setup, credential refresh, model pinning, Mantle endpoint, IAM policy, Guardrails, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, wizard login, region configuration, manual setup, model pinning, IAM, startup model checks, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, resource provisioning, API key and Entra ID auth, model pinning, RBAC configuration, troubleshooting
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — gateway requirements, API formats, LiteLLM setup, authentication methods, pass-through endpoints
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — deployment options comparison, proxy and gateway setup, enterprise best practices, next steps

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise Deployment Overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
