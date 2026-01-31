FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# 🔥 FIX: Make binary executable
RUN chmod +x /app/privatevault || true

# If privatevault is a script, ensure interpreter
RUN ls -l /app/privatevault || true

CMD ["/app/privatevault", "run", "demo"]
