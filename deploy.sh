#! /bin/bash

containerId=`docker ps -a --filter name="cosine-backend" | awk '{print $1}'`
echo "$containerId"
if [ "$containerId" != "" ]; then
	echo "containerId: $containerId"
	docker stop $containerId
	docker rm -f $containerId
	echo "成功删除容器:$containerId"
fi

imageId=`docker images | grep -w registry.sensetime.com/demos/cosine-backend | awk '{print $3}'`
echo "$imageId"
if [ "imageId" != "" ]; then
	docker rmi -f $imageId
	echo "成功删除镜像:$imageId"
fi
