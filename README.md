## # Group 08D12 DO-48: Marketing Service (Python Flask)
## Division
D12
## Group
Group 08D12
## Project Number
DO-46
## Problem Statement

Dockerized Marketing PHP Laravel Service

## Description

Containerize a Marketing service (built with PHP Laravel) using industry best practices for Docker. The project includes writing multi-stage Dockerfiles to optimize image size and security,alongside a Docker Compose configuration to orchestrate the application and its database dependencies. This ensures a consistent, portable development and production environment across the entire team.

## Structure
- `marketing_service/` — Flask app and Dockerfile
- `docker-compose.yml` — Orchestrates app and database

## Usage

### 1. Build and Run
```sh
docker-compose up --build
```
- The Flask app will be available at http://localhost:5000
- The Postgres database will be available at localhost:5432

### 2. Stopping
```sh
docker-compose down
```

## Environment Variables
- App: `FLASK_APP`, `FLASK_ENV`
- DB: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`

## Notes
- Multi-stage Dockerfile optimizes image size and security.
- Data is persisted in a Docker volume (`pgdata`).
- Update the Flask app to connect to the database as needed.

## Group Members
Gaurav Raundhale EN22IT301036

Saniya Khan  EN22IT301091

Soham Singh Khushwah  EN22IT301104

Vedant Meena     EN22IT301120
  
