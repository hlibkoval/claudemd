---
name: cloud-providers-doc
description: Complete official documentation for Claude Code cloud provider integrations — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateway configuration, and enterprise deployment overview with comparison table.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for Claude Code cloud provider and third-party integrations.

## Quick Reference

### Deployment options comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations (recommended) | Individual developers | AWS-native deployments | GCP-native deployments | Azure-native deployments |
| Billing | $150/seat (Teams) or contact sales | PAYG | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team mgmt, SSO, usage monitoring | None | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |

---

### Amazon Bedrock

**Quick start (wizard):** Run `claude`, select **3rd-party platform** → **Amazon Bedrock**. Run `/setup-bedrock` to reopen wizard.

**Manual setup environment variables:**

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-east-1
# Optional: Override region for small/fast model
export ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION=us-west-2
# Optional: Override endpoint
# export ANTHROPIC_BEDROCK_BASE_URL=https://bedrock-runtime.us-east-1.amazonaws.com
```

**Credential methods:**

| Method | How |
| :--- | :--- |
| AWS CLI | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>`, then `AWS_PROFILE=<name>` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

**Auto credential refresh** (add to settings file):

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

Use `awsAuthRefresh` for commands that update `.aws` (output shown to user). Use `awsCredentialExport` only when you cannot modify `.aws`; it must print JSON with `Credentials.AccessKeyId`, `SecretAccessKey`, `SessionToken`.

**Model pinning (recommended for team deployments):**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

Default models when no pinning is set:

| Model type | Default |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**Model overrides per version** (in settings file, for multiple versions on custom ARNs):

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

**IAM policy — minimum required actions:**

```json
{
  "Action": [
    "bedrock:InvokeModel",
    "bedrock:InvokeModelWithResponseStream",
    "bedrock:ListInferenceProfiles",
    "bedrock:GetInferenceProfile"
  ]
}
```

**1M context window:** Append `[1m]` to a manually pinned model ID, or use the wizard's 1M option. Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6.

**AWS Guardrails** (add to settings file):

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

**Mantle endpoint** (native Anthropic API shape via Bedrock; requires v2.1.94+):

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip client-side SigV4 (for gateway setups) |

Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run Mantle alongside the standard Invoke API. Mantle model IDs use the `anthropic.` prefix (e.g., `anthropic.claude-haiku-4-5`).

**Troubleshooting:**

| Issue | Fix |
| :--- | :--- |
| "on-demand throughput isn't supported" | Use an inference profile ID |
| Region issues | Check `aws bedrock list-inference-profiles --region <region>`; switch to `us-east-1` |
| SSO browser tab loop | Remove `awsAuthRefresh` from settings; run `aws sso login` manually before starting |
| Mantle `403` | Account not granted access to requested model — contact AWS account team |
| Mantle `400` naming model ID | Model not on Mantle; use Mantle-format ID or enable both endpoints |

---

### Google Vertex AI

**Quick start (wizard; requires v2.1.98+):** Run `claude`, select **3rd-party platform** → **Google Vertex AI**. Run `/setup-vertex` to reopen.

**Manual setup environment variables:**

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global      # or multi-region (eu, us) or specific region
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
# Optional: Override endpoint
# export ANTHROPIC_VERTEX_BASE_URL=https://aiplatform.googleapis.com
# Optional: Per-model region overrides when using global endpoint
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

**Authentication:** Uses Google Cloud Application Default Credentials (ADC). Supports X.509 certificate-based Workload Identity Federation (v2.1.121+). Set `GOOGLE_APPLICATION_CREDENTIALS` to credential config file path.

**IAM:** Assign `roles/aiplatform.user` (includes `aiplatform.endpoints.predict`).

**Model pinning:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

Default models when no pinning is set:

| Model type | Default |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**1M context window:** Append `[1m]` to a manually pinned model ID. Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6.

**MCP tool search:** Disabled by default on Vertex (endpoint doesn't accept required beta header). Opt in with `ENABLE_TOOL_SEARCH=true`.

**Troubleshooting:**

| Issue | Fix |
| :--- | :--- |
| 404 "model not found" | Confirm model enabled in Model Garden; verify endpoint type (global vs regional) |
| Global endpoint + unsupported model | Use `VERTEX_REGION_<MODEL_NAME>` or specify model with `ANTHROPIC_MODEL` |
| 429 errors | Switch to `CLOUD_ML_REGION=global`; request quota increase |

---

### Microsoft Foundry

**Setup environment variables:**

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}   # Azure resource name
# Or provide full URL:
# export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

**Authentication:**

| Method | How |
| :--- | :--- |
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-key` |
| Microsoft Entra ID (default when key not set) | `az login` (uses Azure SDK default credential chain) |

**Model pinning:**

```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

**RBAC:** `Azure AI User` or `Cognitive Services User` roles include all required permissions. Minimum custom role needs `Microsoft.CognitiveServices/accounts/providers/*` data action.

**Prompt caching:** Enabled automatically. Request 1-hour TTL with `ENABLE_PROMPT_CACHING_1H=1`.

**Troubleshooting:** "Failed to get token from azureADTokenProvider" → configure Entra ID or set `ANTHROPIC_FOUNDRY_API_KEY`.

---

### LLM Gateway

Gateways provide centralized auth, usage tracking, cost controls, audit logging, and model routing.

**Gateway API format requirements (must support at least one):**

| Format | Endpoints | Must preserve |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | Forward headers: `anthropic-beta`, `anthropic-version` |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | Body fields: `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | Forward headers: `anthropic-beta`, `anthropic-version` |

Claude Code sends `X-Claude-Code-Session-Id` on every request (unique per session; useful for aggregating requests without parsing body).

**LiteLLM — unified endpoint (recommended):**

```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
```

**LiteLLM — provider pass-through:**

```bash
# Bedrock pass-through
export ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock
export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
export CLAUDE_CODE_USE_BEDROCK=1

# Vertex AI pass-through
export ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1
export ANTHROPIC_VERTEX_PROJECT_ID=your-gcp-project-id
export CLAUDE_CODE_SKIP_VERTEX_AUTH=1
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
```

**Authentication with LiteLLM:**

| Method | Config |
| :--- | :--- |
| Static API key | `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` |
| Dynamic key (helper script) | `"apiKeyHelper": "~/bin/get-litellm-key.sh"` in settings; `CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000` |

**Warning:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware — do not install these versions.

**Note:** When using Anthropic Messages format with Bedrock or Vertex, set `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` if needed.

---

### Corporate proxy vs LLM gateway — quick reference

| Config | Variable | Use case |
| :--- | :--- | :--- |
| Corporate proxy | `HTTPS_PROXY` / `HTTP_PROXY` | Route all outbound traffic through org proxy |
| Anthropic gateway | `ANTHROPIC_BASE_URL` | Centralized auth/routing for direct API |
| Bedrock gateway | `ANTHROPIC_BEDROCK_BASE_URL` | Centralized auth/routing for Bedrock |
| Vertex gateway | `ANTHROPIC_VERTEX_BASE_URL` | Centralized auth/routing for Vertex AI |
| Foundry gateway | `ANTHROPIC_FOUNDRY_BASE_URL` | Centralized auth/routing for Foundry |

Use `/status` in Claude Code to verify provider and proxy configuration.

---

### Prompt caching and model settings (all providers)

| Variable | Purpose |
| :--- | :--- |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour cache TTL (billed at higher rate) |
| `ANTHROPIC_MODEL` | Override primary model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus model |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku (small/fast) model |

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, sign-in wizard, manual setup, credential options, auto-refresh, model pinning, IAM policy, 1M context window, Guardrails, Mantle endpoint, startup model checks, and troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, sign-in wizard, region configuration, manual setup, GCP credentials, model pinning, startup model checks, IAM, 1M context window, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, provisioning, API key and Entra ID auth, environment variables, model pinning, RBAC configuration, and troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements, API formats, LiteLLM setup, authentication methods, unified and pass-through endpoints
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment option comparison table, corporate proxy vs LLM gateway setup, best practices for organizations

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
