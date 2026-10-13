# pi

[pi](https://github.com/badlogic/pi-mono) coding agent 的配置沉淀。

## 仓库管什么

### 插件清单：[`package.json`](./package.json)

格式为 `Array<{ name: string; repo: string }>`：

```json
[
  { "name": "pi-context", "repo": "npm:pi-context" },
  { "name": "i-have-adhd", "repo": "https://github.com/ayghri/i-have-adhd" }
]
```

安装时逐条执行 `pi install <repo>`，可重复执行（幂等）。

### 主题：[`themes/`](./themes/)

静态 JSON 主题文件（如 [`nord.json`](./themes/nord.json)），安装时复制到 `~/.pi/agent/themes/`。pi 只读主题文件、从不写入，无污染风险；启用则在本机 `/settings` 里把 Theme 选为对应名字（如 `nord`）。

## 仓库不管什么

`~/.pi/agent/settings.json` 及其余文件均为**机器本地状态**，不做链接或部署，避免 pi 把 `lastChangelogVersion`、`defaultModel` 等运行时写入污染仓库：

- `settings.json` — 本机设置与运行时状态
- `auth.json` — API 密钥 / OAuth 凭据
- `trust.json`、`models-store.json`、`sessions/`、`npm/`、`install/` 等

## 日常使用

```bash
# 本机加新插件（写进本机 settings.json）
pi install npm:some-package

# 记得同步回仓库：在 pi/package.json 里加一行
{ "name": "some-package", "repo": "npm:some-package" }

# 改主题：编辑仓库里的 pi/themes/nord.json，重新部署后 /reload 生效
./bootstrap/install.sh --pi
```

## 新机器安装

```bash
# 1. 安装 pi 本体
curl -fsSL https://pi.dev/install.sh | sh

# 2. 同步插件清单
./bootstrap/install.sh --pi
```
