# OpenCode Manager

OpenCode Manager is a FreePascal/Lazarus LCL desktop editor for OpenCode configuration. It focuses on safe editing for OpenCode and Oh My OpenAgent/Oh My OpenCode config files, with structured editors, validation, backups, usage statistics, and tests.

Chinese documentation: [docs/README.zh-CN.md](docs/README.zh-CN.md)

## Features

- Auto-discover, read, validate, and save OpenCode `opencode.json/jsonc`.
- Manage Oh My OpenAgent `oh-my-openagent.json/jsonc`, with compatibility for the legacy `oh-my-opencode.json/jsonc` names.
- Manage Providers and Models, including common Provider/NPM SDK presets and model connectivity testing.
- Manage OpenCode Agents, including built-in `plan`/`build`, `description`, `mode`, `model`, `prompt`, `temperature`, `disable`, `hidden`, `color`, `maxSteps`, and tool switches.
- Manage Oh My OpenAgent Agents and Categories, including built-in OMO Agents, `model`, `category`, `variant`, `prompt_append`, `temperature`, `disable`, `thinking`, and `reasoning`.
- Manage MCP entries for local commands, remote URLs, and enabled/disabled state.
- Manage OpenCode `plugin` array entries.
- Manage Profiles by creating, copying, and deleting isolated config directories under `~/.config/opencode-profiles`.
- Inspect OpenCode SQLite usage metadata from `~/.local/share/opencode/opencode.db` without reading message bodies.
- View project/session/model token usage with compact statistics and charts.
- Edit raw OpenCode and OMO JSON directly when needed.
- Automatically create backups under `backups/` before saving, using temporary file replacement for writes.
- FPCUnit tests cover the core configuration, path, preset, profile, and session usage services.

## UI Language

The application defaults to English. Use the Language selector in the left navigation to switch between English and Chinese at runtime.

## Build

Requirements: FreePascal and Lazarus must be available on `PATH`, or set `LAZBUILD` to the full `lazbuild` executable path.

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/build.ps1
```

Default Windows output:

```text
lib/x86_64-win64/opencode_manager.exe
```

You can also open the Lazarus project directly:

```text
src/app/opencode_manager.lpi
```

## Test

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/test.ps1
```

CI-friendly test command:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/ci-test.ps1
```

Test project:

```text
tests/opencode_manager_tests.lpi
```

## Release Builds

GitHub Actions builds downloadable zip artifacts on push and pull requests for:

- Windows x86_64
- Linux x86_64
- Linux aarch64
- macOS x86_64
- macOS aarch64

Pushing a `v*` tag publishes the artifacts to a GitHub Release.

## Project Layout

```text
src/
  app/                  LCL desktop application entry point and main form
  core/                 Testable core services without UI dependencies
tests/                  FPCUnit tests
scripts/                build/test/package scripts
docs/                   localized documentation
```

## Presets

Provider presets include `anthropic`, `openai`, `google`, `openrouter`, `github-copilot`, `azure`, `bedrock`, `vertex`, `mistral`, `groq`, `deepseek`, `xai`, `together`, `fireworks`, `perplexity`, and `ollama`. Selecting a preset fills the display name, NPM SDK, and default Base URL while still allowing manual edits.

Built-in OpenCode Agents match Studio behavior: `plan` and `build` are shown by default and can be edited or disabled, but not deleted. Built-in OMO Agents include `Sisyphus`, `oracle`, `librarian`, `frontend-ui-ux-engineer`, `document-writer`, `multimodal-looker`, and `explore`.

## Config Paths

Default OpenCode config discovery order:

1. File pointed to by `OPENCODE_CONFIG`
2. Directory pointed to by `OPENCODE_CONFIG_DIR`
3. Existing `~/.config/opencode/opencode.jsonc` or `~/.config/opencode/opencode.json`
4. Windows fallback `%APPDATA%/opencode/opencode.jsonc`
5. Other platforms fallback `~/.config/opencode/opencode.jsonc`

Supported environment variables:

- `OPENCODE_CONFIG`
- `OPENCODE_CONFIG_DIR`

Oh My OpenAgent config discovery order:

- `oh-my-openagent.jsonc`
- `oh-my-openagent.json`
- `oh-my-opencode.jsonc`
- `oh-my-opencode.json`

OpenCode usage database discovery prioritizes `~/.local/share/opencode/opencode.db` and falls back to common platform app data locations when the database has the expected OpenCode tables.

## Development Notes

- Use Conventional Commit messages, for example `feat(config): add provider editor`.
- Keep core logic in `src/core` so it remains testable.
- Keep the UI focused on data binding and interaction; do not manually assemble JSON strings in UI code.
- Preserve unknown fields while saving config files to avoid breaking newer OpenCode versions.
