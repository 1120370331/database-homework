from django.contrib import admin

from . import models


@admin.register(
    models.SalesPlatform,
    models.OperationTeam,
    models.Shop,
    models.ShopAssignment,
    models.Customer,
    models.Product,
    models.ProductAttributeDefinition,
    models.ProductAttributeValue,
    models.ProductVariant,
    models.Warehouse,
    models.Supplier,
    models.PurchaseOrder,
    models.PurchaseOrderLine,
    models.InventoryDocument,
    models.InventoryDocumentLine,
    models.InventoryLedger,
    models.InventoryBalance,
    models.SalesDocument,
    models.SalesDocumentLine,
    models.SalesLedgerEntry,
    models.MetricDefinition,
    models.ReportQueryModel,
    models.ReportQueryParameter,
    models.ReportQueryField,
)
class DefaultAdmin(admin.ModelAdmin):
    list_per_page = 30
