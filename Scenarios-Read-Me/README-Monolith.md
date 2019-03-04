
## MSMQ Monolith

We will want to run the MSMQ Monolith container.  Conceptually, we're going to use a private queue that will be accessible from within the container by both the sender and receiver applications.

The queue by default will be located at .\private$\testQueue.

![Monolith with private queue.](../media/monolith/scenario.png 'Monolith')

```powershell
docker run -it <my-repo>/windows-ad:msmq-monolith-test
```

We should be able to see the private queue accessible from both the sender and receiver applications.  

Since we're in interactive mode, we can also attach to the running container and run the applications separately.  We can also examine the logs if we redirect output to the file system.

![Monolith with private queue.](../media/monolith/logging.png 'Monolith Logs')

### Running the applications

```powershell
docker run -d <my-repo>/windows-ad:msmq-monolith-test
```

```powershell
docker exec -it <my-container-id> powershell
# run this in the container
C:\Sender\MSMQSenderTest.exe
```

```powershell
docker exec -it <my-container-id> powershell
# run this in the container
C:\Receiver\MSMQReceiverTest.exe
```

![Test Success.](../media/monolith/successful-test.png 'Monolith test')
