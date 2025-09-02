MPD
# 配置

```yaml
media_folder: /media/mpd/media
playlist_folder: /media/mpd/playlists
volume_normalization: false
httpd_output: false
```

### `volume_normalization`

 启用内置的音量标准化功能。

### `httpd_output`

启用 httpd 音频输出。

### `media_folder`

此选项允许你指定一个自定义的媒体文件夹。

### `playlist_folder`

此选项允许你指定一个自定义的播放列表文件夹。

### `verbose`（可选）

让 `mpd` 输出详细日志。

```yaml
verbose: true
```

### `custom_config`（可选）

**如果指定了这个选项，其他所有选项都会被忽略。**

此选项允许你为 MPD 指定一个自定义配置文件。
为了把所有 MPD 文件放在一个地方，路径前缀被限制为 `/share/mpd`。
建议以插件的默认 [mpd.conf](https://github.com/Poeschl/Hassio-Addons/blob/main/mpd/root/etc/mpd.conf) 作为起点。
如果配置遇到问题，可以参考 [MPD 官方文档](https://www.musicpd.org/doc/html/user.html#configuration)。

工作示例：

```yaml
...
custom_config: /share/mpd/mpd.conf
```

---

# 故障排查

### `RTIOThread could not get realtime scheduling, continuing anyway: sched_setscheduler`

这个错误会在非 glibc 系统（如 alpine linux）上出现。MPD 在这种情况下仍然可以正常运行。
更多说明见 [MPD Issue](https://github.com/MusicPlayerDaemon/MPD/issues/218)

### `Failed to open '/data/database/mpd.db': No such file or directory`

这个错误会在第一次启动时显示，因为还没有数据库。第二次运行时数据库会自动生成。

---

# MPD

要从 Home Assistant 连接，填写以下参数：

```text
media_player:
  - platform: mpd
    host: 243ffc37-mpd
    port: 6600

```


