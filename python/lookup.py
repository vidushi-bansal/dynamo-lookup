import boto3
import json
import logging
from decimal import Decimal

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# JSON encoder for Decimal values
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')

# Helper function to check item matches the filter params
def matches_filters(item, filters):
    try:
        raw_data = item.get('raw_data')
        raw_tags = {}

        if raw_data:
            raw_json = json.loads(raw_data)
            raw_tags = raw_json.get("tags", {})

        for key, expected_value in filters.items():
            item_value = item.get(key)

            if item_value is not None:
                if str(item_value).lower() != expected_value:
                    return False
            else:
                # Check inside raw_data.tags with multiple casing attempts
                tag_val = (
                        raw_tags.get(key)
                        or raw_tags.get(key.capitalize())
                        or raw_tags.get(key.upper())
                )
                if tag_val is None or str(tag_val).lower() != expected_value:
                    return False

        return True
    except Exception as e:
        logger.warning(f"Error parsing item {item}: {e}")
        return False

def lambda_handler(event, context):
    query_params = event.get('queryStringParameters') or {}
    table_name = query_params.get('ddtable')
    if not table_name:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Missing ddtable parameter'})
        }

    logger.info(f"Scanning table: {table_name} with query: {query_params}")

    # Parse version safely
    version_param = query_params.get('version')
    try:
        requested_version = int(version_param) if version_param else None
    except ValueError:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Invalid version format'})
        }

    # Normalize filter params
    filter_params = {k.lower(): v.lower() for k, v in query_params.items() if k not in ['ddtable', 'version']}

    try:
        table = dynamodb.Table(table_name)
        response = table.scan()
        items = response.get('Items', [])

        # Handle pagination
        while 'LastEvaluatedKey' in response:
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            items.extend(response.get('Items', []))

        logger.info(f"Fetched {len(items)} items from table.")

        # Filter items
        filtered_items = [item for item in items if matches_filters(item, filter_params)]

        # Filter by requested version if specified
        if requested_version is not None:
            filtered_items = [item for item in filtered_items if item.get('version') == requested_version]

        # If no version was specified, return only the latest version
        if requested_version is None and filtered_items:
            filtered_items = [max(filtered_items, key=lambda item: item.get('version', 0))]

        if filtered_items:
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps(filtered_items, cls=DecimalEncoder)
            }
        else:
            return {
                'statusCode': 404,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps({'error': 'No matching items found'})
            }

    except Exception as e:
        logger.error(f"Error querying table: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
