import pytest
import requests
import json
from dotenv import load_dotenv
import os
class MissingEnvironmentVariable(Exception):
    pass

load_dotenv() ## This loads variables from .env into os.environ
post_variable="API_URL"
url = os.getenv(post_variable, "No API URL found")
if(url == "No API URL found"):
    raise  MissingEnvironmentVariable(f"{post_variable} does not exist")

"""
Make sure your API responds to
unexpected input correctly; what if the
inbound request is not formatted the
right way?

"""

# test all methods agains the urls
def test_urls():
    methods = ['post','get','put','delete']

    # loop through GET, Then POST
    for method in methods:
        
        request_func = getattr(requests, method, None)

        try:
            # make a request to the value of GET/POST which is the url
            if method == 'post':
                response = request_func(url, data={'key': 'value'})
            else:
                response = request_func(url)
        except requests.exceptions.ConnectionError as r:
            raise r
        
        # from the response GET should be 200 and the rest should be 400 (which i costumized in my API GW)
        # if the url key = method (I.E get = get) it should return 200
        if(method in ['get','post']):
            assert response.status_code == 200
        
        else:
            assert response.status_code != 200

# if used the wrong method
"""
{
  "message": "Bad Request",
  "hint": "The HTTP method or resources may not be supported.",
  "StatusCode": 400
}
"""
# if specified a body in the request
"""
{
  "error": "Invalid JSON in request body"
}
"""

# if specified a header in the request
"""
StatusCode        : 200
StatusDescription : OK
Content           : {"message": "Visitor count recieved", "Visitor_Count": 201}
RawContent        : HTTP/1.1 200 OK
                    Date: Tue, 06 May 2025 08:04:30 GMT
                    Connection: keep-alive
                    x-amzn-RequestId: d38501d5-b58d-497d-9a59-dd5c25671ce3
                    Access-Control-Allow-Origin: *
                    Access-Control-Allow-Headers: Cont…
Headers           : {[Date, System.String[]], [Connection, System.String[]], [x-amzn-RequestId, System.String[]], [Access-Control-Allow-Origin, System.String[]]…}
Images            : {}
InputFields       : {}
Links             : {}
RawContentLength  : 59
RelationLink      : {}
"""

### What you learend here?
    # Test your api to check how it response to BAd request, or Bad paths with a bad method
    # to loop through methods use, getattr() with this syntax
        # methods you want 
        # variable to store getattr() (think about it like a package [url, method])
        # variable to store the response (think about it as a placeholder for this package when sent.)


"""
Make sure you are checking edge cases
in your function logic. What happens if
the visitor count is not initialized (ie, on
the first time the function is invoked?)
"""