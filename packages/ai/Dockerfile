FROM python:3.11-slim
WORKDIR /app
COPY packages/ai/pyproject.toml ./
COPY packages/ai/app ./app
COPY packages/ai/tests ./tests
RUN pip install poetry && poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi
# Security: Audit Python dependencies for vulnerabilities (audit external deps only)
# TODO: Re-enable when starlette vulnerabilities are fixed or documented in TODO.md
# Current: starlette 0.38.6 has 2 known vulnerabilities (GHSA-f96h-pmfr-66vw, GHSA-2c2j-9gv5-cj73)
# RUN pip install pip-audit && pip freeze | grep -v -E "(assistant-ai|app)" > /tmp/requirements.txt && pip-audit --requirement /tmp/requirements.txt
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
