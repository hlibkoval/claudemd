---
name: cloud-providers-doc
description: Complete official documentation for deploying Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry, enterprise deployment comparison, and LLM gateway configuration.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

### Deployment options comparison

| Feature | Claude for Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Best for** | Most organizations (recommended) | Individual developers | AWS-native deployments | GCP-native deployments | Azure-native deployments |
| **Billing** | Per-seat or contact sales | PAYG | PAYG through AWS | PAYG through GCP | PAYG through Azure |
| **Authentication** | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Microsoft Entra ID |
| **Includes Claude on web** | Yes | No | No | No | No |
| **Enterprise features** | Team management, SSO | None | IAM policies, CloudTrail | IAM roles, Cloud Audit Logs | RBAC policies, Azure Monitor |

### Enable provider integration (key env vars)

| Provider | Required env vars |
| :--- | :--- |
| **Amazon Bedrock** | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1` |
| **Google Vertex AI** | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=YOUR-PROJECT-ID` |
| **Microsoft Foundry** | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE={resource}` |
| **Bedrock Mantle** | `CLAUDE_CODE_USE_MANTLE=1`, `AWS_REGION=us-east-1` |

### Login wizards

| Provider | Wizard command | Min version |
| :--- | :--- | :--- |
| Amazon Bedrock | `claude` → 3rd-party platform → Amazon Bedrock; re-open with `/setup-bedrock` | Any |
| Google Vertex AI | `claude` → 3rd-party platform → Google Vertex AI; re-open with `/setup-vertex` | v2.1.98 |

When using any cloud provider, `/login` and `/logout` are disabled — authentication is handled by provider credentials.

### Pin model versions (recommended for multi-user deploys)

Always pin when deploying to multiple users. Without pinning, aliases like `sonnet` resolve to the latest version, which may not yet be available in your account.

```bash
# Amazon Bedrock (cross-region inference profile IDs)
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'

# Google Vertex AI
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'

# Microsoft Foundry (match your deployment names)
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-7'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

### Amazon Bedrock credential methods

| Method | How |
| :--- | :--- |
| AWS CLI config | `aws configure` |
| Access key env vars | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>` + `AWS_PROFILE=<name>` |
| AWS Management Console | `aws login` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

For automatic credential refresh, add to settings.json:

```json
{
  "awsAuthRefresh": "aws sso login --profile myprofile",
  "env": { "AWS_PROFILE": "myprofile" }
}
```

`awsCredentialExport` is an alternative that silently captures JSON credentials output (`Credentials.AccessKeyId`, `SecretAccessKey`, `SessionToken`).

### Amazon Bedrock IAM permissions

Required actions: `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` on inference-profile, application-inference-profile, and foundation-model resources.

### Bedrock Mantle endpoint

Mantle serves Claude via the native Anthropic API shape (not Bedrock Invoke API). Requires v2.1.94+. Model IDs use `anthropic.` prefix without version suffix (e.g., `anthropic.claude-haiku-4-5`).

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE` | Enable Mantle endpoint (`1` or `true`) |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override default Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip client-side auth for proxy/gateway setups |

To run both Bedrock Invoke API and Mantle: set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1`.

### Google Vertex AI region variables

```bash
export CLOUD_ML_REGION=global
# Per-model region overrides when using global endpoint:
export VERTEX_REGION_CLAUDE_HAIKU_4_5=us-east5
export VERTEX_REGION_CLAUDE_4_6_SONNET=europe-west1
```

IAM: `roles/aiplatform.user` (or custom role with `aiplatform.endpoints.predict`).

### Microsoft Foundry authentication

| Method | How |
| :--- | :--- |
| API key | `ANTHROPIC_FOUNDRY_API_KEY=your-azure-api-key` |
| Microsoft Entra ID | Omit API key; uses Azure SDK default credential chain (e.g., `az login`) |

RBAC: `Azure AI User` or `Cognitive Services User` roles include all required permissions. Custom role needs `Microsoft.CognitiveServices/accounts/providers/*` data action.

### 1M token context window

Opus 4.7, Opus 4.6, and Sonnet 4.6 support 1M context on both Bedrock and Vertex AI. Claude Code auto-enables it when you select a 1M model variant. For manual pinning, append `[1m]` to the model ID.

### Startup model checks

On startup with Bedrock (v2.1.94+) or Vertex AI (v2.1.98+), Claude Code verifies model availability. If the pinned version is older than the default and the newer version is available, you're prompted to update. If unpinned and the default is unavailable, Claude Code falls back to the previous version for that session only.

### AWS Guardrails (Bedrock)

Create a Guardrail in the Bedrock console, then add headers to your settings.json:

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-guardrail-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### LLM gateway configuration

Gateways must expose one of: Anthropic Messages (`/v1/messages`), Bedrock InvokeModel (`/invoke`), or Vertex rawPredict (`:rawPredict`) API formats, and forward `anthropic-beta` / `anthropic-version` headers.

| Provider via gateway | Key env vars |
| :--- | :--- |
| Anthropic API (LiteLLM unified) | `ANTHROPIC_BASE_URL=https://litellm-server:4000` |
| Bedrock via LiteLLM | `ANTHROPIC_BEDROCK_BASE_URL=...`, `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1`, `CLAUDE_CODE_USE_BEDROCK=1` |
| Vertex via LiteLLM | `ANTHROPIC_VERTEX_BASE_URL=...`, `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`, `CLAUDE_CODE_USE_VERTEX=1` |
| Foundry via gateway | `ANTHROPIC_FOUNDRY_BASE_URL=...`, `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

For rotating keys or per-user auth, configure `apiKeyHelper` in settings.json pointing to a script that outputs the key; set `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval.

**LiteLLM security warning**: PyPI versions 1.82.7 and 1.82.8 were compromised. Do not install these versions; rotate credentials if you did.

### Corporate proxy configuration (all providers)

Set `HTTPS_PROXY=https://proxy.example.com:8080` alongside provider env vars. Use `/status` in Claude Code to verify proxy and gateway configuration.

### modelOverrides (Bedrock — map versions to application inference profile ARNs)

```json
{
  "modelOverrides": {
    "claude-opus-4-7": "arn:aws:bedrock:us-east-2:123456789012:application-inference-profile/opus-47-prod"
  }
}
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, login wizard, manual setup, IAM, credential refresh, model pinning, Mantle endpoint, Guardrails, startup model checks, and troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, login wizard, manual setup, IAM, region configuration, model pinning, 1M context, startup model checks, and troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, provisioning, API key and Entra ID auth, model pinning, RBAC configuration, and troubleshooting
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment options comparison, proxy and gateway configuration per provider, and organizational best practices
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway API format requirements, LiteLLM setup, authentication methods, and provider-specific pass-through endpoints

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
