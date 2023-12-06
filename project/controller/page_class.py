"""
Классы Page(Data, Custom, Func) предназначены для хранения,
необходимых для вывода страницы, данных.
"""


class Page:
    """Родительский класс, содержит только данные и методы,
 которые могут понадобиться во всех случаях"""
    def __init__(self, table: str = "",
                 return_mode: bool = False):

        self.table_name = table
        self.return_mode = return_mode

        self.error = False
        self.error_message = None

        self.tables_names = tuple()

    @staticmethod
    def result_handler(result: tuple) -> tuple:
        """Распаковка значений из бд"""
        return tuple(zip(*result))[0]

    def set_error(self, message: str) -> None:
        self.error = True
        self.error_message = message

    def set_return_mode(self, value: bool) -> None:
        self.return_mode = value

    def set_tables_names(self, tables: tuple):
        self.tables_names = sorted(self.result_handler(tables))


class PageData(Page):
    """Класс для вывода страниц из меню Data"""
    def __init__(self,
                 table: str,
                 return_mode: bool = False):

        super().__init__(table, return_mode)

        self.caption = table.title()

        self.table_columns = tuple()
        self.table_data = tuple()

        self.has_table = True
        self.csv_path = ""

    def set_columns_names(self, columns: tuple):
        self.table_columns = self.result_handler(columns)

    def set_table_data(self, data: tuple):
        self.table_data = sorted(data)

    def set_table_not_exist(self):
        self.has_table = False

    def set_csv_path(self, path: str):
        self.csv_path = path


class PageCustom(PageData):
    """Класс для вывода страницы пользовательского запроса"""
    def __init__(self, return_mode: bool = False):
        super().__init__(table="custom_table",
                         return_mode=return_mode)


class PageFunc(PageData):
    """Класс для работы с хранимыми функциями"""
    def __init__(self,
                 operation_name: str = "",
                 return_mode: bool = False,
                 has_table: bool = True):

        super().__init__(table="func_result",
                         return_mode=return_mode)

        self.operation_name = operation_name

        self.ref_columns = tuple()
        self.ref_data = list()

        self.refcursor_used = True
        self.out_var_used = False
        self.has_table = has_table

        self.functions = list()
        self.proc_result = ""

    @property
    def func_name(self):
        return self.operation_name

    @property
    def proc_name(self):
        return self.operation_name

    @staticmethod
    def description_handler(description: tuple) -> str:
        return description[0][0] if len(description) > 0 else None

    def add_function(self, function):
        self.functions.append(function)

    def set_proc_result(self, val = None):
        if not self.error:
            result = f"The procedure {self.proc_name} has successfully completed."
        else:
            result = f"The procedure {self.proc_name} has failed."

        if val:
            val = self.result_handler(val)
            result = "".join((result, f"The result is: {val[0]}"))

        self.proc_result = result

    def set_refcursor_used(self, val: bool):
        self.refcursor_used = val

    def set_out_var_used(self, val: bool):
        self.out_var_used = val

    def set_columns(self, description):
        self.ref_columns = tuple((col.name for col in description))

    def set_data(self, data: list):
        self.ref_data = data
