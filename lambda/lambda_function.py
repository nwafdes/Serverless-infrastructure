import json
import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel("INFO")
ddb = boto3.client("dynamodb")

# table name
env_TableName = os.getenv("TABLE_NAME", "No Table Name retrieved")

# Partition Key
env_partitionKey = os.getenv("PARTITION_KEY", "No PARTION KEY retrieved")

# ITEM NAME
env_itemName = os.getenv("ITEM_NAME", "No ITEM_NAME was found")

# Attribute Name
env_AttributeName = os.getenv("ATTRIBUTE_NAME", "No ATTRIBUTE_NAME was found")

# API Path
env_ApiPath = os.getenv("API_PATH", "No API_PATH was found")


def lambda_handler(event, context):

    table_name = env_TableName
    key = {f"{env_partitionKey}": {"S": f"{env_itemName}"}}
    allowed_cors = "*"

    try:
        item = ddb.get_item(TableName=table_name, Key=key)
        # hello
        # this is a trial 

    except Exception as e:
        logger.error(e)
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "DynamoDB error Hint: check table_name and key"})
        }

    # if attribute not exist in DB
    try:
        item_value = int(item["Item"][f"{env_AttributeName}"]["N"])
    except Exception as e:
        logger.error(e)
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "DynamoDB attribute Name doesn't exist"})
        }

    logger.info(item_value)

    try:
        if event['httpMethod'] == 'GET' and event['path'] == f'{env_ApiPath}':
            logger.info("GET request received")
            body = {
                "message": "Visitor count recieved",
                "Visitor_Count": item_value
                }
            return {
            "statusCode": 200,
            "isBase64Encoded": False,
            "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": allowed_cors,
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type"
            },
            "body": json.dumps(body)
            }

        elif event['httpMethod'] == 'POST' and event['path'] == f'{env_ApiPath}':
            
            item_value += 1

            # Safely parse body (even if not required)
            try:
                raw_body = event.get("body")
            # if raw_body:
            #     try:
            #         body = json.loads(raw_body)

            except Exception as e:
                logger.error(e)
                return {
                    'statusCode': 400,
                    'body': json.dumps({"error": "Invalid JSON in request body"})
            }
#sdflkjsdfl;ksjvl;kasjdflkajsdflkjasfdlkjasdflkasjdfl'kasjdf;laskdjf
            try:
                # Update DynamoDB
                ddb.update_item(
                    Key=key,
                    TableName=table_name,
                    UpdateExpression=f"SET {env_AttributeName}= :N",
                    ExpressionAttributeValues={
                        ":N": {"N": str(item_value)}
                    }
                )
            except Exception as e:
                logger.error(e)
                return {
                    'statusCode': 500,
                    'body': json.dumps({"error": "DynamoDB error"})
                }

            response_body = {
                "message": "Successfully updated DDB Table",
                "Visitor_Count": item_value
            }

            return {
                "statusCode": 200,
                "isBase64Encoded": False,
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": allowed_cors,
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Content-Type"
                },
                "body": json.dumps(response_body)
            }

        else:
            return {
                'statusCode': 400,
                'body': json.dumps({"Error": "Invalid Request"})
            }
    except Exception as e:
        logger.error(e)
        return {
            'statusCode': 500,
            'body': json.dumps({"Error": "WE are Facing an error!!"})
        }