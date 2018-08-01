#set -e

# for wsl to work
alias docker=docker.exe

#repo=$1
repo = 'jsturtevant'

#MSMQ
docker build -f MSMQReceiverTest/Dockerfile -t jsturtevant/windows-ad:msmq-receiver-test .
docker build -f MSMQSenderTest/Dockerfile -t jsturtevant/windows-ad:msmq-sender-test .