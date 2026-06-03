from django.db import models as django_models
from django.db.models import Q
from rest_framework import viewsets

from . import models, serializers


class BaseModelViewSet(viewsets.ModelViewSet):
    ordering = ["id"]
    ignored_query_params = {"format", "page", "page_size", "search", "ordering"}

    def get_queryset(self):
        queryset = super().get_queryset()
        queryset = self.apply_exact_filters(queryset)
        queryset = self.apply_search(queryset)
        queryset = self.apply_ordering(queryset)
        return queryset

    def apply_exact_filters(self, queryset):
        model_fields = self.get_model_fields()
        exact_filters = {}

        for key, value in self.request.query_params.items():
            if key in self.ignored_query_params or value == "":
                continue

            field_name = key[:-3] if key.endswith("_id") else key
            field = model_fields.get(field_name)
            if field is None:
                continue

            lookup_key = key if key.endswith("_id") else field_name
            exact_filters[lookup_key] = value

        if exact_filters:
            queryset = queryset.filter(**exact_filters)
        return queryset

    def apply_search(self, queryset):
        keyword = self.request.query_params.get("search", "").strip()
        if not keyword:
            return queryset

        search_query = Q()
        for field_name, field in self.get_model_fields().items():
            if isinstance(
                field,
                (
                    django_models.CharField,
                    django_models.TextField,
                    django_models.EmailField,
                    django_models.URLField,
                ),
            ):
                search_query |= Q(**{f"{field_name}__icontains": keyword})

        if search_query:
            queryset = queryset.filter(search_query)
        return queryset

    def apply_ordering(self, queryset):
        raw_ordering = self.request.query_params.get("ordering", "")
        if not raw_ordering:
            return queryset

        valid_fields = set(self.get_model_fields().keys())
        ordering = []
        for field_name in raw_ordering.split(","):
            field_name = field_name.strip()
            normalized = field_name.lstrip("-")
            if normalized in valid_fields:
                ordering.append(field_name)

        if ordering:
            queryset = queryset.order_by(*ordering)
        return queryset

    def get_model_fields(self):
        return {
            field.name: field
            for field in self.queryset.model._meta.fields
            if not isinstance(field, django_models.JSONField)
        }


def viewset_for(model_class, serializer_class):
    return type(
        f"{model_class.__name__}ViewSet",
        (BaseModelViewSet,),
        {
            "queryset": model_class.objects.all(),
            "serializer_class": serializer_class,
        },
    )


SalesPlatformViewSet = viewset_for(models.SalesPlatform, serializers.SalesPlatformSerializer)
OperationTeamViewSet = viewset_for(models.OperationTeam, serializers.OperationTeamSerializer)
ShopViewSet = viewset_for(models.Shop, serializers.ShopSerializer)
ShopAssignmentViewSet = viewset_for(models.ShopAssignment, serializers.ShopAssignmentSerializer)
CustomerViewSet = viewset_for(models.Customer, serializers.CustomerSerializer)
ProductViewSet = viewset_for(models.Product, serializers.ProductSerializer)
ProductVariantViewSet = viewset_for(models.ProductVariant, serializers.ProductVariantSerializer)
WarehouseViewSet = viewset_for(models.Warehouse, serializers.WarehouseSerializer)
SupplierViewSet = viewset_for(models.Supplier, serializers.SupplierSerializer)
PurchaseOrderViewSet = viewset_for(models.PurchaseOrder, serializers.PurchaseOrderSerializer)
PurchaseOrderLineViewSet = viewset_for(models.PurchaseOrderLine, serializers.PurchaseOrderLineSerializer)
InventoryDocumentViewSet = viewset_for(models.InventoryDocument, serializers.InventoryDocumentSerializer)
InventoryDocumentLineViewSet = viewset_for(models.InventoryDocumentLine, serializers.InventoryDocumentLineSerializer)
InventoryLedgerViewSet = viewset_for(models.InventoryLedger, serializers.InventoryLedgerSerializer)
InventoryBalanceViewSet = viewset_for(models.InventoryBalance, serializers.InventoryBalanceSerializer)
SalesDocumentViewSet = viewset_for(models.SalesDocument, serializers.SalesDocumentSerializer)
SalesDocumentLineViewSet = viewset_for(models.SalesDocumentLine, serializers.SalesDocumentLineSerializer)
SalesLedgerEntryViewSet = viewset_for(models.SalesLedgerEntry, serializers.SalesLedgerEntrySerializer)
MetricDefinitionViewSet = viewset_for(models.MetricDefinition, serializers.MetricDefinitionSerializer)
ReportQueryModelViewSet = viewset_for(models.ReportQueryModel, serializers.ReportQueryModelSerializer)
ReportQueryFieldViewSet = viewset_for(models.ReportQueryField, serializers.ReportQueryFieldSerializer)
ReportQuerySnapshotViewSet = viewset_for(models.ReportQuerySnapshot, serializers.ReportQuerySnapshotSerializer)
