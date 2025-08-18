FROM python:3.11-slim
WORKDIR /app
COPY packages/ai/pyproject.toml ./
COPY packages/ai/app ./app
COPY packages/ai/tests ./tests
RUN pip install poetry && poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi
# Security: Audit Python dependencies for vulnerabilities (audit external deps only)
RUN pip install pip-audit && pip freeze | grep -v -E "(assistant-ai|app)" > /tmp/requirements.txt && pip-audit --strict --requirement /tmp/requirements.txt
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
