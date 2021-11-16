#!python

import boto3
import base64

def create_launch_template(aws_region, template_name, mime_file):
    with open(mime_file, "rb") as f:
        read_data = f.read()
        user_data = base64.b64encode(read_data)
    launch_template_json = {
        "LaunchTemplateName": template_name,
        "LaunchTemplateData": {
            "UserData": str(user_data)[2:-1]
        }
    }    
    ## REMEMBER TO CHANGE THIS IF YOU HAVE MORE THAN ONE PROFILE##
    ec2_client = boto3.client('ec2', region_name=aws_region)
    ec2_client.create_launch_template(**launch_template_json)

if __name__ == "__main__":
    create_launch_template("us-east-1", "virus_hunting_pipeline_template", "mount-efs-template.yml")
