
## MSMQ with Persistent Volumes on Host

We will mount a persistent volume to the host (could be a Windows VM, Azure Windows VM) so that the private queue (e.g. .\private$\testQueue) will have the data stored in the mount.

![Persistent volume on host for MSMQ private queue with sender and receiver containers.](../media/persistent-volume/scenario.png 'Persistent Volume')

#### Links

These will describe some of the concepts that we're using in this scenario.

1. [MSMQ MQQB Protocol](https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-MQQB/[MS-MQQB].pdf)
1. [Windows Containers Networking](https://blogs.technet.microsoft.com/virtualization/2016/05/05/windows-container-networking/)
1. [Windows Containers Volumes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage)

#### Prep script

A setup script in  **.\scripts\persistent-volume-mount-prep.ps1** will help with this process, and we'll want to run it on the host.  We will run the containers **sequentially** as each of the containers will have their own queue manager, which will assume ownership of the file mount.  This **prevents two containers** from using the **same volume mount** and running at the **same time**.

```powershell
.\scripts\persistent-volume-mount-prep.ps1
```

The script will set up a **local folder** for testing the **volume mount** on the host, for instance C:\msmq.

It will grant **permissions** for **everyone** on that folder (this is just a test).

We will also want to verify the bootstrapped data will exist in the mount once we run the container.  If the script completes successfully, we'll have the **storage** and **mapping** folders in the **volume mount**.

![Persistent volume data.](../media/persistent-volume/volume-mount-data.png 'Queue Data')

#### Running the scenario

We can verify the permissions on the folder in PowerShell.

```powershell
Get-ACL C:\<local volume mount>
```

![Persistent volume permissions.](../media/persistent-volume/folder-permissions.png 'Permissions')

We'll want to run the containers next and point them to the local volume mount.

We can test the **sender** with the **default driver (NAT)** in an interative mode:
```powershell
docker run --name=persistent_volume_sender_test --security-opt "credentialspec=file://MSMQSend.json" -h MSMQSend -it -v c:\msmq\sender:c:/Windows/System32/msmq -e QUEUE_NAME='MSMQRec\private$\testQueue' -e TRACE_LEVEL=1 <my-repo>/windows-ad:msmq-persistent-volume-sender-test
```

We can test the **receiver** with the **default driver (NAT)** in an interative mode:
```powershell
docker run --name=persistent_volume_receiver_test --security-opt "credentialspec=file://MSMQRec.json" -h MSMQRec -it -v c:\msmq\receiver:c:/Windows/System32/msmq <my-repo>/windows-ad:msmq-persistent-volume-receiver-test
```

If we're using **transparent network driver**, it might look something like this:

Run the sender.

```powershell
docker run --security-opt "credentialspec=file://MSMQsend.json" -it -v C:\msmq\sender:c:/Windows/System32/msmq -h MSMQsend --network=tlan2 --dns=10.123.80.123 --name persistent_store -e QUEUE_NAME='MSMQRec\private$\testQueue' <my-repo>/windows-ad:msmq-sender-test powershell
```

Run the receiver.

```powershell
docker run --security-opt "credentialspec=file://MSMQRec.json" -it -v C:\msmq\receiver:c:/Windows/System32/msmq -h MSMQRec --network=tlan2 --dns=10.123.80.123 --name persistent_store_receiver <my-repo>/windows-ad:msmq-receiver-test powershell
```

If we're using **NAT network driver** with **port mappings**, it might look something like this:

Run the sender.

```powershell
docker run --security-opt "credentialspec=file://MSMQsend.json" -it -v C:\msmq\sender:c:/Windows/System32/msmq -h MSMQsend -p 80:80 -p 4020:4020 -p 4021:4021 -p 135:135/udp -p 389:389 -p 1801:1801/udp -p 2101:2101 -p 2103:2103/udp -p 2105:2105/udp -p 3527:3527 -p 3527:3527/udp -p 2879:2879 --name persistent_store -e QUEUE_NAME='MSMQRec\private$\testQueue' <my-repo>/windows-ad:msmq-sender-test powershell
```

Run the receiver.

```powershell
docker run --security-opt "credentialspec=file://MSMQRec.json" -it -v C:\msmq\receiver:c:/Windows/System32/msmq -h MSMQRec -p 80:80 -p 4020:4020 -p 4021:4021 -p 135:135/udp -p 389:389 -p 1801:1801/udp -p 2101:2101 -p 2103:2103/udp -p 2105:2105/udp -p 3527:3527 -p 3527:3527/udp -p 2879:2879 --ip 172.31.230.92 --name persistent_store_receiver <my-repo>/windows-ad:msmq-receiver-test powershell
```


![Persistent volume both containers.](../media/persistent-volume/together.png 'Both Containers Interactive')

We can also stop the Sender container (docker stop [container id]), and then the Receiver container should have less messages.

![Persistent volume only receiver containers.](../media/persistent-volume/only-receiver.png 'Only receiver container Interactive')