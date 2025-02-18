# 베이스 이미지로 Python 3.9 슬림 사용
FROM python:3.9-slim

# 작업 디렉토리 설정
WORKDIR /app

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    libmariadb-dev gcc default-mysql-client curl && \
    rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Flask 앱 파일 복사
COPY app.py /app/

# Gunicorn을 사용해 애플리케이션 실행
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "app:app"]
