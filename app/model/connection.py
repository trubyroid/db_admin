from typing import Iterable

from controller.page_class import Page
from loguru import logger
from psycopg2 import DatabaseError, connect, sql

from model.utils import db_error_handler


class Database:

    def __init__(self, params: dict):

        self.params = params
        self.connection = None

    def __del__(self):
        self.disconnect_db()

    def connect_db(self) -> None:
        """Подключается к бд"""

        logger.info("Connecting to the database...")

        while 1:
            try:
                self.connection = connect(**self.params)
            except (Exception, DatabaseError) as err:
                logger.warning(err)
                logger.info("Trying to connect again...")
            else:
                logger.success("Connection successful.")
                break

    def disconnect_db(self) -> None:
        """Отключается от бд"""
        logger.success("Connection terminated.")
        if self.connection is not None:
            self.connection.close()

    def query_execute(
        self, page: Page, query: sql.SQL, params: Iterable = None
    ) -> list:
        """Выполняет запрос, возвращает результат"""
        result = tuple()
        try:
            cur = self.connection.cursor()
            cur.execute(query, params)

            if page.return_mode:
                result = cur.fetchall()

                if page.table_name == "func_result" and page.refcursor_used:
                    page.set_columns(tuple(cur.description))
                    page.refcursor_used = False

            cur.close()
        except (Exception, DatabaseError) as err:
            err_string = db_error_handler(err)
            page.set_error(err_string)
            logger.error(err)
        finally:
            self.connection.commit()
        return result
