# 工具环境

## ⚡ 工具并发规则（Claude Code 启发）

- 🟢 **只读工具可并发**：ls, cat, grep, find, curl GET, read — 同时发起多个
- 🔴 **写入工具串行**：write, edit, rm, mv, npm install, git push — 一个一个来
- 并发上限：最多 3 个并行只读操作

## 必知路径
| 路径 | 用途 |
|------|------|
| `~/.openclaw/openclaw.json` | OpenClaw 配置 |
| `~/.openclaw/workspace` | 工作区（五文件所在地） |
| `~/.openclaw/workspace/skills` | 共享技能目录（阿飞研发产出 → 我调用） |
| `~/comic_work.log` | 执行日志（我写 → 阿飞读） |
| `~/comic_output` | 漫剧默认输出目录 |
| `~/comic_scripts` | 脚本存储目录 |
| `~/comic_scripts/漫剧制作完整手册.md` | 漫剧全流程操作手册（7模块） |
| `~/.hermes/skills/creative/comfyui/` | ComfyUI 技能（本地+云端） |
| `~/hermes_memory` | 阿飞进化笔记 |
| `~/scripts` | 阿飞临时脚本存放处 |
| `~/hermes_with_soul.sh` | 阿飞启动脚本 |

## 常用命令
| 用途 | 命令 |
|------|------|
| 重启网关 | `openclaw gateway restart` |
| 查看状态 | `openclaw gateway status` |
| 列出模型 | `openclaw models list` |
| 安装技能 | `clawhub install <技能名>` |
| 手动调用技能 | `openclaw skill run <技能名>` |
| 查看日志 | `tail -50 /tmp/openclaw/openclaw-*.log` |
| 测试推理 | `openclaw run "你好" --model deepseek/deepseek-v4-flash` |
| 查看工作日志 | `cat ~/comic_work.log` |
| 查看共享技能 | `ls -la ~/.openclaw/workspace/skills/` |
| 调用阿飞处理技术问题 | `~/hermes_with_soul.sh "请分析 xxx 问题并修复"` |

## 版本信息
| 项目 | 版本 |
|------|------|
| OpenClaw | 2026.5.20 |
| Python | 3.12 |
| Node | 22.22 |
| GPU | NVIDIA RTX 5060 Ti 8GB（WSL2） |

## 模型策略
| 角色 | 模型 ID | 说明 |
|------|---------|------|
| 🏆 **主力** | `bailian-token/qwen3.7-plus` | 推理、创作、日常交互（新主力） |
| 🧠 推理备选 | `deepseek/deepseek-v4-pro` | 深度推理、复杂代码 |
| 🚀 高吞吐 | `deepseek/deepseek-v4-flash` | 日常快速响应、1M 上下文 |
| 🎬 视频 | `doubao-seedance-2-0-260128` | 火山引擎 Seedance 2.0 |
| 👁️ 看图 | `kimi-k2.5` | 图片/视频理解专用 |
| 🎬 视频备选 | `kling-v2-6` (可灵) | JWT鉴权，5s/镜 ¥3-4，无审核误判 |
| 🔄 备用 | `bailian-token/qwen3.6-plus` | deepseek 不可用时 |

## API 端点速查
| 用途 | 端点/方式 |
|------|----------|
| 火山视频生成 | `POST https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks` |
| 火山视频轮询 | `GET https://ark.cn-beijing.volces.com/api/v3/contents/generations/tasks/{id}` |
| Kling 文生视频 | `POST https://api-beijing.klingai.com/v1/videos/text2video` |
| Kling 图生视频 | `POST https://api-beijing.klingai.com/v1/videos/image2video` |
| Kling 任务查询 | `GET https://api-beijing.klingai.com/v1/videos/text2video/{id}` |
| ComfyUI 云端 | `export COMFY_CLOUD_API_KEY; --host https://cloud.comfy.org` |
| 图片生成 | `nano-banana-pro` 技能 或 memefast |

## 环境变量
| 变量名 | 作用 | 定义位置 |
|--------|------|---------|
| `DASHSCOPE_API_KEY` | 阿里云百炼 API | `~/.hermes/.env` |
| `NANOPHOTO_API_KEY` | NanoPhoto 图片/提示词 API | `~/.openclaw/openclaw.json` |
| `BYTEPLUS_API_KEY` | 火山引擎视频 API（Seedance） | `~/.openclaw/openclaw.json` |
| `KLING_AK` | Kling 可灵视频 AccessKey | `~/.hermes/kling/config.json` |
| `KLING_SK` | Kling 可灵视频 SecretKey | `~/.hermes/kling/config.json` |
| `COMFY_CLOUD_API_KEY` | ComfyUI Cloud API | 需飞哥配置 |
| DeepSeek API Key | DeepSeek 推理 | `~/.openclaw/openclaw.json` 内 models 配置 |

## 技能管理
- 共享技能目录中的技能**优先级低于**内置技能，但被自动扫描到
- 若与内置技能同名，内置技能生效（无需处理）
- 手动调用共享技能：`openclaw skill run --skill-dir ~/.openclaw/workspace/skills/<技能名>`
- 查看全部技能：`openclaw skills list`

## 飞书渠道

（待飞哥配置飞书配对后启用）

## 调试
```bash
# 看 OpenClaw 完整日志
tail -100 /tmp/openclaw/openclaw-*.log

# 查配置文件
cat ~/.openclaw/openclaw.json | python3 -m json.tool
```
