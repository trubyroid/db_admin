import logging

from loguru import logger

LOG_CONFIG = {
    "sink": "logs/log_{time:DD-MM-YY-HH-mm-SS}.log",
    "rotation": "00:00",
    "retention": 20,
    "format": "{time:HH:mm:ss MM-DD-YYYY} {level} {message}",
    "backtrace": True,
}

logger.remove(0)
logger.add(**LOG_CONFIG)


class InterceptHandler(logging.Handler):

    def emit(self, record: logging.LogRecord) -> None:
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        frame = logging.currentframe()
        depth = 0
        while frame and (depth == 0 or frame.f_code.co_filename == logging.__file__):
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(
            level, record.getMessage()
        )
