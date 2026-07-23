import json
import os
import boto3
from botocore.config import Config
import pymysql

# 캐싱용 (Lambda 컨테이너 재사용 시 재조회 방지)
_secret_cache = None


def get_secret():
    global _secret_cache
    if _secret_cache is not None:
        return _secret_cache

    secret_name = os.environ["DB_SECRET_NAME"]
    region_name = os.environ.get("AWS_REGION", "us-west-1")

    client = boto3.client(
        "secretsmanager",
        region_name=region_name,
        config=Config(connect_timeout=3, read_timeout=3, retries={"max_attempts": 1}),
    )
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
    # REST API(AWS_PROXY, 페이로드 포맷 1.0) 기준 method 추출
    method = event.get("httpMethod", "")

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
        "body": json.dumps({"status": "Success" if is_connected else "Failure"}),
    }


def cors_headers():
    return {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }