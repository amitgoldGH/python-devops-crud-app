import pytest
from app import app
from database import db


@pytest.fixture
def test_client():
    """Create a Flask test client with an in-memory database."""
    app.config['TESTING'] = True
    # in-memory DB
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    with app.app_context():
        db.create_all()  # create tables fresh for each test

    client = app.test_client()
    yield client

    # Cleanup after test
    with app.app_context():
        db.session.remove()
        db.drop_all()


def test_add_and_get_task(test_client):
    """Test adding a task and then retrieving it."""
    # Add a task
    response = test_client.post('/tasks', json={'title': 'Test Task'})
    assert response.status_code == 201
    assert response.get_json() == {"message": "Task added"}

    # Get all tasks
    response = test_client.get('/tasks')
    assert response.status_code == 200
    data = response.get_json()
    assert len(data) == 1
    assert data[0]['title'] == 'Test Task'
    assert data[0]['completed'] is False


def test_delete_task(test_client):
    """Test deleting a task."""
    # Add a task
    test_client.post('/tasks', json={'title': 'Temp Task'})

    # Delete it
    response = test_client.delete('/tasks/1')
    assert response.status_code == 200
    assert response.get_json() == {"message": "Task deleted"}

    # Ensure it’s gone
    response = test_client.get('/tasks')
    data = response.get_json()
    assert data == []
