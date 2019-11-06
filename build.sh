#!/bin/bash 

help () {
  echo " !! Missing arguments !! "
  echo "Run: ./build.sh <tag-name>"
}

#docker login
echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin

DOCKER_ORG=sixsq
DOCKER_IMAGE=wrapper-cleaner
DOCKER_CLI_EXPERIMENTAL=enabled

platforms="amd64 arm arm64"

if [[ -z $1 ]]
then
	help
	exit 1
else
	manifest=${DOCKER_ORG}/${DOCKER_IMAGE}:${tag_name}
	echo "  --  Building ${manifest} for platforms: ${platforms}..."
fi


rm -Rf target/*.tar
mkdir -p target

for platform in $platforms
do
	# Build docker image
	docker run --rm --privileged -v ${PWD}:/tmp/work --entrypoint buildctl-daemonless.sh moby/buildkit:master \
	       build \
	       --frontend dockerfile.v0 \
	       --opt platform=linux/${platform} \
	       --opt filename=./Dockerfile \
	       --output type=tar,name=${manifest}-${platform},dest=/tmp/work/target/${DOCKER_IMAGE}-${platform}.docker.tar \
	       --local context=/tmp/work \
	       --local dockerfile=/tmp/work \
	       --progress plain

	# Load docker image locally
	docker load --input ./target/${DOCKER_IMAGE}-${platform}.docker.tar

	# Push platform specific image to docker hub
	docker push ${manifest}-${platform}

        
	docker manifest create "${manifest}" "${manifest}-${platform}"

	docker manifest annotate ${manifest} ${manifest}-${platform} --arch ${platform}

	docker manifest push --purge ${manifest}
done


rm -Rf target
