# Long-Term Memory

> memory_types: user_preference | project_fact | workflow | correction | convention | daily_digest
> WHAT NOT TO SAVE: 临时进度、Session结果、7天内过时工件、PR号/issue号、commit SHA、心跳记录
> 每次有意义的会话结束时，阿砚必须追加一条到 Recent Events。不写 = 明天失忆。

## Rules
<!-- memory_type: user_preference -->
- Kimi K2.5 只用于看图片和视频的时候调用，日常对话/任务不准用。 (2026-05-09)
- 每完成一项任务，必须给飞哥输出结构化总结卡片（做了什么、改了什么、结果状态）。不做事后默默无声。 (2026-05-09)
- 做完任何事都要主动列出做了什么，逐条说清楚，不准默默结束。这是铁律。 (2026-05-09)
- 视频生成用火山引擎 Seedance 2.0 直调 API，不依赖第三方 wrapper。日常对话和创作都用 deepseek。 (2026-05-21)
- 学技能必须深度学——拆节点/跑参数/写手册，不准只读文档就说学会了。 (2026-05-21)
- 漫剧制作优先角色一致性：三视图→img2img→固定seed，不准跳过角色设计直接出片。 (2026-05-21)
- 复杂分析任务走胡说老木五步框架（多维拆解→正反推演→深度质疑→全局复盘→终态结论）。涂津豪协议保证内部思考质量，五步框架保证外部输出可审计。分层协作，不互替。 (2026-06-08)
- Harness-1 外置记忆舱架构已升级为全局操作系统 v2.0：不只漫剧，所有项目共享同一套七模块架构（候选池/精选集/线索图谱/验证缓存/动作指令集/压缩规则/全局参数）。新项目第一步是建 memory_bank.json。通用模板：~/comic_output/_memory_bank_template.json。 (2026-06-08)
- **铁律：每次有意义的会话结束后，必须追加一条到 Recent Events。不写 = 明天失忆 = 飞哥要重新讲一遍。** (2026-06-14)

## Technical Facts
<!-- memory_type: project_fact -->
- 火山引擎 Seedance 2.0：Base URL `https://ark.cn-beijing.volces.com/api/v3`，模型 `doubao-seedance-2-0-260128`。 (2026-05-21)
- WSL2 本地 GPU: RTX 5060 Ti 8GB, CUDA 13.1，可跑 SDXL + AnimateDiff，Flux需优化。 (2026-05-21)
- Darwin Cull 技能墓地: `~/.openclaw/workspace/skills/.graveyard/`，当前 21 个活跃技能。 (2026-05-21)
- web-search 技能已从 duckduckgo_search 迁移到 ddgs 包。 (2026-05-15)
- OpenClaw 版本: v2026.6.6（从 2026.5.20 升级）。Gateway 端口 18789，bind=lan。 (2026-06-14)
- session.maintenance 配置: pruneAfter=30d, resetArchiveRetention=30d, mode=enforce（2026-06-14 阿砚配置） (2026-06-14)
- Codex（Windows端）通过 gateway.remote.url=http://172.26.0.1:18789 连接 WSL Gateway，remote.token 已同步，v2026.6.6 使用 openclaw config 设置 client mode。bridge 通道就绪。 (2026-06-14)
- 会话记忆问题：每天凌晨3点自动清理旧会话导致新对话失忆。原因：session.maintenance 默认保留期太短 + dreaming插件写的是诗不是记忆 + MEMORY.md Recent Events 停止更新22天。 (2026-06-14)

## Recent Events
## 每日摘要 2026-06-14
<!-- memory_type: daily_digest -->
- 关键决策：诊断并修复跨天失忆问题（session 30d保留/dreaming禁用/第零层记忆唤醒/Remember铁律）。模型从deepseek-v4-pro切到bailian-token/qwen3.7-plus后又切回。searxng→duckduckgo搜索切换（duckduckgo也不通，待修复）。
- 进行中任务：8装修工程分包报价分析已完成（材料人工综合分析表+分包报价决策表）。搜索修复待阿飞处理。
- 待办事项：飞哥需确认分包报价方案。searxng/Docker修复。
- 配置变更：session.maintenance(30d)、dreaming全部禁用、search provider切duckduckgo、新增每日摘要cron、主模型切换又切回、Agent新增qwen3.7-plus模型

## 每日摘要 2026-06-15
<!-- memory_type: daily_digest -->
无会话记录

## 每日摘要 2026-06-16
<!-- memory_type: daily_digest -->
无会话记录

## Recent Events
- 2026-06-17: 深度系统体检+修复。OpenClaw 2026.6.8 已是最新。修复：kimi cost.output、飞书插件 2026.6.8、gateway service 文件、6325 孤儿会话归档、legacy state 清理。主模型切到 qwen3.7-plus。发现 Kilo Code（OpenClaw 托管版竞品）。安全审计 7 CRITICAL 待飞哥决策。
- 2026-06-14: 发现并修复跨天失忆问题。session.maintenance 设30天保留 + cron每日摘要 + MEMORY.md Recent Events铁律 + dreaming REM阶段禁用。
- 2026-06-14: Codex配置同步完成，bridge通道就绪。Windows端v2026.6.6不再使用client.mode，改用openclaw config。
- 2026-06-13: 工作区整理（comic_skills 归档、cron修复、Darwin Cull配置、guofeng-drama去重检查）。
- 2026-06-08: 胡说老木五步框架+Harness-1外置记忆舱全局化注入SOUL.md。
- 2026-06-05: OpenClaw 升级 2026.6.1。Codex安全隔离解除。
- 2026-06-03: 瘸子的剑 ep1 Seedance 视频生成，审核闸门通过。
- 2026-05-23: 涂津豪 V5.1 深度思考协议注入 SOUL.md，漫剧流水线升级 v3。A100云端Wan 2.1 I2V管线验证通过。
- 2026-05-21: 女娲蒸馏荒木飞吕彦完成，arakawa-perspective技能安装。ComfyUI深度掌握。
- 2026-05-18: 瘸子的剑精细化剧本（70KB）。OpenClaw升级2026.5.20。
- 2026-05-13: 火山引擎Seedance接入，30s国风测试片。
- 2026-05-10: 魔因漫创v0.2.6部署，黑悟空剧本完成。
