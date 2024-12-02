import pytest
import allure
import requests
from bs4 import BeautifulSoup


@pytest.fixture(scope="session")
@allure.title("Get current tables names")
def tables_names():
    """
    Return a list of tables names.
    """
    response = requests.get("http://localhost:5001")

    soup = BeautifulSoup(response.content, features="html.parser")
    scrollbar = soup.find(name="div", class_="tables scrollbar")

    return scrollbar.get_text().strip().split("\n")


@pytest.fixture(scope="session")
@allure.title("Drop table test_table for teardown")
def teardown_db():
    """
    Drop the test_table after the tests.
    """
    yield
    requests.post(
        url="http://localhost:5001/query_input/",
        data={"query": "DROP TABLE IF EXISTS test_table;"},
    )
