#MSMQ
param (
    [string]$repo = "myplooploops"
)

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
