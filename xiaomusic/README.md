# wwzn-china — Home Assistant 自定义加载项仓库

## 包含加载项

| 加载项 | 说明 |
|--------|------|
| XiaoMusic | 使用小爱音箱播放音乐，支持本地及在线音乐，yt-dlp 下载 |

---

---

##在 HA 中添加自定义仓库

1. 打开 Home Assistant → **加载项商店**
2. 点击右上角 **? → 仓库**
3. 输入你的仓库地址：
   ```
   https://github.com/wuwweizn/wwzn-china
   ```
4. 点击 **添加** → 刷新页面
5. 在加载项列表中找到 **XiaoMusic** 并安装

---

## 更新加载项版本

当 xiaomusic 上游发布新版本时，修改 `xiaomusic/config.yaml` 中的 `version` 字段，提交到 main 分支，Actions 自动重新构建推送新镜像。

```yaml
version: "0.3.102"  # 改成最新版本号
```

---

## XiaoMusic 使用说明

- 安装启动后，访问 `http://你的HA地址:58090` 进入 Web 管理后台
- 在 Web 页面输入**小米账号和密码**，保存后获取设备列表
- 支持的语音口令：播放歌曲、上一首、下一首、单曲循环、随机播放等
- 详细文档：https://xdocs.hanxi.cc/