# 心跳配置 · 健康检查

## 🔧 工具链健康探测（每次心跳执行）
心跳时必须批量探测以下服务状态：

| 检查项 | 探测命令 | 异常阈值 |
|--------|---------|---------|
| searxng 搜索 | `curl -s -m 3 http://127.0.0.1:8888/health` | 连续2次失败 → 汇报飞哥 |
| 火山 API | `curl -s -m 3 https://ark.cn-beijing.volces.com/api/v3/health` | 连续2次失败 → 汇报飞哥 |
| ComfyUI 本地 | `curl -s -m 2 http://127.0.0.1:8188/system_stats` | 离线 → 汇报飞哥 |
| Gateway 健康 | `curl -s http://127.0.0.1:18789/health` | 挂了 → 无法汇报 |
| 磁盘空间 | `df -h /` | 使用率 > 90% → 提醒飞哥 |
| 会话目录 | `du -sh ~/.openclaw/agents/main/sessions/` | > 2GB → 提醒归档 |

## 自动检查项
- 队列检查（cron job queue-check 每2分钟）
- 技能目录检查：`~/.openclaw/workspace/skills/` 新技能通知
- Darwin Cull 墓地检查：`~/.openclaw/workspace/skills/.graveyard/` 可逆恢复
- 日志大小检查：`~/comic_work.log` 超过 1MB 提醒归档
- **Codex协同检查**：读 `D:\codex\shared\output\codex_done.md` → 有新内容汇报飞哥
- **记忆健康检查**：查 MEMORY.md Recent Events 最后更新时间 → 超过 48h 未更新需主动报告

## 心跳响应规范
- 工具链全部健康 → `HEARTBEAT_OK`
- 有服务异常 → 列出异常项 → `HEARTBEAT_ISSUES: [具体项]`
- 不要每次心跳都重复汇报已知问题（24h 内同一问题只报一次）

## 当前技能分布 (22个)
漫剧核心: seedance-2-video-gen / comic-drama-generate / video-prompt-generator / audio-cog / text-to-speech-and-voice-cloning-agent / translatepro / sora-2-generate
漫剧辅助: arakawa-perspective / nuwa / nano-banana-pro / playwright / humanizer
日常基础: web-search / web-browsing / devops / system-data-intelligence / notes / repo-guardian / bruce-drawio
元工具: darwin-cull / sqlite-client / pdf-text-extractor
墓地(纯冗余): free-image-and-video-generation / social-scheduler / wan-image-video-generation-editting
