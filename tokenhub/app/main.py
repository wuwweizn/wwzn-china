#!/usr/bin/env python3
"""HACS Token Hub - HA 加载项版"""

import base64
import hashlib
import os
import random
import sqlite3
from contextlib import asynccontextmanager
from datetime import datetime

import aiohttp
from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel

# HA 加载项持久化数据目录
DB_PATH = os.path.join(os.environ.get("DATA_PATH", "/data"), "tokens.db")
# 用 ghapi.hacs.vip 验证，避免直连 api.github.com 的 TLS 问题
VERIFY_BASE = "https://ghapi.hacs.vip"

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="zh-Hans">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HACS Token Hub</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.prod.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <style>
        .font-monospace { font-family: monospace; font-size: 0.85em; }
        .badge-remaining { min-width: 60px; }
    </style>
</head>
<body class="bg-light">
<div id="app" class="container py-4">
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white d-flex align-items-center">
            <span class="fs-5 fw-bold me-2">🔑 HACS Token Hub</span>
            <span class="badge bg-light text-primary">自托管版 v1.0</span>
            <span class="ms-auto badge bg-light text-primary">共 {{ tokens.length }} 个 Token</span>
        </div>
        <div class="card-body">

            <!-- 添加 Token -->
            <form @submit.prevent="shareToken" class="mb-4">
                <label class="form-label fw-semibold">添加 GitHub Token</label>
                <div class="input-group">
                    <input v-model="tokenToShare" type="text" class="form-control font-monospace"
                           placeholder="ghp_xxxxxxxxxxxxxxxxxxxx" required :disabled="loading">
                    <button type="submit" class="btn btn-primary" :disabled="loading">
                        <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                        {{ loading ? '验证中...' : '➕ 添加' }}
                    </button>
                </div>
                <div class="form-text">
                    在 <a href="https://github.com/settings/tokens" target="_blank">GitHub → Settings → Personal access tokens</a>
                    创建，选 <strong>Tokens (classic)</strong>，勾选 <code>repo</code> 权限即可
                </div>
                <div v-if="message" :class="'alert mt-2 py-2 ' + (messageType === 'error' ? 'alert-danger' : 'alert-success')">
                    {{ message }}
                </div>
            </form>

            <!-- Token 列表 -->
            <div class="table-responsive">
                <table class="table table-hover table-sm align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>GitHub 账号</th>
                            <th class="text-center">API 剩余配额</th>
                            <th class="text-center">使用次数</th>
                            <th>更新时间</th>
                            <th class="text-center">操作</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-if="tokens.length === 0">
                            <td colspan="5" class="text-center text-muted py-4">
                                暂无 Token，请添加至少一个 GitHub Token
                            </td>
                        </tr>
                        <tr v-for="t in tokens" :key="t.id">
                            <td>
                                <a :href="'https://github.com/' + t.login" target="_blank" class="text-decoration-none">
                                    {{ t.login || '(未知)' }}
                                </a>
                            </td>
                            <td class="text-center">
                                <span class="badge badge-remaining"
                                      :class="t.remaining > 1000 ? 'bg-success' : t.remaining > 100 ? 'bg-warning text-dark' : 'bg-danger'">
                                    {{ t.remaining }}
                                </span>
                            </td>
                            <td class="text-center text-muted">{{ t.use_count }}</td>
                            <td class="text-muted small">{{ t.updated_at }}</td>
                            <td class="text-center">
                                <button @click="refreshToken(t.id)" class="btn btn-sm btn-outline-secondary me-1" title="刷新配额">↻</button>
                                <button @click="deleteToken(t.id)" class="btn btn-sm btn-outline-danger" title="删除">✕</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- 使用说明 -->
    <div class="card mt-3 shadow-sm">
        <div class="card-body">
            <h6 class="fw-bold mb-2">📖 HACS 配置说明</h6>
            <ol class="mb-2">
                <li>在上方添加至少一个 GitHub Token</li>
                <li>打开 <strong>HACS → 右上角三点菜单 → 自定义存储库</strong></li>
                <li>或在 HACS 选项中将「共享令牌服务器地址」设为：http://ha-ip:8765</li>
            </ol>
            <div class="alert alert-info py-2 mb-0 small">
                <strong>提示：</strong>添加后 HACS 设置共享令牌服务器地址为本服务器地址，重新配置 HACS 集成即可使用共享令牌登录。
            </div>
        </div>
    </div>
</div>

<script>
const { createApp } = Vue;
createApp({
    data() {
        return {
            tokens: [],
            tokenToShare: '',
            loading: false,
            message: '',
            messageType: 'success',
            apiBase: window.location.origin,
        };
    },
    mounted() { this.getTokens(); },
    methods: {
        async getTokens() {
            const r = await axios.get('./api/tokens');
            this.tokens = r.data.list;
        },
        async shareToken() {
            this.loading = true; this.message = '';
            try {
                const r = await axios.post('./api/token/share', { token: this.tokenToShare.trim(), type: 'github' });
                this.message = `✅ 添加成功！账号: ${r.data.login}，剩余配额: ${r.data.remaining}`;
                this.messageType = 'success';
                this.tokenToShare = '';
                await this.getTokens();
            } catch (e) {
                this.message = '❌ ' + (e.response?.data?.detail || '添加失败，请检查 Token 是否有效');
                this.messageType = 'error';
            } finally { this.loading = false; }
        },
        async refreshToken(id) {
            try {
                const r = await axios.get(`./api/tokens/${id}`);
                const i = this.tokens.findIndex(t => t.id === id);
                if (i !== -1) this.tokens[i] = r.data.data;
            } catch (e) {
                if (e.response?.status === 401 || e.response?.status === 404)
                    this.tokens = this.tokens.filter(t => t.id !== id);
            }
        },
        async deleteToken(id) {
            if (!confirm('确定删除这个 Token？')) return;
            await axios.delete(`./api/tokens/${id}`);
            this.tokens = this.tokens.filter(t => t.id !== id);
        },
    }
}).mount('#app');
</script>
</body>
</html>"""


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    conn = get_db()
    conn.execute("""
        CREATE TABLE IF NOT EXISTS tokens (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            token      TEXT    UNIQUE NOT NULL,
            login      TEXT    DEFAULT '',
            remaining  INTEGER DEFAULT 5000,
            use_count  INTEGER DEFAULT 0,
            type       TEXT    DEFAULT 'github',
            created_at TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%S','now')),
            updated_at TEXT    DEFAULT (strftime('%Y-%m-%d %H:%M:%S','now'))
        )
    """)
    conn.commit()
    conn.close()


async def verify_token(token: str) -> dict | None:
    """通过 ghapi.hacs.vip 代理验证 token，完全绕过直连 GitHub 的 TLS 问题。"""
    headers = {"Authorization": f"token {token}"}
    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(
                f"{VERIFY_BASE}/rate_limit", headers=headers,
                timeout=aiohttp.ClientTimeout(total=10),
            ) as resp:
                if resp.status != 200:
                    return None
                remaining = (await resp.json()).get("rate", {}).get("remaining", 0)

            async with session.get(
                f"{VERIFY_BASE}/user", headers=headers,
                timeout=aiohttp.ClientTimeout(total=10),
            ) as resp:
                login = (await resp.json()).get("login", "unknown") if resp.status == 200 else "unknown"

            return {"login": login, "remaining": remaining}
        except Exception:
            return None


def _decrypt_token(enc_b64: str) -> str:
    """用内置密钥 XOR 解密 token。"""
    key = hashlib.sha256(b"hacs-tokenhub-wwzn-2024").digest()
    data = base64.b64decode(enc_b64.strip())
    return "".join(chr(b ^ key[i % len(key)]) for i, b in enumerate(data))


async def load_init_token():
    """启动时自动加载内置加密 token 或配置文件中的 token。"""
    token = None

    # 优先读取构建时内置的加密 token
    enc_file = "/app/init_token.enc"
    if os.path.exists(enc_file):
        try:
            token = _decrypt_token(open(enc_file).read())
        except Exception as e:
            print(f"[WARNING] 解密内置 token 失败: {e}")

    # 其次读取加载项配置中的 init_token（用户手动填写）
    if not token:
        import json
        options_path = "/data/options.json"
        if os.path.exists(options_path):
            try:
                options = json.load(open(options_path))
                token = (options.get("init_token") or "").strip()
            except Exception as e:
                print(f"[WARNING] 读取 options.json 失败: {e}")

    if not token:
        return

    conn = get_db()
    exists = conn.execute("SELECT id FROM tokens WHERE token=?", (token,)).fetchone()
    conn.close()
    if exists:
        return

    info = await verify_token(token)
    if not info:
        print("[WARNING] 内置 token 验证失败，跳过自动添加")
        return

    conn = get_db()
    conn.execute(
        "INSERT OR IGNORE INTO tokens (token,login,remaining) VALUES (?,?,?)",
        (token, info["login"], info["remaining"]),
    )
    conn.commit()
    conn.close()
    print(f"[INFO] 内置 token 已自动添加，账号: {info['login']}")


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    await load_init_token()
    yield


app = FastAPI(title="HACS Token Hub", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])


class ShareTokenRequest(BaseModel):
    token: str
    type: str = "github"


def now_str():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    # 支持 HA ingress 路径前缀
    return HTML_TEMPLATE


@app.get("/api/tokens")
async def list_tokens():
    conn = get_db()
    rows = conn.execute(
        "SELECT id,login,remaining,use_count,type,created_at,updated_at FROM tokens ORDER BY remaining DESC"
    ).fetchall()
    conn.close()
    return {"list": [dict(r) for r in rows]}


@app.get("/api/token/get")
async def get_token():
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM tokens WHERE remaining > 100 ORDER BY remaining DESC LIMIT 20"
    ).fetchall()
    conn.close()

    if not rows:
        return JSONResponse(status_code=400, content={
            "error": "no available tokens, please add one at the Token Hub web UI",
            "toast": "no tokens"
        })

    row = dict(random.choice(rows))
    info = await verify_token(row["token"])

    conn = get_db()
    if not info:
        conn.execute("DELETE FROM tokens WHERE id=?", (row["id"],))
        conn.commit()
        conn.close()
        return JSONResponse(status_code=400, content={
            "error": "token invalid, removed",
            "login": row["login"],
            "toast": "try again"
        })

    conn.execute(
        "UPDATE tokens SET use_count=use_count+1, remaining=?, login=?, updated_at=? WHERE id=?",
        (info["remaining"], info["login"], now_str(), row["id"]),
    )
    conn.commit()
    conn.close()
    return {"data": {"token": row["token"]}}


@app.post("/api/token/share")
async def share_token(req: ShareTokenRequest):
    token = req.token.strip()
    if not token:
        raise HTTPException(status_code=400, detail="Token 不能为空")

    info = await verify_token(token)
    if not info:
        raise HTTPException(status_code=401, detail="Token 验证失败，请确认 Token 有效且具有 repo 权限")

    conn = get_db()
    try:
        conn.execute(
            "INSERT INTO tokens (token,login,remaining) VALUES (?,?,?)",
            (token, info["login"], info["remaining"]),
        )
    except sqlite3.IntegrityError:
        conn.execute(
            "UPDATE tokens SET login=?,remaining=?,updated_at=? WHERE token=?",
            (info["login"], info["remaining"], now_str(), token),
        )
    conn.commit()
    conn.close()
    return {"message": "添加成功", "login": info["login"], "remaining": info["remaining"]}


@app.get("/api/tokens/{token_id}")
async def refresh_token(token_id: int):
    conn = get_db()
    row = conn.execute("SELECT * FROM tokens WHERE id=?", (token_id,)).fetchone()
    conn.close()
    if not row:
        raise HTTPException(status_code=404, detail="not found")

    info = await verify_token(dict(row)["token"])
    conn = get_db()
    if not info:
        conn.execute("DELETE FROM tokens WHERE id=?", (token_id,))
        conn.commit()
        conn.close()
        raise HTTPException(status_code=401, detail="Token 已失效，已自动移除")

    conn.execute(
        "UPDATE tokens SET remaining=?,login=?,updated_at=? WHERE id=?",
        (info["remaining"], info["login"], now_str(), token_id),
    )
    conn.commit()
    updated = conn.execute(
        "SELECT id,login,remaining,use_count,type,created_at,updated_at FROM tokens WHERE id=?",
        (token_id,),
    ).fetchone()
    conn.close()
    return {"data": dict(updated)}


@app.delete("/api/tokens/{token_id}")
async def delete_token(token_id: int):
    conn = get_db()
    conn.execute("DELETE FROM tokens WHERE id=?", (token_id,))
    conn.commit()
    conn.close()
    return {"message": "已删除"}
