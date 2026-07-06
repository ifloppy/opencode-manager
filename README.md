# OpenCode Manager

使用 FreePascal 和 Lazarus LCL 编写的 OpenCode 配置编辑器。当前版本是可运行的桌面 MVP，重点覆盖 OpenCode 与 Oh My OpenAgent/Oh My OpenCode 配置文件的安全读写、结构化编辑、校验、备份和测试。

## 功能

- OpenCode `opencode.json/jsonc` 自动发现、读取、校验和保存。
- Oh My OpenAgent `oh-my-openagent.json/jsonc` 管理，兼容旧名 `oh-my-opencode.json/jsonc`。
- Provider 和 Model 管理，参考 OpenCode Config Manager 的 Provider/Model 模式。
- OpenCode Agent 管理：`description`、`mode`、`model`、`prompt`、`temperature`、`disable`。
- Oh My OpenAgent Agent 和 Category 管理：`model`、`category`、`variant`、`prompt_append`、`temperature`、`disable`。
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

## 配置位置

默认 OpenCode 配置：

- Windows: `%APPDATA%/opencode/opencode.json`
- macOS/Linux: `~/.config/opencode/opencode.json`

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
