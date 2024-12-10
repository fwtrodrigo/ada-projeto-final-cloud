import json
import urllib.parse
import boto3
import os
import logging
from datetime import datetime


s3 = boto3.client("s3")
ddb = boto3.resource("dynamodb")
logger = logging.getLogger()
sns_client = boto3.client('sns', region_name='us-east-1')
sns = boto3.client('sns')

def lambda_handler(event, context):

    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(
        event["Records"][0]["s3"]["object"]["key"], encoding="utf-8"
    )

    try:
        response = s3.get_object(Bucket=bucket, Key=key)

        file_content = response["Body"].read().decode("utf-8")
        lines = file_content.splitlines()
        lines_count = len(lines)
        dt = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        ddb_table = os.environ["DYNAMODB_TABLE_NAME"]
        table = ddb.Table(ddb_table)

        item = {
            'filename': key,
            'lines_count': lines_count,
        }

        print("Inserindo dados no Dynamo.  " + str(dt))
        print("Dados: ", item)
        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Dados processados e salvos com sucesso"}),
        }

    except Exception as e:
        sns_arn = os.environ["SNS_TOPIC_ARN"]
        response = sns.publish(TopicArn=sns_arn, Message=file_content)
        
        print(f"Erro: {str(e)}")
        print(
            f"Erro durante a execução do processo. Verifique se o objeto {key} do bucket {bucket}. Verifique se o objeto existe e se o bucket está na mesma região da função."
        )
        raise e
