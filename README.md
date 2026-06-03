# 外贸通电商智控系统数据库大作业

本仓库用于存放《数据库原理与应用》大作业的报告、前台模板和 Django 后端原型。

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
    └── Django + DRF + SimpleJWT 认证和业务 CRUD 原型
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
python manage.py migrate
python manage.py seed_demo_data
python manage.py runserver
```

默认后端地址为 `http://127.0.0.1:8000/`。

## API 概览

- `POST /api/auth/login/`：登录并返回 JWT。
- `POST /api/auth/token/refresh/`：刷新访问令牌。
- `GET /api/auth/me/`：获取当前用户信息。
- `POST /api/auth/logout/`：退出登录并记录审计信息。
- `GET/POST /api/auth/users/`：用户列表与新增。
- `GET/POST /api/auth/permission-codes/`：权限码列表与新增。
- `GET/POST /api/auth/permission-groups/`：权限组列表与新增。
- `GET/POST /api/operations/products/`：商品 CRUD。
- `GET/POST /api/operations/product-attribute-definitions/`：商品扩展属性定义 CRUD。
- `GET/POST /api/operations/product-attribute-values/`：商品扩展属性值 CRUD。
- `GET/POST /api/operations/product-variants/`：SKU CRUD。
- `GET/POST /api/operations/warehouses/`：仓库 CRUD。
- `GET/POST /api/operations/customers/`：客户 CRUD。
- `GET/POST /api/operations/purchase-orders/`：采购订单 CRUD。
- `GET/POST /api/operations/inventory-documents/`：库存单据 CRUD。
- `GET/POST /api/operations/sales-documents/`：销售单据 CRUD。
- `GET/POST /api/operations/report-query-models/`：报表查询模型 CRUD。
- `GET/POST /api/operations/report-query-parameters/`：报表查询参数 CRUD。

## 说明

课程报告中的 SQL Server 建表代码位于 `docs/database_principles_homework_report.md`，用于满足课程文档要求，并明确核心关系模式达到第三范式。工程原型的后端实现以 Django ORM、migration 和 DRF 接口为准；为了便于本地演示，默认数据库使用 SQLite。
