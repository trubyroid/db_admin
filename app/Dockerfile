FROM python:3.9-slim

WORKDIR /app

COPY ./ /app/
RUN pip install -r /app/requirements.txt


ENTRYPOINT FLASK_APP=/app/app.py flask run --host=0.0.0.0 --port=5000