# Start both backend and frontend servers
# Run this in PowerShell

# Start backend in background
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'c:\Users\chalu\OneDrive\Desktop\DevOps\DevOps-Assignment\backend'; uvicorn app.main:app --reload --port 8000" -WindowStyle Normal -Verb RunAs

# Wait a moment
Start-Sleep -Seconds 2

# Start frontend in background
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'c:\Users\chalu\OneDrive\Desktop\DevOps\DevOps-Assignment\frontend'; npm run dev" -WindowStyle Normal -Verb RunAs

Write-Host "Servers starting..."
Write-Host "Backend: http://localhost:8000"
Write-Host "Frontend: http://localhost:3000"
