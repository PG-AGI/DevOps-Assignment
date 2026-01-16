# Kubernetes Deployment Manifests for Alternative Option

This directory can be used if you want to deploy to Kubernetes instead of/in addition to cloud platforms.

## GKE (Google Kubernetes Engine)

```yaml
# backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: pg-agi-backend
  labels:
    app: pg-agi-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: pg-agi-backend
  template:
    metadata:
      labels:
        app: pg-agi-backend
    spec:
      containers:
      - name: pg-agi-backend
        image: gcr.io/PROJECT_ID/pg-agi-backend:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: pg-agi-backend
spec:
  selector:
    app: pg-agi-backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer
```

## EKS (AWS Elastic Kubernetes Service)

Similar structure, but use ECR image URLs:
```yaml
image: ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/pg-agi-backend:latest
```

## AKS (Azure Kubernetes Service)

Similar structure, but use ACR image URLs:
```yaml
image: myregistry.azurecr.io/pg-agi-backend:latest
```

## To deploy Kubernetes manifests, add to GitHub Actions:

```yaml
- name: Deploy to GKE
  run: |
    gcloud container clusters get-credentials pg-agi-cluster --region us-central1
    kubectl apply -f k8s/
    kubectl set image deployment/pg-agi-backend pg-agi-backend=gcr.io/${{ env.GCP_PROJECT }}/pg-agi-backend:${{ steps.image-tag.outputs.tag }}
    kubectl rollout status deployment/pg-agi-backend
```
