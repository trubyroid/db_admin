from model.connection import Database
from model.queries import (call_procedure, call_ref_procedure,
                           create_ref_table, drop_tmp_table,
                           get_func_description, get_funcs, get_result_table,
                           get_tables_names, insert_ref_values, use_function)
from settings import db, logger

from controller.page_class import PageFunc

except_funcs = (
    "pr_import_from_csv_to_table",
    "pr_export_to_csv_from_table",
    "fnc_transferred_points_after_p2p_start",
    "fnc_xp",
    "to_minutes"
)


def get_functions_page(pf: PageFunc) -> dict:
    """Возвращает данные для страницы с хранимыми функциями"""
    if pf is None:
        pf = PageFunc(return_mode=True, has_table=False)

    logger.info("Functions page was requested.")
    pf.set_return_mode(True)

    get_tables_names(pf)
    get_funcs(pf)
    get_functions_data(pf)

    return pf.__dict__


def get_functions_data(pf: PageFunc) -> None:
    """Обрабатывает данные о функциях"""

    for func_type, func_name, func_args, args_mode, args_type in pf.funcs_data:

        if func_name in except_funcs:
            continue

        func_data = {'name': func_name,
                     'args': list(),
                     'description': get_func_description(pf, func_name),
                     'type': "function" if func_type == "f" else "procedure"}

        if func_args:
            args_type = args_type.split(', ')

            if args_mode is None:
                for i, t in enumerate(args_type):
                    if t != 'refcursor':
                        func_data['args'].append(func_args[i])
                    else:
                        func_data['args'].append({'type': 'refcursor', 'name': 'ref'})
            else:
                for n, t in zip(func_args, args_mode):
                    if t == 'i':
                        if args_type[func_args.index(n)] == 'refcursor':
                            func_data['args'].append({'type': 'refcursor', 'name': 'ref'})
                        else:
                            func_data['args'].append(n)
                    elif t == "o":
                        func_data['args'].append({'type': 'OUT', 'name': 0})

        pf.add_function(func_data)


def execute_operation(operation_name: str, args: dict) -> PageFunc:
    """Запускает процесс выполнения функции/процедуры"""
    logger.info(f"The operation {operation_name} was requested.")

    pf = PageFunc(operation_name=operation_name)

    pf.set_refcursor_used(True if "refcursor" in args else False)
    pf.set_out_var_used(True if any(map(lambda x: x in args, ["OUT", "INOUT"])) else False)

    drop_tmp_table(pf)
    params = tuple(args.values())

    if operation_name.startswith("fnc"):
        execute_function(pf, params)
    elif operation_name.startswith("pr"):
        execute_procedure(pf, params)
    else:
        logger.info(f"Unidentified operation was requested.")
        pf.set_error("ERROR: unidentified operation.")

    return pf


def execute_function(pf: PageFunc, params: tuple) -> None:
    """Выполнение функции"""
    use_function(pf, params)
    if not pf.error:
        get_result_table(pf)


def execute_procedure(pf: PageFunc, params: tuple) -> None:
    """Выполнение процедуры"""
    if pf.refcursor_used and not pf.out_var_used:
        pf.set_return_mode(True)
        call_ref_procedure(pf, params)

        pf.set_return_mode(False)
        create_ref_table(pf)
        insert_ref_values(pf)
        if not pf.error:
            get_result_table(pf)
    else:
        if pf.out_var_used:
            pf.set_return_mode(True)

        pf.set_table_not_exist()
        result = call_procedure(pf, params)
        pf.set_proc_result(result)

