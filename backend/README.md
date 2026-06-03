# 后端认证原型

本目录是 `database-homework` 子仓库内的 Django 后端原型，提供
Django REST Framework + SimpleJWT 基础认证能力。

## 本地启动

```powershell
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

也可以直接执行：

```powershell
.\start.bat
```

默认服务地址：`http://127.0.0.1:8000/`

## 环境变量

可复制 `.env.example` 为 `.env` 后按需配置。当前代码通过系统环境变量读取配置；
如果使用 `.env` 文件，请由本地终端或 IDE 注入这些变量。

- `DJANGO_SECRET_KEY`：Django 密钥，默认仅适合开发环境。
- `DJANGO_DEBUG`：是否开启调试模式，默认 `true`。
- `DJANGO_ALLOWED_HOSTS`：逗号分隔的允许访问主机。
- `SQLITE_DATABASE`：SQLite 数据库文件路径，默认 `db.sqlite3`。

## 数据模型

- `User`：自定义用户，包含角色、数据范围、账号状态、手机号和权限组。
- `PermissionGroup`：权限组，维护权限标识列表和默认数据范围。
- `LoginAuditLog`：登录、失败登录和登出审计日志。

## API 简表

- `POST /api/auth/login/`：账号密码登录，返回 `access`、`refresh` 和用户信息。
- `POST /api/auth/register/`：注册基础账号，默认使用普通业务角色和本人数据范围。
- `POST /api/auth/refresh/`：刷新访问令牌。
- `GET /api/auth/me/`：获取当前登录用户信息。
- `POST /api/auth/logout/`：拉黑刷新令牌并写入登出审计。
- `GET /api/auth/users/`：查询用户列表。
- `POST /api/auth/users/`：创建用户。
- `GET /api/auth/users/{id}/`：查询单个用户。
- `PUT/PATCH /api/auth/users/{id}/`：更新用户。
- `DELETE /api/auth/users/{id}/`：删除用户。
- `GET /api/auth/permission-groups/`：查询权限组列表。
- `POST /api/auth/permission-groups/`：创建权限组。
- `GET /api/auth/permission-groups/{id}/`：查询单个权限组。
- `PUT/PATCH /api/auth/permission-groups/{id}/`：更新权限组。
- `DELETE /api/auth/permission-groups/{id}/`：删除权限组。

登录接口会返回扁平化 `permissions`、`role` 和 `data_scope`，用于前台做基础菜单和按钮控制。
除注册、登录和刷新令牌接口外，默认需要在请求头携带：

```text
Authorization: Bearer <access_token>
```

用户和权限组管理接口仅允许管理员、后台员工或超级用户访问。

## 验证命令

```powershell
python manage.py check
python manage.py makemigrations --check --dry-run
```
