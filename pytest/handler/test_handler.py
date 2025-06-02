import pytest
import requests
import json
from app.lambda_function import lambda_handler

def get_data(self):

    return {
        "resource":"/visitors",
        "path": "/visitors",
        "httpMethod": "GET",
        "isBase64Encoded": "false"
    }

def check_get_data():
    response = lambda_handler(get_data, "")

    assert response.statusCode == 200

def post_data(self):

    return {
        "resource":"/visitors",
        "path": "/visitors",
        "httpMethod": "POST",
        "isBase64Encoded": "false"
    }

def check_post_data():
    response = lambda_handler(post_data, "")

    assert response.statusCode == 200

