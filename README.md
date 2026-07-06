# OpenCode Manager

使用 FreePascal 和 Lazarus LCL 编写的 OpenCode 配置编辑器。当前版本是可运行的桌面 MVP，重点覆盖 OpenCode 与 Oh My OpenAgent/Oh My OpenCode 配置文件的安全读写、结构化编辑、校验、备份和测试。

## 功能

- OpenCode `opencode.json/jsonc` 自动发现、读取、校验和保存。
- Oh My OpenAgent `oh-my-openagent.json/jsonc` 管理，兼容旧名 `oh-my-opencode.json/jsonc`。
- Provider 和 Model 管理，内置常见 Provider/NPM SDK 下拉预设，并支持模型连通性测试。
- OpenCode Agent 管理：支持内置 `plan`/`build`、`description`、`mode`、`model`、`prompt`、`temperature`、`disable`、`hidden`、`color`、`maxSteps` 和工具开关。
- Oh My OpenAgent Agent 和 Category 管理：支持内置 OMO Agent、`model`、`category`、`variant`、`prompt_append`、`temperature`、`disable`、`thinking` 和 `reasoning`。
- MCP 管理：local command、remote URL、启用/禁用。
- Plugin 管理：维护 OpenCode `plugin` 数组。
- Profile 管理：在 `~/.config/opencode-profiles` 下创建、复制和删除隔离配置目录。
- 原始 JSON 编辑页：可直接编辑 OpenCode 和 OMO 配置并应用。
- 保存前自动创建 `backups/` 备份，写入采用临时文件替换。
- FPCUnit 单元测试覆盖核心配置服务。

## 构建

环境要求：FreePascal 和 Lazarus 已加入 `PATH`。

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1
```

构建产物默认输出到：

```text
lib/x86_64-win64/opencode_manager.exe
```

也可以用 Lazarus 直接打开：

```text
src/app/opencode_manager.lpi
```

## 测试

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/test.ps1
```

测试项目位于：

```text
tests/opencode_manager_tests.lpi
```

## 项目结构

```text
src/
  app/                  LCL 桌面应用入口和主窗体
  core/                 可测试核心服务，无 UI 依赖
tests/                  FPCUnit 测试
scripts/                build/test/clean 脚本
```

## 预设

Provider 下拉预设覆盖 `anthropic`、`openai`、`google`、`openrouter`、`github-copilot`、`azure`、`bedrock`、`vertex`、`mistral`、`groq`、`deepseek`、`xai`、`together`、`fireworks`、`perplexity` 和 `ollama`。选择预设会自动填充显示名、NPM SDK 和默认 Base URL，仍可手动覆盖。

内置 OpenCode Agent 与 Studio 行为保持一致：`plan` 和 `build` 默认显示，可编辑或禁用，但不能删除。OMO 内置 Agent 包含 `Sisyphus`、`oracle`、`librarian`、`frontend-ui-ux-engineer`、`document-writer`、`multimodal-looker` 和 `explore`。

## 配置位置

默认 OpenCode 配置探测顺序：

1. `OPENCODE_CONFIG` 指向的文件
2. `OPENCODE_CONFIG_DIR` 指向的目录
3. `~/.config/opencode/opencode.json` 或 `~/.config/opencode/opencode.jsonc` 已存在时使用 `~/.config/opencode`
4. Windows 上回退到 `%APPDATA%/opencode/opencode.jsonc`
5. 其他平台回退到 `~/.config/opencode/opencode.jsonc`

支持环境变量：

- `OPENCODE_CONFIG`
- `OPENCODE_CONFIG_DIR`

Oh My OpenAgent 配置按以下顺序探测：

- `oh-my-openagent.jsonc`
- `oh-my-openagent.json`
- `oh-my-opencode.jsonc`
- `oh-my-opencode.json`

## 开发约定

- 使用 Conventional Commit，例如 `feat(config): add provider editor`。
- 核心逻辑放在 `src/core`，保持可测试。
- UI 只负责数据绑定和交互，不直接拼接 JSON 字符串。
- 保存配置前保留未知字段，避免破坏 OpenCode 新版本配置。
