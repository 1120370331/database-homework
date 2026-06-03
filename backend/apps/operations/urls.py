from django.urls import include, path
from rest_framework.routers import DefaultRouter

from . import views


router = DefaultRouter()
router.register("sales-platforms", views.SalesPlatformViewSet, basename="sales-platform")
router.register("operation-teams", views.OperationTeamViewSet, basename="operation-team")
router.register("shops", views.ShopViewSet, basename="shop")
router.register("shop-assignments", views.ShopAssignmentViewSet, basename="shop-assignment")
router.register("customers", views.CustomerViewSet, basename="customer")
router.register("products", views.ProductViewSet, basename="product")
router.register("product-variants", views.ProductVariantViewSet, basename="product-variant")
router.register("warehouses", views.WarehouseViewSet, basename="warehouse")
router.register("suppliers", views.SupplierViewSet, basename="supplier")
router.register("purchase-orders", views.PurchaseOrderViewSet, basename="purchase-order")
router.register("purchase-order-lines", views.PurchaseOrderLineViewSet, basename="purchase-order-line")
router.register("inventory-documents", views.InventoryDocumentViewSet, basename="inventory-document")
router.register("inventory-document-lines", views.InventoryDocumentLineViewSet, basename="inventory-document-line")
router.register("inventory-ledgers", views.InventoryLedgerViewSet, basename="inventory-ledger")
router.register("inventory-balances", views.InventoryBalanceViewSet, basename="inventory-balance")
router.register("sales-documents", views.SalesDocumentViewSet, basename="sales-document")
router.register("sales-document-lines", views.SalesDocumentLineViewSet, basename="sales-document-line")
router.register("sales-ledgers", views.SalesLedgerEntryViewSet, basename="sales-ledger")
router.register("metrics", views.MetricDefinitionViewSet, basename="metric")
router.register("report-query-models", views.ReportQueryModelViewSet, basename="report-query-model")
router.register("report-query-fields", views.ReportQueryFieldViewSet, basename="report-query-field")
router.register("report-query-snapshots", views.ReportQuerySnapshotViewSet, basename="report-query-snapshot")

urlpatterns = [
    path("", include(router.urls)),
]
