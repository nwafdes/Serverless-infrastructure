import requests
import pytest
import os

api_url = os.getenv("API_URL", "")

def test_get():
    response = requests.get(api_url)
    assert response.status_code == 200
