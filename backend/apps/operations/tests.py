from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

from apps.operations.models import Product


class OperationsApiSmokeTests(TestCase):
    def setUp(self):
        User = get_user_model()
        self.user = User.objects.create_user(
            username="admin",
            password="admin123",
            role="admin",
            data_scope="all",
            status="active",
        )
        Product.objects.create(
            code="WT-DRESS-001",
            name="外贸女装连衣裙",
            unit="件",
            category="服装",
            status="active",
        )
        Product.objects.create(
            code="WT-SHOES-021",
            name="跨境运动鞋",
            unit="双",
            category="鞋履",
            status="active",
        )
        self.client = APIClient()

    def test_products_require_authentication(self):
        response = self.client.get("/api/operations/products/")

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_login_and_search_products(self):
        login_response = self.client.post(
            "/api/auth/login/",
            {"username": "admin", "password": "admin123"},
            format="json",
        )
        self.assertEqual(login_response.status_code, status.HTTP_200_OK)
        access_token = login_response.data["access"]

        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access_token}")
        response = self.client.get(
            "/api/operations/products/",
            {"search": "连衣裙", "ordering": "-created_at"},
        )

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["code"], "WT-DRESS-001")
