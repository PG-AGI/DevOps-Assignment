import Link from 'next/link';

export default function Navbar() {
    return (
        <nav>
            <div className="container">
                <Link href="/" className="logo">
                    Incident Notes
                </Link>
                <ul>
                    <li>
                        <Link href="/">All Incidents</Link>
                    </li>
                    <li>
                        <Link href="/new">New Incident</Link>
                    </li>
                </ul>
            </div>
        </nav>
    );
}
