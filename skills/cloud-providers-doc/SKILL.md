---
name: cloud-providers-doc
description: Complete official documentation for Claude Code cloud provider integrations — Amazon Bedrock (setup, IAM, Mantle endpoint, guardrails, model pinning), Google Vertex AI (setup, regions, IAM, model pinning), Microsoft Foundry (setup, RBAC, Entra ID), LLM gateway configuration (LiteLLM, pass-through endpoints), and enterprise deployment comparison and best practices.
user-invocable: false
---

# Cloud Providers Documentation

This skill provides the complete official documentation for running Claude Code through third-party cloud providers and LLM gateways.

## Quick Reference

### Deployment options comparison

| Feature | Claude Teams/Enterprise | Anthropic Console | Amazon Bedrock | Google Vertex AI | Microsoft Foundry |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Best for | Most organizations | Individual developers | AWS-native | GCP-native | Azure-native |
| Billing | Per-seat or contact sales | PAYG | PAYG via AWS | PAYG via GCP | PAYG via Azure |
| Authentication | Claude.ai SSO or email | API key | API key or AWS credentials | GCP credentials | API key or Entra ID |
| Includes Claude on web | Yes | No | No | No | No |
| Enterprise features | Team mgmt, SSO, monitoring | None | IAM, CloudTrail | IAM, Cloud Audit Logs | RBAC, Azure Monitor |

### Enable variable per provider

| Provider | Enable variable | Other required variables |
| :--- | :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` | `AWS_REGION` |
| Mantle (Bedrock) | `CLAUDE_CODE_USE_MANTLE=1` | `AWS_REGION` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` | `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID` |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` | `ANTHROPIC_FOUNDRY_RESOURCE` or `ANTHROPIC_FOUNDRY_BASE_URL` |

### Model pinning variables (all providers)

Pin these when deploying to multiple users to prevent breakage on new releases:

| Variable | Purpose |
| :--- | :--- |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Pin Opus model version |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Pin Sonnet model version |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Pin Haiku model version |
| `ANTHROPIC_MODEL` | Override primary model entirely |

### Amazon Bedrock

**Authentication options:**

| Method | Variables / commands |
| :--- | :--- |
| AWS CLI profile | `aws configure` then `AWS_PROFILE=your-profile` |
| Access key + secret | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |
| SSO profile | `aws sso login --profile=<name>`, then `AWS_PROFILE=your-profile` |
| Bedrock API key | `AWS_BEARER_TOKEN_BEDROCK=your-key` |

**Automatic credential refresh:**

| Setting | Description |
| :--- | :--- |
| `awsAuthRefresh` | Command that modifies `.aws` dir (SSO flows, browser-based); output shown to user |
| `awsCredentialExport` | Command that outputs JSON credentials directly; output captured silently |

**Key Bedrock environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_BEDROCK=1` | Enable Bedrock |
| `AWS_REGION` | Required; not read from `.aws` config |
| `ANTHROPIC_SMALL_FAST_MODEL_AWS_REGION` | Override region for Haiku-class model |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint (custom gateways) |
| `DISABLE_PROMPT_CACHING=1` | Disable prompt caching |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour cache TTL (higher cost) |

**Default Bedrock models (when not pinned):**

| Model type | Default |
| :--- | :--- |
| Primary | `us.anthropic.claude-sonnet-4-5-20250929-v1:0` |
| Small/fast | `us.anthropic.claude-haiku-4-5-20251001-v1:0` |

**Bedrock IAM policy actions required:**
- `bedrock:InvokeModel`
- `bedrock:InvokeModelWithResponseStream`
- `bedrock:ListInferenceProfiles`

**Mantle endpoint** (native Anthropic API shape over Bedrock):

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_MANTLE=1` | Enable Mantle |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Mantle endpoint |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Skip SigV4 auth (for gateway setups) |

Run both Bedrock and Mantle simultaneously: set both `CLAUDE_CODE_USE_BEDROCK=1` and `CLAUDE_CODE_USE_MANTLE=1`. Model IDs with `anthropic.` prefix route to Mantle; all others go to Invoke API.

**AWS Guardrails** — add to settings `env` block:
```
ANTHROPIC_CUSTOM_HEADERS: "X-Amzn-Bedrock-GuardrailIdentifier: <id>\nX-Amzn-Bedrock-GuardrailVersion: 1"
```

**1M context window:** Opus 4.7, Opus 4.6, and Sonnet 4.6 support it on Bedrock. Append `[1m]` to a manually pinned model ID to enable.

### Google Vertex AI

**Required environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_VERTEX=1` | Enable Vertex AI |
| `CLOUD_ML_REGION` | `global`, multi-region (`eu`, `us`), or specific region (e.g. `us-east5`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex endpoint |
| `VERTEX_REGION_CLAUDE_HAIKU_4_5` | Per-model region override when using global endpoint |
| `VERTEX_REGION_CLAUDE_4_6_SONNET` | Per-model region override when using global endpoint |
| `ENABLE_TOOL_SEARCH=true` | Opt in to MCP tool search (disabled by default on Vertex) |

**Default Vertex models (when not pinned):**

| Model type | Default |
| :--- | :--- |
| Primary | `claude-sonnet-4-5@20250929` |
| Small/fast | `claude-haiku-4-5@20251001` |

**IAM:** `roles/aiplatform.user` is sufficient (`aiplatform.endpoints.predict` permission).

**Wizard:** `/setup-vertex` reopens the Vertex setup wizard (requires Claude Code v2.1.98+).

**1M context window:** Opus 4.7, Opus 4.6, and Sonnet 4.6 support it on Vertex. Append `[1m]` to a manually pinned model ID.

### Microsoft Foundry

**Required environment variables:**

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_USE_FOUNDRY=1` | Enable Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Azure resource name |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL (alternative to resource name) |
| `ANTHROPIC_FOUNDRY_API_KEY` | API key (omit to use Entra ID via default credential chain) |
| `ENABLE_PROMPT_CACHING_1H=1` | Request 1-hour cache TTL (higher cost) |

**Authentication:**
- **API key:** Set `ANTHROPIC_FOUNDRY_API_KEY`
- **Entra ID:** Omit key; Claude Code uses Azure SDK default credential chain (supports `az login`, managed identity, env vars, etc.)

**RBAC:** `Azure AI User` or `Cognitive Services User` default roles include all required permissions.

**Foundry model names** (match your Azure deployment names):
```
ANTHROPIC_DEFAULT_OPUS_MODEL=claude-opus-4-7
ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6
ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-haiku-4-5
```

### LLM gateway configuration

**Gateway API format requirements** — must expose at least one of:

| Format | Endpoints | Must forward |
| :--- | :--- | :--- |
| Anthropic Messages | `/v1/messages`, `/v1/messages/count_tokens` | `anthropic-beta`, `anthropic-version` headers |
| Bedrock InvokeModel | `/invoke`, `/invoke-with-response-stream` | `anthropic_beta`, `anthropic_version` body fields |
| Vertex rawPredict | `:rawPredict`, `:streamRawPredict`, `/count-tokens:rawPredict` | `anthropic-beta`, `anthropic-version` headers |

**Base URL overrides per provider:**

| Provider | Variable |
| :--- | :--- |
| Anthropic API / LiteLLM unified | `ANTHROPIC_BASE_URL` |
| Bedrock pass-through | `ANTHROPIC_BEDROCK_BASE_URL` |
| Vertex pass-through | `ANTHROPIC_VERTEX_BASE_URL` |
| Foundry pass-through | `ANTHROPIC_FOUNDRY_BASE_URL` |

**Skip auth variables** (when gateway handles credentials):

| Variable | Skips |
| :--- | :--- |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` | AWS SigV4 signing |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH=1` | GCP credential injection |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH=1` | Azure credential injection |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH=1` | Mantle SigV4 signing |

**LiteLLM auth methods:**

| Method | Variable / setting |
| :--- | :--- |
| Static API key | `ANTHROPIC_AUTH_TOKEN=sk-litellm-key` (sent as `Authorization` header) |
| Dynamic key helper | `apiKeyHelper` setting pointing to a script; `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` for refresh interval |

**Note:** LiteLLM PyPI versions 1.82.7 and 1.82.8 were compromised with credential-stealing malware — do not use those versions.

### Session header for gateway logging

Every Claude Code request includes `X-Claude-Code-Session-Id` — a unique session identifier gateways can use to aggregate requests without parsing the request body.

### Corporate proxy vs. LLM gateway

| | Corporate proxy | LLM gateway |
| :--- | :--- | :--- |
| Purpose | Route all outbound traffic through HTTPS proxy | Sit between Claude Code and provider for auth/routing |
| Configure with | `HTTPS_PROXY` / `HTTP_PROXY` | `ANTHROPIC_BASE_URL` / provider-specific `*_BASE_URL` |
| Use case | Security monitoring, compliance, network policy | Centralized auth, usage tracking, rate limiting, budgets |

Use `/status` inside Claude Code to verify provider and gateway configuration.

### Organization best practices

- Deploy `CLAUDE.md` at org level (`/Library/Application Support/ClaudeCode/CLAUDE.md` on macOS) and repo level
- Pin model versions before any team rollout; review model upgrade timing carefully
- Use `modelOverrides` in settings to map model names to application inference profile ARNs (Bedrock)
- Use `/permissions` to audit permission settings; use managed settings to enforce org-wide standards
- Create a dedicated cloud account/project for Claude Code to simplify cost tracking

## Full Documentation

For the complete official documentation, see the reference files:

- [Claude Code on Amazon Bedrock](references/claude-code-amazon-bedrock.md) — prerequisites, sign-in wizard, manual setup, IAM policy, Mantle endpoint, guardrails, startup model checks, troubleshooting
- [Claude Code on Google Vertex AI](references/claude-code-google-vertex-ai.md) — prerequisites, sign-in wizard, region configuration, manual setup, IAM, startup model checks, troubleshooting
- [Claude Code on Microsoft Foundry](references/claude-code-microsoft-foundry.md) — prerequisites, setup, API key and Entra ID authentication, RBAC, troubleshooting
- [LLM gateway configuration](references/claude-code-llm-gateway.md) — gateway requirements, LiteLLM setup, static and dynamic auth, unified and pass-through endpoints
- [Enterprise deployment overview](references/claude-code-third-party-integrations.md) — deployment option comparison, proxy and gateway setup per provider, organization best practices

## Sources

- Claude Code on Amazon Bedrock: https://code.claude.com/docs/en/amazon-bedrock.md
- Claude Code on Google Vertex AI: https://code.claude.com/docs/en/google-vertex-ai.md
- Claude Code on Microsoft Foundry: https://code.claude.com/docs/en/microsoft-foundry.md
- LLM gateway configuration: https://code.claude.com/docs/en/llm-gateway.md
- Enterprise deployment overview: https://code.claude.com/docs/en/third-party-integrations.md
