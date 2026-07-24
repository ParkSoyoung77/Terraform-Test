import json
import os
import boto3
import pymysql

_secret_cache = None


def get_secret():
    global _secret_cache
    if _secret_cache is not None:
        return _secret_cache

    secret_name = os.environ["DB_SECRET_NAME"]
    region_name = os.environ.get("AWS_REGION", "us-west-1")

    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)
    _secret_cache = json.loads(response["SecretString"])
    return _secret_cache


def get_connection():
    secret = get_secret()
    return pymysql.connect(
        host=secret.get("host") or os.environ["DB_HOST"],
        user=secret["username"],
        password=secret["password"],
        database=os.environ.get("DB_NAME", "studydb"),
        port=int(os.environ.get("DB_PORT", 3306)),
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor,
    )


def check_db_connection() -> bool:
    conn = None
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        return True
    except Exception as e:
        print(f"DB connection failed: {e}")
        return False
    finally:
        if conn:
            conn.close()


def lambda_handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method", "")
    if method == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": cors_headers(),
            "body": "",
        }

    is_connected = check_db_connection()

    return {
        "statusCode": 200 if is_connected else 500,
        "headers": cors_headers(),
        "body": json.dumps({"status": "Success" if is_connected else "Failure"}),   # 여기만 변경
    }


def cors_headers():
    return {
        "Content-Type": "application/json",   # text/plain → application/json
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }