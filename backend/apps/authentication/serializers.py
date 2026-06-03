from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.tokens import RefreshToken

from .models import LoginAuditLog, PermissionGroup, User


class PermissionGroupSerializer(serializers.ModelSerializer):
    class Meta:
        model = PermissionGroup
        fields = [
            "id",
            "code",
            "name",
            "description",
            "permissions",
            "data_scope",
            "is_active",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=False, allow_blank=False)
    permissions = serializers.SerializerMethodField()
    permission_groups_detail = PermissionGroupSerializer(
        source="permission_groups", many=True, read_only=True
    )

    class Meta:
        model = User
        fields = [
            "id",
            "username",
            "password",
            "email",
            "first_name",
            "last_name",
            "phone",
            "role",
            "data_scope",
            "status",
            "is_active",
            "is_staff",
            "date_joined",
            "created_at",
            "updated_at",
            "permissions",
            "permission_groups",
            "permission_groups_detail",
        ]
        read_only_fields = ["id", "date_joined", "created_at", "updated_at", "permissions"]
        extra_kwargs = {
            "permission_groups": {"required": False},
        }

    def get_permissions(self, obj):
        return obj.get_permission_codes()

    def create(self, validated_data):
        password = validated_data.pop("password", None)
        groups = validated_data.pop("permission_groups", [])
        user = User(**validated_data)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save()
        user.permission_groups.set(groups)
        return user

    def update(self, instance, validated_data):
        password = validated_data.pop("password", None)
        groups = validated_data.pop("permission_groups", None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if password:
            instance.set_password(password)
        instance.save()
        if groups is not None:
            instance.permission_groups.set(groups)
        return instance


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)

    class Meta:
        model = User
        fields = ["id", "username", "password", "email", "first_name", "last_name", "phone"]
        read_only_fields = ["id"]

    def validate_password(self, value):
        validate_password(value)
        return value

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, attrs):
        request = self.context.get("request")
        username = attrs["username"]
        password = attrs["password"]
        user = authenticate(request=request, username=username, password=password)

        if user is None:
            self._write_audit(username, LoginAuditLog.Result.FAILED, "用户名或密码错误")
            raise serializers.ValidationError({"detail": "用户名或密码错误"})
        if not user.is_enabled:
            self._write_audit(username, LoginAuditLog.Result.FAILED, "账号已被禁用或锁定", user)
            raise serializers.ValidationError({"detail": "账号已被禁用或锁定"})

        refresh = RefreshToken.for_user(user)
        self._write_audit(username, LoginAuditLog.Result.SUCCESS, "登录成功", user)
        return {
            "refresh": str(refresh),
            "access": str(refresh.access_token),
            "user": UserSerializer(user).data,
            "permissions": user.get_permission_codes(),
            "role": user.role,
            "data_scope": user.data_scope,
        }

    def _write_audit(self, username, result, message, user=None):
        request = self.context.get("request")
        LoginAuditLog.objects.create(
            user=user,
            username=username,
            result=result,
            ip_address=_get_client_ip(request),
            user_agent=request.META.get("HTTP_USER_AGENT", "") if request else "",
            message=message,
        )


class LogoutSerializer(serializers.Serializer):
    refresh = serializers.CharField()

    def validate_refresh(self, value):
        try:
            self.token = RefreshToken(value)
        except Exception as exc:
            raise serializers.ValidationError("刷新令牌无效") from exc
        return value

    def save(self, **kwargs):
        self.token.blacklist()
        request = self.context.get("request")
        user = request.user if request and request.user.is_authenticated else None
        LoginAuditLog.objects.create(
            user=user,
            username=user.username if user else "",
            result=LoginAuditLog.Result.LOGOUT,
            ip_address=_get_client_ip(request),
            user_agent=request.META.get("HTTP_USER_AGENT", "") if request else "",
            message="登出成功",
        )


def _get_client_ip(request):
    if not request:
        return None
    forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
    if forwarded_for:
        return forwarded_for.split(",")[0].strip()
    return request.META.get("REMOTE_ADDR")
