
from flask import Blueprint, render_template, request, send_file
from loguru import logger

from controller.custom_query import custom_query_handler
from controller.data import (create_operation, delete_operation, export_table,
                             get_tables, import_table, read_operation,
                             update_operation)
from controller.functions import execute_operation, get_functions_page

app_route = Blueprint("route", __name__)
app_error = Blueprint("errors", __name__)

crud_funcs = {
        "create": create_operation,
        "update": update_operation,
        "delete": delete_operation
        }


@app_route.route("/")
@app_route.route("/index")
@app_route.route("/index/")
def main_page():
    logger.info("Main page was requested.")
    return render_template("index.html", **get_tables())


@app_route.route('/table_<string:table_name>', methods=['get', 'post'])
@app_route.route('/table_<string:table_name>/', methods=['get', 'post'])
def data_page(table_name: str):

    page_data = None

    if request.method == 'POST':

        requested_form = dict(**request.form)
        operation_type = requested_form.pop('type')

        if operation_type == 'import':
            imported_file = request.files['import']
            page_data = import_table(table_name, imported_file)
        elif operation_type == 'export':
            page_data = export_table(table_name)
            if not page_data.error:
                return send_file(page_data.csv_path, as_attachment=True)
            else:
                return server_error(500)
        else:
            page_data = crud_funcs[operation_type](table_name, requested_form)

    return render_template('data.html', **read_operation(table_name, page_data))


@app_route.route('/query_input/', methods=['get', 'post'])
def custom_query():
    if request.method == "POST":
        query = request.form.get("query")
        return render_template('operations.html', **custom_query_handler(query), query=query)
    return render_template('operations.html', **get_tables(), query='')


@app_route.route('/custom_query_export/', methods=['post'])
def query_result_export():
    logger.info("Result of custom query was exported.")
    page_data = export_table("custom_table")
    return send_file(page_data.csv_path, as_attachment=True)


@app_route.route('/functions', methods=['get'])
@app_route.route('/functions/', methods=['get'])
@app_route.route('/function-<string:func_name>', methods=['post'])
@app_route.route('/procedure-<string:func_name>', methods=['post'])
def functions_page(func_name: str = None):
    page_data = None

    if request.method == 'POST':
        page_data = execute_operation(func_name, dict(request.form))
    return render_template('functions.html', **get_functions_page(page_data))


@app_route.route('/function_result_export', methods=['post'])
def function_result_export():
    if request.method == 'POST':
        logger.info("Operation result was exported.")
        page_data = export_table("func_result")
        if not page_data.error:
            return send_file(page_data.csv_path, as_attachment=True)
        else:
            return server_error(500)


@app_error.app_errorhandler(404)
def page_not_found(_):
    logger.error("404 error was raised")
    error_code = 404
    error_description = 'Not Found'
    return render_template("error_page.html",
                           **get_tables(),
                           error_code=error_code,
                           error_description=error_description), 404


@app_error.app_errorhandler(500)
def server_error(_):
    logger.error("500 error was raised")
    error_code = 500
    error_description = 'Internal Server Error'
    return render_template("error_page.html",
                           **get_tables(),
                           error_code=error_code,
                           error_description=error_description), 500


@app_error.app_errorhandler(405)
def method_error(_):
    logger.error("405 error was raised")
    error_code = 405
    error_description = 'Method Not Allowed'
    return render_template("error_page.html",
                           **get_tables(),
                           error_code=error_code,
                           error_description=error_description), 405
