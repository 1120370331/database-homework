from django.conf import settings
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    class Role(models.TextChoices):
        ADMIN = "admin", "管理员"
        PRODUCT_OPERATOR = "product_operator", "商品运营"
        INVENTORY_STAFF = "inventory_staff", "库存人员"
        SALES_STAFF = "sales_staff", "销售人员"
        FINANCE_STAFF = "finance_staff", "财务人员"
        AUDITOR = "auditor", "审计人员"

    class DataScope(models.TextChoices):
        ALL = "all", "全部数据"
        OPERATION_GROUP = "operation_group", "运营组数据"
        SHOP = "shop", "店铺数据"
        SELF = "self", "本人数据"
        CUSTOM = "custom", "自定义数据"

    class Status(models.TextChoices):
        ACTIVE = "active", "启用"
        DISABLED = "disabled", "禁用"
        LOCKED = "locked", "锁定"

    role = models.CharField("角色", max_length=32, choices=Role.choices, default=Role.PRODUCT_OPERATOR)
    data_scope = models.CharField(
        "数据范围", max_length=32, choices=DataScope.choices, default=DataScope.SELF
    )
    status = models.CharField("账号状态", max_length=32, choices=Status.choices, default=Status.ACTIVE)
    phone = models.CharField("手机号", max_length=32, blank=True)
    permission_groups = models.ManyToManyField(
        "PermissionGroup",
        verbose_name="权限组",
        blank=True,
        related_name="users",
    )
    created_at = models.DateTimeField("创建时间", auto_now_add=True)
    updated_at = models.DateTimeField("更新时间", auto_now=True)

    class Meta:
        verbose_name = "用户"
        verbose_name_plural = "用户"

    @property
    def is_enabled(self):
        return self.is_active and self.status == self.Status.ACTIVE

    def get_permission_codes(self):
        if self.is_superuser:
            return ["*"]

        permissions = set(super().get_all_permissions())
        active_groups = self.permission_groups.filter(is_active=True)
        for group in active_groups:
            permissions.update(
                group.permissions.filter(is_active=True).values_list("code", flat=True)
            )
        return sorted(permissions)

    def has_permission(self, permission_code):
        if self.is_superuser:
            return True
        return permission_code in self.get_permission_codes()


class PermissionCode(models.Model):
    code = models.CharField("权限编码", max_length=100, unique=True)
    name = models.CharField("权限名称", max_length=128)
    description = models.TextField("说明", blank=True)
    is_active = models.BooleanField("是否启用", default=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)
    updated_at = models.DateTimeField("更新时间", auto_now=True)

    class Meta:
        verbose_name = "权限码"
        verbose_name_plural = "权限码"
        ordering = ["code"]

    def __str__(self):
        return self.name


class PermissionGroup(models.Model):
    code = models.CharField("编码", max_length=64, unique=True)
    name = models.CharField("名称", max_length=128)
    description = models.TextField("说明", blank=True)
    permissions = models.ManyToManyField(
        PermissionCode,
        verbose_name="权限码",
        blank=True,
        related_name="permission_groups",
    )
    data_scope = models.CharField(
        "默认数据范围",
        max_length=32,
        choices=User.DataScope.choices,
        default=User.DataScope.SELF,
    )
    is_active = models.BooleanField("是否启用", default=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)
    updated_at = models.DateTimeField("更新时间", auto_now=True)

    class Meta:
        verbose_name = "权限组"
        verbose_name_plural = "权限组"
        ordering = ["code"]

    def __str__(self):
        return self.name


class LoginAuditLog(models.Model):
    class Result(models.TextChoices):
        SUCCESS = "success", "成功"
        FAILED = "failed", "失败"
        LOGOUT = "logout", "登出"

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        verbose_name="用户",
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="login_audit_logs",
    )
    username = models.CharField("用户名", max_length=150)
    result = models.CharField("结果", max_length=16, choices=Result.choices)
    ip_address = models.GenericIPAddressField("IP 地址", null=True, blank=True)
    user_agent = models.TextField("User Agent", blank=True)
    message = models.CharField("说明", max_length=255, blank=True)
    created_at = models.DateTimeField("创建时间", auto_now_add=True)

    class Meta:
        verbose_name = "登录审计日志"
        verbose_name_plural = "登录审计日志"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.username} {self.result} {self.created_at:%Y-%m-%d %H:%M:%S}"
