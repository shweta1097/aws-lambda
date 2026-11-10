import boto3
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

ec2_client = boto3.client("ec2")

# Lambda function to stop EC2 instances based on specific tags
def lambda_handler(event, context):
  logger.info("Starting automated evening cost-optimization sequence...")
  # Filter for instances that are RUNNING and have the tag Environment=dev
  filters = [
    {'Name': 'tag:Environment', 'Values': ['dev']},
    {'Name': 'instance-state-name', 'Values': ['running']}
  ]
  try:
    #scan for instances that are matching filter criteria
    response = ec2_client.describe_instances(Filter=filters)
    instance_ids = []
    for reservation in response['Reservations']:
      for instance in reservation['Instances']:
        instance_ids.append(instance['InstanceId'])
    #if active instance are found stop them
    if instance_ids:
        logger.info(f"Running dev instances found: {instance_ids}. Stopping them now...")
        ec2_client.stop_instances(InstanceIds=instance_ids)
        logger.info("Stop command executed successfully.")
    else:
        logger.info("No running dev instances found matching 'Environment=dev'. No action needed.")
  except Exception as e:
     logger.error(f"Error during exception: {str(e)}")
     raise e 
  return {
     'statusCode': 200,
     'body': 'Evening cost optimization sequence finished processing.'
  }
