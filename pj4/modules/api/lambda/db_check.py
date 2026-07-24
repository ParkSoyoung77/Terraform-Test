import json
import os
import boto3
import pymysql

# 캐싱용 (Lambda 컨테이너 재사용 시 재조회 방지)
_secret_cache = None


def get_secret():
    global _secret_cache
    if _secret_cache is not None:
        return _secret_cache

    secret_name = os.environ["DB_SECRET_NAME"]  # 시크릿 이름/ARN은 환경변수로
    region_name = os.environ.get("AWS_REGION", "us-west-1")

    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)
    _secret_cache = json.loads(response["SecretString"])
    return _secret_cache


def get_connection():
    secret = get_secret()
    return pymysql.connect(
        host=secret.get("host") or os.environ["DB_HOST"],  # host는 시크릿에 없으면 환경변수로
        user=secret["username"],
        password=secret["password"],
        database=os.environ.get("DB_NAME", "studydb"),
        port=int(os.environ.get("DB_PORT", 3306)),
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor,
    )


def check_db_connection() -> bool:
    """DB에 연결해서 간단한 쿼리(SELECT 1)까지 성공하면 True, 무엇이든 실패하면 False."""
    conn = None
    try:
        conn = get_connection()
        with conn.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        return True
    except Exception as e:
        # CloudWatch Logs에 실패 원인을 남긴다 (브라우저에는 노출하지 않음)
        print(f"DB connection failed: {e}")
        return False
    finally:
        if conn:
            conn.close()


def lambda_handler(event, context):
    # CORS preflight 처리
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
        "body": "Success" if is_connected else "Failure",
    }


def cors_headers():
    return {
        # 브라우저에서 바로 텍스트로 보이도록 text/plain 사용
        "Content-Type": "text/plain; charset=utf-8",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }