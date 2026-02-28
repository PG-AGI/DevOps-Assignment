import unittest
from src.api import app

class APITestCase(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_example_endpoint(self):
        response = self.app.get('/api/example')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {'message': 'Hello, World!'})

if __name__ == '__main__':
    unittest.main()