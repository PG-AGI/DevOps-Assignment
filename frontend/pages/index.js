import { useState } from 'react';

const MOCK_INCIDENTS = [
  {
    id: 1,
    title: "Production DB Latency",
    status: "open",
    created_at: "2023-10-20T10:00:00Z"
  },
  {
    id: 2,
    title: "Failed Deployment",
    status: "resolved",
    created_at: "2023-10-19T14:30:00Z"
  },
  {
    id: 3,
    title: "API Rate Limiting Issue",
    status: "open",
    created_at: "2023-10-21T09:15:00Z"
  }
];

export default function Home() {
  const [incidents, setIncidents] = useState(MOCK_INCIDENTS);

  const toggleStatus = (id) => {
    setIncidents(incidents.map(incident => {
      if (incident.id === id) {
        return {
          ...incident,
          status: incident.status === 'open' ? 'resolved' : 'open'
        };
      }
      return incident;
    }));
  };

  return (
    <div>
      <h1>Incident Notes</h1>

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
                onClick={() => toggleStatus(incident.id)}
                className="toggle-btn"
              >
                Mark as {incident.status === 'open' ? 'Resolved' : 'Open'}
              </button>
            </div>
          </div>
        ))}
      </div>

      <style jsx>{`
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
