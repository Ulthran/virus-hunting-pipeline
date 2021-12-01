import boto3
import sys
from csv import reader

def submit_jobs(SRA):
  # Job 0: Download

  result0 = client.submit_job(
    jobName=SRA+'_job0',
    jobQueue='vhp3_q',
    jobDefinition='vhp3_jobdef:9',
    containerOverrides={
      'resourceRequirements':{
        {
          'type': 'MEMORY',
          'value': '2048'
        },
        {
          'type': 'VCPU',
          'value': '1'
        }
      },
      'command': [
        '/efs/virus-hunting-pipeline/run/launcher0.sh',
        SRA
      ]
    },
    retryStrategy={
      'attempts': 3
    },
    timeout={
      'attemptDurationSeconds': 3600
    }
  )
  print(result0)

  # Job 1: Sunbeam and Megahit

  result1 = client.submit_job(
    jobName=SRA+'_job1',
    jobQueue='vhp3_q',
    dependsOn=[
      {
        'jobId': result0['jobId']
      }
    ],
    jobDefinition='vhp3_jobdef:9',
    containerOverrides={
      'resourceRequirements':{
        {
          'type': 'MEMORY',
          'value': '58000'
        },
        {
          'type': 'VCPU',
          'value': '36'
        }
      },
      'command': [
        '/efs/virus-hunting-pipeline/run/launcher1.sh',
        SRA
      ]
    },
    retryStrategy={
      'attempts': 3
    },
    timeout={
      'attemptDurationSeconds': 7200
    }
  )
  print(result1)

  # Job 2: Cenote and Cleanup

  result2 = client.submit_job(
    jobName=SRA+'_job2',
    jobQueue='vhp3_q',
    dependsOn=[
      {
        'jobId': result1['jobId']
      }
    ],
    jobDefinition='vhp3_jobdef:9',
    containerOverrides={
      'resourceRequirements':{
        {
          'type': 'MEMORY',
          'value': '58000'
        },
        {
          'type': 'VCPU',
          'value': '36'
        }
      },
      'command': [
        '/efs/virus-hunting-pipeline/run/launcher2.sh',
        SRA
      ]
    },
    retryStrategy={
      'attempts': 3
    },
    timeout={
      'attemptDurationSeconds': 10000
    }
  )
  print(result2)

def run_many(file):
  with open(file, 'r') as read_obj:
    csv_reader = reader(read_obj)
    for row in csv_reader:
      SRA = row[0]
      submit_job(SRA)
      
if __name__ == '__main__':
  file = str(sys.argv[1])
  boto3.setup_default_session(profile_name='penn') # only include this line if you have multiple AWS profiles
  # and change the profile_name to whatever your desired profile is (find profiles in ~/.aws/credentials probably)
  client = boto3.client('batch')
  
  run_many(file)