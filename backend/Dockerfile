FROM python:3.11-slim
WORKDIR /app
# to install only essential python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib//apt/lists/*

#copy requiremnts to install
COPY requiremnts.txt .

#install python packages from requiremnts.txt
RUN pip install --no-cache-dir -r requiremnts.txt

COPY . .

EXPOSE 8000

CMD ["uvicron", "app.main:app", "--host"  "0.0.0.0" "--port", "8080"]