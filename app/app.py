import logging

from flask import Flask
from loguru import logger

from controller.routes import app_error, app_route

# Запуск приложения
app = Flask(__name__, template_folder="view/templates", static_folder="view/static")
# Добавляем роуты
app.register_blueprint(app_route)
app.register_blueprint(app_error)

# Устанавливаем логгер flask-a на уровень WARNING
log = logging.getLogger("werkzeug")
log.setLevel(logging.WARNING)

# Отправляем сообщение в loguru
logger.success("App started working. Running on http://127.0.0.1:5000")


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000)
