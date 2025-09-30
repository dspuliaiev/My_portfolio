# Stage 1: Build
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --upgrade pip --no-cache-dir && pip install -r requirements.txt

COPY . /app/
RUN python manage.py collectstatic --noinput

# Stage 2: Final
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# All from first step
COPY --from=builder /app /app
COPY --from=builder /usr/local /usr/local

# Swith on the Gunicorn (port $PORT!)
CMD ["sh", "-c", "gunicorn --workers 2 --timeout 120 My_portfolio.wsgi:application --bind 0.0.0.0:$PORT"]


