from django.conf import settings
from django.db import models


class TimeStampedModel(models.Model):
    created_at = models.DateTimeField("创建时间", auto_now_add=True)
    updated_at = models.DateTimeField("更新时间", auto_now=True)

    class Meta:
        abstract = True


class SalesPlatform(TimeStampedModel):
    code = models.CharField("平台编码", max_length=80, unique=True)
    name = models.CharField("平台名称", max_length=120)
    is_active = models.BooleanField("是否启用", default=True)

    class Meta:
        verbose_name = "销售平台"
        verbose_name_plural = "销售平台"
        ordering = ["code"]

    def __str__(self):
        return self.name


class OperationTeam(TimeStampedModel):
    code = models.CharField("运营组编码", max_length=80, unique=True)
    name = models.CharField("运营组名称", max_length=120)
    is_active = models.BooleanField("是否启用", default=True)

    class Meta:
        verbose_name = "运营组"
        verbose_name_plural = "运营组"
        ordering = ["code"]

    def __str__(self):
        return self.name


class Shop(TimeStampedModel):
    class Status(models.TextChoices):
        ACTIVE = "active", "启用"
        DISABLED = "disabled", "停用"

    class SalesType(models.TextChoices):
        RETAIL = "retail", "零售"
        WHOLESALE = "wholesale", "批发"

    name = models.CharField("店铺名称", max_length=255, unique=True)
    platform = models.ForeignKey(SalesPlatform, verbose_name="销售平台", null=True, blank=True, on_delete=models.SET_NULL)
    shop_url = models.URLField("店铺地址", max_length=500, blank=True)
    owner = models.CharField("负责人", max_length=80, blank=True)
    contact_phone = models.CharField("联系电话", max_length=30, blank=True)
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.ACTIVE)
    sales_type = models.CharField("销售类型", max_length=20, choices=SalesType.choices, default=SalesType.RETAIL)
    remark = models.TextField("备注", blank=True)

    class Meta:
        verbose_name = "店铺"
        verbose_name_plural = "店铺"
        ordering = ["id"]

    def __str__(self):
        return self.name


class ShopAssignment(TimeStampedModel):
    shop = models.ForeignKey(Shop, verbose_name="店铺", on_delete=models.CASCADE, related_name="assignments")
    operation_team = models.ForeignKey(OperationTeam, verbose_name="运营组", on_delete=models.CASCADE)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name="用户", on_delete=models.CASCADE)
    assignment_role = models.CharField("分工角色", max_length=30, default="owner")
    effective_from = models.DateTimeField("生效时间", auto_now_add=True)
    effective_to = models.DateTimeField("失效时间", null=True, blank=True)
    is_active = models.BooleanField("是否有效", default=True)

    class Meta:
        verbose_name = "店铺分配"
        verbose_name_plural = "店铺分配"
        unique_together = [("shop", "operation_team", "user", "assignment_role")]


class Customer(TimeStampedModel):
    class Status(models.TextChoices):
        ACTIVE = "active", "启用"
        DISABLED = "disabled", "停用"

    customer_code = models.CharField("客户编码", max_length=50, unique=True)
    name = models.CharField("客户名称", max_length=120)
    contact_person = models.CharField("联系人", max_length=80, blank=True)
    phone = models.CharField("电话", max_length=30, blank=True)
    email = models.EmailField("邮箱", blank=True)
    address = models.TextField("地址", blank=True)
    customer_type = models.CharField("客户类型", max_length=40, default="buyer")
    level = models.PositiveSmallIntegerField("客户等级", default=0)
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.ACTIVE)
    credit_limit = models.DecimalField("信用额度", max_digits=18, decimal_places=2, default=0)
    current_balance = models.DecimalField("当前余额", max_digits=18, decimal_places=2, default=0)

    class Meta:
        verbose_name = "客户"
        verbose_name_plural = "客户"
        ordering = ["customer_code"]

    def __str__(self):
        return self.name


class Product(TimeStampedModel):
    class Status(models.TextChoices):
        ACTIVE = "active", "启用"
        DISABLED = "disabled", "停用"

    code = models.CharField("货号", max_length=100, unique=True)
    name = models.CharField("商品名称", max_length=255)
    specification = models.CharField("规格", max_length=255, blank=True)
    unit = models.CharField("单位", max_length=100, default="件")
    barcode = models.CharField("条码", max_length=100, blank=True)
    brand = models.CharField("品牌", max_length=80, default="外贸通")
    year = models.CharField("年份", max_length=10, blank=True)
    season = models.CharField("季节", max_length=20, blank=True)
    category = models.CharField("分类", max_length=100, blank=True)
    color = models.CharField("颜色", max_length=100, blank=True)
    safety_stock = models.IntegerField("安全库存", null=True, blank=True)
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.ACTIVE)
    remark = models.TextField("备注", blank=True)

    class Meta:
        verbose_name = "商品"
        verbose_name_plural = "商品"
        ordering = ["code"]

    def __str__(self):
        return f"{self.code} {self.name}"


class ProductAttributeDefinition(TimeStampedModel):
    code = models.CharField("属性编码", max_length=100, unique=True)
    name = models.CharField("属性名称", max_length=120)
    data_type = models.CharField("数据类型", max_length=30, default="string")
    is_active = models.BooleanField("是否启用", default=True)

    class Meta:
        verbose_name = "商品扩展属性定义"
        verbose_name_plural = "商品扩展属性定义"
        ordering = ["code"]

    def __str__(self):
        return self.name


class ProductAttributeValue(models.Model):
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.CASCADE, related_name="attribute_values")
    attribute = models.ForeignKey(ProductAttributeDefinition, verbose_name="属性", on_delete=models.CASCADE)
    value_text = models.CharField("属性值", max_length=255)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "商品扩展属性值"
        verbose_name_plural = "商品扩展属性值"
        unique_together = [("product", "attribute")]
        ordering = ["product_id", "attribute_id"]


class ProductVariant(TimeStampedModel):
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.CASCADE, related_name="variants")
    variant_key = models.CharField("变体键", max_length=160)
    sku_code = models.CharField("SKU", max_length=120, unique=True, null=True, blank=True)
    size = models.CharField("尺码", max_length=50, blank=True)
    color = models.CharField("颜色", max_length=100, blank=True)
    specification = models.CharField("规格", max_length=255, blank=True)
    barcode = models.CharField("条码", max_length=100, blank=True)
    is_default = models.BooleanField("默认变体", default=False)
    is_active = models.BooleanField("是否启用", default=True)

    class Meta:
        verbose_name = "商品变体"
        verbose_name_plural = "商品变体"
        unique_together = [("product", "variant_key")]
        ordering = ["product_id", "variant_key"]

    def __str__(self):
        return self.sku_code or self.variant_key


class Warehouse(TimeStampedModel):
    code = models.CharField("仓库编码", max_length=100, unique=True, null=True, blank=True)
    name = models.CharField("仓库名称", max_length=100)
    warehouse_kind = models.CharField("仓库类型", max_length=20, default="standard")
    address = models.TextField("地址", blank=True)
    manager = models.CharField("负责人", max_length=120, blank=True)
    remark = models.TextField("备注", blank=True)

    class Meta:
        verbose_name = "仓库"
        verbose_name_plural = "仓库"
        ordering = ["code", "id"]

    def __str__(self):
        return self.name


class Supplier(TimeStampedModel):
    class Status(models.TextChoices):
        ACTIVE = "active", "启用"
        DISABLED = "disabled", "停用"

    supplier_code = models.CharField("供应商编码", max_length=80, unique=True)
    name = models.CharField("供应商名称", max_length=160)
    contact_person = models.CharField("联系人", max_length=80, blank=True)
    phone = models.CharField("电话", max_length=30, blank=True)
    email = models.EmailField("邮箱", blank=True)
    address = models.TextField("地址", blank=True)
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.ACTIVE)

    class Meta:
        verbose_name = "供应商"
        verbose_name_plural = "供应商"
        ordering = ["supplier_code"]

    def __str__(self):
        return self.name


class PurchaseOrder(TimeStampedModel):
    class Status(models.TextChoices):
        DRAFT = "draft", "草稿"
        APPROVED = "approved", "已审核"
        IN_TRANSIT = "in_transit", "在途"
        RECEIVED = "received", "已入库"
        CANCELLED = "cancelled", "已取消"

    order_no = models.CharField("采购单号", max_length=120, unique=True)
    supplier = models.ForeignKey(Supplier, verbose_name="供应商", on_delete=models.PROTECT)
    shop = models.ForeignKey(Shop, verbose_name="关联店铺", null=True, blank=True, on_delete=models.SET_NULL)
    warehouse = models.ForeignKey(Warehouse, verbose_name="入库仓库", on_delete=models.PROTECT)
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.DRAFT)
    order_date = models.DateField("下单日期")
    expected_arrival_date = models.DateField("预计到货日期", null=True, blank=True)
    received_at = models.DateTimeField("入库时间", null=True, blank=True)
    currency = models.CharField("币种", max_length=10, default="CNY")
    total_amount = models.DecimalField("总金额", max_digits=18, decimal_places=2, default=0)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name="创建人", null=True, blank=True, on_delete=models.SET_NULL)
    memo = models.TextField("备注", blank=True)

    class Meta:
        verbose_name = "采购订单"
        verbose_name_plural = "采购订单"
        ordering = ["-order_date", "-id"]

    def __str__(self):
        return self.order_no


class PurchaseOrderLine(models.Model):
    order = models.ForeignKey(PurchaseOrder, verbose_name="采购订单", on_delete=models.CASCADE, related_name="lines")
    line_no = models.PositiveIntegerField("行号")
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.PROTECT)
    variant = models.ForeignKey(ProductVariant, verbose_name="SKU", null=True, blank=True, on_delete=models.PROTECT)
    ordered_quantity = models.DecimalField("采购数量", max_digits=18, decimal_places=4, default=0)
    received_quantity = models.DecimalField("已收数量", max_digits=18, decimal_places=4, default=0)
    unit_price = models.DecimalField("采购单价", max_digits=18, decimal_places=2, default=0)
    amount = models.DecimalField("金额", max_digits=18, decimal_places=2, default=0)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "采购订单明细"
        verbose_name_plural = "采购订单明细"
        unique_together = [("order", "line_no")]
        ordering = ["order_id", "line_no"]


class InventoryDocument(TimeStampedModel):
    class DocumentType(models.TextChoices):
        STOCK_IN = "stock_in", "入库"
        STOCK_OUT = "stock_out", "出库"
        RETURN = "return", "退货"
        TRANSFER = "transfer", "调拨"
        OPENING_BALANCE = "opening_balance", "期初"

    class Status(models.TextChoices):
        DRAFT = "draft", "草稿"
        POSTED = "posted", "已过账"
        CANCELLED = "cancelled", "已取消"

    document_no = models.CharField("库存单号", max_length=120, unique=True)
    document_type = models.CharField("单据类型", max_length=30, choices=DocumentType.choices)
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.DRAFT)
    business_time = models.DateTimeField("业务时间")
    posted_at = models.DateTimeField("过账时间", null=True, blank=True)
    source_type = models.CharField("来源类型", max_length=80, blank=True)
    source_ref = models.CharField("来源单号", max_length=120, blank=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name="创建人", null=True, blank=True, on_delete=models.SET_NULL)
    memo = models.TextField("备注", blank=True)

    class Meta:
        verbose_name = "库存单据"
        verbose_name_plural = "库存单据"
        ordering = ["-business_time", "-id"]

    def __str__(self):
        return self.document_no


class InventoryDocumentLine(models.Model):
    document = models.ForeignKey(InventoryDocument, verbose_name="库存单据", on_delete=models.CASCADE, related_name="lines")
    line_no = models.PositiveIntegerField("行号")
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.PROTECT)
    variant = models.ForeignKey(ProductVariant, verbose_name="SKU", null=True, blank=True, on_delete=models.PROTECT)
    warehouse = models.ForeignKey(Warehouse, verbose_name="仓库", on_delete=models.PROTECT, related_name="inventory_lines")
    counterpart_warehouse = models.ForeignKey(Warehouse, verbose_name="对方仓库", null=True, blank=True, on_delete=models.PROTECT, related_name="counterpart_inventory_lines")
    quantity_bucket = models.CharField("库存桶", max_length=40, default="on_hand")
    delta_quantity = models.BigIntegerField("变动数量", default=0)
    target_quantity = models.BigIntegerField("目标数量", null=True, blank=True)
    unit_cost = models.DecimalField("单位成本", max_digits=18, decimal_places=2, null=True, blank=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "库存单据明细"
        verbose_name_plural = "库存单据明细"
        unique_together = [("document", "line_no")]
        ordering = ["document_id", "line_no"]


class InventoryLedger(models.Model):
    event_id = models.CharField("流水事件ID", max_length=64, primary_key=True)
    document_line = models.ForeignKey(InventoryDocumentLine, verbose_name="库存单据行", null=True, blank=True, on_delete=models.SET_NULL)
    event_type = models.CharField("事件类型", max_length=32)
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.PROTECT)
    variant = models.ForeignKey(ProductVariant, verbose_name="SKU", null=True, blank=True, on_delete=models.PROTECT)
    warehouse = models.ForeignKey(Warehouse, verbose_name="仓库", on_delete=models.PROTECT)
    delta_quantity = models.BigIntegerField("变动数量", default=0)
    biz_time = models.DateTimeField("业务时间")
    source_type = models.CharField("来源类型", max_length=64, blank=True)
    source_ref = models.CharField("来源单号", max_length=128, blank=True)
    idempotency_key = models.CharField("幂等键", max_length=128, unique=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "库存流水"
        verbose_name_plural = "库存流水"
        ordering = ["-biz_time"]


class InventoryBalance(TimeStampedModel):
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.CASCADE)
    variant = models.ForeignKey(ProductVariant, verbose_name="SKU", null=True, blank=True, on_delete=models.CASCADE)
    warehouse = models.ForeignKey(Warehouse, verbose_name="仓库", on_delete=models.CASCADE)
    quantity = models.BigIntegerField("当前库存", default=0)
    last_event = models.ForeignKey(InventoryLedger, verbose_name="最后流水", null=True, blank=True, on_delete=models.SET_NULL)
    last_biz_time = models.DateTimeField("最后业务时间", null=True, blank=True)

    class Meta:
        verbose_name = "当前库存余额"
        verbose_name_plural = "当前库存余额"
        unique_together = [("product", "variant", "warehouse")]


class SalesDocument(TimeStampedModel):
    class Status(models.TextChoices):
        DRAFT = "draft", "草稿"
        POSTED = "posted", "已过账"
        CANCELLED = "cancelled", "已取消"

    document_no = models.CharField("销售单号", max_length=120, unique=True)
    document_type = models.CharField("单据类型", max_length=30, default="sale")
    status = models.CharField("状态", max_length=20, choices=Status.choices, default=Status.DRAFT)
    shop = models.ForeignKey(Shop, verbose_name="店铺", null=True, blank=True, on_delete=models.SET_NULL)
    customer = models.ForeignKey(Customer, verbose_name="客户", null=True, blank=True, on_delete=models.SET_NULL)
    transaction_time = models.DateTimeField("交易时间", null=True, blank=True)
    source_system = models.CharField("来源系统", max_length=80, blank=True)
    source_record_key = models.CharField("来源记录", max_length=255, blank=True)
    currency = models.CharField("币种", max_length=10, default="CNY")
    total_amount = models.DecimalField("总金额", max_digits=18, decimal_places=2, default=0)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name="创建人", null=True, blank=True, on_delete=models.SET_NULL)
    memo = models.TextField("备注", blank=True)

    class Meta:
        verbose_name = "销售单据"
        verbose_name_plural = "销售单据"
        ordering = ["-transaction_time", "-id"]

    def __str__(self):
        return self.document_no


class SalesDocumentLine(models.Model):
    document = models.ForeignKey(SalesDocument, verbose_name="销售单据", on_delete=models.CASCADE, related_name="lines")
    line_no = models.PositiveIntegerField("行号")
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.PROTECT)
    variant = models.ForeignKey(ProductVariant, verbose_name="SKU", null=True, blank=True, on_delete=models.PROTECT)
    quantity = models.DecimalField("数量", max_digits=18, decimal_places=4, default=0)
    unit_price = models.DecimalField("单价", max_digits=18, decimal_places=2, default=0)
    amount = models.DecimalField("金额", max_digits=18, decimal_places=2, default=0)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "销售单据明细"
        verbose_name_plural = "销售单据明细"
        unique_together = [("document", "line_no")]
        ordering = ["document_id", "line_no"]


class SalesLedgerEntry(models.Model):
    document = models.ForeignKey(SalesDocument, verbose_name="销售单据", on_delete=models.CASCADE)
    document_line = models.ForeignKey(SalesDocumentLine, verbose_name="销售明细", on_delete=models.CASCADE)
    entry_type = models.CharField("流水类型", max_length=30, default="sale")
    quantity_scope = models.CharField("数量口径", max_length=30, default="deal")
    entry_status = models.CharField("流水状态", max_length=20, default="posted")
    shop = models.ForeignKey(Shop, verbose_name="店铺", null=True, blank=True, on_delete=models.SET_NULL)
    product = models.ForeignKey(Product, verbose_name="商品", on_delete=models.PROTECT)
    variant = models.ForeignKey(ProductVariant, verbose_name="SKU", null=True, blank=True, on_delete=models.PROTECT)
    quantity = models.DecimalField("数量", max_digits=18, decimal_places=4, default=0)
    amount = models.DecimalField("金额", max_digits=18, decimal_places=2, default=0)
    business_time = models.DateTimeField("业务时间")
    idempotency_key = models.CharField("幂等键", max_length=255, unique=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "销售流水"
        verbose_name_plural = "销售流水"
        ordering = ["-business_time"]


class MetricDefinition(TimeStampedModel):
    metric_code = models.CharField("指标编码", max_length=100, unique=True)
    metric_name = models.CharField("指标名称", max_length=120)
    metric_domain = models.CharField("指标域", max_length=80)
    grain = models.CharField("统计粒度", max_length=100)
    source_fact = models.CharField("来源事实", max_length=120)
    owner = models.CharField("负责人", max_length=100, blank=True)
    status = models.CharField("状态", max_length=20, default="active")
    description = models.TextField("说明", blank=True)

    class Meta:
        verbose_name = "指标定义"
        verbose_name_plural = "指标定义"
        ordering = ["metric_code"]


class ReportQueryModel(TimeStampedModel):
    query_code = models.CharField("查询模型编码", max_length=100, unique=True)
    query_name = models.CharField("查询模型名称", max_length=120)
    report_domain = models.CharField("报表域", max_length=80)
    source_fact = models.CharField("主事实源", max_length=120)
    default_time_field = models.CharField("默认时间字段", max_length=100)
    default_grain = models.CharField("默认粒度", max_length=100)
    permission_code = models.CharField("权限编码", max_length=100, blank=True)
    cache_policy = models.CharField("缓存策略", max_length=30, default="none")
    is_active = models.BooleanField("是否启用", default=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, verbose_name="创建人", null=True, blank=True, on_delete=models.SET_NULL)

    class Meta:
        verbose_name = "报表查询模型"
        verbose_name_plural = "报表查询模型"
        ordering = ["query_code"]

    def __str__(self):
        return self.query_name


class ReportQueryParameter(models.Model):
    query_model = models.ForeignKey(ReportQueryModel, verbose_name="查询模型", on_delete=models.CASCADE, related_name="parameters")
    param_key = models.CharField("参数键", max_length=100)
    param_label = models.CharField("参数名", max_length=120)
    data_type = models.CharField("数据类型", max_length=30, default="string")
    default_value = models.CharField("默认值", max_length=255, blank=True)
    is_required = models.BooleanField("是否必填", default=False)
    sort_order = models.IntegerField("排序", default=0)

    class Meta:
        verbose_name = "报表查询参数"
        verbose_name_plural = "报表查询参数"
        unique_together = [("query_model", "param_key")]
        ordering = ["query_model_id", "sort_order", "id"]


class ReportQueryField(models.Model):
    query_model = models.ForeignKey(ReportQueryModel, verbose_name="查询模型", on_delete=models.CASCADE, related_name="fields")
    metric = models.ForeignKey(MetricDefinition, verbose_name="指标", null=True, blank=True, on_delete=models.SET_NULL)
    field_key = models.CharField("字段键", max_length=100)
    field_label = models.CharField("字段名", max_length=120)
    field_role = models.CharField("字段角色", max_length=20)
    data_type = models.CharField("数据类型", max_length=30, default="string")
    expression_text = models.TextField("表达式", blank=True)
    is_required = models.BooleanField("是否必选", default=False)
    is_visible = models.BooleanField("是否显示", default=True)
    sort_order = models.IntegerField("排序", default=0)

    class Meta:
        verbose_name = "报表查询字段"
        verbose_name_plural = "报表查询字段"
        unique_together = [("query_model", "field_key")]
        ordering = ["query_model_id", "sort_order", "id"]
