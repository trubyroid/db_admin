from model.connection import Database
from dotenv import load_dotenv

import log
from loguru import logger

import os
import sys
import signal


def get_params() -> dict:
    """Возвращает параметры для соединения с бд"""

    dotenv_path = os.path.join(os.path.dirname(__file__), '.env')
    if os.path.exists(dotenv_path):
        load_dotenv(dotenv_path)

    host = os.environ['POSTG_HOST']
    port = os.environ['POSTG_PORT']
    database = os.environ['DATABASE']
    user = os.environ['POSTG_USER']
    password = os.environ['POSTG_PASW']

    return {
        "host": host,
        "port": port,
        "database": database,
        "user": user,
        "password": password
    }


# Настройка логгера
intercept_handler = log.InterceptHandler()
log.logging.basicConfig(handlers=[intercept_handler], level=0, force=True)

# Установка соединения с бд
params = get_params()
db = Database(params)
db.connect_db()


# Конец работы приложения
def signal_handler(sig, frame):
    db.disconnect_db()
    logger.success("App finished working.")
    sys.exit(0)


signal.signal(signal.SIGINT, signal_handler)
