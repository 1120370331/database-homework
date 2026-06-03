-- 外贸通电商智控系统 SQL Server 建表脚本
-- 来源：docs/database_principles_homework_report.md 第 5 节建表代码，并补充采购订单后台表
-- 执行顺序：先执行 01_schema.sql，再执行 02_seed_data.sql

CREATE DATABASE ForeignTradeConnectDB;
GO

USE ForeignTradeConnectDB;
GO

CREATE TABLE dbo.sys_permission (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    code NVARCHAR(100) NOT NULL UNIQUE,
    type NVARCHAR(50) NOT NULL,
    remark NVARCHAR(500) NULL
);

CREATE TABLE dbo.sys_permission_group (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE,
    code NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.sys_user (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    avatar NVARCHAR(255) NULL,
    email NVARCHAR(100) NULL UNIQUE,
    phone_number NVARCHAR(20) NULL,
    login_date DATETIME2 NULL,
    status INT NOT NULL DEFAULT 0,
    is_staff BIT NOT NULL DEFAULT 1,
    is_superuser BIT NOT NULL DEFAULT 0,
    data_scope NVARCHAR(20) NOT NULL DEFAULT N'custom',
    operation_teams_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    accessible_shops_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    remark NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT ck_sys_user_status CHECK (status IN (0, 1)),
    CONSTRAINT ck_sys_user_data_scope CHECK (data_scope IN (N'all', N'team', N'shop', N'mixed', N'custom')),
    CONSTRAINT ck_sys_user_operation_teams_json CHECK (ISJSON(operation_teams_json) = 1),
    CONSTRAINT ck_sys_user_accessible_shops_json CHECK (ISJSON(accessible_shops_json) = 1)
);

CREATE TABLE dbo.sys_user_permission (
    user_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (user_id, permission_id),
    CONSTRAINT fk_user_permission_user FOREIGN KEY (user_id) REFERENCES dbo.sys_user(id),
    CONSTRAINT fk_user_permission_permission FOREIGN KEY (permission_id) REFERENCES dbo.sys_permission(id)
);

CREATE TABLE dbo.sys_user_permission_group (
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    PRIMARY KEY (user_id, group_id),
    CONSTRAINT fk_user_group_user FOREIGN KEY (user_id) REFERENCES dbo.sys_user(id),
    CONSTRAINT fk_user_group_group FOREIGN KEY (group_id) REFERENCES dbo.sys_permission_group(id)
);

CREATE TABLE dbo.sys_group_permission (
    group_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (group_id, permission_id),
    CONSTRAINT fk_group_permission_group FOREIGN KEY (group_id) REFERENCES dbo.sys_permission_group(id),
    CONSTRAINT fk_group_permission_permission FOREIGN KEY (permission_id) REFERENCES dbo.sys_permission(id)
);

CREATE TABLE dbo.sys_group_parent (
    group_id INT NOT NULL,
    parent_group_id INT NOT NULL,
    PRIMARY KEY (group_id, parent_group_id),
    CONSTRAINT fk_group_parent_group FOREIGN KEY (group_id) REFERENCES dbo.sys_permission_group(id),
    CONSTRAINT fk_group_parent_parent FOREIGN KEY (parent_group_id) REFERENCES dbo.sys_permission_group(id),
    CONSTRAINT ck_group_parent_not_self CHECK (group_id <> parent_group_id)
);

CREATE TABLE dbo.sys_login_audit_log (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NULL,
    username NVARCHAR(100) NOT NULL,
    ip_address NVARCHAR(64) NULL,
    user_agent NVARCHAR(500) NULL,
    success BIT NOT NULL,
    failure_reason NVARCHAR(500) NULL,
    login_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_login_log_user FOREIGN KEY (user_id) REFERENCES dbo.sys_user(id)
);

CREATE TABLE dbo.shop_sales_platform (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(80) NOT NULL UNIQUE,
    name NVARCHAR(120) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.shop_operation_team (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(80) NOT NULL UNIQUE,
    name NVARCHAR(120) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.sys_shop (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(255) NOT NULL UNIQUE,
    platform_id INT NULL,
    shop_url NVARCHAR(500) NULL,
    shop_owner NVARCHAR(50) NULL,
    contact_phone NVARCHAR(30) NULL,
    status INT NOT NULL DEFAULT 0,
    sales_type NVARCHAR(20) NOT NULL DEFAULT N'retail',
    remark NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_shop_platform FOREIGN KEY (platform_id) REFERENCES dbo.shop_sales_platform(id),
    CONSTRAINT ck_shop_status CHECK (status IN (0, 1))
);

CREATE TABLE dbo.shop_assignment (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    shop_id INT NOT NULL,
    operation_team_id INT NOT NULL,
    user_id INT NOT NULL,
    assignment_role NVARCHAR(30) NOT NULL DEFAULT N'owner',
    effective_from DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    effective_to DATETIME2 NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_shop_assignment_shop FOREIGN KEY (shop_id) REFERENCES dbo.sys_shop(id),
    CONSTRAINT fk_shop_assignment_team FOREIGN KEY (operation_team_id) REFERENCES dbo.shop_operation_team(id),
    CONSTRAINT fk_shop_assignment_user FOREIGN KEY (user_id) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_shop_assignment_period CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE TABLE dbo.customer (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer_code NVARCHAR(50) NOT NULL UNIQUE,
    name NVARCHAR(100) NOT NULL,
    contact_person NVARCHAR(50) NULL,
    phone NVARCHAR(20) NULL,
    email NVARCHAR(100) NULL,
    address NVARCHAR(MAX) NULL,
    customer_type INT NOT NULL DEFAULT 0,
    level INT NOT NULL DEFAULT 0,
    status INT NOT NULL DEFAULT 0,
    credit_limit DECIMAL(18,2) NOT NULL DEFAULT 0,
    current_balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.customer_contact (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer_id INT NOT NULL,
    name NVARCHAR(50) NOT NULL,
    position NVARCHAR(50) NULL,
    phone NVARCHAR(20) NULL,
    email NVARCHAR(100) NULL,
    is_primary BIT NOT NULL DEFAULT 0,
    remark NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_customer_contact_customer FOREIGN KEY (customer_id) REFERENCES dbo.customer(id)
);

CREATE TABLE dbo.sys_product (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(100) NOT NULL UNIQUE,
    name NVARCHAR(255) NOT NULL,
    specification NVARCHAR(255) NULL,
    unit NVARCHAR(100) NOT NULL,
    barcode NVARCHAR(100) NULL,
    brand NVARCHAR(50) NULL DEFAULT N'外贸通',
    year NVARCHAR(10) NULL,
    season NVARCHAR(10) NULL,
    quarter_scope NVARCHAR(20) NOT NULL DEFAULT N'unassigned',
    category NVARCHAR(100) NULL,
    style NVARCHAR(100) NULL,
    color NVARCHAR(100) NULL,
    safety_stock INT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    custom_fields_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    remark NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT ck_product_custom_fields_json CHECK (ISJSON(custom_fields_json) = 1)
);

CREATE TABLE dbo.sys_product_variant (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_key NVARCHAR(160) NOT NULL,
    sku_code NVARCHAR(120) NULL UNIQUE,
    external_sku_code NVARCHAR(120) NULL,
    size NVARCHAR(50) NULL,
    color NVARCHAR(100) NULL,
    specification NVARCHAR(255) NULL,
    barcode NVARCHAR(100) NULL,
    is_default BIT NOT NULL DEFAULT 0,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_product_variant_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT uq_product_variant_key UNIQUE (product_id, variant_key)
);

CREATE TABLE dbo.sys_season (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) NOT NULL UNIQUE,
    year INT NOT NULL,
    season NVARCHAR(20) NOT NULL,
    name NVARCHAR(80) NOT NULL,
    season_index INT NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    CONSTRAINT uq_season_year_season UNIQUE (year, season)
);

CREATE TABLE dbo.sys_product_season (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    season_id INT NOT NULL,
    relation_type NVARCHAR(30) NOT NULL DEFAULT N'primary',
    effective_from DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    effective_to DATETIME2 NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_product_season_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_product_season_season FOREIGN KEY (season_id) REFERENCES dbo.sys_season(id),
    CONSTRAINT fk_product_season_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_product_season_period CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE TABLE dbo.sys_product_media (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    media_type NVARCHAR(20) NOT NULL DEFAULT N'image',
    file_url NVARCHAR(500) NULL,
    external_url NVARCHAR(500) NULL,
    role NVARCHAR(50) NOT NULL DEFAULT N'gallery',
    sort_order INT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_product_media_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_product_media_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id)
);

CREATE TABLE dbo.sys_product_property_definition (
    id INT IDENTITY(1,1) PRIMARY KEY,
    property_key NVARCHAR(100) NOT NULL UNIQUE,
    label NVARCHAR(120) NOT NULL,
    value_type NVARCHAR(20) NOT NULL DEFAULT N'text',
    group_key NVARCHAR(80) NOT NULL DEFAULT N'custom',
    required BIT NOT NULL DEFAULT 0,
    searchable BIT NOT NULL DEFAULT 0,
    filterable BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.sys_product_property_value (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    definition_id INT NOT NULL,
    value_text NVARCHAR(MAX) NULL,
    value_decimal DECIMAL(18,4) NULL,
    value_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    updated_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_property_value_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_property_value_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_property_value_definition FOREIGN KEY (definition_id) REFERENCES dbo.sys_product_property_definition(id),
    CONSTRAINT fk_property_value_user FOREIGN KEY (updated_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT uq_property_value UNIQUE (product_id, variant_id, definition_id),
    CONSTRAINT ck_property_value_json CHECK (ISJSON(value_json) = 1)
);

CREATE TABLE dbo.sys_product_operation_track (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL UNIQUE,
    track_no NVARCHAR(120) NOT NULL UNIQUE,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    owner_id INT NULL,
    last_value_updated_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_operation_track_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_operation_track_owner FOREIGN KEY (owner_id) REFERENCES dbo.sys_user(id)
);

CREATE TABLE dbo.sys_operation_track_field_definition (
    id INT IDENTITY(1,1) PRIMARY KEY,
    field_key NVARCHAR(100) NOT NULL UNIQUE,
    field_label NVARCHAR(120) NOT NULL,
    value_type NVARCHAR(20) NOT NULL DEFAULT N'text',
    required BIT NOT NULL DEFAULT 0,
    searchable BIT NOT NULL DEFAULT 0,
    filterable BIT NOT NULL DEFAULT 0,
    is_system BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.sys_operation_track_value (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    track_id BIGINT NOT NULL,
    field_id INT NOT NULL,
    value_text NVARCHAR(MAX) NULL,
    value_decimal DECIMAL(18,4) NULL,
    value_datetime DATETIME2 NULL,
    value_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    updated_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_track_value_track FOREIGN KEY (track_id) REFERENCES dbo.sys_product_operation_track(id),
    CONSTRAINT fk_track_value_field FOREIGN KEY (field_id) REFERENCES dbo.sys_operation_track_field_definition(id),
    CONSTRAINT fk_track_value_user FOREIGN KEY (updated_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT uq_track_value UNIQUE (track_id, field_id),
    CONSTRAINT ck_track_value_json CHECK (ISJSON(value_json) = 1)
);

CREATE TABLE dbo.sys_product_operation_track_projection (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    track_id BIGINT NOT NULL UNIQUE,
    product_id BIGINT NOT NULL,
    product_code_snapshot NVARCHAR(100) NOT NULL,
    product_name_snapshot NVARCHAR(255) NOT NULL DEFAULT N'',
    values_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    projection_status NVARCHAR(20) NOT NULL DEFAULT N'fresh',
    rebuilt_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_track_projection_track FOREIGN KEY (track_id) REFERENCES dbo.sys_product_operation_track(id),
    CONSTRAINT fk_track_projection_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT ck_track_projection_json CHECK (ISJSON(values_json) = 1)
);

CREATE TABLE dbo.sys_warehouse (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(100) NULL UNIQUE,
    name NVARCHAR(100) NOT NULL,
    warehouse_kind NVARCHAR(20) NOT NULL DEFAULT N'standard',
    address NVARCHAR(MAX) NULL,
    manager NVARCHAR(255) NULL,
    remark NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.sys_import_batch (
    batch_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    import_type NVARCHAR(30) NOT NULL,
    user_id INT NULL,
    file_name NVARCHAR(255) NULL,
    start_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    end_time DATETIME2 NULL,
    sync_time DATETIME2 NULL,
    status NVARCHAR(30) NOT NULL DEFAULT N'processing',
    task_stage NVARCHAR(50) NOT NULL DEFAULT N'',
    progress_percent TINYINT NOT NULL DEFAULT 0,
    retry_count INT NOT NULL DEFAULT 0,
    last_error NVARCHAR(MAX) NULL,
    import_effects_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    total_records_in_file INT NOT NULL DEFAULT 0,
    processed_records INT NOT NULL DEFAULT 0,
    failed_records INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_import_batch_user FOREIGN KEY (user_id) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_import_batch_progress CHECK (progress_percent BETWEEN 0 AND 100),
    CONSTRAINT ck_import_batch_effects_json CHECK (ISJSON(import_effects_json) = 1)
);

CREATE TABLE dbo.sys_inventory_document (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_no NVARCHAR(120) NOT NULL UNIQUE,
    document_type NVARCHAR(30) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    business_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    posted_at DATETIME2 NULL,
    source_type NVARCHAR(80) NULL,
    source_ref NVARCHAR(120) NULL,
    import_batch_id UNIQUEIDENTIFIER NULL,
    created_by INT NULL,
    memo NVARCHAR(MAX) NULL,
    reversal_of BIGINT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_inventory_doc_batch FOREIGN KEY (import_batch_id) REFERENCES dbo.sys_import_batch(batch_id),
    CONSTRAINT fk_inventory_doc_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT fk_inventory_doc_reversal FOREIGN KEY (reversal_of) REFERENCES dbo.sys_inventory_document(id),
    CONSTRAINT ck_inventory_doc_type CHECK (document_type IN (N'stock_in', N'stock_out', N'return', N'transfer', N'snapshot_set', N'opening_balance')),
    CONSTRAINT ck_inventory_doc_status CHECK (status IN (N'draft', N'posted', N'cancelled', N'reversed'))
);

CREATE TABLE dbo.sys_inventory_document_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id BIGINT NOT NULL,
    line_no INT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    warehouse_id INT NOT NULL,
    counterpart_warehouse_id INT NULL,
    quantity_bucket NVARCHAR(40) NOT NULL DEFAULT N'on_hand',
    delta_quantity BIGINT NOT NULL DEFAULT 0,
    target_quantity BIGINT NULL,
    unit_cost DECIMAL(18,2) NULL,
    source_line_key NVARCHAR(150) NULL,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_inventory_line_document FOREIGN KEY (document_id) REFERENCES dbo.sys_inventory_document(id),
    CONSTRAINT fk_inventory_line_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_inventory_line_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_inventory_line_warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.sys_warehouse(id),
    CONSTRAINT fk_inventory_line_counterpart FOREIGN KEY (counterpart_warehouse_id) REFERENCES dbo.sys_warehouse(id),
    CONSTRAINT uq_inventory_line_no UNIQUE (document_id, line_no),
    CONSTRAINT ck_inventory_line_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE TABLE dbo.sys_inventory_ledger (
    event_id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    document_line_id BIGINT NULL,
    event_type NVARCHAR(32) NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    warehouse_id INT NOT NULL,
    delta_quantity BIGINT NOT NULL DEFAULT 0,
    snapshot_quantity BIGINT NULL,
    biz_time DATETIME2 NOT NULL,
    source_type NVARCHAR(64) NULL,
    source_ref NVARCHAR(128) NULL,
    idempotency_key NVARCHAR(128) NOT NULL UNIQUE,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_inventory_ledger_line FOREIGN KEY (document_line_id) REFERENCES dbo.sys_inventory_document_line(id),
    CONSTRAINT fk_inventory_ledger_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_inventory_ledger_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_inventory_ledger_warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.sys_warehouse(id),
    CONSTRAINT ck_inventory_ledger_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE TABLE dbo.sys_inventory_balance_current (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    warehouse_id INT NOT NULL,
    quantity BIGINT NOT NULL DEFAULT 0,
    last_event_id UNIQUEIDENTIFIER NULL,
    last_biz_time DATETIME2 NULL,
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_inventory_balance_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_inventory_balance_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_inventory_balance_warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.sys_warehouse(id),
    CONSTRAINT fk_inventory_balance_event FOREIGN KEY (last_event_id) REFERENCES dbo.sys_inventory_ledger(event_id),
    CONSTRAINT uq_inventory_balance UNIQUE (product_id, variant_id, warehouse_id)
);

CREATE TABLE dbo.sys_inventory_period_lock (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    is_locked BIT NOT NULL DEFAULT 1,
    locked_by INT NULL,
    locked_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    remark NVARCHAR(MAX) NULL,
    CONSTRAINT fk_inventory_period_lock_user FOREIGN KEY (locked_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT uq_inventory_period_lock UNIQUE (year, month),
    CONSTRAINT ck_inventory_period_month CHECK (month BETWEEN 1 AND 12)
);

CREATE TABLE dbo.sales_document (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_no NVARCHAR(120) NOT NULL UNIQUE,
    document_type NVARCHAR(30) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    shop_id INT NULL,
    customer_name_snapshot NVARCHAR(255) NULL,
    transaction_time DATETIME2 NULL,
    source_system NVARCHAR(80) NULL,
    source_record_key NVARCHAR(255) NULL,
    import_batch_id UNIQUEIDENTIFIER NULL,
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    memo NVARCHAR(MAX) NULL,
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_sales_doc_shop FOREIGN KEY (shop_id) REFERENCES dbo.sys_shop(id),
    CONSTRAINT fk_sales_doc_batch FOREIGN KEY (import_batch_id) REFERENCES dbo.sys_import_batch(batch_id),
    CONSTRAINT fk_sales_doc_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id)
);

CREATE TABLE dbo.sales_document_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id BIGINT NOT NULL,
    line_no INT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    product_code_snapshot NVARCHAR(100) NOT NULL,
    sku_key_snapshot NVARCHAR(160) NULL,
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    source_line_key NVARCHAR(150) NULL,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_sales_line_document FOREIGN KEY (document_id) REFERENCES dbo.sales_document(id),
    CONSTRAINT fk_sales_line_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_sales_line_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT uq_sales_line_no UNIQUE (document_id, line_no),
    CONSTRAINT ck_sales_line_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE TABLE dbo.sales_ledger_entry (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id BIGINT NOT NULL,
    document_line_id BIGINT NOT NULL,
    reversal_of BIGINT NULL,
    entry_type NVARCHAR(30) NOT NULL,
    quantity_scope NVARCHAR(30) NOT NULL,
    entry_status NVARCHAR(20) NOT NULL DEFAULT N'posted',
    is_reversal BIT NOT NULL DEFAULT 0,
    shop_id INT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    business_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    source_system NVARCHAR(80) NULL,
    source_record_key NVARCHAR(255) NULL,
    idempotency_key NVARCHAR(255) NOT NULL UNIQUE,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_sales_ledger_document FOREIGN KEY (document_id) REFERENCES dbo.sales_document(id),
    CONSTRAINT fk_sales_ledger_line FOREIGN KEY (document_line_id) REFERENCES dbo.sales_document_line(id),
    CONSTRAINT fk_sales_ledger_reversal FOREIGN KEY (reversal_of) REFERENCES dbo.sales_ledger_entry(id),
    CONSTRAINT fk_sales_ledger_shop FOREIGN KEY (shop_id) REFERENCES dbo.sys_shop(id),
    CONSTRAINT fk_sales_ledger_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_sales_ledger_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT ck_sales_ledger_scope CHECK (quantity_scope IN (N'deal', N'outbound', N'net', N'financial'))
);

CREATE TABLE dbo.sales_fulfillment_link (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    sales_document_id BIGINT NOT NULL,
    sales_line_id BIGINT NOT NULL,
    inventory_document_id BIGINT NULL,
    matched_quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    status NVARCHAR(20) NOT NULL DEFAULT N'matched',
    matched_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_fulfillment_sales_doc FOREIGN KEY (sales_document_id) REFERENCES dbo.sales_document(id),
    CONSTRAINT fk_fulfillment_sales_line FOREIGN KEY (sales_line_id) REFERENCES dbo.sales_document_line(id),
    CONSTRAINT fk_fulfillment_inventory_doc FOREIGN KEY (inventory_document_id) REFERENCES dbo.sys_inventory_document(id)
);

CREATE TABLE dbo.database_metric_definition (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    metric_code NVARCHAR(100) NOT NULL UNIQUE,
    metric_name NVARCHAR(120) NOT NULL,
    metric_domain NVARCHAR(80) NOT NULL,
    grain NVARCHAR(100) NOT NULL,
    source_fact NVARCHAR(120) NOT NULL,
    owner NVARCHAR(100) NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    description NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT ck_metric_definition_status CHECK (status IN (N'draft', N'active', N'retired'))
);

CREATE TABLE dbo.database_metric_version (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    metric_id BIGINT NOT NULL,
    version_no NVARCHAR(50) NOT NULL,
    formula_text NVARCHAR(MAX) NOT NULL,
    scope_text NVARCHAR(MAX) NULL,
    time_field NVARCHAR(100) NOT NULL,
    effective_from DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    effective_to DATETIME2 NULL,
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_metric_version_metric FOREIGN KEY (metric_id) REFERENCES dbo.database_metric_definition(id),
    CONSTRAINT fk_metric_version_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT uq_metric_version UNIQUE (metric_id, version_no),
    CONSTRAINT ck_metric_version_period CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE TABLE dbo.report_query_model (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    query_code NVARCHAR(100) NOT NULL UNIQUE,
    query_name NVARCHAR(120) NOT NULL,
    report_domain NVARCHAR(80) NOT NULL,
    source_fact NVARCHAR(120) NOT NULL,
    default_time_field NVARCHAR(100) NOT NULL,
    default_grain NVARCHAR(100) NOT NULL,
    permission_code NVARCHAR(100) NULL,
    cache_policy NVARCHAR(30) NOT NULL DEFAULT N'none',
    default_params_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    is_active BIT NOT NULL DEFAULT 1,
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_report_query_model_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_report_query_cache_policy CHECK (cache_policy IN (N'none', N'memory', N'snapshot', N'locked_snapshot')),
    CONSTRAINT ck_report_query_default_params_json CHECK (ISJSON(default_params_json) = 1)
);

CREATE TABLE dbo.report_query_field (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    query_model_id BIGINT NOT NULL,
    metric_id BIGINT NULL,
    field_key NVARCHAR(100) NOT NULL,
    field_label NVARCHAR(120) NOT NULL,
    field_role NVARCHAR(20) NOT NULL,
    data_type NVARCHAR(30) NOT NULL DEFAULT N'string',
    expression_text NVARCHAR(MAX) NULL,
    is_required BIT NOT NULL DEFAULT 0,
    is_visible BIT NOT NULL DEFAULT 1,
    sort_order INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_report_query_field_model FOREIGN KEY (query_model_id) REFERENCES dbo.report_query_model(id),
    CONSTRAINT fk_report_query_field_metric FOREIGN KEY (metric_id) REFERENCES dbo.database_metric_definition(id),
    CONSTRAINT uq_report_query_field UNIQUE (query_model_id, field_key),
    CONSTRAINT ck_report_query_field_role CHECK (field_role IN (N'dimension', N'metric', N'filter', N'sort'))
);

CREATE TABLE dbo.report_query_snapshot (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    query_model_id BIGINT NOT NULL,
    query_params_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    result_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    metric_versions_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    source_trace_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    data_mode NVARCHAR(30) NOT NULL DEFAULT N'realtime',
    snapshot_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_report_snapshot_model FOREIGN KEY (query_model_id) REFERENCES dbo.report_query_model(id),
    CONSTRAINT fk_report_snapshot_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_report_snapshot_params_json CHECK (ISJSON(query_params_json) = 1),
    CONSTRAINT ck_report_snapshot_result_json CHECK (ISJSON(result_json) = 1),
    CONSTRAINT ck_report_snapshot_metric_versions_json CHECK (ISJSON(metric_versions_json) = 1),
    CONSTRAINT ck_report_snapshot_source_trace_json CHECK (ISJSON(source_trace_json) = 1),
    CONSTRAINT ck_report_snapshot_data_mode CHECK (data_mode IN (N'realtime', N'snapshot', N'closed_snapshot'))
);

CREATE TABLE dbo.sales_summary_record (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    year INT NOT NULL,
    operation_team NVARCHAR(100) NOT NULL,
    manager_name NVARCHAR(100) NOT NULL,
    platform NVARCHAR(100) NOT NULL,
    shop_name NVARCHAR(200) NOT NULL,
    shop_rating DECIMAL(8,2) NULL,
    monthly_data_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_sales_summary_record UNIQUE (year, shop_name),
    CONSTRAINT ck_sales_summary_monthly_json CHECK (ISJSON(monthly_data_json) = 1)
);

CREATE TABLE dbo.monthly_sales_summary (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    operation_team NVARCHAR(100) NOT NULL,
    manager_name NVARCHAR(100) NOT NULL,
    shop_name NVARCHAR(255) NOT NULL,
    daily_sales_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    total_sales_volume INT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_monthly_sales_summary UNIQUE (year, month, shop_name),
    CONSTRAINT ck_monthly_sales_month CHECK (month BETWEEN 1 AND 12),
    CONSTRAINT ck_monthly_sales_daily_json CHECK (ISJSON(daily_sales_json) = 1)
);

CREATE TABLE dbo.reports_quarterly_sales_summary (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    year INT NOT NULL,
    quarter NVARCHAR(10) NOT NULL,
    actual_sales DECIMAL(18,2) NOT NULL DEFAULT 0,
    quantity_sold INT NOT NULL DEFAULT 0,
    order_count INT NOT NULL DEFAULT 0,
    sales_target DECIMAL(18,2) NOT NULL DEFAULT 0,
    completion_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    yoy_growth DECIMAL(8,4) NOT NULL DEFAULT 0,
    avg_order_value DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_quarterly_sales_summary UNIQUE (year, quarter)
);

CREATE TABLE dbo.total_inventory_summary (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    season NVARCHAR(20) NOT NULL,
    year INT NOT NULL,
    product_code NVARCHAR(100) NOT NULL,
    color NVARCHAR(50) NOT NULL,
    inventory_quantity INT NOT NULL DEFAULT 0,
    sales_7_days INT NOT NULL DEFAULT 0,
    sales_30_days INT NOT NULL DEFAULT 0,
    total_sales INT NOT NULL DEFAULT 0,
    purchase_in_transit INT NOT NULL DEFAULT 0,
    transfer_inventory_quantity INT NOT NULL DEFAULT 0,
    total_inbound INT NOT NULL DEFAULT 0,
    sellout_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    return_exchange_total INT NOT NULL DEFAULT 0,
    total_returns INT NOT NULL DEFAULT 0,
    return_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_total_inventory_summary UNIQUE (year, season, product_code, color)
);

CREATE TABLE dbo.merchandise_analysis_summary (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    summary_date DATE NOT NULL UNIQUE,
    actual_inventory INT NOT NULL DEFAULT 0,
    total_inventory INT NOT NULL DEFAULT 0,
    purchase_in_transit INT NOT NULL DEFAULT 0,
    transfer_inventory_quantity INT NOT NULL DEFAULT 0,
    seasonal_inventory_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    daily_inbound INT NOT NULL DEFAULT 0,
    daily_sales_outbound INT NOT NULL DEFAULT 0,
    daily_returns INT NOT NULL DEFAULT 0,
    daily_exchanges INT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT ck_merchandise_seasonal_json CHECK (ISJSON(seasonal_inventory_json) = 1)
);

CREATE TABLE dbo.sellout_rate_summary (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    year INT NOT NULL UNIQUE,
    spring_sellout_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    summer_sellout_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    autumn_sellout_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    winter_sellout_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    past_season_sellout_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
    spring_total_sales INT NOT NULL DEFAULT 0,
    summer_total_sales INT NOT NULL DEFAULT 0,
    autumn_total_sales INT NOT NULL DEFAULT 0,
    winter_total_sales INT NOT NULL DEFAULT 0,
    past_season_total_sales INT NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.sales_forecast_plan (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    year INT NOT NULL,
    month INT NOT NULL,
    season NVARCHAR(10) NOT NULL,
    sales_count INT NOT NULL DEFAULT 0,
    return_count INT NOT NULL DEFAULT 0,
    restock_count INT NOT NULL DEFAULT 0,
    inbound_count INT NOT NULL DEFAULT 0,
    outbound_count INT NOT NULL DEFAULT 0,
    sales_percentage DECIMAL(8,4) NOT NULL DEFAULT 0,
    return_percentage DECIMAL(8,4) NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT uq_sales_forecast_plan UNIQUE (year, month, season),
    CONSTRAINT ck_sales_forecast_month CHECK (month BETWEEN 1 AND 12)
);

CREATE TABLE dbo.sys_product_price (
    product_id BIGINT PRIMARY KEY,
    retail_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    cost_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    wholesale_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_product_price_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id)
);

CREATE TABLE dbo.product_price_value (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    price_profile_id BIGINT NULL,
    variant_id BIGINT NULL,
    price_type NVARCHAR(80) NOT NULL,
    amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    source NVARCHAR(30) NOT NULL DEFAULT N'manual',
    source_ref NVARCHAR(120) NULL,
    effective_from DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    effective_to DATETIME2 NULL,
    is_current BIT NOT NULL DEFAULT 1,
    updated_by INT NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_price_value_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_price_value_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_price_value_user FOREIGN KEY (updated_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_price_value_amount CHECK (amount >= 0),
    CONSTRAINT ck_price_value_period CHECK (effective_to IS NULL OR effective_to >= effective_from)
);

CREATE TABLE dbo.product_price_projection (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    base_values_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    formula_values_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    all_values_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    projection_status NVARCHAR(20) NOT NULL DEFAULT N'fresh',
    rebuilt_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_price_projection_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_price_projection_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT uq_price_projection UNIQUE (product_id, variant_id, currency),
    CONSTRAINT ck_price_projection_base_json CHECK (ISJSON(base_values_json) = 1),
    CONSTRAINT ck_price_projection_formula_json CHECK (ISJSON(formula_values_json) = 1),
    CONSTRAINT ck_price_projection_all_json CHECK (ISJSON(all_values_json) = 1)
);

CREATE TABLE dbo.product_price_change (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    change_source NVARCHAR(50) NULL,
    reason NVARCHAR(MAX) NULL,
    changed_by INT NULL,
    changed_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    context_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    CONSTRAINT fk_price_change_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_price_change_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_price_change_user FOREIGN KEY (changed_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_price_change_context_json CHECK (ISJSON(context_json) = 1)
);

CREATE TABLE dbo.product_price_change_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    change_id BIGINT NOT NULL,
    price_type NVARCHAR(80) NOT NULL,
    old_value_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    new_value_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    CONSTRAINT fk_price_change_line_change FOREIGN KEY (change_id) REFERENCES dbo.product_price_change(id),
    CONSTRAINT ck_price_change_line_old_json CHECK (ISJSON(old_value_json) = 1),
    CONSTRAINT ck_price_change_line_new_json CHECK (ISJSON(new_value_json) = 1)
);

CREATE TABLE dbo.inventory_cost_layer (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    product_code_snapshot NVARCHAR(100) NOT NULL,
    layer_type NVARCHAR(20) NOT NULL DEFAULT N'raw',
    source_year NVARCHAR(10) NULL,
    source_season NVARCHAR(10) NULL,
    target_year NVARCHAR(10) NULL,
    target_season NVARCHAR(10) NULL,
    unit_cost DECIMAL(18,2) NOT NULL DEFAULT 0,
    remaining_qty DECIMAL(18,4) NOT NULL DEFAULT 0,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_cost_layer_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id)
);

CREATE TABLE dbo.financial_accounting_book (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) NOT NULL UNIQUE,
    name NVARCHAR(100) NOT NULL,
    base_currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    is_default BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.financial_accounting_period (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    period_type NVARCHAR(20) NOT NULL DEFAULT N'monthly',
    year INT NOT NULL,
    month INT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_period_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT uq_period_book_month UNIQUE (book_id, year, month),
    CONSTRAINT ck_period_month CHECK (month IS NULL OR month BETWEEN 1 AND 12),
    CONSTRAINT ck_period_date CHECK (end_date >= start_date),
    CONSTRAINT ck_period_status CHECK (status IN (N'draft', N'initialized', N'submitted', N'approved', N'closed', N'reopened'))
);

CREATE TABLE dbo.financial_account (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) NOT NULL UNIQUE,
    name NVARCHAR(100) NOT NULL,
    category NVARCHAR(20) NOT NULL,
    normal_side NVARCHAR(10) NOT NULL,
    level INT NOT NULL DEFAULT 1,
    parent_id BIGINT NULL,
    is_postable BIT NOT NULL DEFAULT 1,
    is_active BIT NOT NULL DEFAULT 1,
    memo NVARCHAR(MAX) NULL,
    CONSTRAINT fk_account_parent FOREIGN KEY (parent_id) REFERENCES dbo.financial_account(id),
    CONSTRAINT ck_account_side CHECK (normal_side IN (N'debit', N'credit'))
);

CREATE TABLE dbo.financial_dimension_type (
    id INT IDENTITY(1,1) PRIMARY KEY,
    code NVARCHAR(50) NOT NULL UNIQUE,
    name NVARCHAR(100) NOT NULL,
    is_system BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.financial_dimension_value (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    dimension_type_id INT NOT NULL,
    code NVARCHAR(100) NOT NULL,
    name NVARCHAR(255) NOT NULL,
    external_ref NVARCHAR(100) NULL,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    is_active BIT NOT NULL DEFAULT 1,
    CONSTRAINT fk_dimension_value_type FOREIGN KEY (dimension_type_id) REFERENCES dbo.financial_dimension_type(id),
    CONSTRAINT uq_dimension_value UNIQUE (dimension_type_id, code),
    CONSTRAINT ck_dimension_value_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE TABLE dbo.financial_document (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    period_id BIGINT NOT NULL,
    doc_type NVARCHAR(50) NOT NULL,
    doc_no NVARCHAR(100) NOT NULL,
    biz_date DATE NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    source_system NVARCHAR(50) NULL,
    source_model NVARCHAR(100) NULL,
    source_id NVARCHAR(100) NULL,
    memo NVARCHAR(MAX) NULL,
    posted_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_fin_doc_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT fk_fin_doc_period FOREIGN KEY (period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT uq_fin_doc_no UNIQUE (book_id, doc_no)
);

CREATE TABLE dbo.financial_document_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id BIGINT NOT NULL,
    line_no INT NOT NULL,
    line_type NVARCHAR(50) NOT NULL DEFAULT N'base',
    summary NVARCHAR(255) NULL,
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    amount_local DECIMAL(18,2) NOT NULL DEFAULT 0,
    source_line_key NVARCHAR(100) NULL,
    extra_payload_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    CONSTRAINT fk_fin_doc_line_doc FOREIGN KEY (document_id) REFERENCES dbo.financial_document(id),
    CONSTRAINT uq_fin_doc_line_no UNIQUE (document_id, line_no),
    CONSTRAINT ck_fin_doc_line_payload_json CHECK (ISJSON(extra_payload_json) = 1)
);

CREATE TABLE dbo.financial_document_line_dimension (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_line_id BIGINT NOT NULL,
    dimension_type_id INT NOT NULL,
    dimension_value_id BIGINT NOT NULL,
    CONSTRAINT fk_doc_line_dim_line FOREIGN KEY (document_line_id) REFERENCES dbo.financial_document_line(id),
    CONSTRAINT fk_doc_line_dim_type FOREIGN KEY (dimension_type_id) REFERENCES dbo.financial_dimension_type(id),
    CONSTRAINT fk_doc_line_dim_value FOREIGN KEY (dimension_value_id) REFERENCES dbo.financial_dimension_value(id),
    CONSTRAINT uq_doc_line_dim UNIQUE (document_line_id, dimension_type_id)
);

CREATE TABLE dbo.financial_journal_entry (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    period_id BIGINT NOT NULL,
    document_id BIGINT NULL,
    entry_no NVARCHAR(100) NOT NULL,
    entry_date DATE NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    summary NVARCHAR(255) NULL,
    total_debit DECIMAL(18,2) NOT NULL DEFAULT 0,
    total_credit DECIMAL(18,2) NOT NULL DEFAULT 0,
    reversal_of BIGINT NULL,
    posted_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_journal_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT fk_journal_period FOREIGN KEY (period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT fk_journal_document FOREIGN KEY (document_id) REFERENCES dbo.financial_document(id),
    CONSTRAINT fk_journal_reversal FOREIGN KEY (reversal_of) REFERENCES dbo.financial_journal_entry(id),
    CONSTRAINT uq_journal_entry_no UNIQUE (book_id, entry_no),
    CONSTRAINT ck_journal_balance CHECK (total_debit = total_credit)
);

CREATE TABLE dbo.financial_journal_entry_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    entry_id BIGINT NOT NULL,
    line_no INT NOT NULL,
    account_id BIGINT NOT NULL,
    summary NVARCHAR(255) NULL,
    debit DECIMAL(18,2) NOT NULL DEFAULT 0,
    credit DECIMAL(18,2) NOT NULL DEFAULT 0,
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    amount_local DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_journal_line_entry FOREIGN KEY (entry_id) REFERENCES dbo.financial_journal_entry(id),
    CONSTRAINT fk_journal_line_account FOREIGN KEY (account_id) REFERENCES dbo.financial_account(id),
    CONSTRAINT uq_journal_line_no UNIQUE (entry_id, line_no),
    CONSTRAINT ck_journal_line_amount CHECK (debit >= 0 AND credit >= 0 AND NOT (debit > 0 AND credit > 0))
);

CREATE TABLE dbo.financial_account_balance_snapshot (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    period_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    dimension_key NVARCHAR(255) NOT NULL DEFAULT N'',
    dimension_snapshot_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    opening_balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    period_debit DECIMAL(18,2) NOT NULL DEFAULT 0,
    period_credit DECIMAL(18,2) NOT NULL DEFAULT 0,
    closing_balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_balance_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT fk_balance_period FOREIGN KEY (period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT fk_balance_account FOREIGN KEY (account_id) REFERENCES dbo.financial_account(id),
    CONSTRAINT uq_balance_snapshot UNIQUE (book_id, period_id, account_id, dimension_key),
    CONSTRAINT ck_balance_dimension_json CHECK (ISJSON(dimension_snapshot_json) = 1)
);

CREATE TABLE dbo.financial_close_batch (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    period_id BIGINT NOT NULL,
    batch_no NVARCHAR(100) NOT NULL UNIQUE,
    status NVARCHAR(20) NOT NULL DEFAULT N'initialized',
    snapshot_version INT NOT NULL DEFAULT 1,
    started_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    completed_at DATETIME2 NULL,
    CONSTRAINT fk_close_batch_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT fk_close_batch_period FOREIGN KEY (period_id) REFERENCES dbo.financial_accounting_period(id)
);

CREATE TABLE dbo.financial_close_snapshot (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    book_id INT NOT NULL,
    period_id BIGINT NOT NULL,
    snapshot_type NVARCHAR(50) NOT NULL,
    snapshot_key NVARCHAR(255) NOT NULL,
    snapshot_data_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_close_snapshot_batch FOREIGN KEY (batch_id) REFERENCES dbo.financial_close_batch(id),
    CONSTRAINT fk_close_snapshot_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT fk_close_snapshot_period FOREIGN KEY (period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT uq_close_snapshot UNIQUE (batch_id, snapshot_type, snapshot_key),
    CONSTRAINT ck_close_snapshot_json CHECK (ISJSON(snapshot_data_json) = 1)
);

CREATE TABLE dbo.financial_action_log (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    period_id BIGINT NULL,
    document_id BIGINT NULL,
    journal_entry_id BIGINT NULL,
    action_type NVARCHAR(50) NOT NULL,
    status_before NVARCHAR(20) NULL,
    status_after NVARCHAR(20) NULL,
    actor_id INT NULL,
    actor_name NVARCHAR(100) NULL,
    reason NVARCHAR(MAX) NULL,
    payload_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_fin_action_book FOREIGN KEY (book_id) REFERENCES dbo.financial_accounting_book(id),
    CONSTRAINT fk_fin_action_period FOREIGN KEY (period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT fk_fin_action_document FOREIGN KEY (document_id) REFERENCES dbo.financial_document(id),
    CONSTRAINT fk_fin_action_journal FOREIGN KEY (journal_entry_id) REFERENCES dbo.financial_journal_entry(id),
    CONSTRAINT fk_fin_action_actor FOREIGN KEY (actor_id) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_fin_action_payload_json CHECK (ISJSON(payload_json) = 1)
);

CREATE TABLE dbo.inventory_cost_adjustment_document (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_no NVARCHAR(120) NOT NULL UNIQUE,
    adjustment_type NVARCHAR(30) NOT NULL,
    cost_basis NVARCHAR(30) NOT NULL DEFAULT N'management',
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    business_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    business_period_id BIGINT NULL,
    posting_period_id BIGINT NULL,
    source_type NVARCHAR(80) NULL,
    source_ref NVARCHAR(120) NULL,
    import_batch_id UNIQUEIDENTIFIER NULL,
    created_by INT NULL,
    posted_at DATETIME2 NULL,
    reversal_of BIGINT NULL,
    CONSTRAINT fk_cost_doc_business_period FOREIGN KEY (business_period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT fk_cost_doc_posting_period FOREIGN KEY (posting_period_id) REFERENCES dbo.financial_accounting_period(id),
    CONSTRAINT fk_cost_doc_batch FOREIGN KEY (import_batch_id) REFERENCES dbo.sys_import_batch(batch_id),
    CONSTRAINT fk_cost_doc_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT fk_cost_doc_reversal FOREIGN KEY (reversal_of) REFERENCES dbo.inventory_cost_adjustment_document(id)
);

CREATE TABLE dbo.inventory_cost_adjustment_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id BIGINT NOT NULL,
    line_no INT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    product_code_snapshot NVARCHAR(100) NOT NULL,
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    old_unit_cost DECIMAL(18,2) NULL,
    new_unit_cost DECIMAL(18,2) NULL,
    amount_delta DECIMAL(18,2) NOT NULL DEFAULT 0,
    source_line_key NVARCHAR(150) NULL,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    CONSTRAINT fk_cost_line_document FOREIGN KEY (document_id) REFERENCES dbo.inventory_cost_adjustment_document(id),
    CONSTRAINT fk_cost_line_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_cost_line_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT uq_cost_line_no UNIQUE (document_id, line_no),
    CONSTRAINT ck_cost_line_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE TABLE dbo.inventory_cost_movement (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    document_id BIGINT NOT NULL,
    document_line_id BIGINT NOT NULL,
    movement_type NVARCHAR(30) NOT NULL,
    cost_basis NVARCHAR(30) NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    quantity_delta DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount_delta DECIMAL(18,2) NOT NULL DEFAULT 0,
    unit_cost_after DECIMAL(18,2) NULL,
    business_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    idempotency_key NVARCHAR(255) NOT NULL UNIQUE,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    CONSTRAINT fk_cost_movement_doc FOREIGN KEY (document_id) REFERENCES dbo.inventory_cost_adjustment_document(id),
    CONSTRAINT fk_cost_movement_line FOREIGN KEY (document_line_id) REFERENCES dbo.inventory_cost_adjustment_line(id),
    CONSTRAINT fk_cost_movement_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_cost_movement_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT ck_cost_movement_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE TABLE dbo.inventory_cost_balance_projection (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    cost_basis NVARCHAR(30) NOT NULL,
    quantity_balance DECIMAL(18,4) NOT NULL DEFAULT 0,
    amount_balance DECIMAL(18,2) NOT NULL DEFAULT 0,
    unit_cost DECIMAL(18,2) NOT NULL DEFAULT 0,
    as_of_time DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    projection_status NVARCHAR(20) NOT NULL DEFAULT N'fresh',
    last_movement_id BIGINT NULL,
    CONSTRAINT fk_cost_balance_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_cost_balance_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT fk_cost_balance_movement FOREIGN KEY (last_movement_id) REFERENCES dbo.inventory_cost_movement(id),
    CONSTRAINT uq_cost_balance UNIQUE (product_id, variant_id, cost_basis)
);

CREATE TABLE dbo.database_external_source_type_definition (
    id INT IDENTITY(1,1) PRIMARY KEY,
    source_type NVARCHAR(100) NOT NULL UNIQUE,
    source_system NVARCHAR(80) NOT NULL,
    source_kind NVARCHAR(30) NOT NULL,
    display_name NVARCHAR(120) NOT NULL,
    target_domain NVARCHAR(80) NOT NULL,
    target_fact_model NVARCHAR(120) NULL,
    parser_key NVARCHAR(120) NULL,
    parser_version NVARCHAR(50) NULL,
    required_fields_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    schema_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    error_policy NVARCHAR(30) NOT NULL DEFAULT N'manual_review',
    reversal_policy NVARCHAR(30) NOT NULL DEFAULT N'manual_review',
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT ck_source_required_json CHECK (ISJSON(required_fields_json) = 1),
    CONSTRAINT ck_source_schema_json CHECK (ISJSON(schema_json) = 1)
);

CREATE TABLE dbo.database_migration_plan (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    plan_code NVARCHAR(100) NOT NULL UNIQUE,
    domain NVARCHAR(50) NOT NULL,
    source_tables_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    target_tables_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    description NVARCHAR(MAX) NULL,
    CONSTRAINT ck_migration_plan_source_json CHECK (ISJSON(source_tables_json) = 1),
    CONSTRAINT ck_migration_plan_target_json CHECK (ISJSON(target_tables_json) = 1)
);

CREATE TABLE dbo.database_migration_run (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    plan_id BIGINT NOT NULL,
    run_no INT NOT NULL,
    mode NVARCHAR(30) NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'running',
    source_checksum NVARCHAR(128) NULL,
    target_checksum NVARCHAR(128) NULL,
    started_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    finished_at DATETIME2 NULL,
    CONSTRAINT fk_migration_run_plan FOREIGN KEY (plan_id) REFERENCES dbo.database_migration_plan(id),
    CONSTRAINT uq_migration_run UNIQUE (plan_id, run_no)
);

CREATE TABLE dbo.database_external_raw_record (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    source_type_id INT NOT NULL,
    import_batch_id UNIQUEIDENTIFIER NULL,
    migration_run_id BIGINT NULL,
    source_record_key NVARCHAR(255) NULL,
    source_row_no INT NULL,
    raw_payload_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    raw_hash NVARCHAR(128) NOT NULL,
    idempotency_key NVARCHAR(255) NOT NULL UNIQUE,
    status NVARCHAR(20) NOT NULL DEFAULT N'loaded',
    loaded_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    created_by INT NULL,
    CONSTRAINT fk_raw_source_type FOREIGN KEY (source_type_id) REFERENCES dbo.database_external_source_type_definition(id),
    CONSTRAINT fk_raw_import_batch FOREIGN KEY (import_batch_id) REFERENCES dbo.sys_import_batch(batch_id),
    CONSTRAINT fk_raw_migration_run FOREIGN KEY (migration_run_id) REFERENCES dbo.database_migration_run(id),
    CONSTRAINT fk_raw_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_raw_payload_json CHECK (ISJSON(raw_payload_json) = 1)
);

CREATE TABLE dbo.database_external_staging_record (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    raw_record_id BIGINT NOT NULL,
    staging_key NVARCHAR(255) NOT NULL,
    normalized_payload_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    validation_status NVARCHAR(20) NOT NULL DEFAULT N'parsed',
    validation_errors_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    applied_fact_type NVARCHAR(120) NULL,
    applied_fact_id NVARCHAR(100) NULL,
    applied_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_staging_raw FOREIGN KEY (raw_record_id) REFERENCES dbo.database_external_raw_record(id),
    CONSTRAINT ck_staging_payload_json CHECK (ISJSON(normalized_payload_json) = 1),
    CONSTRAINT ck_staging_errors_json CHECK (ISJSON(validation_errors_json) = 1),
    CONSTRAINT ck_staging_status CHECK (validation_status IN (N'parsed', N'valid', N'invalid', N'applied'))
);

CREATE TABLE dbo.database_migration_record_map (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id BIGINT NOT NULL,
    source_table NVARCHAR(100) NOT NULL,
    source_pk NVARCHAR(100) NULL,
    source_line_key NVARCHAR(150) NULL,
    source_business_key NVARCHAR(255) NULL,
    target_model NVARCHAR(120) NOT NULL,
    target_pk NVARCHAR(100) NULL,
    target_business_key NVARCHAR(255) NULL,
    idempotency_key NVARCHAR(255) NOT NULL UNIQUE,
    mapping_type NVARCHAR(30) NOT NULL DEFAULT N'created',
    is_current BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_migration_map_run FOREIGN KEY (run_id) REFERENCES dbo.database_migration_run(id)
);

CREATE TABLE dbo.database_migration_issue (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id BIGINT NOT NULL,
    linked_record_map_id BIGINT NULL,
    source_table NVARCHAR(100) NULL,
    source_pk NVARCHAR(100) NULL,
    source_row_key NVARCHAR(150) NULL,
    issue_type NVARCHAR(40) NOT NULL,
    severity NVARCHAR(20) NOT NULL,
    message NVARCHAR(MAX) NOT NULL,
    owner_id INT NULL,
    resolution_status NVARCHAR(30) NOT NULL DEFAULT N'open',
    resolved_by INT NULL,
    resolved_at DATETIME2 NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_migration_issue_run FOREIGN KEY (run_id) REFERENCES dbo.database_migration_run(id),
    CONSTRAINT fk_migration_issue_map FOREIGN KEY (linked_record_map_id) REFERENCES dbo.database_migration_record_map(id),
    CONSTRAINT fk_migration_issue_owner FOREIGN KEY (owner_id) REFERENCES dbo.sys_user(id),
    CONSTRAINT fk_migration_issue_resolved_by FOREIGN KEY (resolved_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_migration_issue_severity CHECK (severity IN (N'info', N'warning', N'error', N'critical'))
);

CREATE TABLE dbo.database_migration_reconciliation_report (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id BIGINT NOT NULL,
    report_code NVARCHAR(120) NOT NULL,
    metric_code NVARCHAR(100) NOT NULL,
    version_no NVARCHAR(50) NOT NULL,
    grain NVARCHAR(100) NOT NULL,
    tolerance DECIMAL(18,4) NOT NULL DEFAULT 0,
    old_value DECIMAL(18,4) NOT NULL DEFAULT 0,
    new_value DECIMAL(18,4) NOT NULL DEFAULT 0,
    difference DECIMAL(18,4) NOT NULL DEFAULT 0,
    missing_records_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    unexpected_records_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    value_differences_json NVARCHAR(MAX) NOT NULL DEFAULT N'[]',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_reconciliation_run FOREIGN KEY (run_id) REFERENCES dbo.database_migration_run(id),
    CONSTRAINT ck_reconciliation_missing_json CHECK (ISJSON(missing_records_json) = 1),
    CONSTRAINT ck_reconciliation_unexpected_json CHECK (ISJSON(unexpected_records_json) = 1),
    CONSTRAINT ck_reconciliation_values_json CHECK (ISJSON(value_differences_json) = 1)
);

-- 采购后台补充表：用于采购订单、采购在途和入库追踪。
CREATE TABLE dbo.supplier (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    supplier_code NVARCHAR(80) NOT NULL UNIQUE,
    name NVARCHAR(160) NOT NULL,
    contact_person NVARCHAR(80) NULL,
    phone NVARCHAR(30) NULL,
    email NVARCHAR(120) NULL,
    address NVARCHAR(MAX) NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'active',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT ck_supplier_status CHECK (status IN (N'active', N'disabled'))
);

CREATE TABLE dbo.purchase_order (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_no NVARCHAR(120) NOT NULL UNIQUE,
    supplier_id BIGINT NOT NULL,
    shop_id INT NULL,
    warehouse_id INT NOT NULL,
    status NVARCHAR(20) NOT NULL DEFAULT N'draft',
    order_date DATE NOT NULL,
    expected_arrival_date DATE NULL,
    received_at DATETIME2 NULL,
    currency NVARCHAR(10) NOT NULL DEFAULT N'CNY',
    total_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    created_by INT NULL,
    memo NVARCHAR(MAX) NULL,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_purchase_order_supplier FOREIGN KEY (supplier_id) REFERENCES dbo.supplier(id),
    CONSTRAINT fk_purchase_order_shop FOREIGN KEY (shop_id) REFERENCES dbo.sys_shop(id),
    CONSTRAINT fk_purchase_order_warehouse FOREIGN KEY (warehouse_id) REFERENCES dbo.sys_warehouse(id),
    CONSTRAINT fk_purchase_order_user FOREIGN KEY (created_by) REFERENCES dbo.sys_user(id),
    CONSTRAINT ck_purchase_order_status CHECK (status IN (N'draft', N'approved', N'in_transit', N'received', N'cancelled')),
    CONSTRAINT ck_purchase_order_amount CHECK (total_amount >= 0)
);

CREATE TABLE dbo.purchase_order_line (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    order_id BIGINT NOT NULL,
    line_no INT NOT NULL,
    product_id BIGINT NOT NULL,
    variant_id BIGINT NULL,
    ordered_quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    received_quantity DECIMAL(18,4) NOT NULL DEFAULT 0,
    unit_price DECIMAL(18,2) NOT NULL DEFAULT 0,
    amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    source_line_key NVARCHAR(150) NULL,
    metadata_json NVARCHAR(MAX) NOT NULL DEFAULT N'{}',
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT fk_purchase_line_order FOREIGN KEY (order_id) REFERENCES dbo.purchase_order(id),
    CONSTRAINT fk_purchase_line_product FOREIGN KEY (product_id) REFERENCES dbo.sys_product(id),
    CONSTRAINT fk_purchase_line_variant FOREIGN KEY (variant_id) REFERENCES dbo.sys_product_variant(id),
    CONSTRAINT uq_purchase_line_no UNIQUE (order_id, line_no),
    CONSTRAINT ck_purchase_line_quantity CHECK (ordered_quantity >= 0 AND received_quantity >= 0),
    CONSTRAINT ck_purchase_line_amount CHECK (unit_price >= 0 AND amount >= 0),
    CONSTRAINT ck_purchase_line_metadata_json CHECK (ISJSON(metadata_json) = 1)
);

CREATE INDEX ix_purchase_order_supplier_status ON dbo.purchase_order (supplier_id, status);
CREATE INDEX ix_purchase_order_line_product ON dbo.purchase_order_line (product_id, variant_id);
GO
