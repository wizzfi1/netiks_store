FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /workspace

COPY packages/shared-python /workspace/packages/shared-python
COPY services/identity-service /workspace/services/identity-service

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir /workspace/packages/shared-python /workspace/services/identity-service

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

RUN useradd --create-home --shell /usr/sbin/nologin appuser

COPY --from=builder /opt/venv /opt/venv
COPY services/identity-service /workspace/services/identity-service

WORKDIR /workspace/services/identity-service
USER appuser

CMD ["sh", "-c", "alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port 8001"]
