import requests
import pytest
import os

api_url = "https://60h2ko3a49.execute-api.us-east-1.amazonaws.com/prod/visitors"
headers = {
    "x-api-key": 'I8QYNljUps2cpMILlq9mZ9KnI3jTlKpS8sanuHv'
}
def test_get():
    response = requests.get(api_url,headers=headers)
    assert response.status_code == 200
