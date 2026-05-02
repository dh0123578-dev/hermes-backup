---
name: hermes-health-check
description: Periodic health check for Hermes Agent — gateway process status, platform connection health, and model API availability.
---

# Hermes Health Check

Run three core checks on Hermes Agent. Designed for cron job execution.

## Checks

### 1. Gateway Process
- Read `~/.hermes/gateway_state.json`
- Verify `gateway_state` is `"running"`
- Verify all platforms (wecom, feishu) have `state` = `"connected"`
- Verify PID is alive with `kill -0 <pid>`
- If abnormal, attempt restart via `python -m hermes_cli.main gateway run --replace` in background

### 2. Model API
- The model API key may be stored externally (env vars, separate config files), not in `config.yaml` directly
- Test with a minimal chat completion request
- Expected: HTTP 200, not 401/402/429/5xx
- The `config.yaml` `auxiliary.vision` key belongs to the vision provider (e.g. Zhipu GLM), not the main model

### 3. Alerting
- Cron jobs auto-deliver their final response — no need for `send_message`
- Report format: what failed + auto-repair outcome

## Pitfalls
- Do NOT recursively create new cron jobs inside a cron-run session
- If API returns 401, check you're using the right key source (env vs config)
- Gateway can run without systemd showing active — foreground/tmux mode is valid
- When writing back to `gateway_state.json`, use `cat > file << 'EOF'` in terminal, not `read_file()` (it adds line number prefixes)
