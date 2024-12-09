import boto3
import random
import os
import logging
import json
import sys
from uuid import uuid4


class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
        }
        return json.dumps(log_record)


handler = logging.StreamHandler(sys.stdout)
formatter = JsonFormatter()
handler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(handler)
logger.setLevel(logging.INFO)


def create_client(service_name):
    try:
        access_key = os.getenv("AWS_ACCESS_KEY_ID")
        secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
        region = os.getenv("AWS_REGION")

        if not all([access_key, secret_key, region]):
            raise ValueError(
                "Credenciais AWS incompletas. Verifique as variáveis de ambiente."
            )

        client = boto3.client(
            service_name,
            aws_access_key_id=access_key,
            aws_secret_access_key=secret_key,
            region_name=region,
        )

        return client

    except Exception as e:
        logger.error(f"Erro ao criar cliente AWS: {e}")
        raise


def generate_file(prefix="ada-contabilidade", max_lines=100, min_lines=10):
    try:
        filename = f"{prefix}-{uuid4()}.txt"
        lines = random.randint(min_lines, max_lines)

        with open(filename, "w") as file:
            for ln in range(lines):
                file.write(f"linha {ln+1}\n")

        logger.info(f"Arquivo gerado: {filename} com {lines} linhas")
        return filename

    except IOError as e:
        logger.error(f"Erro ao gerar arquivo: {e}")
        raise


def upload_object(client, filename, bucket_name):
    try:
        client.upload_file(filename, bucket_name, filename)
        logger.info(
            f"Upload do arquivo {filename} para o bucket {bucket_name} concluido"
        )
        return True

    except Exception as e:
        logger.error(
            f"Erro durante o upload do arquivo {filename} para o bucket {bucket_name}: {e}"
        )
        raise


def main(client):
    bucket_name = os.getenv("AWS_BUCKET_NAME")

    try:
        filename = generate_file()

        if not os.path.exists(filename):
            raise FileNotFoundError(f"O arquivo {filename} não foi gerado corretamente")

        upload_object(client, filename, bucket_name)

        os.remove(filename)

    except boto3.exceptions.S3UploadFailedError as e:
        logger.error(f"Erro durante o upload para o S3: {e}")

    except Exception as e:
        logger.error(f"Erro durante a execução do programa: {e}")


if __name__ == "__main__":
    client = create_client("s3")
    main(client)
