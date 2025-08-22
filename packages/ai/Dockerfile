FROM python:3.13.7-alpine3.22
WORKDIR /app
# Security: Install required packages and create non-root user
RUN apk add --no-cache shadow && \
    addgroup -S python && \
    adduser -D -s /bin/sh -G python python
COPY packages/ai/pyproject.toml ./
COPY packages/ai/app ./app
COPY packages/ai/tests ./tests
RUN pip install poetry && poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi
# Security: Audit Python dependencies for vulnerabilities (audit external deps only)
RUN pip install pip-audit && pip freeze | grep -v -E "(assistant-ai|app)" > /tmp/requirements.txt && pip-audit --strict --requirement /tmp/requirements.txt
# Security: Change ownership to non-root user and set proper permissions
RUN chown -R python:python /app && \
    chmod -R 755 /app && \
    chmod -R 644 /app/pyproject.toml
# Security: Switch to non-root user
USER python
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
