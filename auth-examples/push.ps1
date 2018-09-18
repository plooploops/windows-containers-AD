#MSMQ
param (
    [string]$repo = "myplooploops"
)

#base images
docker push "$repo/dotnet-framework:4.7.2-runtime-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/aspnet:4.7.2-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/iis:windowsservercore-insider-10.0.17666.1000"

#IIS
docker push "$repo/windows-ad:no-auth"
docker push "$repo/windows-ad:simple"
docker push "$repo/windows-ad:iis-simple"
docker push "$repo/windows-ad:impersonate-frontend"
docker push "$repo/windows-ad:impersonate-backend"
docker push "$repo/windows-ad:impersonate-explicit-frontend"
docker push "$repo/windows-ad:impersonate-groupupn-backend"
docker push "$repo/windows-ad:impersonate-globalasax-backend"

#base image
docker push "$repo/windows-ad:msmq-base-1803"

docker push "$repo/windows-ad:msmq-receiver-test"
docker push "$repo/windows-ad:msmq-sender-test"

#monolith
docker push "$repo/windows-ad:msmq-monolith-test"

#persistent volume
docker push "$repo/windows-ad:msmq-persistent-volume-bootstrap"
docker push "$repo/windows-ad:msmq-persistent-volume-sender-test"
docker push "$repo/windows-ad:msmq-persistent-volume-receiver-test"

#public queue
docker push "$repo/windows-ad:msmq-public-queue-receiver-test-1709"
docker push "$repo/windows-ad:msmq-public-queue-sender-test-1709"
docker push "$repo/windows-ad:msmq-public-queue-receiver-test-1803"
docker push "$repo/windows-ad:msmq-public-queue-sender-test-1803"