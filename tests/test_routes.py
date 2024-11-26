"""
General tests for the web app.
"""

import requests
from bs4 import BeautifulSoup


def test_index():
    """
    Test if the index page is working correctly.
    Also gets the tables names.
    """
    response = requests.get("http://localhost:5001")
    assert response.status_code == 200
    assert response.headers["Content-Type"] == "text/html; charset=utf-8"
    assert response.headers["Content-Length"] == "5590"


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


def test_query_input(tables_names):
    """Test if the query input is working correctly."""
    response = requests.post(
        url="http://localhost:5001/query_input/",
        data={"query": f"select * from {tables_names[0]};"},
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
