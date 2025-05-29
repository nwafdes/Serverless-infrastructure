import pytest
import requests
import json
from dotenv import load_dotenv
import os
class MissingEnvironmentVariable(Exception):
    pass
load_dotenv()
variable="API_URL"
url = os.getenv(variable, "No API URL found")

def test_cors():
    methods = ['GET','POST']

    for method in methods:
        package = getattr(requests, method.lower(), None)
        response = package(url)
        assert ("Access-Control-Allow-Origin" in response.headers.keys()) == True
