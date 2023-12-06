from psycopg2 import sql


def formatting_update_vals(keys: list) -> sql.SQL:
    """Формирует строку с ключами и значениями обновляемых данных"""
    new_vals = sql.SQL("{col} = {val}").format(
        col=sql.Identifier(keys[0]),
        val=sql.Placeholder())
    for key in keys[1:]:
        new_pair = sql.SQL("{col} = {val}").format(
            col=sql.Identifier(key),
            val=sql.Placeholder())
        new_vals = sql.SQL(', ').join([new_vals, new_pair])
    return new_vals


def db_error_handler(err):
    """Обрабатывает ошибку бд для читабельного вывода"""
    strs = err.pgerror.split('\n')

    for s in strs:
        if s.startswith("DETAIL"):
            return s.replace("DETAIL", "ERROR")

    for s in strs:
        if s.startswith("ОШИБКА"):
            return s.replace("ОШИБКА", "ERROR")

    return str(err).replace("LINE 1", "ERROR")
