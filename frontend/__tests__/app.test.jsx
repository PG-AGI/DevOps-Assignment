import { render, screen, waitFor } from '@testing-library/react';
import Home from '../pages/index';
import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';

// Create a new Axios mock instance
const mock = new MockAdapter(axios);

// Mock backend responses
mock.onGet(`${process.env.NEXT_PUBLIC_API_URL}/api/health`).reply(200, {
  status: 'healthy',
  message: 'Backend is running successfully',
});

mock.onGet(`${process.env.NEXT_PUBLIC_API_URL}/api/message`).reply(200, {
  message: "You've successfully integrated the backend!",
});

describe('Home page', () => {
  test('renders integration message', async () => {
    render(<Home />);
    await waitFor(() =>
      expect(screen.getByText(/Backend is connected/i)).toBeInTheDocument()
    );
  });

  test('renders backend URL', async () => {
    render(<Home />);
    await waitFor(() =>
      expect(
        screen.getByText(new RegExp(process.env.NEXT_PUBLIC_API_URL, 'i'))
      ).toBeInTheDocument()
    );
  });

  test('renders backend message', async () => {
    render(<Home />);
    await waitFor(() =>
      expect(
        screen.getByText(/You've successfully integrated the backend!/i)
      ).toBeInTheDocument()
    );
  });
});

