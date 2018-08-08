param (
    [string]$repo = "myplooploops"
)

#MSMQ
docker build -f MSMQBase/Dockerfile -t "$repo/windows-ad:msmq-base-1803" .
docker build -f MSMQReceiverTest/Dockerfile -t "$repo/windows-ad:msmq-receiver-test" .
docker build -f MSMQSenderTest/Dockerfile -t "$repo/windows-ad:msmq-sender-test" .

#monolith
docker build -f MSMQMonolithTest/Dockerfile -t "$repo/windows-ad:msmq-monolith-test" .

#persistent volume
docker build -f MSMQPersistentVolume/MSMQPersistentVolumeBootstrap/Dockerfile -t "$repo/windows-ad:msmq-persistent-volume-bootstrap" .
docker build -f MSMQPersistentVolume/MSMQPersistentVolumeSenderTest/Dockerfile -t "$repo/windows-ad:msmq-persistent-volume-sender-test" .
docker build -f MSMQPersistentVolume/MSMQPersistentVolumeReceiverTest/Dockerfile -t "$repo/windows-ad:msmq-persistent-volume-receiver-test" .

#public queue
docker build -f MSMQPublicQueueTest/MSMQReceiverTest-1709/Dockerfile -t "$repo/windows-ad:msmq-public-queue-receiver-test-1709" .
docker build -f MSMQPublicQueueTest/MSMQSenderTest-1709/Dockerfile -t "$repo/windows-ad:msmq-public-queue-sender-test-1709" .
docker build -f MSMQPublicQueueTest/MSMQReceiverTest-1803/Dockerfile -t "$repo/windows-ad:msmq-public-queue-receiver-test-1803" .
docker build -f MSMQPublicQueueTest/MSMQSenderTest-1803/Dockerfile -t "$repo/windows-ad:msmq-public-queue-sender-test-1803" .

