import boto3
import json
import mysql.connector
import os

def lambda_handler(event, context):
    secret_id = event['SecretId']
    token = event['ClientRequestToken']
    step = event['Step']

    secrets_manager = boto3.client('secretsmanager')

    if step == "createSecret":
        create_secret(secrets_manager, secret_id, token)
    elif step == "setSecret":
        set_secret(secrets_manager, secret_id, token)
    elif step == "testSecret":
        test_secret(secrets_manager, secret_id, token)
    elif step == "finishSecret":
        finish_secret(secrets_manager, secret_id, token)
    else:
        raise ValueError("Invalid step parameter")

    return {"statusCode": 200, "body": json.dumps("Secret rotation successful")}

def create_secret(secrets_manager, secret_id, token):
    current_secret = get_secret(secrets_manager, secret_id)
    new_username = current_secret['username']
    new_password = generate_password(secrets_manager)

    new_secret = {
        'username': new_username,
        'password': new_password
    }

    secrets_manager.put_secret_value(SecretId=secret_id, ClientRequestToken=token, SecretString=json.dumps(new_secret), VersionStages=['AWSPENDING'])

def set_secret(secrets_manager, secret_id, token):
    pending_secret = get_secret(secrets_manager, secret_id, 'AWSPENDING')
    current_secret = get_secret(secrets_manager, secret_id)

    db_connection = mysql.connector.connect(
        host=os.environ['DB_HOST'],
        user=current_secret['username'],
        password=current_secret['password']
    )

    cursor = db_connection.cursor()
    cursor.execute(f"ALTER USER '{pending_secret['username']}'@'%' IDENTIFIED BY '{pending_secret['password']}'")
    db_connection.commit()
    cursor.close()
    db_connection.close()

def test_secret(secrets_manager, secret_id, token):
    pending_secret = get_secret(secrets_manager, secret_id, 'AWSPENDING')

    db_connection = mysql.connector.connect(
        host=os.environ['DB_HOST'],
        user=pending_secret['username'],
        password=pending_secret['password']
    )
    db_connection.close()

def finish_secret(secrets_manager, secret_id, token):
    secrets_manager.update_secret_version_stage(
        SecretId=secret_id,
        VersionStage='AWSCURRENT',
        MoveToVersionId=token,
        RemoveFromVersionId=get_secret_version_id(secrets_manager, secret_id, 'AWSCURRENT')
    )

def get_secret(secrets_manager, secret_id, version_stage='AWSCURRENT'):
    response = secrets_manager.get_secret_value(SecretId=secret_id, VersionStage=version_stage)
    return json.loads(response['SecretString'])

def get_secret_version_id(secrets_manager, secret_id, version_stage):
    response = secrets_manager.describe_secret(SecretId=secret_id)
    return response['VersionIdsToStages'][version_stage][0]

def get_environment_bool(variable_name, default_value):
    """Loads the environment variable and converts it to the boolean.

    Args:
        variable_name (string): Name of environment variable

        default_value (bool): The result will fallback to the default_value when the environment variable with the given name doesn't exist.

    Returns:
        bool: True when the content of environment variable contains either 'true', '1', 'y' or 'yes'
    """
    variable = os.environ.get(variable_name, str(default_value))
    return variable.lower() in ['true', '1', 'y', 'yes']

def generate_password(secrets_manager):
    passwd = secrets_manager.get_random_password (
        ExcludeCharacters=os.environ.get('EXCLUDE_CHARACTERS', '/@"\'\\'),
        PasswordLength=int(os.environ.get('PASSWORD_LENGTH', 32)),
        ExcludeNumbers=get_environment_bool('EXCLUDE_NUMBERS', False),
        ExcludePunctuation=get_environment_bool('EXCLUDE_PUNCTUATION', False),
        ExcludeUppercase=get_environment_bool('EXCLUDE_UPPERCASE', False),
        ExcludeLowercase=get_environment_bool('EXCLUDE_LOWERCASE', False),
        RequireEachIncludedType=get_environment_bool('REQUIRE_EACH_INCLUDED_TYPE', True)
    )
    return passwd
