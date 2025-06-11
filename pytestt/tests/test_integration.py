import requests
import pytest
import os

api_url = "https://c5wxmbe439.execute-api.us-east-1.amazonaws.com/prod/visitors"
headers = {
    "x-api-key": "6ZMb1OILNx1hYMFmBdurvKcy2mBHzib8wzRBGy39"
}
def test_get():
    response = requests.get(api_url,headers=headers)
    assert response.status_code == 200
