
function generate_mfa_token(){
	# $1 -> Profile name as configured in ~/.aws/config
	# #$2 -> Token code from MFA device
	aws --profile "$1" sts get-session-token --serial-number `cat ~/.aws/aws_arn` --token-code "$2" > /tmp/aws_auth
}

function update_mfa_token(){
	# $1 -> Profile name as configured in ~/.aws/config
	# #$2 -> Token code from MFA device
	generate_mfa_token "$1" "$2"

	# Fetch new auth
	new_aws_access_key_id=`grep "AccessKeyId" "/tmp/aws_auth" | cut -d ":" -f 2 | tr -d "," | tr -d '"' | tr -d '[:space:]'`
	new_aws_secret_access_key=`grep "SecretAccessKey" "/tmp/aws_auth" | cut -d ":" -f 2 | tr -d "," | tr -d '"' | tr -d '[:space:]'`
	new_aws_session_token=`grep "SessionToken" "/tmp/aws_auth" | cut -d ":" -f 2 | tr -d "," | tr -d '"' | tr -d '[:space:]'`

	# Fetch old auth
	# Make sure to pick creds for MFA profile
	old_aws_access_key_id=`grep mfa -A 10 ~/.aws/credentials | grep "aws_access_key_id" | cut -d "=" -f 2 | tr -d "," | tr -d '"' | tr -d '[:space:]'`
	old_aws_secret_access_key=`grep mfa -A 10 ~/.aws/credentials | grep "aws_secret_access_key" | cut -d "=" -f 2 | tr -d "," | tr -d '"' | tr -d '[:space:]'`
	old_aws_session_token=`grep mfa -A 10 ~/.aws/credentials | grep "aws_session_token" | cut -d "=" -f 2 | tr -d "," | tr -d '"' | tr -d '[:space:]'`

	# Update auth
	sed -i '.bup' "s|$old_aws_access_key_id|$new_aws_access_key_id|g" ~/.aws/credentials
	sed -i '.bup' "s|$old_aws_secret_access_key|$new_aws_secret_access_key|g" ~/.aws/credentials
	sed -i '.bup' "s|$old_aws_session_token|$new_aws_session_token|g" ~/.aws/credentials

	echo "****** AWS MFA Auth updated successfully ******"
}
