"""
General tests for the web app.
"""

import requests
import pytest
from bs4 import BeautifulSoup


def test_index():
    """
    Test if the index page is working correctly.
    """
    response = requests.get("http://localhost:5001")
    assert response.status_code == 200
    assert response.headers["Content-Type"] == "text/html; charset=utf-8"


def test_tables_pages(tables_names):
    """Test if the tables pages are working correctly."""
    for name in tables_names:
        response = requests.get(f"http://localhost:5001/table_{name}")
        assert response.status_code == 200
        assert response.headers["Content-Type"] == "text/html; charset=utf-8"


def test_query_input_page():
    """Test if the query input page is working correctly."""
    response = requests.get("http://localhost:5001/query_input/")
    assert response.status_code == 200
    assert response.headers["Content-Type"] == "text/html; charset=utf-8"


@pytest.mark.parametrize("query", [
    "CREATE TABLE test_table (test varchar UNIQUE primary key);",
    "INSERT INTO test_table(test) VALUES ('test_value');",
    "UPDATE test_table SET test = 'new_value' WHERE test = 'test_value';",
    "SELECT * FROM test_table;",
    "DELETE FROM test_table WHERE test = 'new_value';"
])
def test_query_input(query, teardown_db):
    """Test if the query input is working correctly."""
    response = requests.post(
        url="http://localhost:5001/query_input/",
        data={"query": query},
    )

    assert BeautifulSoup(response.content, features="html.parser").find(
        name="div", class_="result-table"
    )


def test_functions_page():
    """Test if the functions page is working correctly."""
    response = requests.get("http://localhost:5001/functions/")
    assert response.status_code == 200
    assert response.headers["Content-Type"] == "text/html; charset=utf-8"

    soup = BeautifulSoup(response.content, features="html.parser")
    assert soup.find(name="div", class_="funcs scrollbar")

    for card in soup.find_all(name="div", class_="procedure card"):
        assert card.find(name="a", class_="btn card-execute")

    for card in soup.find_all(name="div", class_="function card"):
        assert card.find(name="a", class_="btn card-execute")
