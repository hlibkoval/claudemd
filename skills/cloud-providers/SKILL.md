---
name: cloud-providers
description: Reference documentation for deploying Claude Code through cloud providers (Amazon Bedrock, Google Vertex AI, Microsoft Foundry) and LLM gateways. Use when configuring provider authentication, setting environment variables, choosing deployment options, setting up IAM/RBAC permissions, configuring proxy or gateway routing, or troubleshooting cloud provider connectivity.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and LLM gateways.

## Quick Reference

Claude Code can connect through Anthropic directly, or through Amazon Bedrock, Google Vertex AI, or Microsoft Foundry. Each provider is enabled via a single environment variable and uses native cloud credentials.

### Enabling a Provider

| Provider           | Enable variable              | Region variable                    | Required credential                          |
|:-------------------|:-----------------------------|:-----------------------------------|:---------------------------------------------|
| Amazon Bedrock     | `CLAUDE_CODE_USE_BEDROCK=1`  | `AWS_REGION=us-east-1`             | AWS SDK credential chain or `AWS_BEARER_TOKEN_BEDROCK` |
| Google Vertex AI   | `CLAUDE_CODE_USE_VERTEX=1`   | `CLOUD_ML_REGION=global`           | `gcloud` auth + `ANTHROPIC_VERTEX_PROJECT_ID`|
| Microsoft Foundry  | `CLAUDE_CODE_USE_FOUNDRY=1`  | n/a                                | `ANTHROPIC_FOUNDRY_API_KEY` or Entra ID      |

All providers disable `/login` and `/logout` since authentication is handled by cloud credentials.

### Default Models per Provider

| Provider         | Primary model                                      | Small/fast model                            |
|:-----------------|:---------------------------------------------------|:--------------------------------------------|
| Bedrock          | `global.anthropic.claude-sonnet-4-6`               | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |
| Vertex AI        | `claude-sonnet-4-6`                                | `claude-haiku-4-5@20251001`                 |
| Foundry          | Set via `ANTHROPIC_DEFAULT_SONNET_MODEL`            | Set via `ANTHROPIC_DEFAULT_HAIKU_MODEL`     |

Override with `ANTHROPIC_MODEL` and `ANTHROPIC_SMALL_FAST_MODEL`. For Foundry, set deployment names via `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`.

### IAM / RBAC Permissions

| Provider    | Required permissions                                               | Recommended role             |
|:------------|:-------------------------------------------------------------------|:-----------------------------|
| Bedrock     | `bedrock:InvokeModel`, `bedrock:InvokeModelWithResponseStream`, `bedrock:ListInferenceProfiles` | Custom policy (see reference) |
| Vertex AI   | `aiplatform.endpoints.predict`                                     | `roles/aiplatform.user`      |
| Foundry     | `Microsoft.CognitiveServices/accounts/providers/*`                 | `Azure AI User` or `Cognitive Services User` |

### Bedrock Credential Options

| Method             | Setup                                      |
|:-------------------|:-------------------------------------------|
| AWS CLI            | `aws configure`                            |
| Access key envs    | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile        | `aws sso login --profile=<name>` + `AWS_PROFILE` |
| AWS login          | `aws login`                                |
| Bedrock API key    | `AWS_BEARER_TOKEN_BEDROCK`                 |
| Auto-refresh (SSO) | `awsAuthRefresh` / `awsCredentialExport` in settings |

### Vertex AI Region Overrides

When using `CLOUD_ML_REGION=global`, override per-model regions with:

```bash
VERTEX_REGION_CLAUDE_3_5_HAIKU=us-east5
VERTEX_REGION_CLAUDE_4_0_SONNET=us-east5
VERTEX_REGION_CLAUDE_4_1_OPUS=europe-west1
```

### LLM Gateway Configuration

Gateways proxy between Claude Code and providers for centralized auth, usage tracking, cost controls, and audit logging.

**Supported API formats:** Anthropic Messages (`/v1/messages`), Bedrock InvokeModel (`/invoke`), Vertex rawPredict (`:rawPredict`).

| Routing target      | Base URL variable                | Skip auth variable                |
|:---------------------|:---------------------------------|:----------------------------------|
| Anthropic API        | `ANTHROPIC_BASE_URL`             | n/a                               |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL`     | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` |
| Vertex pass-through  | `ANTHROPIC_VERTEX_BASE_URL`      | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1`  |
| Foundry pass-through | `ANTHROPIC_FOUNDRY_BASE_URL`     | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

**LiteLLM unified endpoint (recommended):**

```bash
export ANTHROPIC_BASE_URL=https://litellm-server:4000
export ANTHROPIC_AUTH_TOKEN=sk-litellm-key
```

For rotating keys, use `apiKeyHelper` in settings with optional `CLAUDE_CODE_API_KEY_HELPER_TTL_MS`.

### Corporate Proxy

Route traffic through an HTTP/HTTPS proxy with `HTTPS_PROXY`:

```bash
export HTTPS_PROXY='https://proxy.example.com:8080'
```

### Bedrock Guardrails

```json
{
  "env": {
    "ANTHROPIC_CUSTOM_HEADERS": "X-Amzn-Bedrock-GuardrailIdentifier: your-id\nX-Amzn-Bedrock-GuardrailVersion: 1"
  }
}
```

### Deployment Options Comparison

| Feature              | Teams/Enterprise          | Anthropic Console | Bedrock          | Vertex AI       | Foundry          |
|:---------------------|:--------------------------|:------------------|:-----------------|:----------------|:-----------------|
| Best for             | Most orgs (recommended)   | Individual devs   | AWS-native       | GCP-native      | Azure-native     |
| Billing              | Per-seat or contact sales | PAYG              | PAYG via AWS     | PAYG via GCP    | PAYG via Azure   |
| Auth                 | Claude.ai SSO/email       | API key           | AWS creds/key    | GCP creds       | API key/Entra ID |
| Includes Claude web  | Yes                       | No                | No               | No              | No               |

### Troubleshooting Quick Tips

- **Bedrock region issues:** `aws bedrock list-inference-profiles --region your-region`, or use inference profiles for cross-region access.
- **Bedrock "on-demand throughput isn't supported":** Specify the model as an inference profile ID.
- **Vertex 404 "model not found":** Confirm model is enabled in Model Garden; check global endpoint support; use `VERTEX_REGION_*` overrides.
- **Vertex 429 rate limit:** Ensure models are supported in your region, or switch to `CLOUD_ML_REGION=global`.
- **Foundry auth failure:** Set `ANTHROPIC_FOUNDRY_API_KEY` or configure Entra ID credentials.
- **Verify config:** Run `/status` inside Claude Code.

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) -- full setup, IAM policy, credential refresh, guardrails, and troubleshooting
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) -- full setup, IAM roles, region configuration, and 1M context window
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) -- full setup, RBAC configuration, Entra ID authentication
- [LLM Gateway](references/claude-code-llm-gateway.md) -- gateway requirements, LiteLLM configuration, pass-through endpoints
- [Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) -- deployment comparison, proxy/gateway setup, organization best practices

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM Gateway: https://code.claude.com/docs/en/llm-gateway.md
- Enterprise Deployment: https://code.claude.com/docs/en/third-party-integrations.md
