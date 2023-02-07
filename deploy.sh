ENV=${1,,}

function allow_connection_to_db() {
  SG_NAME=$1
  SECURITY_GROUP_ID=$(aws ec2 --profile admin describe-security-groups --filter=Name=group-name,Values=$METABASE_SG_NAME | jq -r .SecurityGroups[0].GroupId)
  SECURITY_RULE_ID=$(aws ec2 --region ap-southeast-2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges="[{CidrIp=0.0.0.0/0,Description='Temporary Terraform Cloud'}]" | jq -r .SecurityGroupRules[0].SecurityGroupRuleId)
  echo "$SECURITY_GROUP_ID $SECURITY_RULE_ID"
}

function revoke_db_access(){
  echo $1 $2

  SECURITY_GROUP_ID=$1
  SECURITY_RULE_ID=$2

  aws --region ap-southeast-2 ec2 revoke-security-group-ingress --group-id $SECURITY_GROUP_ID --security-group-rule-ids $SECURITY_RULE_ID > /dev/null
}

if [ "" == "$1" ]; then
  echo "Environment name not provider."
  echo "Please run: $0 [environment_name]. E.g.: $0 staging"
  exit 1;
fi;

TERRAFORM_FOLDER="./.cicd/terraform"
export ENVIRONMENT=$ENV
export NAMESPACE=$ENV

cd $TERRAFORM_FOLDER
TF_VARS_DIST_FILE="tfvars.$ENVIRONMENT.dist"
TF_VARS_FILE="variables.tfvars"

echo "Parsing $TF_VARS_DIST_FILE"
envsubst < "$TF_VARS_DIST_FILE" > "$TF_VARS_FILE"

find . -type f -name '*.tf*.dist' |
while read -r FILE; do
  NEW_FILENAME=${FILE/.dist/}
  echo "Parsing $NEW_FILENAME"
  envsubst < "$FILE" > "$NEW_FILENAME"
done


echo "ses-dashboard-${ENVIRONMENT}" | terraform init
tfswitch

METABASE_SG_NAME="metabase-${ENVIRONMENT}-sg"
echo "Updating SG ${SG_NAME} to allow TF Cloud temporary permission to access DB."

# This is a work-around to prevent terraform from inactivating the task definition
# Check https://github.com/hashicorp/terraform-provider-aws/issues/258
terraform state rm aws_ecs_task_definition.api || true
SG_DATA=$(allow_connection_to_db $METABASE_SG_NAME)
terraform apply -var-file="$TF_VARS_FILE"

echo "Deleting Terraform cloud rule $SG_DATA"
revoke_db_access $SG_DATA
# if clean up is configured
rm -f terraform.tf
rm -f variables.tfvars
