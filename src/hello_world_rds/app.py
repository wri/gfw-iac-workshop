import os
import psycopg2

from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello_world():
    conn = psycopg2.connect(
        dbname=os.getenv("POSTGRES_NAME"),
        user=os.getenv("POSTGRES_USERNAME"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_PORT"),
    )
    cur = conn.cursor()
    cur.execute("SELECT version();")
    return " ".join(cur.fetchone())
