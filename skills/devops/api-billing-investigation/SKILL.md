---
name: api-billing-investigation
description: Investigate unexpected API billing or token consumption patterns — cross-reference provider dashboards with local logs, session records, and config to find the real cause.
version: 1.0.0
---

# API Billing & Token Consumption Investigation

## When to Use

- User reports unexpected or excessive token consumption
- User asks why a model they didn't configure is showing up in billing
- Provider dashboard shows model X consuming tokens, but local config says model Y

## Core Insight

Provider billing dashboards sometimes group API calls differently than your actual model config. DeepSeek may:
- Map `deepseek-v4-flash` → `deepseek-chat` internally at the API level
- Classify auxiliary/helper-model calls under a different model name
- Show model availability lists (not just actual consumption) in the dashboard

## Investigation Workflow

### Phase 1 — Gather Evidence

**Don't guess. Collect from ALL sources before forming conclusions.**

#### 1. Read the current model config

Check config for `model.default`, `model.provider`, `model.base_url`.

#### 2. Check logs for actual model attribution

```bash
# Find API calls with model names
grep -E "model=" ~/.hermes/logs/agent.log | tail -30

# Find any mention of the disputed model
grep "<disputed-model-name>" ~/.hermes/logs/agent.log

# Check credential pool rotation (can look like model switching)
grep "credential_pool" ~/.hermes/logs/agent.log | tail -10
```

#### 3. Search session history for model discussions

```python
# Search session files for user messages mentioning the disputed model
# Check whether the agent listed that model in an informational table
# Check whether the user explicitly approved/rejected switching to it
```

#### 4. Query provider's model list for aliases

```bash
curl -s "https://api.deepseek.com/v1/models" \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" | python3 -m json.tool
```

### Phase 2 — Cross-Reference

For each finding, ask:
- Is this from actual API calls, or just metadata/listings from a model comparison?
- Dashboard: showing consumption or available model list?
- Are auxiliary models (vision, compression, title generation) using a separate name?
- Did a past conversation include listing model pricing that the user misinterpreted?

#### Common confusion patterns

| User says | Likely cause |
|-----------|-------------|
| "Didn't configure model X but it's using tokens" | Dashboard may group calls under a parent family. Or auxiliary models auto-detect under a different alias. |
| "Consumption is way too high" | 1M context sessions + many turns = real high consumption. Count sessions × turns. |
| "Model X appeared in my bill" | Could be a model list/availability query from a past conversation. |
| "Never authorized that model" | Agent may have listed it informatively in a comparison table. Listing ≠ using. |

### Phase 3 — Present Findings

Structure the explanation clearly:

1. Is the model in config? → Show exact config content
2. Is the agent actually calling it? → Show log evidence
3. Why does dashboard show it? → Explain provider billing behavior
4. Why was consumption high? → Session count × turns × context size

### Key Evidence Sources

1. **Config file** — The single source of truth for what's configured
2. **Agent log (`~/.hermes/logs/agent.log`)** — Contains `model=` in API call log lines, credential pool events, auxiliary model auto-detect lines, and error responses
3. **Session files (`~/.hermes/sessions/`)** — Message history for checking past model discussions
4. **Provider API `/v1/models`** — Shows all available models and their API-level names

## Pitfalls

- Session files usually do NOT store token counts or costs. Don't claim you can calculate consumption locally unless verified.
- `deepseek-chat` in logs is DeepSeek's internal API name, not the user's configured model name.
- Credential pool rotation logs (`credential_pool: marking exhausted`) look like model switching but are about API key status.
- Auxiliary models auto-detect as `deepseek-chat` by convention — this is separate from the main conversation model.
- You cannot fix provider billing dashboards. You can explain the discrepancy but the user must contact their provider.
