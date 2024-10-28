from model.queries import (
    create_as_select,
    drop_tmp_table,
    get_result_table,
    get_tables_names,
)
from settings import db, logger

from controller.page_class import PageCustom
from controller.utils import get_changed_table, not_select, query_check


def send_custom_query(pc: PageCustom, query: str):
    """Отправляет запрос, создает результирующую таблицу"""
    pc.set_return_mode(False)

    if not_select(query):
        db.query_execute(pc, query)
        query = get_changed_table(pc, query)

    if query and not pc.error:
        drop_tmp_table(pc)
        create_as_select(pc, query)

    pc.set_return_mode(True)


def custom_query_handler(query: str) -> dict:
    """Запускает процесс обработки пользовательского запроса"""
    pc = PageCustom(return_mode=True)
    get_tables_names(pc)
    logger.info("Custom query was requested.")

    if query_check(pc, query):
        send_custom_query(pc, query)
        if not pc.error:
            get_result_table(pc)

    return pc.__dict__
