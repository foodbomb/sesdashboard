#export COMMIT_SHA=$(git log -1 --pretty='format:%h' master)
export COMMIT_SHA=$(echo $RANDOM | md5sum | head -c 8; echo)
IMAGE_TAG=$COMMIT_SHA-local
REPOSITORY_ADDRESS=238087339149.dkr.ecr.ap-southeast-2.amazonaws.com/ses-dashboard
DOCKER_IMAGE_NAME="$REPOSITORY_ADDRESS:$IMAGE_TAG"

docker build -t $DOCKER_IMAGE_NAME .

aws ecr --region ap-southeast-2 get-login-password | docker login --username AWS --password-stdin "${REPOSITORY_ADDRESS}"
docker push $DOCKER_IMAGE_NAME

echo $DOCKER_IMAGE_NAME
echo $IMAGE_TAG
