from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from .models import LoginAuditLog, PermissionGroup, User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    fieldsets = UserAdmin.fieldsets + (
        ("业务权限", {"fields": ("role", "data_scope", "status", "phone", "permission_groups")}),
    )
    list_display = ("id", "username", "email", "role", "data_scope", "status", "is_staff")
    list_filter = ("role", "data_scope", "status", "is_staff", "is_superuser")
    search_fields = ("username", "email", "phone")


@admin.register(PermissionGroup)
class PermissionGroupAdmin(admin.ModelAdmin):
    list_display = ("id", "code", "name", "data_scope", "is_active")
    list_filter = ("data_scope", "is_active")
    search_fields = ("code", "name")


@admin.register(LoginAuditLog)
class LoginAuditLogAdmin(admin.ModelAdmin):
    list_display = ("id", "username", "user", "result", "ip_address", "created_at")
    list_filter = ("result", "created_at")
    search_fields = ("username", "ip_address")
    readonly_fields = ("user", "username", "result", "ip_address", "user_agent", "message", "created_at")
