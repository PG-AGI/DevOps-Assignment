import { useState, useEffect } from 'react';

export default function Home() {
  const [incidents, setIncidents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchIncidents();
  }, []);

  const fetchIncidents = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/incidents`);
      if (!response.ok) throw new Error('Failed to fetch incidents');
      const data = await response.json();
      setIncidents(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const toggleStatus = async (id, currentStatus) => {
    const newStatus = currentStatus === 'open' ? 'resolved' : 'open';
    try {
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/incidents/${id}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ status: newStatus }),
      });

      if (!response.ok) throw new Error('Failed to update status');

      // Optimistic update
      setIncidents(incidents.map(incident =>
        incident.id === id ? { ...incident, status: newStatus } : incident
      ));
    } catch (err) {
      alert('Error updating status: ' + err.message);
    }
  };

  return (
    <div>
      <h1>Incident Notes</h1>

      {loading && <div className="loading">Loading incidents...</div>}
      {error && <div className="error-message">Error: {error}</div>}

      {!loading && !error && incidents.length === 0 && (
        <div className="empty-state">No incidents found. Create one to get started!</div>
      )}

      <div className="incident-list">
        {incidents.map(incident => (
          <div key={incident.id} className={`incident-card ${incident.status}`}>
            <div className="incident-header">
              <h2>{incident.title}</h2>
              <span className={`status-badge ${incident.status}`}>
                {incident.status}
              </span>
            </div>
            <div className="incident-footer">
              <span className="date">
                {new Date(incident.created_at).toLocaleDateString()}
              </span>
              <button
                onClick={() => toggleStatus(incident.id, incident.status)}
                className="toggle-btn"
              >
                Mark as {incident.status === 'open' ? 'Resolved' : 'Open'}
              </button>
            </div>
          </div>
        ))}
      </div>

      <style jsx>{`
        .loading, .empty-state {
          text-align: center;
          margin-top: 3rem;
          color: #6b7280;
        }

        .error-message {
          background: #ffe4e6;
          color: #e11d48;
          padding: 1rem;
          border-radius: 8px;
          margin-top: 2rem;
        }

        .incident-list {
          display: flex;
          flex-direction: column;
          gap: 1rem;
          margin-top: 2rem;
        }

        .incident-card {
          border: 1px solid #eaeaea;
          border-radius: 8px;
          padding: 1.5rem;
          background: white;
          transition: box-shadow 0.2s ease;
        }

        .incident-card:hover {
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }

        .incident-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 1rem;
        }

        .incident-header h2 {
          margin: 0;
          font-size: 1.25rem;
        }

        .status-badge {
          padding: 0.25rem 0.75rem;
          border-radius: 999px;
          font-size: 0.875rem;
          font-weight: 600;
          text-transform: uppercase;
        }

        .status-badge.open {
          background-color: #ffe4e6;
          color: #e11d48;
        }

        .status-badge.resolved {
          background-color: #dcfce7;
          color: #166534;
        }

        .incident-footer {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-top: 1rem;
          padding-top: 1rem;
          border-top: 1px solid #f3f4f6;
        }

        .date {
          color: #6b7280;
          font-size: 0.875rem;
        }

        .toggle-btn {
          background: transparent;
          border: 1px solid #d1d5db;
          padding: 0.5rem 1rem;
          border-radius: 6px;
          cursor: pointer;
          font-size: 0.875rem;
          transition: all 0.2s;
        }

        .toggle-btn:hover {
          background: #f3f4f6;
          border-color: #9ca3af;
        }
      `}</style>
    </div>
  );
}
