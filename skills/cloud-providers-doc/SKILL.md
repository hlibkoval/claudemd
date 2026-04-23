---
name: cloud-providers-doc
description: Complete official documentation for running Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, LLM gateways, and enterprise deployment comparison.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and third-party platforms.

## Quick Reference

### Deployment option comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :------ | :--------------------------- | :---------------- | :------------- | :--------------- | :---------------- |
| Best for | Most organizations (recommended) | Individual devs | AWS-native | GCP-native | Azure-native |
| Billing | $150/seat or Enterprise contract | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Cost tracking | Usage dashboard | Usage dashboard | AWS Cost Explorer | GCP Billing | Azure Cost Management |

### Enable a provider

| Provider | Required env vars |
| :------- | :---------------- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |
| Mantle (Bedrock) | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |

### Pin model versions (all providers)

Always pin models for multi-user deployments. Use provider-specific model IDs:

| Env var | Bedrock example | Vertex example | Foundry example |
| :------ | :-------------- | :------------- | :-------------- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | `us.anthropic.claude-opus-4-7` | `claude-opus-4-7` | `claude-opus-4-7` |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | `us.anthropic.claude-sonnet-4-6` | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | `us.anthropic.claude-haiku-4-5-20251001-v1:0` | `claude-haiku-4-5@20251001` | `claude-haiku-4-5` |

---

## Amazon Bedrock

### Quick setup (wizard)

```bash
claude  # Select "3rd-party platform" → "Amazon Bedrock"
```

Wizard saves credentials to user settings. Run `/setup-bedrock` to reopen.

### Manual setup — credential options

| Option | Method |
| :----- | :----- |
| A | `aws configure` (CLI) |
| B | `AWS_ACCESS_KEY_ID` + `AWS_SECRET_ACCESS_KEY` + `AWS_SESSION_TOKEN` |
| C | `aws sso login --profile=NAME` then `AWS_PROFILE=NAME` |
| D | `aws login` (Management Console) |
| E | `AWS_BEARER_TOKEN_BEDROCK=your-bedrock-api-key` |

### Credential auto-refresh settings

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

- `awsAuthRefresh`: modifies `.aws` dir; output shown to user; browser-based SSO flows work
- `awsCredentialExport`: captures JSON credentials silently; must output `{ "Credentials": { "AccessKeyId", "SecretAccessKey", "SessionToken" } }`

### IAM policy (minimum required)

```json
{
  "Statement": [{
    "Effect": "Allow",
    "Action": ["bedrock:InvokeModel", "bedrock:InvokeModelWithResponseStream", "bedrock:ListInferenceProfiles"],
    "Resource": ["arn:aws:bedrock:*:*:inference-profile/*", "arn:aws:bedrock:*:*:application-inference-profile/*", "arn:aws:bedrock:*:*:foundation-model/*"]
  }]
}
```

### modelOverrides — map model versions to ARNs

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

### Bedrock Mantle endpoint

Mantle uses the native Anthropic API shape over AWS credentials (requires v2.1.94+).

| Mantle env var | Purpose |
| :------------- | :------ |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip SigV4 for gateway setups |

Mantle model IDs use `anthropic.` prefix (e.g. `anthropic.claude-haiku-4-5`). Set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1` to run both endpoints side by side.

### AWS Guardrails

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### 1M token context window (Bedrock)

Append `[1m]` to the model ID when pinning manually. The setup wizard offers a 1M option. Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6.

### Bedrock defaults (no pinning)

| Model type | Default |
| :--------- | :------ |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

---

## Google Vertex AI

### Quick setup (wizard, requires v2.1.98+)

```bash
claude  # Select "3rd-party platform" → "Google Vertex AI"
```

Run `/setup-vertex` to reopen.

### Manual setup

```bash
gcloud config set project YOUR-PROJECT-ID
gcloud services enable aiplatform.googleapis.com
```

Request Claude model access via Vertex AI Model Garden (may take 24-48 hours).

### Key env vars

```bash
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=global          # or "eu", "us", or a specific region
export ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID
# Optional:
export ANTHROPIC_VERTEX_BASE_URL=https://aiplatform.googleapis.com
export DISABLE_PROMPT_CACHING=1
# Region overrides for models without global endpoint support:
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

### IAM (Vertex)

Role `roles/aiplatform.user` includes `aiplatform.endpoints.predict` which is the only required permission.

### Vertex defaults (no pinning)

| Model type | Default |
| :--------- | :------ |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

### 1M token context window (Vertex)

Same as Bedrock: append `[1m]` to model ID or use the wizard. Supported on Opus 4.7, Opus 4.6, and Sonnet 4.6.

---

## Microsoft Foundry

### Setup

1. Create a resource in [Microsoft Foundry portal](https://ai.azure.com/), create deployments for Opus, Sonnet, and Haiku.
2. Authenticate:
   - **API key**: `export ANTHROPIC_FOUNDRY_API_KEY=your-key`
   - **Entra ID**: omit the API key; Claude Code uses the Azure SDK default credential chain (`az login` locally)
3. Configure:

```bash
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE={resource}
# Or full URL:
# export ANTHROPIC_FOUNDRY_BASE_URL=https://{resource}.services.ai.azure.com/anthropic
```

### Azure RBAC

Roles `Azure AI User` or `Cognitive Services User` are sufficient. Custom role minimum: `Microsoft.CognitiveServices/accounts/providers/*` dataAction.

---

## LLM Gateway

### Gateway API format requirements

| Format | Endpoints | Must forward |
| :----- | :-------- | :----------- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

Claude Code always sends `X-Claude-Code-Session-Id` on every request for session aggregation.

### LiteLLM configuration

**Warning**: LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised. Rotate credentials and upgrade if affected.

| Setup | Env vars |
| :---- | :------- |
| Unified Anthropic endpoint (recommended) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Anthropic pass-through | `ANTHROPIC_BASE_URL=https://litellm-server:4000/anthropic` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL=https://litellm-server:4000/bedrock`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL=https://litellm-server:4000/vertex_ai/v1`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=us-east5` |

**Dynamic API key helper** (for rotating keys):

```json
{ "apiKeyHelper": "~/bin/get-litellm-key.sh" }
```

```bash
export CLAUDE_CODE_API_KEY_HELPER_TTL_MS=3600000  # refresh interval
```

Sent as `Authorization` and `X-Api-Key` headers. Lower precedence than `ANTHROPIC_AUTH_TOKEN` or `ANTHROPIC_API_KEY`.

---

## Proxy and gateway routing

| Provider | Corporate proxy (add to provider vars) | LLM gateway |
| :------- | :------------------------------------- | :---------- |
| Bedrock | `HTTPS_PROXY=https://proxy:8080` | `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex | `HTTPS_PROXY=https://proxy:8080` | `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` |
| Foundry | `HTTPS_PROXY=https://proxy:8080` | `ANTHROPIC_FOUNDRY_BASE_URL=...`, `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

Use `/status` inside Claude Code to verify provider and gateway configuration.

---

## Startup model checks

On start, Claude Code verifies configured models are accessible. Requires v2.1.94+ (Bedrock) and v2.1.98+ (Vertex).

- Pinned model older than current default and newer version available → prompts to update pin (writes to user settings, restarts)
- Pinned model pointing to an application inference profile ARN → skipped (admin-managed)
- No pin, default unavailable → falls back to previous version for session only

---

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, wizard setup, manual credential configuration, IAM policy, model pinning, Mantle endpoint, Guardrails, 1M context window, startup model checks, and troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, wizard setup, region configuration, manual setup, IAM, model pinning, 1M context window, startup model checks, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, provisioning, API key and Entra ID authentication, model pinning, RBAC configuration, and troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements, API formats, LiteLLM setup, authentication methods, and provider-specific pass-through endpoints
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment option comparison, proxy and gateway setup for each provider, and best practices for organizations

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
