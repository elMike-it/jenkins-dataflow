# Usamos una imagen base de Python
FROM python:3.11-slim

# Actualizamos los paquetes del sistema
RUN apt-get update && apt-get install -y \
    python3-venv \
    curl \
    gnupg && \
    apt-get clean

# Instalamos gcloud CLI
RUN curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    apt-get update && apt-get install -y google-cloud-sdk

# Instalamos las dependencias de Python necesarias
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip setuptools && \
    pip install -r /tmp/requirements.txt

# Establecemos el directorio de trabajo
WORKDIR /workspace

# Copiamos el script principal
COPY main.py /workspace/main.py


# Establecemos un entrypoint básico (opcional)
ENTRYPOINT ["python3"]
