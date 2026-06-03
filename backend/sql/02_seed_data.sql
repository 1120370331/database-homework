-- 外贸通电商智控系统 SQL Server 初始化样例数据
-- 执行顺序：先执行 01_schema.sql，再执行本脚本。

USE ForeignTradeConnectDB;
GO

SET NOCOUNT ON;
GO

-- 1. 登录认证、权限组、用户和审计日志
SET IDENTITY_INSERT dbo.sys_permission ON;
INSERT INTO dbo.sys_permission (id, name, code, type, remark) VALUES
(1, N'用户查看', N'user.read', N'button', N'查看用户列表和详情'),
(2, N'用户维护', N'user.write', N'button', N'新增、编辑、停用用户'),
(3, N'商品查看', N'product.read', N'button', N'查看商品和 SKU'),
(4, N'商品维护', N'product.write', N'button', N'维护商品档案'),
(5, N'库存查看', N'inventory.read', N'button', N'查看库存余额和流水'),
(6, N'库存过账', N'inventory.post', N'button', N'库存单据过账'),
(7, N'销售查看', N'sales.read', N'button', N'查看销售单据和流水'),
(8, N'报表查看', N'report.read', N'button', N'查询和导出报表');
SET IDENTITY_INSERT dbo.sys_permission OFF;
GO

SET IDENTITY_INSERT dbo.sys_permission_group ON;
INSERT INTO dbo.sys_permission_group (id, name, code, description) VALUES
(1, N'系统管理员', N'admin', N'拥有系统管理和全部业务查看权限'),
(2, N'商品运营', N'product_operator', N'维护商品、SKU 和运营资料'),
(3, N'库存人员', N'inventory_staff', N'处理库存单据和库存查询'),
(4, N'销售人员', N'sales_staff', N'处理销售单据和销售报表'),
(5, N'财务/报表人员', N'report_staff', N'查看报表和财务统计口径');
SET IDENTITY_INSERT dbo.sys_permission_group OFF;
GO

INSERT INTO dbo.sys_group_permission (group_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8),
(2, 3), (2, 4), (2, 8),
(3, 5), (3, 6), (3, 8),
(4, 7), (4, 8),
(5, 8);
GO

SET IDENTITY_INSERT dbo.sys_user ON;
INSERT INTO dbo.sys_user (
    id, username, password_hash, email, phone_number, status, is_staff, is_superuser,
    data_scope, operation_teams_json, accessible_shops_json, remark
) VALUES
(1, N'admin', N'pbkdf2_sha256$demo$admin123', N'admin@ftc.local', N'13800000001', 0, 1, 1, N'all', N'[]', N'[]', N'答辩演示管理员'),
(2, N'chenweijia', N'pbkdf2_sha256$demo$admin123', N'chen@example.com', N'13800000002', 0, 1, 0, N'team', N'[1]', N'[1]', N'陈炜嘉'),
(3, N'kuangwentao', N'pbkdf2_sha256$demo$admin123', N'kuang@example.com', N'13800000003', 0, 1, 0, N'team', N'[1]', N'[1]', N'邝文涛'),
(4, N'subingbo', N'pbkdf2_sha256$demo$admin123', N'su@example.com', N'13800000004', 0, 1, 0, N'shop', N'[]', N'[1]', N'苏秉铂');
SET IDENTITY_INSERT dbo.sys_user OFF;
GO

INSERT INTO dbo.sys_user_permission_group (user_id, group_id) VALUES
(1, 1), (2, 2), (3, 3), (4, 5);
GO

INSERT INTO dbo.sys_login_audit_log (user_id, username, ip_address, user_agent, success, failure_reason) VALUES
(1, N'admin', N'127.0.0.1', N'Chrome', 1, NULL),
(2, N'chenweijia', N'127.0.0.1', N'Chrome', 1, NULL);
GO

-- 2. 平台、店铺、客户
SET IDENTITY_INSERT dbo.shop_sales_platform ON;
INSERT INTO dbo.shop_sales_platform (id, code, name) VALUES
(1, N'shopify', N'Shopify'),
(2, N'amazon', N'Amazon');
SET IDENTITY_INSERT dbo.shop_sales_platform OFF;
GO

SET IDENTITY_INSERT dbo.shop_operation_team ON;
INSERT INTO dbo.shop_operation_team (id, code, name) VALUES
(1, N'ops-a', N'运营一组'),
(2, N'ops-b', N'运营二组');
SET IDENTITY_INSERT dbo.shop_operation_team OFF;
GO

SET IDENTITY_INSERT dbo.sys_shop ON;
INSERT INTO dbo.sys_shop (id, name, platform_id, shop_url, shop_owner, contact_phone, status, sales_type, remark) VALUES
(1, N'外贸通香港店', 1, N'https://hk.example.com', N'陈炜嘉', N'13800000002', 0, N'retail', N'课程作业演示店铺'),
(2, N'外贸通北美店', 2, N'https://na.example.com', N'邝文涛', N'13800000003', 0, N'wholesale', N'跨境平台店铺');
SET IDENTITY_INSERT dbo.sys_shop OFF;
GO

INSERT INTO dbo.shop_assignment (shop_id, operation_team_id, user_id, assignment_role) VALUES
(1, 1, 2, N'owner'),
(1, 1, 3, N'inventory'),
(2, 2, 4, N'report');
GO

SET IDENTITY_INSERT dbo.customer ON;
INSERT INTO dbo.customer (id, customer_code, name, contact_person, phone, email, address, customer_type, level, status, credit_limit, current_balance) VALUES
(1, N'CUST-001', N'Hong Kong Retail Ltd.', N'Lee', N'852-0001', N'lee@example.hk', N'Hong Kong', 1, 2, 0, 50000.00, 12800.00),
(2, N'CUST-002', N'North America Buyer Inc.', N'Alice', N'1-0002', N'alice@example.com', N'Los Angeles', 1, 1, 0, 80000.00, 26000.00);
SET IDENTITY_INSERT dbo.customer OFF;
GO

INSERT INTO dbo.customer_contact (customer_id, name, position, phone, email, is_primary) VALUES
(1, N'Lee', N'采购经理', N'852-0001', N'lee@example.hk', 1),
(2, N'Alice', N'Buyer', N'1-0002', N'alice@example.com', 1);
GO

-- 3. 商品、SKU、仓库
SET IDENTITY_INSERT dbo.sys_product ON;
INSERT INTO dbo.sys_product (id, code, name, specification, unit, barcode, brand, year, season, category, color, safety_stock, status, custom_fields_json, remark) VALUES
(1, N'WT-DRESS-001', N'外贸女装连衣裙', N'M/L/XL', N'件', N'690000000001', N'外贸通', N'2026', N'SS', N'服装', N'蓝色', 20, N'active', N'{"style":"dress"}', N'演示商品'),
(2, N'WT-SHOES-021', N'跨境运动鞋', N'40-44', N'双', N'690000000002', N'外贸通', N'2026', N'SS', N'鞋履', N'白色', 30, N'active', N'{"style":"shoes"}', N'低库存样例'),
(3, N'WT-BAG-078', N'便携收纳包', N'标准款', N'个', N'690000000003', N'外贸通', N'2026', N'SS', N'箱包', N'黑色', 15, N'active', N'{"style":"bag"}', N'缺货样例');
SET IDENTITY_INSERT dbo.sys_product OFF;
GO

SET IDENTITY_INSERT dbo.sys_product_variant ON;
INSERT INTO dbo.sys_product_variant (id, product_id, variant_key, sku_code, size, color, is_default, status) VALUES
(1, 1, N'WT-DRESS-001-M-BLUE', N'WT-DRESS-001-M', N'M', N'蓝色', 1, N'active'),
(2, 2, N'WT-SHOES-021-42-WHITE', N'WT-SHOES-021-42', N'42', N'白色', 1, N'active'),
(3, 3, N'WT-BAG-078-STD-BLACK', N'WT-BAG-078-STD', N'标准', N'黑色', 1, N'active');
SET IDENTITY_INSERT dbo.sys_product_variant OFF;
GO

SET IDENTITY_INSERT dbo.sys_warehouse ON;
INSERT INTO dbo.sys_warehouse (id, code, name, warehouse_kind, address, manager, remark) VALUES
(1, N'GZ', N'广州仓', N'standard', N'广州白云区', N'库存人员A', N'主仓'),
(2, N'SZ', N'深圳仓', N'standard', N'深圳龙岗区', N'库存人员B', N'跨境出货仓'),
(3, N'YW', N'义乌仓', N'standard', N'义乌国际商贸城', N'库存人员C', N'备货仓');
SET IDENTITY_INSERT dbo.sys_warehouse OFF;
GO

-- 4. 采购事实：供应商、采购订单、采购明细
SET IDENTITY_INSERT dbo.supplier ON;
INSERT INTO dbo.supplier (id, supplier_code, name, contact_person, phone, email, address, status) VALUES
(1, N'SUP-001', N'广州成衣供应商', N'王经理', N'020-0001', N'gz-supplier@example.com', N'广州市白云区', N'active'),
(2, N'SUP-002', N'深圳鞋履供应商', N'赵经理', N'0755-0002', N'sz-supplier@example.com', N'深圳市龙岗区', N'active');
SET IDENTITY_INSERT dbo.supplier OFF;
GO

SET IDENTITY_INSERT dbo.purchase_order ON;
INSERT INTO dbo.purchase_order (id, order_no, supplier_id, shop_id, warehouse_id, status, order_date, expected_arrival_date, currency, total_amount, created_by, memo) VALUES
(1, N'PO-20260603-001', 2, 1, 2, N'in_transit', '2026-06-03', '2026-06-10', N'CNY', 6000.00, 3, N'跨境运动鞋补货在途');
SET IDENTITY_INSERT dbo.purchase_order OFF;
GO

SET IDENTITY_INSERT dbo.purchase_order_line ON;
INSERT INTO dbo.purchase_order_line (id, order_id, line_no, product_id, variant_id, ordered_quantity, received_quantity, unit_price, amount, source_line_key, metadata_json) VALUES
(1, 1, 1, 2, 2, 50.0000, 0.0000, 120.00, 6000.00, N'PO-20260603-001-L1', N'{"reason":"low_stock_replenishment"}');
SET IDENTITY_INSERT dbo.purchase_order_line OFF;
GO

-- 5. 库存事实：单据、明细、流水、当前余额
SET IDENTITY_INSERT dbo.sys_inventory_document ON;
INSERT INTO dbo.sys_inventory_document (id, document_no, document_type, status, business_time, posted_at, source_type, source_ref, created_by, memo) VALUES
(1, N'INV-IN-20260603-001', N'stock_in', N'posted', '2026-06-03T09:00:00', '2026-06-03T09:10:00', N'manual', N'opening-demo', 3, N'初始化入库'),
(2, N'INV-OUT-20260603-001', N'stock_out', N'posted', '2026-06-03T11:00:00', '2026-06-03T11:05:00', N'sales', N'SO-20260603-001', 3, N'销售出库');
SET IDENTITY_INSERT dbo.sys_inventory_document OFF;
GO

SET IDENTITY_INSERT dbo.sys_inventory_document_line ON;
INSERT INTO dbo.sys_inventory_document_line (id, document_id, line_no, product_id, variant_id, warehouse_id, quantity_bucket, delta_quantity, unit_cost, metadata_json) VALUES
(1, 1, 1, 1, 1, 1, N'on_hand', 100, 68.00, N'{"reason":"opening"}'),
(2, 1, 2, 2, 2, 2, N'on_hand', 30, 120.00, N'{"reason":"opening"}'),
(3, 2, 1, 1, 1, 1, N'on_hand', -14, 68.00, N'{"source":"sales"}'),
(4, 2, 2, 2, 2, 2, N'on_hand', -12, 120.00, N'{"source":"sales"}');
SET IDENTITY_INSERT dbo.sys_inventory_document_line OFF;
GO

DECLARE @event_dress UNIQUEIDENTIFIER = '11111111-1111-1111-1111-111111111111';
DECLARE @event_shoes UNIQUEIDENTIFIER = '22222222-2222-2222-2222-222222222222';

INSERT INTO dbo.sys_inventory_ledger (
    event_id, document_line_id, event_type, product_id, variant_id, warehouse_id,
    delta_quantity, snapshot_quantity, biz_time, source_type, source_ref, idempotency_key, metadata_json
) VALUES
(@event_dress, 3, N'stock_out', 1, 1, 1, -14, 86, '2026-06-03T11:05:00', N'sales', N'SO-20260603-001', N'inv-ledger-demo-001', N'{}'),
(@event_shoes, 4, N'stock_out', 2, 2, 2, -12, 18, '2026-06-03T11:05:00', N'sales', N'SO-20260603-001', N'inv-ledger-demo-002', N'{}');

INSERT INTO dbo.sys_inventory_balance_current (product_id, variant_id, warehouse_id, quantity, last_event_id, last_biz_time) VALUES
(1, 1, 1, 86, @event_dress, '2026-06-03T11:05:00'),
(2, 2, 2, 18, @event_shoes, '2026-06-03T11:05:00'),
(3, 3, 3, 0, NULL, NULL);
GO

-- 6. 销售事实：单据、明细、销售流水
SET IDENTITY_INSERT dbo.sales_document ON;
INSERT INTO dbo.sales_document (id, document_no, document_type, status, shop_id, customer_name_snapshot, transaction_time, source_system, source_record_key, currency, total_amount, memo, created_by) VALUES
(1, N'SO-20260603-001', N'sale', N'posted', 1, N'Hong Kong Retail Ltd.', '2026-06-03T10:30:00', N'manual', N'SO-DEMO-001', N'CNY', 32860.00, N'演示销售订单', 2);
SET IDENTITY_INSERT dbo.sales_document OFF;
GO

SET IDENTITY_INSERT dbo.sales_document_line ON;
INSERT INTO dbo.sales_document_line (id, document_id, line_no, product_id, variant_id, product_code_snapshot, sku_key_snapshot, quantity, unit_price, amount, source_line_key, metadata_json) VALUES
(1, 1, 1, 1, 1, N'WT-DRESS-001', N'WT-DRESS-001-M', 14.0000, 168.00, 2352.00, N'SO-DEMO-001-L1', N'{}'),
(2, 1, 2, 2, 2, N'WT-SHOES-021', N'WT-SHOES-021-42', 12.0000, 260.00, 3120.00, N'SO-DEMO-001-L2', N'{}');
SET IDENTITY_INSERT dbo.sales_document_line OFF;
GO

SET IDENTITY_INSERT dbo.sales_ledger_entry ON;
INSERT INTO dbo.sales_ledger_entry (id, document_id, document_line_id, entry_type, quantity_scope, entry_status, shop_id, product_id, variant_id, quantity, amount, business_time, source_system, source_record_key, idempotency_key) VALUES
(1, 1, 1, N'sale', N'deal', N'posted', 1, 1, 1, 14.0000, 2352.00, '2026-06-03T10:30:00', N'manual', N'SO-DEMO-001-L1', N'sales-ledger-demo-001'),
(2, 1, 2, N'sale', N'deal', N'posted', 1, 2, 2, 12.0000, 3120.00, '2026-06-03T10:30:00', N'manual', N'SO-DEMO-001-L2', N'sales-ledger-demo-002');
SET IDENTITY_INSERT dbo.sales_ledger_entry OFF;
GO

-- 7. 报表查询模型、指标版本和快照
SET IDENTITY_INSERT dbo.database_metric_definition ON;
INSERT INTO dbo.database_metric_definition (id, metric_code, metric_name, metric_domain, grain, source_fact, owner, status, description) VALUES
(1, N'sales_amount', N'销售额', N'sales', N'shop_day', N'SalesLedgerEntry', N'运营组', N'active', N'销售流水金额汇总'),
(2, N'inventory_balance', N'库存余额', N'inventory', N'product_warehouse', N'InventoryBalanceCurrent', N'仓储组', N'active', N'当前库存余额');
SET IDENTITY_INSERT dbo.database_metric_definition OFF;
GO

SET IDENTITY_INSERT dbo.database_metric_version ON;
INSERT INTO dbo.database_metric_version (id, metric_id, version_no, formula_text, scope_text, time_field, created_by) VALUES
(1, 1, N'v1', N'SUM(amount)', N'entry_status = posted AND quantity_scope = transaction', N'business_time', 2),
(2, 2, N'v1', N'SUM(quantity)', N'按商品、SKU、仓库汇总当前余额', N'last_biz_time', 3);
SET IDENTITY_INSERT dbo.database_metric_version OFF;
GO

SET IDENTITY_INSERT dbo.report_query_model ON;
INSERT INTO dbo.report_query_model (id, query_code, query_name, report_domain, source_fact, default_time_field, default_grain, permission_code, cache_policy, default_params_json, created_by) VALUES
(1, N'sales_summary_query', N'销售汇总报表', N'sales', N'SalesLedgerEntry', N'business_time', N'shop_day', N'report.read', N'snapshot', N'{"date_range":"last_7_days"}', 4),
(2, N'inventory_summary_query', N'库存汇总报表', N'inventory', N'InventoryBalanceCurrent', N'last_biz_time', N'product_warehouse', N'report.read', N'snapshot', N'{"include_zero":true}', 4);
SET IDENTITY_INSERT dbo.report_query_model OFF;
GO

SET IDENTITY_INSERT dbo.report_query_field ON;
INSERT INTO dbo.report_query_field (id, query_model_id, metric_id, field_key, field_label, field_role, data_type, expression_text, is_required, is_visible, sort_order) VALUES
(1, 1, NULL, N'shop_id', N'店铺', N'dimension', N'int', N'shop_id', 0, 1, 10),
(2, 1, 1, N'sales_amount', N'销售额', N'metric', N'decimal', N'SUM(amount)', 0, 1, 20),
(3, 2, NULL, N'product_id', N'商品', N'dimension', N'int', N'product_id', 0, 1, 10),
(4, 2, 2, N'inventory_balance', N'库存余额', N'metric', N'int', N'SUM(quantity)', 0, 1, 20);
SET IDENTITY_INSERT dbo.report_query_field OFF;
GO

SET IDENTITY_INSERT dbo.report_query_snapshot ON;
INSERT INTO dbo.report_query_snapshot (id, query_model_id, query_params_json, result_json, metric_versions_json, source_trace_json, data_mode, snapshot_time, created_by) VALUES
(1, 1, N'{"date":"2026-06-03","shop_id":1}', N'[{"shop":"外贸通香港店","sales_amount":5472.00}]', N'[{"metric":"sales_amount","version":"v1"}]', N'{"source":["sales_ledger_entry"]}', N'realtime', '2026-06-03T12:00:00', 4),
(2, 2, N'{"warehouse_id":2}', N'[{"product":"跨境运动鞋","warehouse":"深圳仓","quantity":18}]', N'[{"metric":"inventory_balance","version":"v1"}]', N'{"source":["sys_inventory_balance_current"]}', N'realtime', '2026-06-03T12:05:00', 4);
SET IDENTITY_INSERT dbo.report_query_snapshot OFF;
GO

PRINT N'外贸通演示数据初始化完成。';
GO
