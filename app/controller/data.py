import os

import werkzeug.datastructures.file_storage
from model.queries import (
    call_procedure,
    delete_row,
    get_result_table,
    get_tables_names,
    insert_row,
    truncate_cascade,
    update_row,
)
from settings import logger

from controller.page_class import Page, PageData

project_dir = os.path.dirname(os.path.dirname(__file__))
if not os.path.exists("tables"):
    os.mkdir("tables")


def get_tables() -> dict:
    """Возвращает данные для страницы с названиями таблиц в меню"""

    pd = Page(return_mode=True)
    get_tables_names(pd)
    logger.info("Default page was requested.")

    return pd.__dict__


def read_operation(table_name: str, pd: PageData) -> dict:
    """Осуществляет операцию чтения данных из таблицы,
    возвращает данные для страницы data"""
    if pd is None:
        pd = PageData(table=table_name)

    pd.set_return_mode(True)

    get_tables_names(pd)

    if table_name in pd.tables_names:
        get_result_table(pd)
    else:
        logger.info("Not existing table was requested.")
        pd.set_error("ERROR: table does not exist.")
        pd.set_table_not_exist()

    return pd.__dict__


def create_operation(table_name: str, form: dict) -> dict:
    """Запускает процесс создания записи в таблице"""

    pd = PageData(table=table_name)

    params = tuple(form.values())
    insert_row(pd, params)

    return pd


def update_operation(table_name: str, requested_form: dict) -> dict:
    """Обрабатывает данные из формы,
    запускает процесс обновления записи в таблице"""

    form_items = requested_form.items().__iter__()
    primary_key, primary_val = next(form_items)
    form = dict(form_items)

    pd = PageData(table=table_name)
    pd.pk = primary_key

    params = [*form.values(), primary_val]
    keys = list(form.keys())

    update_row(pd, keys, params)
    return pd


def delete_operation(table_name: str, requested_form: dict) -> dict:
    """Считывает данные из формы,
    запускает процесс удаления записи из таблицы"""
    primary_key, primary_val = next(requested_form.items().__iter__())

    pd = PageData(table=table_name)
    pd.pk = primary_key
    params = (primary_val,)

    delete_row(pd, params)
    return pd


def import_table(
    table_name: str, imported_file: werkzeug.datastructures.file_storage.FileStorage
) -> dict:
    """Запускает процесс импорта данных из csv"""

    pd = PageData(table=table_name)

    if not imported_file.filename.endswith(".csv"):
        pd.set_error("ERROR: invalid file format.")
    else:
        new_table_file = imported_file.filename
        pd.set_csv_path(f"{project_dir}/tables/{new_table_file}")
        imported_file.save(pd.csv_path)

        pd.proc_name = "pr_import_from_csv_to_table"
        params = (table_name, pd.csv_path, ",")

        truncate_cascade(pd)
        call_procedure(pd, params)

    return pd


def export_table(table_name: str) -> dict:
    """Запускает процесс экспорта данных в csv"""
    pd = PageData(table=table_name)

    pd.set_csv_path(f"{project_dir}/tables/{table_name}.csv")

    pd.proc_name = "pr_export_to_csv_from_table"
    params = (table_name, pd.csv_path, ",")

    call_procedure(pd, params)
    return pd
