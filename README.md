Multi-Cloud Infrastructure Design – DevOps Assignment

Overview

This project demonstrates a structured multi-cloud infrastructure design across:
	•	Amazon Web Services (AWS)
	•	Google Cloud Platform (GCP)

The focus of this assignment is infrastructure thinking, scalability planning, and environment separation rather than application complexity.

⸻

Cloud & Region Selection

AWS
Region: ap-south-1 (Mumbai)
Reason: Low latency and cost efficiency.

GCP
Region: asia-south1
Reason: Geographic alignment and service availability.

⸻

Environment Strategy

Each cloud contains:
	•	Dev – Single small virtual machine
	•	Staging – Medium-sized virtual machine
	•	Production – Multiple instances with auto-scaling concept

This ensures environment isolation and safe promotion of changes.

⸻

Infrastructure as Code

Terraform is used to define infrastructure resources.

State Management Design:
	•	AWS: S3 backend with DynamoDB locking (design intention)
	•	GCP: Cloud Storage backend (design intention)
	•	Separate configuration per environment

⸻

Scalability & Availability

Production environments are designed to scale horizontally to handle traffic spikes.

Instance failure handling:
	•	Auto-scaling replaces failed instances.
	•	Load balancer routes traffic only to healthy instances.

⸻

Future Improvements
	•	Multi-region deployment
	•	CI/CD automation pipeline
	•	Kubernetes-based container orchestration
	•	Web Application Firewall integration
	
11. What Was Intentionally Not Implemented
	•	Kubernetes (overkill for this application)
	•	Multi-region failover
	•	CI/CD automation pipeline
	•	Web Application Firewall

Reason:
Focused on foundational infrastructure clarity within assignment constraints.	

