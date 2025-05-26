import pytest
import requests
import json
from dotenv import load_dotenv
import os
class MissingEnvironmentVariable(Exception):
    pass
load_dotenv()
post_variable="POST_PATH"
post_url = os.getenv(post_variable, "No API URL found")
if(post_url == "No API URL found"):
    raise  MissingEnvironmentVariable(f"{post_variable} does not exist")

get_variable="GET_PATH"
get_url=os.getenv(get_variable, "No API URL found")
if(get_url == "No API URL found"):
    raise  MissingEnvironmentVariable(f"{get_variable} does not exist")

def test_cors():
    urls = {'GET': get_url, 'POST': post_url}

    for url in urls.keys():
        package = getattr(requests, url.lower(), None)
        response = package(urls[url])
        assert ("Access-Control-Allow-Origin" in response.headers.keys()) == True
