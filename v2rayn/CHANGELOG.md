# 项目目录结构

在您的仓库 `https://github.com/wuwweizn/wwzn-china` 中，需要创建以下目录结构：

```
wwzn-china/
├── .github/
│   └── workflows/
│       └── v2ray-builder.yml          # GitHub Actions 工作流文件
├── v2ray/                             # V2Ray 加载项目录
│   ├── config.yaml                    # Home Assistant 加载项配置
│   ├── Dockerfile                     # Docker 构建文件
│   ├── run.sh                         # 启动脚本
│   └── README.md                      # 使用说明
└── repository.yaml                    # 仓库配置文件 (可选)
```

## 部署步骤

### 1. 创建文件
将上面提供的文件放置在对应位置：

- 将 `v2ray-builder.yml` 放在 `.github/workflows/` 目录下
- 将 `config.yaml`, `Dockerfile`, `run.sh`, `README.md` 放在 `v2ray/` 目录下

### 2. 配置 GitHub Secrets
在您的 GitHub 仓库设置中添加以下 Secrets：

- `DOCKER_USERNAME`: Docker Hub 用户名
- `DOCKER_PASSWORD`: Docker Hub 密码或访问令牌
- `GH_PAT`: GitHub Personal Access Token (用于推送到 GHCR)

### 3. 运行构建
- 推送代码到 `main` 分支，或者
- 在 GitHub Actions 页面手动触发 `workflow_dispatch`

### 4. 添加到 Home Assistant
构建完成后，在 Home Assistant 中：
1. 进入 Supervisor > Add-on Store
2. 点击右上角菜单 > Repositories
3. 添加仓库地址：`https://github.com/wuwweizn/wwzn-china`
4. 安装 V2Ray Core 加载项

## 可选：repository.yaml

如果要自定义仓库信息，可以创建 `repository.yaml`：

```yaml
name: "WWZN China Add-ons"
url: "https://github.com/wuwweizn/wwzn-china"
maintainer: "wuwweizn"
```

## 注意事项

1. **版本控制**: 在 `config.yaml` 中更新版本号时，构建会自动使用该版本号
2. **架构支持**: 支持 amd64, aarch64, armv7 三种架构
3. **镜像仓库**: 镜像会同时推送到 Docker Hub 和 GitHub Container Registry
4. **配置文件**: V2Ray 配置文件位于 `/config/v2ray/config.json`，首次运行会自动创建模板