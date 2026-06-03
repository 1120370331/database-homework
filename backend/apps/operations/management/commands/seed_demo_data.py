from datetime import date
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand
from django.utils import timezone

from apps.operations import models


class Command(BaseCommand):
    help = "写入外贸通课程作业演示数据"

    def handle(self, *args, **options):
        User = get_user_model()
        admin, created = User.objects.get_or_create(
            username="admin",
            defaults={
                "email": "admin@ftc.local",
                "role": "admin",
                "data_scope": "all",
                "status": "active",
                "is_staff": True,
                "is_superuser": True,
            },
        )
        if created:
            admin.set_password("admin123")
            admin.save(update_fields=["password"])

        platform, _ = models.SalesPlatform.objects.update_or_create(
            code="shopify",
            defaults={"name": "Shopify", "is_active": True},
        )
        team, _ = models.OperationTeam.objects.update_or_create(
            code="ops-a",
            defaults={"name": "运营一组", "is_active": True},
        )
        shop, _ = models.Shop.objects.update_or_create(
            name="外贸通香港店",
            defaults={
                "platform": platform,
                "shop_url": "https://hk.example.com",
                "owner": "陈炜嘉",
                "contact_phone": "13800000002",
                "status": "active",
                "sales_type": "retail",
            },
        )
        models.ShopAssignment.objects.update_or_create(
            shop=shop,
            operation_team=team,
            user=admin,
            assignment_role="owner",
            defaults={"is_active": True},
        )

        customer, _ = models.Customer.objects.update_or_create(
            customer_code="CUST-001",
            defaults={
                "name": "Hong Kong Retail Ltd.",
                "contact_person": "Lee",
                "phone": "852-0001",
                "email": "lee@example.hk",
                "address": "Hong Kong",
                "level": 2,
                "credit_limit": Decimal("50000.00"),
                "current_balance": Decimal("12800.00"),
            },
        )

        dress, _ = models.Product.objects.update_or_create(
            code="WT-DRESS-001",
            defaults={
                "name": "外贸女装连衣裙",
                "specification": "M/L/XL",
                "unit": "件",
                "barcode": "690000000001",
                "year": "2026",
                "season": "SS",
                "category": "服装",
                "color": "蓝色",
                "safety_stock": 20,
                "custom_fields": {"style": "dress"},
            },
        )
        shoes, _ = models.Product.objects.update_or_create(
            code="WT-SHOES-021",
            defaults={
                "name": "跨境运动鞋",
                "specification": "40-44",
                "unit": "双",
                "barcode": "690000000002",
                "year": "2026",
                "season": "SS",
                "category": "鞋履",
                "color": "白色",
                "safety_stock": 30,
                "custom_fields": {"style": "shoes"},
            },
        )
        dress_variant, _ = models.ProductVariant.objects.update_or_create(
            product=dress,
            variant_key="WT-DRESS-001-M-BLUE",
            defaults={"sku_code": "WT-DRESS-001-M", "size": "M", "color": "蓝色", "is_default": True},
        )
        shoes_variant, _ = models.ProductVariant.objects.update_or_create(
            product=shoes,
            variant_key="WT-SHOES-021-42-WHITE",
            defaults={"sku_code": "WT-SHOES-021-42", "size": "42", "color": "白色", "is_default": True},
        )

        gz_warehouse, _ = models.Warehouse.objects.update_or_create(
            code="GZ",
            defaults={"name": "广州仓", "warehouse_kind": "standard", "address": "广州白云区", "manager": "库存人员A"},
        )
        sz_warehouse, _ = models.Warehouse.objects.update_or_create(
            code="SZ",
            defaults={"name": "深圳仓", "warehouse_kind": "standard", "address": "深圳龙岗区", "manager": "库存人员B"},
        )

        supplier, _ = models.Supplier.objects.update_or_create(
            supplier_code="SUP-002",
            defaults={
                "name": "深圳鞋履供应商",
                "contact_person": "赵经理",
                "phone": "0755-0002",
                "email": "sz-supplier@example.com",
                "address": "深圳市龙岗区",
            },
        )
        purchase_order, _ = models.PurchaseOrder.objects.update_or_create(
            order_no="PO-20260603-001",
            defaults={
                "supplier": supplier,
                "shop": shop,
                "warehouse": sz_warehouse,
                "status": "in_transit",
                "order_date": date(2026, 6, 3),
                "expected_arrival_date": date(2026, 6, 10),
                "total_amount": Decimal("6000.00"),
                "created_by": admin,
                "memo": "跨境运动鞋补货在途",
            },
        )
        models.PurchaseOrderLine.objects.update_or_create(
            order=purchase_order,
            line_no=1,
            defaults={
                "product": shoes,
                "variant": shoes_variant,
                "ordered_quantity": Decimal("50.0000"),
                "received_quantity": Decimal("0.0000"),
                "unit_price": Decimal("120.00"),
                "amount": Decimal("6000.00"),
                "metadata": {"reason": "low_stock_replenishment"},
            },
        )

        now = timezone.now()
        inventory_document, _ = models.InventoryDocument.objects.update_or_create(
            document_no="INV-OUT-20260603-001",
            defaults={
                "document_type": "stock_out",
                "status": "posted",
                "business_time": now,
                "posted_at": now,
                "source_type": "sales",
                "source_ref": "SO-20260603-001",
                "created_by": admin,
                "memo": "销售出库",
            },
        )
        inventory_line, _ = models.InventoryDocumentLine.objects.update_or_create(
            document=inventory_document,
            line_no=1,
            defaults={
                "product": dress,
                "variant": dress_variant,
                "warehouse": gz_warehouse,
                "delta_quantity": -14,
                "unit_cost": Decimal("68.00"),
                "metadata": {"source": "sales"},
            },
        )
        inventory_event, _ = models.InventoryLedger.objects.update_or_create(
            event_id="11111111-1111-1111-1111-111111111111",
            defaults={
                "document_line": inventory_line,
                "event_type": "stock_out",
                "product": dress,
                "variant": dress_variant,
                "warehouse": gz_warehouse,
                "delta_quantity": -14,
                "snapshot_quantity": 86,
                "biz_time": now,
                "source_type": "sales",
                "source_ref": "SO-20260603-001",
                "idempotency_key": "inv-ledger-demo-001",
            },
        )
        models.InventoryBalance.objects.update_or_create(
            product=dress,
            variant=dress_variant,
            warehouse=gz_warehouse,
            defaults={"quantity": 86, "last_event": inventory_event, "last_biz_time": now},
        )

        sales_document, _ = models.SalesDocument.objects.update_or_create(
            document_no="SO-20260603-001",
            defaults={
                "document_type": "sale",
                "status": "posted",
                "shop": shop,
                "customer": customer,
                "customer_name_snapshot": customer.name,
                "transaction_time": now,
                "source_system": "manual",
                "source_record_key": "SO-DEMO-001",
                "total_amount": Decimal("2352.00"),
                "created_by": admin,
                "memo": "演示销售订单",
            },
        )
        sales_line, _ = models.SalesDocumentLine.objects.update_or_create(
            document=sales_document,
            line_no=1,
            defaults={
                "product": dress,
                "variant": dress_variant,
                "product_code_snapshot": dress.code,
                "sku_key_snapshot": dress_variant.sku_code or "",
                "quantity": Decimal("14.0000"),
                "unit_price": Decimal("168.00"),
                "amount": Decimal("2352.00"),
            },
        )
        models.SalesLedgerEntry.objects.update_or_create(
            idempotency_key="sales-ledger-demo-001",
            defaults={
                "document": sales_document,
                "document_line": sales_line,
                "entry_type": "sale",
                "quantity_scope": "deal",
                "entry_status": "posted",
                "shop": shop,
                "product": dress,
                "variant": dress_variant,
                "quantity": Decimal("14.0000"),
                "amount": Decimal("2352.00"),
                "business_time": now,
            },
        )

        metric, _ = models.MetricDefinition.objects.update_or_create(
            metric_code="sales_amount",
            defaults={
                "metric_name": "销售额",
                "metric_domain": "sales",
                "grain": "shop_day",
                "source_fact": "SalesLedgerEntry",
                "owner": "运营组",
                "status": "active",
                "description": "销售流水金额汇总",
            },
        )
        query_model, _ = models.ReportQueryModel.objects.update_or_create(
            query_code="sales_summary_query",
            defaults={
                "query_name": "销售汇总报表",
                "report_domain": "sales",
                "source_fact": "SalesLedgerEntry",
                "default_time_field": "business_time",
                "default_grain": "shop_day",
                "permission_code": "report.read",
                "cache_policy": "snapshot",
                "default_params": {"date_range": "last_7_days"},
                "created_by": admin,
            },
        )
        models.ReportQueryField.objects.update_or_create(
            query_model=query_model,
            field_key="sales_amount",
            defaults={
                "metric": metric,
                "field_label": "销售额",
                "field_role": "metric",
                "data_type": "decimal",
                "expression_text": "SUM(amount)",
                "sort_order": 10,
            },
        )
        models.ReportQuerySnapshot.objects.update_or_create(
            id=1,
            defaults={
                "query_model": query_model,
                "query_params": {"date": "2026-06-03", "shop_id": shop.id},
                "result": [{"shop": shop.name, "sales_amount": "2352.00"}],
                "metric_versions": [{"metric": "sales_amount", "version": "v1"}],
                "source_trace": {"source": ["sales_ledger_entry"]},
                "data_mode": "realtime",
                "snapshot_time": now,
                "created_by": admin,
            },
        )

        self.stdout.write(self.style.SUCCESS("外贸通 Django ORM 演示数据初始化完成"))
