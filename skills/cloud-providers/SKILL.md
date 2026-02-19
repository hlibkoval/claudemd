---
name: cloud-providers
description: Reference documentation for deploying Claude Code through cloud providers — Amazon Bedrock, Google Vertex AI, Microsoft Foundry — including environment variable setup, credential configuration, model pinning, IAM/RBAC permissions, LLM gateway configuration, and enterprise deployment comparisons. Use when configuring third-party cloud provider access, proxy or gateway routing, or enterprise deployment options.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for deploying Claude Code through cloud providers and enterprise infrastructure.

## Quick Reference

### Deployment Options Comparison

| Feature              | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock      | Google Vertex AI    | Microsoft Foundry   |
|:---------------------|:------------------------|:------------------|:--------------------|:--------------------|:--------------------|
| Best for             | Most orgs (recommended) | Individual devs   | AWS-native          | GCP-native          | Azure-native        |
| Billing              | $150/seat or Enterprise | PAYG              | PAYG via AWS        | PAYG via GCP        | PAYG via Azure      |
| Auth                 | Claude.ai SSO / email   | API key           | API key / AWS creds | GCP credentials     | API key / Entra ID  |
| Includes web Claude  | Yes                     | No                | No                  | No                  | No                  |

### Enable a Cloud Provider

| Provider          | Required env vars                                                               |
|:------------------|:--------------------------------------------------------------------------------|
| Amazon Bedrock    | `CLAUDE_CODE_USE_BEDROCK=1`, `AWS_REGION=us-east-1`                            |
| Google Vertex AI  | `CLAUDE_CODE_USE_VERTEX=1`, `CLOUD_ML_REGION=global`, `ANTHROPIC_VERTEX_PROJECT_ID=<id>` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1`, `ANTHROPIC_FOUNDRY_RESOURCE=<name>`               |

### Pin Model Versions (Required for Deployments)

Pin versions to avoid breakage when Anthropic releases new models. Aliases (`sonnet`, `opus`, `haiku`) without pinning may resolve to unavailable models.

**Bedrock:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='us.anthropic.claude-opus-4-6-v1'
export ANTHROPIC_DEFAULT_SONNET_MODEL='us.anthropic.claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='us.anthropic.claude-haiku-4-5-20251001-v1:0'
```

**Vertex AI:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5@20251001'
```

**Foundry:**
```bash
export ANTHROPIC_DEFAULT_OPUS_MODEL='claude-opus-4-6'
export ANTHROPIC_DEFAULT_SONNET_MODEL='claude-sonnet-4-6'
export ANTHROPIC_DEFAULT_HAIKU_MODEL='claude-haiku-4-5'
```

### Authentication Methods

| Provider   | Method A                                      | Method B                               |
|:-----------|:----------------------------------------------|:---------------------------------------|
| Bedrock    | `AWS_BEARER_TOKEN_BEDROCK=<key>` (API key)    | `aws configure` / `AWS_PROFILE`        |
| Vertex AI  | Application Default Credentials (`gcloud`)    | `GOOGLE_APPLICATION_CREDENTIALS`       |
| Foundry    | `ANTHROPIC_FOUNDRY_API_KEY=<key>`             | Microsoft Entra ID (`az login`)        |

Auto credential refresh (Bedrock): configure `awsAuthRefresh` or `awsCredentialExport` in settings.

### Proxy and Gateway Routing

| Type              | Bedrock env var                  | Vertex env var                    | Foundry env var                    |
|:------------------|:---------------------------------|:----------------------------------|:-----------------------------------|
| Corporate proxy   | `HTTPS_PROXY=<url>`              | `HTTPS_PROXY=<url>`               | `HTTPS_PROXY=<url>`                |
| LLM gateway       | `ANTHROPIC_BEDROCK_BASE_URL=<url>` | `ANTHROPIC_VERTEX_BASE_URL=<url>` | `ANTHROPIC_FOUNDRY_BASE_URL=<url>` |
| Skip cloud auth   | `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` |

Use `/status` inside Claude Code to verify proxy/gateway configuration.

### LLM Gateway Requirements

A gateway must expose at least one of these API formats:

| Format                    | Endpoints                                           | Headers to forward                          |
|:--------------------------|:----------------------------------------------------|:--------------------------------------------|
| Anthropic Messages        | `/v1/messages`, `/v1/messages/count_tokens`         | `anthropic-beta`, `anthropic-version`       |
| Bedrock InvokeModel       | `/invoke`, `/invoke-with-response-stream`           | body fields `anthropic_beta`, `anthropic_version` |
| Vertex rawPredict         | `:rawPredict`, `:streamRawPredict`                  | `anthropic-beta`, `anthropic-version`       |

LiteLLM unified endpoint (recommended): `export ANTHROPIC_BASE_URL=https://litellm-server:4000`

### Permissions / IAM

**Bedrock IAM actions required:**
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`

**Vertex AI role required:** `roles/aiplatform.user` (grants `aiplatform.endpoints.predict`)

**Foundry RBAC roles:** `Azure AI User` or `Cognitive Services User`

## Full Documentation

For the complete official documentation, see the reference files:

- [Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, AWS credential setup, IAM policy, Guardrails, model pinning, and troubleshooting
- [Google Vertex AI](references/claude-code-google-vertex-ai.md) — GCP setup, credential configuration, IAM, 1M token context, regional endpoints, and troubleshooting
- [Microsoft Foundry](references/claude-code-microsoft-foundry.md) — Azure provisioning, API key and Entra ID auth, RBAC, model pinning, and troubleshooting
- [Third-Party Integrations / Enterprise Deployment Overview](references/claude-code-third-party-integrations.md) — deployment option comparison, proxy/gateway setup per provider, and enterprise best practices
- [LLM Gateway Configuration](references/claude-code-llm-gateway.md) — gateway requirements, LiteLLM setup, authentication methods, and provider-specific pass-through endpoints

## Sources

- Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- Third-Party Integrations: https://code.claude.com/docs/en/third-party-integrations.md
- LLM Gateway Configuration: https://code.claude.com/docs/en/llm-gateway.md
