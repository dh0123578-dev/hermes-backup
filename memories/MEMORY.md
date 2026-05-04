模型: deepseek-v4-flash (DeepSeek API)
Vision: 智谱 GLM-4V-Flash (免费)
§
Git自动备份: ~/.hermes/ 每30min → git@github.com:dh0123578-dev/hermes-backup.git
§
企业微信网关: python -m hermes_cli.main gateway run 后台启动
§
Token优化已实施: 记忆精简88%, user缩减91%, cron频率降75%, max_turns 90→50, reasoning_effort medium→low, compression 加强, 记忆注入上限降低
§
memory(action='replace') does NOT delete old entries — it replaces matching text in place. Old entries that don't match old_text remain. Use write_file to overwrite .md files directly, then memory(action='remove') for orphaned entries.