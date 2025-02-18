import os
import json
import boto3
from flask import Flask, request
import pymysql

app = Flask(__name__)

# MySQL 연결 정보 (ConfigMap & Secret에서 가져옴)
db_host = os.getenv("MYSQL_HOST")
db_port = int(os.getenv("MYSQL_PORT", 3306))
db_user = os.getenv("MYSQL_USER")
db_name = os.getenv("MYSQL_DATABASE")

# AWS Secrets Manager에서 RDS 비밀번호 가져오기
secret_name = os.getenv("AWS_SECRET_NAME")
region_name = os.getenv("AWS_REGION", "ap-northeast-2")

session = boto3.session.Session()
client = session.client(service_name="secretsmanager", region_name=region_name)

try:
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(get_secret_value_response["SecretString"])
    db_password = secret["password"]
except Exception as e:
    print(f"Secrets Manager에서 RDS 비밀번호를 가져오는 중 오류 발생: {e}")
    exit(1)

# MySQL 연결 함수
def connect_to_db():
    return pymysql.connect(
        host=db_host,
        port=db_port,
        user=db_user,
        password=db_password,
        database=db_name,
        cursorclass=pymysql.cursors.DictCursor,
    )

@app.route("/")
def index():
    return """
    <h1>상품 관리</h1>
    <form method="POST" action="/add">
        <label for="item">물건 이름:</label><br>
        <input type="text" id="item" name="item"><br>
        <label for="price">가격:</label><br>
        <input type="number" id="price" name="price"><br><br>
        <button type="submit">추가</button>
    </form>
    <br>
    <a href="/items">저장된 상품 보기</a>
    """

@app.route("/add", methods=["POST"])
def add_item():
    item_name = request.form.get("item")
    price = request.form.get("price")

    try:
        connection = connect_to_db()
        with connection.cursor() as cursor:
            cursor.execute("INSERT INTO items (name, price) VALUES (%s, %s)", (item_name, price))
        connection.commit()
    except Exception as e:
        return f"<h1>오류 발생: {e}</h1><br><a href='/'>다시 시도하기</a>"
    finally:
        connection.close()

    return f"<h1>상품 '{item_name}'가 {price}원으로 저장되었습니다!</h1><br><a href='/'>다시 입력하기</a>"

@app.route("/items")
def view_items():
    try:
        connection = connect_to_db()
        with connection.cursor() as cursor:
            cursor.execute("SELECT * FROM items")
            items = cursor.fetchall()
    except Exception as e:
        return f"<h1>오류 발생: {e}</h1><br><a href='/'>다시 시도하기</a>"
    finally:
        connection.close()

    html = "<h1>저장된 상품 목록</h1><ul>"
    for item in items:
        html += f"<li>{item['name']} - {item['price']}원</li>"
    html += "</ul><br><a href='/'>상품 추가하기</a>"

    return html

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
