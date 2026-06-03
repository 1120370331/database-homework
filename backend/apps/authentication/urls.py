from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import (
    LoginView,
    LogoutView,
    MeView,
    PermissionCodeViewSet,
    PermissionGroupViewSet,
    RefreshView,
    RegisterView,
    UserViewSet,
)


router = DefaultRouter()
router.register("users", UserViewSet, basename="user")
router.register("permission-codes", PermissionCodeViewSet, basename="permission-code")
router.register("permission-groups", PermissionGroupViewSet, basename="permission-group")

urlpatterns = [
    path("register/", RegisterView.as_view(), name="auth-register"),
    path("login/", LoginView.as_view(), name="auth-login"),
    path("refresh/", RefreshView.as_view(), name="auth-refresh"),
    path("me/", MeView.as_view(), name="auth-me"),
    path("logout/", LogoutView.as_view(), name="auth-logout"),
    path("", include(router.urls)),
]
