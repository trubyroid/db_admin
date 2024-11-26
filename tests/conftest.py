import pytest
import requests
from bs4 import BeautifulSoup


@pytest.fixture(scope="session")
def tables_names():
    """
    Return a list of tables names.
    """
    response = requests.get("http://localhost:5001")

    soup = BeautifulSoup(response.content, features="html.parser")
    scrollbar = soup.find(name="div", class_="tables scrollbar")

    return scrollbar.get_text().strip().split("\n")
