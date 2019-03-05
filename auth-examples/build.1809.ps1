param (
    [string]$repo = "myplooploops"
)

# build the image to use for building apps
docker build -f web-builder/Dockerfile -t "$repo/4.7-windowsservercore-1709-builder" web-builder

#build individual apps
docker build -f no-auth/Dockerfile -t "$repo/windows-ad:no-auth" no-auth
docker build -f windows-auth-simple/Dockerfile -t "$repo/windows-ad:simple" .
docker build -f iis-simple/Dockerfile -t "$repo/windows-ad:iis-simple" iis-simple
docker build -f windows-auth-impersonate-frontend/Dockerfile -t "$repo/windows-ad:impersonate-frontend-1803" .
docker build -f windows-auth-impersonate-backend/Dockerfile -t "$repo/windows-ad:impersonate-backend-1803" .
docker build -f windows-auth-impersonate-explicit-frontend/Dockerfile -t "$repo/windows-ad:impersonate-explicit-frontend-1803" .
docker build -f windows-auth-impersonate-groupupn-backend/Dockerfile -t "$repo/windows-ad:impersonate-groupupn-backend-1803" .
docker build -f windows-auth-impersonate-globalasax-backend/Dockerfile -t "$repo/windows-ad:impersonate-globalasax-backend-1803" .

#MSMQ
docker build -f MSMQBase/Dockerfile.1809 -t "wincontainerhackfest.azurecr.io/windows-ad:msmq-base-1809" .

docker build -f MSMQBase/Dockerfile.1809 -t "$repo/windows-ad:msmq-base-1809" .
docker build -f MSMQReceiverTest/Dockerfile.1809 -t "$repo/windows-ad:msmq-receiver-test-1809" .
docker build -f MSMQSenderTest/Dockerfile.1809 -t "$repo/windows-ad:msmq-sender-test-1809" .

#monolith
docker build -f MSMQMonolithTest/Dockerfile.1809 -t "$repo/windows-ad:msmq-monolith-test-1809" .

#persistent volume
docker build -f MSMQPersistentVolume/MSMQPersistentVolumeBootstrap/Dockerfile.1809 -t "$repo/windows-ad:msmq-persistent-volume-bootstrap-1809" .
docker build -f MSMQPersistentVolume/MSMQPersistentVolumeSenderTest/Dockerfile.1809 -t "$repo/windows-ad:msmq-persistent-volume-sender-test-1809" .
docker build -f MSMQPersistentVolume/MSMQPersistentVolumeReceiverTest/Dockerfile.1809 -t "$repo/windows-ad:msmq-persistent-volume-receiver-test-1809" .

#public queue
docker build -f MSMQPublicQueueTest/MSMQReceiverTest-1709/Dockerfile -t "$repo/windows-ad:msmq-public-queue-receiver-test-1709" .
docker build -f MSMQPublicQueueTest/MSMQSenderTest-1709/Dockerfile -t "$repo/windows-ad:msmq-public-queue-sender-test-1709" .
docker build -f MSMQPublicQueueTest/MSMQReceiverTest-1803/Dockerfile -t "$repo/windows-ad:msmq-public-queue-receiver-test-1803" .
docker build -f MSMQPublicQueueTest/MSMQSenderTest-1803/Dockerfile -t "$repo/windows-ad:msmq-public-queue-sender-test-1803" .

