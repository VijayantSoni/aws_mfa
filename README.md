# aws_mfa
Script to update MFA credentials automatically instead of having to generate, copy and paste each time the credentials expire.


__Setup__

1. Create file ~/.aws/config with aws profiles and add related info to each profile as required. Example: 
```
[default]
region = us-west-2
output = json
[profile stage]
region = us-east-1
output = json
[profile production]
region = us-west-2
```
2. [Add an MFA device](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_enable_virtual.html) and [get your ARN](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_checking-status.html)
3. Save your ARN at ~/.aws/aws_arn_\<profile> . Check `sample_aws_arn_prd`
4. Create or edit ~/.aws/credentials file. Check `sample_aws_credentials`
5. Source update_mfa.sh from ~/.bash_profile.sh by adding below line at the end:
```
source <path>/update_mfa.sh
```

__Usage__
```
update_mfa_token <profile> <token_code_from_mfa_device>

update_mfa_token prd 111111
```
This will update the credentials in ~/.aws/credentials with the latest one, and you can use AWS CLI to access your resources. Example below uses `mfa` profile, which we updated above with the latest credentials to get terminated nodes for a cluster by passing cluster ID.
```
aws --profile mfa --region us-west-2 emr list-instances --cluster-id "<cluster_id>" --instance-states TERMINATED --query 'Instances[*].[Ec2InstanceId,Status.Timeline.EndDateTime]' --output text
```
