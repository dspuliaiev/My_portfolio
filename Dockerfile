# Stage 1: Build
FROM python:3.11-slim AS builder

# Устанавливаем необходимые системные зависимости
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Обновляем пакеты и устанавливаем зависимости для сборки
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файл зависимостей
COPY requirements.txt /app/

# Обновляем pip и устанавливаем зависимости
RUN pip install --upgrade pip --no-cache-dir && pip install -r requirements.txt

# Копируем остальной код проекта
COPY . /app/

# Собираем статические файлы
RUN python

# Stage 2: Final
FROM python:3.11-slim

# Устанавливаем необходимые системные зависимости
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Обновляем пакеты и устанавливаем зависимости для работы
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем установленные зависимости из builder stage
COPY --from=builder /usr/local /usr/local

# Копируем остальной код проекта
COPY . /app/

# Команда для запуска Django с использованием Gunicorn
CMD ["gunicorn", "--workers", "2", "--timeout", "120", "My_portfolio.wsgi:application", "--bind", "0.0.0.0:8000"]

