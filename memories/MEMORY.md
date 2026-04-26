当前配置的模型是 deepseek-v4-flash，通过 DeepSeek API 调用。用户 HanXianBiao 给配的这个模型。
§
~/.hermes/ 已配置 Git 仓库自动备份，每30分钟系统 cron 自动 commit 并 push 到远程仓库：git@github.com:dh0123578-dev/hermes-backup.git。备份脚本在 ~/.hermes/scripts/auto-backup.sh。备份内容包括：config.yaml、auth.json、.env、memories/、sessions/、skills/、cron/、state.db。已配置 SSH 密钥认证，远程仓库已就绪。
§
企业微信图片读取问题排查：从个人微信转发到企业微信的图片，在企业微信 AI Bot API 中以 image msgtype 发送（base64 或 url+aeskey 加密）。`_extract_media()` 尝试下载解密并缓存到 `~/.hermes/image_cache/`，但缓存可能失败导致 `media_urls` 为空，图片事件被跳过。排查路径：检查 `image_cache` 目录 → 看网关日志中的 DEBUG 输出 → 查看会话 JSON 中 `raw_message` 的图片数据结构。如果缓存失败，建议用户以文件方式发送图片（"发送文件"而非发图片），走 file msgtype 处理。
§
企业微信网关启动方式：用 `python -m hermes_cli.main gateway run` 在后台启动（通过 terminal background=true）。网关状态文件在 `~/.hermes/gateway_state.json`，可以查看 wecom 连接状态。当前网关 PID 309434，wecom 已 connected。
§
用户 HanXianBiao 询问为什么清空了之前的对话记录。需要解释这是正常的会话隔离机制——每个新对话独立，避免上下文混杂。持久记忆功能保留重要信息，之前的会话内容可以通过 session_search 检索。