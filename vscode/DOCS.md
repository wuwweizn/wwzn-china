# Home Assistant 社区插件：Studio Code Server

这个插件运行的是 [code-server](https://github.com/coder/code-server)，
它能让你直接在浏览器中获得 **Visual Studio Code** 的体验。
你可以在 **Home Assistant 前端** 中直接通过浏览器编辑 Home Assistant 配置。

该插件已预装并预配置了 **Home Assistant、MDI 图标和 YAML 扩展**。
这意味着自动补全功能开箱即用，无需额外配置。

---

## 安装

该插件的安装非常简单，与安装其他 Home Assistant 插件并无不同。

1. 点击下面的 **Home Assistant My 按钮**，在你的 Home Assistant 实例中打开插件。

   \[!\[在你的 Home Assistant 实例中打开此插件]\[addon-badge]]\[addon]

2. 点击 **“Install”** 按钮安装插件。

3. 启动 **“Studio Code Server”** 插件。

4. 查看 **“Studio Code Server”** 插件的日志，确认一切正常。

5. 点击 **“OPEN WEB UI”** 按钮打开 Studio Code Server。

---

## 配置

**注意**：*修改配置后请记得重启插件。*

插件配置示例：

```yaml
log_level: info
config_path: /share/my_path
packages:
  - mariadb-client
init_commands:
  - ls -la
```

**注意**：*这只是一个示例，请不要直接复制粘贴！请根据自己的需要创建配置！*

---

### 选项：`log_level`

`log_level` 控制插件的日志输出等级，可调整日志详细程度，
在排查未知问题时非常有用。可选值：

* `trace`：显示每个细节，包括所有内部函数调用。
* `debug`：显示详细的调试信息。
* `info`：普通（通常是有趣的）事件。
* `warning`：异常情况，但不是错误。
* `error`：运行时错误，但无需立即处理。
* `fatal`：严重错误，插件不可用。

每个等级会包含更高等级的日志。例如：`debug` 会同时显示 `info` 信息。
默认值为 `info`，这是推荐设置，除非你在排查问题。

---

### 选项：`config_path`

允许你覆盖插件访问 Web 界面时打开的默认路径。
例如，可以使用 `/share/myconfig` 替代 `/config`。

如果设置为 `/root`，那么 Home Assistant 的常用目录（如 `/config`、`/ssl`、`/share` 等）
会作为子目录出现在每次访问中。

未配置时，默认使用 `/config`。

---

### 选项：`packages`

允许你指定额外的 \[Ubuntu 软件包]\[ubuntu-packages]
在插件的 Shell 环境中安装（如 Python、PHP、Go）。

**注意**：*安装过多软件包会增加插件的启动时间。*

---

### 选项：`init_commands`

使用 `init_commands` 选项可进一步自定义 VSCode 环境。
你可以添加一个或多个 Shell 命令，这些命令会在插件启动时执行。

---

## 重置 VSCode 设置为插件默认值

插件会优化 VSCode 设置以适配 Home Assistant。
一旦你修改了某些设置，插件就不会再覆盖它们，以免造成破坏性影响。

如果你想恢复到插件默认设置，请执行以下操作：

1. 打开 Visual Studio Code 编辑器。

2. 点击顶部菜单栏的 **`Terminal`**，选择 **`New Terminal`**。

3. 在终端窗口执行以下命令：

   ```bash
   reset-settings
   ```

4. 完成！

---

## 已知问题和限制

* **Raspberry Pi 能运行吗？**
  可以，但前提是运行 64 位操作系统。

* **支持的架构**
  目前仅支持 **AMD64** 和 **aarch64/ARM64** 架构。
  虽然支持 ARM 设备，但插件比较吃资源，需要较大的内存。
  不推荐在内存低于 4GB 的设备上运行。

* **“Visual Studio Code is unable to watch for file changes in this large workspace” (错误 ENOSPC)**
  该问题由系统文件句柄不足引起，导致 VSCode 无法监控所有文件。

  * 对于 HassOS，目前唯一的解决方法是点击通知中的小齿轮，选择不再显示。
  * 如果你使用的是通用 Linux 系统（如 Ubuntu），请参考微软的指南：

    [https://code.visualstudio.com/docs/setup/linux#\_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc](https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc)

---

## 更新日志 & 发布

本仓库使用 \[GitHub Releases]\[releases] 功能维护更新日志。

版本号遵循 \[语义化版本号规范]\[semver]，格式为：

* `MAJOR`：不兼容或重大变更
* `MINOR`：向后兼容的新功能或增强
* `PATCH`：向后兼容的错误修复和依赖更新

---

## 支持

有问题？可以通过以下方式获得帮助：

* \[Home Assistant 社区插件 Discord 聊天服务器]\[discord]（插件支持与功能请求）
* \[Home Assistant 官方 Discord 聊天服务器]\[discord-ha]（通用讨论与问题）
* \[Home Assistant 社区论坛]\[forum]
* 加入 \[Reddit 子版块 /r/homeassistant]\[reddit]

你也可以在 GitHub 上 \[提交 issue]\[issue]。

---

## 作者 & 贡献者

本仓库最初由 \[Franck Nijhof]\[frenck] 创建。

查看完整贡献者列表，请访问 \[贡献者页面]\[contributors]。

---

## 许可证

MIT License

版权所有 (c) 2019-2025 Franck Nijhof

特此免费授权，允许任何获得本软件及相关文档的人
不受限制地处理软件，包括但不限于使用、复制、修改、合并、发布、分发、再授权和销售软件的副本，
并允许被提供软件的人也这样做，条件如下：

以上版权声明和本许可声明必须包含在软件的所有副本或主要部分中。

本软件按“原样”提供，不带任何形式的保证，
无论是明示还是暗示，包括但不限于对适销性、
特定用途适用性及非侵权的保证。
作者或版权持有人不对因软件或使用软件引起的任何索赔、损害或其他责任负责，
无论是合同诉讼、侵权行为或其他行为。
