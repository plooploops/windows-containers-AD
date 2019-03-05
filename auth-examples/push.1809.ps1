#MSMQ
param (
    [string]$repo = "myplooploops"
)

#IIS
docker push "$repo/windows-ad:no-auth"
docker push "$repo/windows-ad:simple"
docker push "$repo/windows-ad:iis-simple"
docker push "$repo/windows-ad:impersonate-frontend-1803"
docker push "$repo/windows-ad:impersonate-backend-1803"
docker push "$repo/windows-ad:impersonate-explicit-frontend-1803"
docker push "$repo/windows-ad:impersonate-groupupn-backend-1803"
docker push "$repo/windows-ad:impersonate-globalasax-backend-1803"

#base image
docker push "$repo/windows-ad:msmq-base-1809"

docker push "$repo/windows-ad:msmq-receiver-test-1809"
docker push "$repo/windows-ad:msmq-sender-test-1809"

#monolith
docker push "$repo/windows-ad:msmq-monolith-test-1809"

#persistent volume
docker push "$repo/windows-ad:msmq-persistent-volume-bootstrap-1809"
docker push "$repo/windows-ad:msmq-persistent-volume-sender-test-1809"
docker push "$repo/windows-ad:msmq-persistent-volume-receiver-test-1809"

#public queue
docker push "$repo/windows-ad:msmq-public-queue-receiver-test-1709"
docker push "$repo/windows-ad:msmq-public-queue-sender-test-1709"
docker push "$repo/windows-ad:msmq-public-queue-receiver-test-1803"
docker push "$repo/windows-ad:msmq-public-queue-sender-test-1803"