# Build React frontend, run FastAPI that serves it (single process)
FROM node:20-alpine AS fe
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
COPY --from=fe /app/frontend/dist ./frontend/dist
ENV HOST=0.0.0.0 PORT=8000 VIRALMINT_FRONTEND_DIST=frontend/dist
EXPOSE 8000
# ponytail: assumes backend.main:app + app self-inits its SQLite/migrations on startup;
# if run.py does pre-start migration steps the CMD skips, switch CMD to `python run.py --server-only`
CMD ["sh","-c","uvicorn backend.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
