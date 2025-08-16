FROM python:3.11-slim
WORKDIR /app
COPY packages/ai/pyproject.toml ./
COPY packages/ai/app ./app
COPY packages/ai/tests ./tests
RUN pip install poetry && poetry config virtualenvs.create false && poetry install --no-interaction --no-ansi
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
