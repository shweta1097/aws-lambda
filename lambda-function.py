import boto3
def lambda_handler(event, context):
    ec2 = boto3.client('ec2')

    # Extract the Volume ARN / ID from the EventBridge trigger
    volume_arn = event['detail']['responseElements']['volumeId']

    #Describe the ec2 to get which volumetype it is using
    response = ec2.describe_volumes(VolumeIds=[volume_arn])
    volume = response['Volumes'][0]
    if volume['VolumeType'] == 'gp2':
        print(f"Compliance Violation: Found gp2 volume {volume_arn}. Upgrading to gp3...")
        # Modify the volume type to gp3
        ec2.modify_volume(VolumeId=volume_arn, VolumeType='gp3')
        print(f"Successfully initiated upgrade for {volume_arn} to gp3...")
    else:
        print(f"Volume {volume_arn} is complaint ({volume['volume_type']}). No action needed")