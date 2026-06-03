from rest_framework import serializers

from . import models


class DefaultModelSerializer(serializers.ModelSerializer):
    class Meta:
        fields = "__all__"


def serializer_for(model_class):
    meta = type("Meta", (), {"model": model_class, "fields": "__all__"})
    return type(f"{model_class.__name__}Serializer", (serializers.ModelSerializer,), {"Meta": meta})


SalesPlatformSerializer = serializer_for(models.SalesPlatform)
OperationTeamSerializer = serializer_for(models.OperationTeam)
ShopSerializer = serializer_for(models.Shop)
ShopAssignmentSerializer = serializer_for(models.ShopAssignment)
CustomerSerializer = serializer_for(models.Customer)
ProductSerializer = serializer_for(models.Product)
ProductVariantSerializer = serializer_for(models.ProductVariant)
WarehouseSerializer = serializer_for(models.Warehouse)
SupplierSerializer = serializer_for(models.Supplier)
PurchaseOrderSerializer = serializer_for(models.PurchaseOrder)
PurchaseOrderLineSerializer = serializer_for(models.PurchaseOrderLine)
InventoryDocumentSerializer = serializer_for(models.InventoryDocument)
InventoryDocumentLineSerializer = serializer_for(models.InventoryDocumentLine)
InventoryLedgerSerializer = serializer_for(models.InventoryLedger)
InventoryBalanceSerializer = serializer_for(models.InventoryBalance)
SalesDocumentSerializer = serializer_for(models.SalesDocument)
SalesDocumentLineSerializer = serializer_for(models.SalesDocumentLine)
SalesLedgerEntrySerializer = serializer_for(models.SalesLedgerEntry)
MetricDefinitionSerializer = serializer_for(models.MetricDefinition)
ReportQueryModelSerializer = serializer_for(models.ReportQueryModel)
ReportQueryFieldSerializer = serializer_for(models.ReportQueryField)
ReportQuerySnapshotSerializer = serializer_for(models.ReportQuerySnapshot)
