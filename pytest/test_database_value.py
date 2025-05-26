import pytest
import requests
import json
import boto3
from botocore.config import Config
from dotenv import load_dotenv
from botocore.exceptions import ClientError
import os
class MissingEnvironmentVariable(Exception):
    pass

"""
Make sure your API not only returns an 
updated value to you, but actually updates the database
"""
load_dotenv()
# Upload URL from .env file
variable="POST_PATH"
update_url = os.getenv(variable, "No API URL found")
if(update_url=="No API URL found"):
    raise  MissingEnvironmentVariable(f"{variable} does not exist")


# function to get the visitor_count from the db itself
def get_visitorCount_FromDB():
    my_config = Config(region_name="us-east-1")

    ddb = boto3.client('dynamodb',config=my_config)
    table_name = "Website_visitors"
    key = {"id": {"S": "Limitless"}}
    try:
        item = ddb.get_item(Key=key, TableName=table_name)
        # check if keys are exist
        record = item.get('Item')
        if not record:
            raise KeyError("Item is not a record in the DB")
        # check if price is exist
        price_attr = record.get('price')
        if not price_attr:
            raise KeyError("Price Attribute doesn't exist")
        
        # if all good store result to visitor_count
        visitor_count = price_attr['N']
    except ClientError as e:

        print('General Error')

        raise e
        
    return visitor_count

# function to get the visitor count from the api 
def get_updateVisitorCount_From_Post():

    try:
        
        response = requests.post(url=update_url)

        if(response.status_code!=200):
            raise Exception(f"Request failed with status code {response.status_code}: {response.text}")
    
        # response is not a dict so i cant do response.get(blah), so lets change it to dict
        data = response.json()

        updated_visitor_count = data.get('Visitor_Count', '')

        return updated_visitor_count

    except ConnectionAbortedError as cn:
        print("Connection Error")
        raise cn




def test_db_value():
    
    post_value = get_updateVisitorCount_From_Post()
    db_value = get_visitorCount_FromDB()

    assert int(post_value) == int(db_value)


### what you learned here
    # Assume the opposite what if doesn't occur does code crashes? to avoid use error handeling
    