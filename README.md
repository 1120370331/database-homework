# 外贸通电商智控系统数据库大作业

本仓库用于存放《数据库原理与应用》大作业的报告、前台模板和后端认证原型。

## 小组信息

- 组长：陈炜嘉
- 组员：邝文涛、苏秉铂
- 系统名称：外贸通电商智控系统

## 目录结构

```text
database-homework/
├── docs/
│   └── database_principles_homework_report.md
├── frontend/
│   └── Vite + React + Ant Design 前台模板
└── backend/
    └── Django + DRF + SimpleJWT 后端认证原型
```

## 前端启动

```bash
cd frontend
npm install
npm run dev
```

默认开发地址为 `http://localhost:5173/`。

## 后端启动

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

默认后端地址为 `http://127.0.0.1:8000/`。

## API 概览

- `POST /api/auth/login/`：登录并返回 JWT。
- `POST /api/auth/token/refresh/`：刷新访问令牌。
- `GET /api/auth/me/`：获取当前用户信息。
- `POST /api/auth/logout/`：退出登录并记录审计信息。
- `GET/POST /api/auth/users/`：用户列表与新增。
- `GET/POST /api/auth/permission-groups/`：权限组列表与新增。

## 说明

课程报告中的 SQL Server 建表代码位于 `docs/database_principles_homework_report.md`。工程原型为了便于本地演示，后端默认使用 SQLite；数据库设计与完整性约束以报告为准。
