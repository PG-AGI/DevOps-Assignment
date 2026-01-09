import { useState } from 'react';
import { useRouter } from 'next/router';

export default function NewIncident() {
    const [title, setTitle] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const router = useRouter();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');

        try {
            const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/incidents`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ title, status: 'open' }),
            });

            if (!response.ok) {
                throw new Error('Failed to create incident');
            }

            router.push('/');
        } catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div>
            <h1>Create New Incident</h1>

            <form onSubmit={handleSubmit} className="incident-form">
                {error && <div className="error-message">{error}</div>}

                <div className="form-group">
                    <label htmlFor="title">Incident Title</label>
                    <input
                        id="title"
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        required
                        placeholder="e.g., Database Connection Timeout"
                        disabled={loading}
                    />
                </div>

                <div className="form-actions">
                    <button type="button" onClick={() => router.push('/')} className="cancel-btn" disabled={loading}>
                        Cancel
                    </button>
                    <button type="submit" className="submit-btn" disabled={loading}>
                        {loading ? 'Creating...' : 'Create Incident'}
                    </button>
                </div>
            </form>

            <style jsx>{`
        .incident-form {
          background: white;
          padding: 2rem;
          border-radius: 8px;
          border: 1px solid #eaeaea;
          margin-top: 2rem;
          max-width: 500px;
        }

        .error-message {
          background: #ffe4e6;
          color: #e11d48;
          padding: 0.75rem;
          border-radius: 6px;
          margin-bottom: 1.5rem;
          font-size: 0.875rem;
        }

        .form-group {
          display: flex;
          flex-direction: column;
          gap: 0.5rem;
          margin-bottom: 1.5rem;
        }

        label {
          font-weight: 600;
          font-size: 0.875rem;
        }

        input {
          padding: 0.75rem;
          border: 1px solid #d1d5db;
          border-radius: 6px;
          font-size: 1rem;
        }

        input:focus {
          outline: none;
          border-color: #0070f3;
          ring: 2px solid #0070f3;
        }

        .form-actions {
          display: flex;
          gap: 1rem;
          justify-content: flex-end;
        }

        .submit-btn {
          background: #0070f3;
          color: white;
          border: none;
          padding: 0.75rem 1.5rem;
          border-radius: 6px;
          font-weight: 600;
          cursor: pointer;
          transition: background 0.2s;
        }

        .submit-btn:hover {
          background: #0056b3;
        }

        .submit-btn:disabled {
          background: #93c5fd;
          cursor: not-allowed;
        }

        .cancel-btn {
          background: transparent;
          border: 1px solid #d1d5db;
          padding: 0.75rem 1.5rem;
          border-radius: 6px;
          cursor: pointer;
          transition: background 0.2s;
        }

        .cancel-btn:hover {
          background: #f3f4f6;
        }
      `}</style>
        </div>
    );
}
