export const roleOptions = [
  { label: '管理员', value: 'admin' },
  { label: '商品运营', value: 'product_operator' },
  { label: '库存人员', value: 'inventory_staff' },
  { label: '销售人员', value: 'sales_staff' },
  { label: '财务人员', value: 'finance_staff' },
  { label: '审计人员', value: 'auditor' },
];

export const dataScopeOptions = [
  { label: '全部数据', value: 'all' },
  { label: '运营组数据', value: 'operation_group' },
  { label: '店铺数据', value: 'shop' },
  { label: '本人数据', value: 'self' },
  { label: '自定义数据', value: 'custom' },
];

export const activeStatusOptions = [
  { label: '启用', value: 'active' },
  { label: '停用', value: 'disabled' },
];

export const accountStatusOptions = [
  ...activeStatusOptions,
  { label: '锁定', value: 'locked' },
];

export const documentStatusOptions = [
  { label: '草稿', value: 'draft' },
  { label: '已过账', value: 'posted' },
  { label: '已取消', value: 'cancelled' },
];

export const purchaseStatusOptions = [
  { label: '草稿', value: 'draft' },
  { label: '已审核', value: 'approved' },
  { label: '在途', value: 'in_transit' },
  { label: '已入库', value: 'received' },
  { label: '已取消', value: 'cancelled' },
];

export const yesNoOptions = [
  { label: '是', value: true },
  { label: '否', value: false },
];

const commonTimeFields = [
  { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' },
  { name: 'updated_at', label: '更新时间', readOnly: true, type: 'datetime' },
];

const id = { name: 'id', label: 'ID', readOnly: true, width: 76 };
const active = { name: 'is_active', label: '启用', type: 'boolean', options: yesNoOptions, width: 90 };
const status = (options = activeStatusOptions) => ({ name: 'status', label: '状态', type: 'select', options, width: 100 });
const text = (name, label, extra = {}) => ({ name, label, ...extra });
const number = (name, label, extra = {}) => ({ name, label, type: 'number', ...extra });
const money = (name, label, extra = {}) => ({ name, label, type: 'number', precision: 2, ...extra });
const date = (name, label, extra = {}) => ({ name, label, type: 'date', ...extra });
const datetime = (name, label, extra = {}) => ({ name, label, type: 'datetime', ...extra });
const foreign = (name, label, resource, extra = {}) => ({ name, label, type: 'foreign', resource, ...extra });

export const resources = [
  {
    key: 'users',
    group: '认证与权限',
    label: '用户管理',
    path: '/api/auth/users/',
    note: '管理登录账号、角色、数据范围与权限组。',
    fields: [
      id,
      text('username', '用户名', { required: true, width: 140 }),
      text('password', '密码', { type: 'password', createOnly: false, hideInTable: true }),
      text('email', '邮箱', { type: 'email', width: 190 }),
      text('first_name', '名', { width: 100 }),
      text('last_name', '姓', { width: 100 }),
      text('phone', '手机', { width: 130 }),
      { name: 'role', label: '角色', type: 'select', options: roleOptions, width: 120, required: true },
      { name: 'data_scope', label: '数据范围', type: 'select', options: dataScopeOptions, width: 120 },
      status(accountStatusOptions),
      { name: 'is_active', label: 'Django启用', type: 'boolean', width: 110 },
      { name: 'is_staff', label: '后台权限', type: 'boolean', width: 100 },
      { name: 'permission_groups', label: '权限组', type: 'foreign-multiple', resource: 'permissionGroups', hideInTable: true },
      { name: 'date_joined', label: '加入时间', readOnly: true, type: 'datetime' },
      ...commonTimeFields,
    ],
  },
  {
    key: 'permissionCodes',
    group: '认证与权限',
    label: '权限码',
    path: '/api/auth/permission-codes/',
    note: '维护系统操作权限编码。',
    fields: [id, text('code', '权限编码', { required: true, width: 180 }), text('name', '权限名称', { required: true, width: 160 }), text('description', '说明', { type: 'textarea', width: 260 }), active, ...commonTimeFields],
  },
  {
    key: 'permissionGroups',
    group: '认证与权限',
    label: '权限组',
    path: '/api/auth/permission-groups/',
    note: '维护权限组合和默认数据范围。',
    fields: [id, text('code', '编码', { required: true, width: 140 }), text('name', '名称', { required: true, width: 150 }), text('description', '说明', { type: 'textarea', width: 240 }), { name: 'permissions', label: '权限码', type: 'foreign-multiple', resource: 'permissionCodes', hideInTable: true }, { name: 'data_scope', label: '默认数据范围', type: 'select', options: dataScopeOptions, width: 130 }, active, ...commonTimeFields],
  },
  {
    key: 'salesPlatforms',
    group: '组织与店铺',
    label: '销售平台',
    path: '/api/operations/sales-platforms/',
    note: '维护 Shopify、Amazon 等外贸平台。',
    fields: [id, text('code', '平台编码', { required: true, width: 150 }), text('name', '平台名称', { required: true, width: 180 }), active, ...commonTimeFields],
  },
  {
    key: 'operationTeams',
    group: '组织与店铺',
    label: '运营组',
    path: '/api/operations/operation-teams/',
    note: '维护运营团队和分工。',
    fields: [id, text('code', '运营组编码', { required: true, width: 150 }), text('name', '运营组名称', { required: true, width: 180 }), active, ...commonTimeFields],
  },
  {
    key: 'shops',
    group: '组织与店铺',
    label: '店铺',
    path: '/api/operations/shops/',
    note: '维护平台店铺、负责人和销售类型。',
    fields: [id, text('name', '店铺名称', { required: true, width: 200 }), foreign('platform', '销售平台', 'salesPlatforms'), text('shop_url', '店铺地址', { type: 'url', width: 220 }), text('owner', '负责人', { width: 110 }), text('contact_phone', '联系电话', { width: 130 }), status(activeStatusOptions), { name: 'sales_type', label: '销售类型', type: 'select', options: [{ label: '零售', value: 'retail' }, { label: '批发', value: 'wholesale' }], width: 110 }, text('remark', '备注', { type: 'textarea', width: 220 }), ...commonTimeFields],
  },
  {
    key: 'shopAssignments',
    group: '组织与店铺',
    label: '店铺分配',
    path: '/api/operations/shop-assignments/',
    note: '维护店铺、运营组和用户之间的分工。',
    fields: [id, foreign('shop', '店铺', 'shops', { required: true }), foreign('operation_team', '运营组', 'operationTeams', { required: true }), foreign('user', '用户', 'users', { required: true }), text('assignment_role', '分工角色', { width: 120 }), datetime('effective_from', '生效时间', { readOnly: true }), datetime('effective_to', '失效时间'), active, ...commonTimeFields],
  },
  {
    key: 'customers',
    group: '主数据',
    label: '客户',
    path: '/api/operations/customers/',
    note: '维护客户资料、等级和授信余额。',
    fields: [id, text('customer_code', '客户编码', { required: true, width: 150 }), text('name', '客户名称', { required: true, width: 190 }), text('contact_person', '联系人', { width: 110 }), text('phone', '电话', { width: 130 }), text('email', '邮箱', { type: 'email', width: 180 }), text('address', '地址', { type: 'textarea', width: 220 }), text('customer_type', '客户类型', { width: 110 }), number('level', '等级', { width: 80 }), status(activeStatusOptions), money('credit_limit', '信用额度', { width: 120 }), money('current_balance', '当前余额', { width: 120 }), ...commonTimeFields],
  },
  {
    key: 'suppliers',
    group: '主数据',
    label: '供应商',
    path: '/api/operations/suppliers/',
    note: '维护采购供应商资料。',
    fields: [id, text('supplier_code', '供应商编码', { required: true, width: 150 }), text('name', '供应商名称', { required: true, width: 190 }), text('contact_person', '联系人', { width: 110 }), text('phone', '电话', { width: 130 }), text('email', '邮箱', { type: 'email', width: 180 }), text('address', '地址', { type: 'textarea', width: 220 }), status(activeStatusOptions), ...commonTimeFields],
  },
  {
    key: 'warehouses',
    group: '主数据',
    label: '仓库',
    path: '/api/operations/warehouses/',
    note: '维护仓库编码、类型和负责人。',
    fields: [id, text('code', '仓库编码', { width: 130 }), text('name', '仓库名称', { required: true, width: 170 }), text('warehouse_kind', '仓库类型', { width: 120 }), text('address', '地址', { type: 'textarea', width: 220 }), text('manager', '负责人', { width: 120 }), text('remark', '备注', { type: 'textarea', width: 220 }), ...commonTimeFields],
  },
  {
    key: 'products',
    group: '主数据',
    label: '商品',
    path: '/api/operations/products/',
    note: '维护商品货号、规格、分类和安全库存。',
    fields: [id, text('code', '货号', { required: true, width: 150 }), text('name', '商品名称', { required: true, width: 220 }), text('specification', '规格', { width: 130 }), text('unit', '单位', { width: 90 }), text('barcode', '条码', { width: 140 }), text('brand', '品牌', { width: 120 }), text('year', '年份', { width: 90 }), text('season', '季节', { width: 90 }), text('category', '分类', { width: 120 }), text('color', '颜色', { width: 100 }), number('safety_stock', '安全库存', { width: 110 }), status(activeStatusOptions), text('remark', '备注', { type: 'textarea', width: 220 }), ...commonTimeFields],
  },
  {
    key: 'productAttributeDefinitions',
    group: '主数据',
    label: '商品属性定义',
    path: '/api/operations/product-attribute-definitions/',
    note: '维护商品扩展属性。',
    fields: [id, text('code', '属性编码', { required: true, width: 150 }), text('name', '属性名称', { required: true, width: 160 }), { name: 'data_type', label: '数据类型', type: 'select', options: [{ label: '字符串', value: 'string' }, { label: '数字', value: 'number' }, { label: '日期', value: 'date' }], width: 110 }, active, ...commonTimeFields],
  },
  {
    key: 'productAttributeValues',
    group: '主数据',
    label: '商品属性值',
    path: '/api/operations/product-attribute-values/',
    note: '维护商品与扩展属性的取值。',
    fields: [id, foreign('product', '商品', 'products', { required: true }), foreign('attribute', '属性', 'productAttributeDefinitions', { required: true }), text('value_text', '属性值', { required: true, width: 180 }), { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' }],
  },
  {
    key: 'productVariants',
    group: '主数据',
    label: 'SKU',
    path: '/api/operations/product-variants/',
    note: '维护商品 SKU、尺码、颜色和默认变体。',
    fields: [id, foreign('product', '商品', 'products', { required: true }), text('variant_key', '变体键', { required: true, width: 190 }), text('sku_code', 'SKU', { width: 150 }), text('size', '尺码', { width: 90 }), text('color', '颜色', { width: 100 }), text('specification', '规格', { width: 130 }), text('barcode', '条码', { width: 140 }), { name: 'is_default', label: '默认', type: 'boolean', width: 80 }, active, ...commonTimeFields],
  },
  {
    key: 'purchaseOrders',
    group: '业务单据',
    label: '采购订单',
    path: '/api/operations/purchase-orders/',
    note: '管理采购订单、供应商、入库仓和到货状态。',
    fields: [id, text('order_no', '采购单号', { required: true, width: 170 }), foreign('supplier', '供应商', 'suppliers', { required: true }), foreign('shop', '关联店铺', 'shops'), foreign('warehouse', '入库仓库', 'warehouses', { required: true }), status(purchaseStatusOptions), date('order_date', '下单日期', { required: true }), date('expected_arrival_date', '预计到货'), datetime('received_at', '入库时间'), text('currency', '币种', { width: 90 }), money('total_amount', '总金额', { width: 120 }), foreign('created_by', '创建人', 'users'), text('memo', '备注', { type: 'textarea', width: 220 }), ...commonTimeFields],
  },
  {
    key: 'purchaseOrderLines',
    group: '业务单据',
    label: '采购明细',
    path: '/api/operations/purchase-order-lines/',
    note: '维护采购订单商品明细。',
    fields: [id, foreign('order', '采购订单', 'purchaseOrders', { required: true }), number('line_no', '行号', { required: true, width: 80 }), foreign('product', '商品', 'products', { required: true }), foreign('variant', 'SKU', 'productVariants'), number('ordered_quantity', '采购数量', { precision: 4, width: 120 }), number('received_quantity', '已收数量', { precision: 4, width: 120 }), money('unit_price', '采购单价', { width: 120 }), money('amount', '金额', { width: 120 }), { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' }],
  },
  {
    key: 'inventoryDocuments',
    group: '业务单据',
    label: '库存单据',
    path: '/api/operations/inventory-documents/',
    note: '管理入库、出库、退货、调拨等库存单据。',
    fields: [id, text('document_no', '库存单号', { required: true, width: 180 }), { name: 'document_type', label: '单据类型', type: 'select', options: [{ label: '入库', value: 'stock_in' }, { label: '出库', value: 'stock_out' }, { label: '退货', value: 'return' }, { label: '调拨', value: 'transfer' }, { label: '期初', value: 'opening_balance' }], width: 120, required: true }, status(documentStatusOptions), datetime('business_time', '业务时间', { required: true }), datetime('posted_at', '过账时间'), text('source_type', '来源类型', { width: 120 }), text('source_ref', '来源单号', { width: 160 }), foreign('created_by', '创建人', 'users'), text('memo', '备注', { type: 'textarea', width: 220 }), ...commonTimeFields],
  },
  {
    key: 'inventoryDocumentLines',
    group: '业务单据',
    label: '库存明细',
    path: '/api/operations/inventory-document-lines/',
    note: '维护库存单据的商品和数量变化。',
    fields: [id, foreign('document', '库存单据', 'inventoryDocuments', { required: true }), number('line_no', '行号', { required: true, width: 80 }), foreign('product', '商品', 'products', { required: true }), foreign('variant', 'SKU', 'productVariants'), foreign('warehouse', '仓库', 'warehouses', { required: true }), foreign('counterpart_warehouse', '对方仓库', 'warehouses'), text('quantity_bucket', '库存桶', { width: 110 }), number('delta_quantity', '变动数量', { width: 120 }), number('target_quantity', '目标数量', { width: 120 }), money('unit_cost', '单位成本', { width: 120 }), { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' }],
  },
  {
    key: 'inventoryLedgers',
    group: '业务单据',
    label: '库存流水',
    path: '/api/operations/inventory-ledgers/',
    note: '查看库存流水事件。',
    fields: [text('event_id', '事件ID', { required: true, width: 250 }), foreign('document_line', '库存明细', 'inventoryDocumentLines'), text('event_type', '事件类型', { width: 120 }), foreign('product', '商品', 'products', { required: true }), foreign('variant', 'SKU', 'productVariants'), foreign('warehouse', '仓库', 'warehouses', { required: true }), number('delta_quantity', '变动数量', { width: 120 }), datetime('biz_time', '业务时间', { required: true }), text('source_type', '来源类型', { width: 120 }), text('source_ref', '来源单号', { width: 160 }), text('idempotency_key', '幂等键', { required: true, width: 220 }), { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' }],
    primaryKey: 'event_id',
  },
  {
    key: 'inventoryBalances',
    group: '业务单据',
    label: '库存余额',
    path: '/api/operations/inventory-balances/',
    note: '查看和维护当前库存余额。',
    fields: [id, foreign('product', '商品', 'products', { required: true }), foreign('variant', 'SKU', 'productVariants'), foreign('warehouse', '仓库', 'warehouses', { required: true }), number('quantity', '当前库存', { width: 120 }), foreign('last_event', '最后流水', 'inventoryLedgers'), datetime('last_biz_time', '最后业务时间'), ...commonTimeFields],
  },
  {
    key: 'salesDocuments',
    group: '业务单据',
    label: '销售单据',
    path: '/api/operations/sales-documents/',
    note: '管理销售单、客户、店铺和交易金额。',
    fields: [id, text('document_no', '销售单号', { required: true, width: 180 }), text('document_type', '单据类型', { width: 110 }), status(documentStatusOptions), foreign('shop', '店铺', 'shops'), foreign('customer', '客户', 'customers'), datetime('transaction_time', '交易时间'), text('source_system', '来源系统', { width: 120 }), text('source_record_key', '来源记录', { width: 180 }), text('currency', '币种', { width: 90 }), money('total_amount', '总金额', { width: 120 }), foreign('created_by', '创建人', 'users'), text('memo', '备注', { type: 'textarea', width: 220 }), ...commonTimeFields],
  },
  {
    key: 'salesDocumentLines',
    group: '业务单据',
    label: '销售明细',
    path: '/api/operations/sales-document-lines/',
    note: '维护销售单据商品明细。',
    fields: [id, foreign('document', '销售单据', 'salesDocuments', { required: true }), number('line_no', '行号', { required: true, width: 80 }), foreign('product', '商品', 'products', { required: true }), foreign('variant', 'SKU', 'productVariants'), number('quantity', '数量', { precision: 4, width: 110 }), money('unit_price', '单价', { width: 110 }), money('amount', '金额', { width: 120 }), { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' }],
  },
  {
    key: 'salesLedgers',
    group: '业务单据',
    label: '销售流水',
    path: '/api/operations/sales-ledgers/',
    note: '查看销售流水事实数据。',
    fields: [id, foreign('document', '销售单据', 'salesDocuments', { required: true }), foreign('document_line', '销售明细', 'salesDocumentLines', { required: true }), text('entry_type', '流水类型', { width: 110 }), text('quantity_scope', '数量口径', { width: 110 }), text('entry_status', '流水状态', { width: 110 }), foreign('shop', '店铺', 'shops'), foreign('product', '商品', 'products', { required: true }), foreign('variant', 'SKU', 'productVariants'), number('quantity', '数量', { precision: 4, width: 110 }), money('amount', '金额', { width: 120 }), datetime('business_time', '业务时间', { required: true }), text('idempotency_key', '幂等键', { required: true, width: 220 }), { name: 'created_at', label: '创建时间', readOnly: true, type: 'datetime' }],
  },
  {
    key: 'metrics',
    group: '报表配置',
    label: '指标定义',
    path: '/api/operations/metrics/',
    note: '维护销售、库存、财务等指标定义。',
    fields: [id, text('metric_code', '指标编码', { required: true, width: 160 }), text('metric_name', '指标名称', { required: true, width: 160 }), text('metric_domain', '指标域', { width: 120 }), text('grain', '统计粒度', { width: 130 }), text('source_fact', '来源事实', { width: 150 }), text('owner', '负责人', { width: 110 }), text('status', '状态', { width: 100 }), text('description', '说明', { type: 'textarea', width: 240 }), ...commonTimeFields],
  },
  {
    key: 'reportQueryModels',
    group: '报表配置',
    label: '报表查询模型',
    path: '/api/operations/report-query-models/',
    note: '维护报表查询模型、粒度、缓存和权限。',
    fields: [id, text('query_code', '模型编码', { required: true, width: 170 }), text('query_name', '模型名称', { required: true, width: 180 }), text('report_domain', '报表域', { width: 120 }), text('source_fact', '主事实源', { width: 150 }), text('default_time_field', '默认时间字段', { width: 150 }), text('default_grain', '默认粒度', { width: 130 }), text('permission_code', '权限码', { width: 150 }), text('cache_policy', '缓存策略', { width: 120 }), active, foreign('created_by', '创建人', 'users'), ...commonTimeFields],
  },
  {
    key: 'reportQueryParameters',
    group: '报表配置',
    label: '查询参数',
    path: '/api/operations/report-query-parameters/',
    note: '维护报表查询参数。',
    fields: [id, foreign('query_model', '查询模型', 'reportQueryModels', { required: true }), text('param_key', '参数键', { required: true, width: 140 }), text('param_label', '参数名', { required: true, width: 140 }), text('data_type', '数据类型', { width: 110 }), text('default_value', '默认值', { width: 140 }), { name: 'is_required', label: '必填', type: 'boolean', width: 80 }, number('sort_order', '排序', { width: 90 })],
  },
  {
    key: 'reportQueryFields',
    group: '报表配置',
    label: '查询字段',
    path: '/api/operations/report-query-fields/',
    note: '维护报表字段、指标和表达式。',
    fields: [id, foreign('query_model', '查询模型', 'reportQueryModels', { required: true }), foreign('metric', '指标', 'metrics'), text('field_key', '字段键', { required: true, width: 140 }), text('field_label', '字段名', { required: true, width: 140 }), text('field_role', '字段角色', { width: 110 }), text('data_type', '数据类型', { width: 110 }), text('expression_text', '表达式', { type: 'textarea', width: 220 }), { name: 'is_required', label: '必填', type: 'boolean', width: 80 }, { name: 'is_visible', label: '显示', type: 'boolean', width: 80 }, number('sort_order', '排序', { width: 90 })],
  },
];

export const resourceMap = Object.fromEntries(resources.map((resource) => [resource.key, resource]));

export function getOptionLabel(options, value) {
  return options?.find((option) => option.value === value)?.label ?? value;
}

export function getRecordLabel(record) {
  if (!record) return '-';
  return record.name || record.username || record.code || record.order_no || record.document_no || record.query_name || record.metric_name || record.sku_code || record.variant_key || record.event_id || String(record.id);
}
