import django.contrib.auth.models
import django.contrib.auth.validators
import django.db.models.deletion
import django.utils.timezone
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    initial = True

    dependencies = [
        ("auth", "0012_alter_user_first_name_max_length"),
    ]

    operations = [
        migrations.CreateModel(
            name="PermissionGroup",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("code", models.CharField(max_length=64, unique=True, verbose_name="编码")),
                ("name", models.CharField(max_length=128, verbose_name="名称")),
                ("description", models.TextField(blank=True, verbose_name="说明")),
                ("permissions", models.JSONField(blank=True, default=list, verbose_name="权限标识列表")),
                (
                    "data_scope",
                    models.CharField(
                        choices=[
                            ("all", "全部数据"),
                            ("operation_group", "运营组数据"),
                            ("shop", "店铺数据"),
                            ("self", "本人数据"),
                            ("custom", "自定义数据"),
                        ],
                        default="self",
                        max_length=32,
                        verbose_name="默认数据范围",
                    ),
                ),
                ("is_active", models.BooleanField(default=True, verbose_name="是否启用")),
                ("created_at", models.DateTimeField(auto_now_add=True, verbose_name="创建时间")),
                ("updated_at", models.DateTimeField(auto_now=True, verbose_name="更新时间")),
            ],
            options={
                "verbose_name": "权限组",
                "verbose_name_plural": "权限组",
                "ordering": ["code"],
            },
        ),
        migrations.CreateModel(
            name="User",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("password", models.CharField(max_length=128, verbose_name="password")),
                ("last_login", models.DateTimeField(blank=True, null=True, verbose_name="last login")),
                ("is_superuser", models.BooleanField(default=False, help_text="Designates that this user has all permissions without explicitly assigning them.", verbose_name="superuser status")),
                ("username", models.CharField(error_messages={"unique": "A user with that username already exists."}, help_text="Required. 150 characters or fewer. Letters, digits and @/./+/-/_ only.", max_length=150, unique=True, validators=[django.contrib.auth.validators.UnicodeUsernameValidator()], verbose_name="username")),
                ("first_name", models.CharField(blank=True, max_length=150, verbose_name="first name")),
                ("last_name", models.CharField(blank=True, max_length=150, verbose_name="last name")),
                ("email", models.EmailField(blank=True, max_length=254, verbose_name="email address")),
                ("is_staff", models.BooleanField(default=False, help_text="Designates whether the user can log into this admin site.", verbose_name="staff status")),
                ("is_active", models.BooleanField(default=True, help_text="Designates whether this user should be treated as active. Unselect this instead of deleting accounts.", verbose_name="active")),
                ("date_joined", models.DateTimeField(default=django.utils.timezone.now, verbose_name="date joined")),
                (
                    "role",
                    models.CharField(
                        choices=[
                            ("admin", "管理员"),
                            ("product_operator", "商品运营"),
                            ("inventory_staff", "库存人员"),
                            ("sales_staff", "销售人员"),
                            ("finance_staff", "财务人员"),
                            ("auditor", "审计人员"),
                        ],
                        default="product_operator",
                        max_length=32,
                        verbose_name="角色",
                    ),
                ),
                (
                    "data_scope",
                    models.CharField(
                        choices=[
                            ("all", "全部数据"),
                            ("operation_group", "运营组数据"),
                            ("shop", "店铺数据"),
                            ("self", "本人数据"),
                            ("custom", "自定义数据"),
                        ],
                        default="self",
                        max_length=32,
                        verbose_name="数据范围",
                    ),
                ),
                (
                    "status",
                    models.CharField(
                        choices=[("active", "启用"), ("disabled", "禁用"), ("locked", "锁定")],
                        default="active",
                        max_length=32,
                        verbose_name="账号状态",
                    ),
                ),
                ("phone", models.CharField(blank=True, max_length=32, verbose_name="手机号")),
                ("created_at", models.DateTimeField(auto_now_add=True, verbose_name="创建时间")),
                ("updated_at", models.DateTimeField(auto_now=True, verbose_name="更新时间")),
                ("groups", models.ManyToManyField(blank=True, help_text="The groups this user belongs to. A user will get all permissions granted to each of their groups.", related_name="user_set", related_query_name="user", to="auth.group", verbose_name="groups")),
                ("permission_groups", models.ManyToManyField(blank=True, related_name="users", to="authentication.permissiongroup", verbose_name="权限组")),
                ("user_permissions", models.ManyToManyField(blank=True, help_text="Specific permissions for this user.", related_name="user_set", related_query_name="user", to="auth.permission", verbose_name="user permissions")),
            ],
            options={
                "verbose_name": "用户",
                "verbose_name_plural": "用户",
            },
            managers=[
                ("objects", django.contrib.auth.models.UserManager()),
            ],
        ),
        migrations.CreateModel(
            name="LoginAuditLog",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("username", models.CharField(max_length=150, verbose_name="用户名")),
                ("result", models.CharField(choices=[("success", "成功"), ("failed", "失败"), ("logout", "登出")], max_length=16, verbose_name="结果")),
                ("ip_address", models.GenericIPAddressField(blank=True, null=True, verbose_name="IP 地址")),
                ("user_agent", models.TextField(blank=True, verbose_name="User Agent")),
                ("message", models.CharField(blank=True, max_length=255, verbose_name="说明")),
                ("created_at", models.DateTimeField(auto_now_add=True, verbose_name="创建时间")),
                ("user", models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, related_name="login_audit_logs", to=settings.AUTH_USER_MODEL, verbose_name="用户")),
            ],
            options={
                "verbose_name": "登录审计日志",
                "verbose_name_plural": "登录审计日志",
                "ordering": ["-created_at"],
            },
        ),
    ]
