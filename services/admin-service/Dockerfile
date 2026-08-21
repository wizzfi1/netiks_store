FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /workspace

COPY packages/shared-python /workspace/packages/shared-python
COPY services/admin-service /workspace/services/admin-service

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip install --no-cache-dir /workspace/packages/shared-python /workspace/services/admin-service

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

RUN useradd --create-home --shell /usr/sbin/nologin appuser

COPY --from=builder /opt/venv /opt/venv
COPY services/admin-service /workspace/services/admin-service

WORKDIR /workspace/services/admin-service
USER appuser

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8005"]

