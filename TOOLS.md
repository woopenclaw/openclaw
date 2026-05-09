# 工具环境

## 必知路径
| 路径 | 用途 |
|------|------|
| `~/.openclaw/openclaw.json` | OpenClaw 配置 |
| `~/.openclaw/workspace` | 工作区（五文件所在地） |
| `~/comic_skills` | 共享技能目录（阿飞研发产出 → 我调用） |
| `~/comic_work.log` | 执行日志（我写 → 阿飞读） |
| `~/comic_output` | 漫剧默认输出目录 |
| `~/comic_scripts` | 脚本存储目录 |
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
| 查看共享技能 | `ls -la ~/comic_skills/` |
| 调用阿飞处理技术问题 | `~/hermes_with_soul.sh "请分析 xxx 问题并修复"` |

## 双核分工
| 角色 | 引擎 | 职责 | 我该怎么做 |
|------|------|------|-----------|
| 🪨 **阿砚（我）** | OpenClaw | 业务执行 | 接单、生产、调工具、写日志 |
| 🦊 **阿飞** | Hermes | 技术研发 | 写Skill、Debug、数据分析、环境维护 |

**遇到超出我能力的技术问题** → 告诉飞哥"建议让阿飞处理"

## 模型策略
| 角色 | 模型 ID | 说明 |
|------|---------|------|
| 🏆 主力 | `deepseek/deepseek-v4-flash` | 高吞吐、低成本、1M 上下文 |
| 🗃️ 备用 | `bailian-token/qwen3.6-plus` | 主力不可用时手动切换 |
| 🔄 切换方法 | `openclaw config set agents.defaults.model.primary "bailian-token/qwen3.6-plus"` | |

## 环境变量
| 变量名 | 作用 | 定义位置 |
|--------|------|---------|
| `DASHSCOPE_API_KEY` | 阿里云百炼 API | `~/.hermes/.env` |
| DeepSeek API Key | DeepSeek 推理 | `~/.openclaw/openclaw.json` 内 models 配置 |

## 日志维护
```bash
# 查看日志大小
ls -lh ~/comic_work.log

# 超过 1MB 时备份归档
mv ~/comic_work.log ~/comic_work_$(date +%Y%m%d_%H%M%S).log.bak
touch ~/comic_work.log
```

## 重启流程
修改 openclaw.json 或文件配置后：
```bash
openclaw gateway restart
openclaw status  # 确认运行正常
```

## 技能管理
- 共享技能目录中的技能**优先级低于**内置技能，但被自动扫描到
- 若与内置技能同名，内置技能生效（无需处理）
- 手动调用共享技能：`openclaw skill run --skill-dir ~/comic_skills/<技能名>`
- 查看全部技能：`openclaw skills list`

## 飞书渠道
```bash
# 测试飞书消息（确认配置正常后）
# 飞哥需要先确认飞书已配对成功
```

## 指令信箱
- `~/yan_queue.md` — 阿飞给我派活的指令文件
- 每次被唤醒时，**必须先检查**这个文件
- 有任务就执行 → 清空 → 回复结果
- 没任务就正常干活

### 自动轮询
- cron job `queue-check` 每2分钟自动检查信箱
- 阿飞直接写队列文件即可，无需飞哥传话
- 查看cron任务：`openclaw cron list`

## 调试
```bash
# 看 OpenClaw 完整日志
tail -100 /tmp/openclaw/openclaw-*.log

# 查配置文件
cat ~/.openclaw/openclaw.json | python3 -m json.tool
```
