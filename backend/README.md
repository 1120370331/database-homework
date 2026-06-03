# Django 后端原型

本目录是 `database-homework` 子仓库内的 Django 后端原型，提供
Django REST Framework + SimpleJWT 基础认证能力，以及外贸通业务 CRUD 接口。

## 本地启动

```powershell
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py seed_demo_data
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

## Django 数据模型

- `User`：自定义用户，包含角色、数据范围、账号状态、手机号和权限组。
- `PermissionCode / PermissionGroup`：权限码和权限组，通过多对多关系维护权限集合。
- `LoginAuditLog`：登录、失败登录和登出审计日志。
- `SalesPlatform / OperationTeam / Shop / ShopAssignment`：店铺平台和运营分工。
- `Customer`：客户资料。
- `Product / ProductVariant / ProductAttributeDefinition / ProductAttributeValue`：商品、SKU 和规范化扩展属性。
- `Warehouse`：仓库。
- `Supplier / PurchaseOrder / PurchaseOrderLine`：供应商和采购订单。
- `InventoryDocument / InventoryDocumentLine / InventoryLedger / InventoryBalance`：库存单据、库存流水和当前库存余额。
- `SalesDocument / SalesDocumentLine / SalesLedgerEntry`：销售单据、销售明细和销售流水。
- `MetricDefinition / ReportQueryModel / ReportQueryParameter / ReportQueryField`：报表指标、查询模型、查询参数和查询字段。

课程报告仍保留 SQL Server 建表代码用于文档提交；后端实现以 Django ORM 模型和 migration 为准。

可用以下命令写入演示数据：

```powershell
python manage.py seed_demo_data
```

该命令会通过 Django ORM 创建演示管理员、店铺、客户、商品、SKU、仓库、供应商、采购订单、库存单据、销售订单和报表查询模型。

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
- `GET/POST /api/auth/permission-codes/`：权限码 CRUD。
- `GET /api/auth/permission-groups/`：查询权限组列表。
- `POST /api/auth/permission-groups/`：创建权限组。
- `GET /api/auth/permission-groups/{id}/`：查询单个权限组。
- `PUT/PATCH /api/auth/permission-groups/{id}/`：更新权限组。
- `DELETE /api/auth/permission-groups/{id}/`：删除权限组。
- `GET/POST /api/operations/products/`：商品 CRUD。
- `GET/POST /api/operations/product-attribute-definitions/`：商品扩展属性定义 CRUD。
- `GET/POST /api/operations/product-attribute-values/`：商品扩展属性值 CRUD。
- `GET/POST /api/operations/product-variants/`：SKU CRUD。
- `GET/POST /api/operations/warehouses/`：仓库 CRUD。
- `GET/POST /api/operations/customers/`：客户 CRUD。
- `GET/POST /api/operations/purchase-orders/`：采购订单 CRUD。
- `GET/POST /api/operations/inventory-documents/`：库存单据 CRUD。
- `GET/POST /api/operations/inventory-balances/`：当前库存查询。
- `GET/POST /api/operations/sales-documents/`：销售单据 CRUD。
- `GET/POST /api/operations/report-query-models/`：报表查询模型 CRUD。
- `GET/POST /api/operations/report-query-parameters/`：报表查询参数 CRUD。

业务 CRUD 列表接口支持基础查询参数：

- `search=关键词`：在字符、文本、邮箱和 URL 字段中模糊搜索。
- `字段名=值`：按模型字段精确过滤，例如 `status=posted`。
- `外键_id=值`：按外键过滤，例如 `shop_id=1`、`product_id=1`。
- `ordering=字段名` 或 `ordering=-字段名`：排序，例如 `ordering=-created_at`。

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
