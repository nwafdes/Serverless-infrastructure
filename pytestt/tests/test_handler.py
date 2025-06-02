import pytest
from app.lambda_function import lambda_handler

def get_data():
    return {
        "resource": "/visitors",
        "path": "/visitors",
        "httpMethod": "GET",
        "isBase64Encoded": "false"
    }

def test_get_data():
    response = lambda_handler(get_data(), "")
    assert response['statusCode'] == 200

def post_data():
    return {
        "resource": "/visitors",
        "path": "/visitors",
        "httpMethod": "POST",
        "isBase64Encoded": "false"
    }

def test_post_data():
    response = lambda_handler(post_data(), "")
    assert response['statusCode'] == 200
