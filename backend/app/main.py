from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Allow all origins for Cloud Run
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "healthy", "message": "Backend is running successfully"}

@app.get("/api/message")
def message():
    return {"message": "You've successfully integrated the backend!"}

# Add a root route
@app.get("/")
def root():
    return {"message": "Backend root endpoint is working!"}

@app.get("/api/secret")
def read_secret():
    secret = os.getenv("APP_SECRET_KEY", "NOT_SET")
    return {
        "secret_loaded": secret != "NOT_SET"
