from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenRefreshView

from .models import PermissionGroup, User
from .serializers import (
    LoginSerializer,
    LogoutSerializer,
    PermissionGroupSerializer,
    UserSerializer,
)


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        return Response(serializer.validated_data)


class RefreshView(TokenRefreshView):
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    def get(self, request):
        return Response(UserSerializer(request.user).data)


class LogoutView(APIView):
    def post(self, request):
        serializer = LogoutSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(status=status.HTTP_204_NO_CONTENT)


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.prefetch_related("permission_groups").order_by("id")
    serializer_class = UserSerializer

    @action(detail=False, methods=["get"], url_path="me")
    def current_user(self, request):
        return Response(self.get_serializer(request.user).data)


class PermissionGroupViewSet(viewsets.ModelViewSet):
    queryset = PermissionGroup.objects.all()
    serializer_class = PermissionGroupSerializer
