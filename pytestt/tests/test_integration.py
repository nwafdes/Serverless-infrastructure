import requests
import pytest
import os

api_url = os.getenv("API_URL", "")
headers = {
    "x-api-key": "your_api_key_here"
}
def test_get():
    response = requests.get(api_url,headers=headers)
    assert response.status_code == 200
