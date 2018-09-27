# AD with Windows Containers

Examples for getting started with Windows containers and AD.  The commands below have been adopted by following basic steps in this [gist to configure AD properly](https://gist.github.com/PatrickLang/27c743782fca17b19bf94490cbb6f960). 

To get started:

1. Clone this repo. The commands below where written and run from the WSL.

2. Set up AD
    - [Create Domain Controller](AD/ad-new-forest-domain/README.md)
    - Create Non-Admin User for testing 
    - [Create Domain Joined VM](AD/vm-domain-join/README.md)
    - [Configure AD with gMSA](AD/create-gmsa/README.md)
3. Run Samples
    - [IIS](Scenarios-Read-Me/README-IIS.md)
    - [MSMQ Monolith](Scenarios-Read-Me/README-Monolith.md)
    - [MSMQ Persistent Volume on Host](Scenarios-Read-Me/README-Persistent-Volume.md)
    - [MSMQ Persistent Volume on Host with Azure File SMB](Scenarios-Read-Me/README-Persistent-Volume-Azure-Files.md)

# Remote Debugging (Optional)

Remote debugging by installing VS debugger in the container. (blog post available)

# Samples

To build the samples (using [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)) run the commands below (be sure to use your images in commands for each example).  Alternatively you can use the provided docker images on my docker hub repo.

**WSL**

```powershell
./auth-examples/build.sh <your-docker-repo>
```

**Powershell**

```powershell
./auth-examples/build.ps1 <your-docker-repo>
```

To publish to a docker repository:

**WSL**

```powershell
docker login
./auth-examples/push.sh <your-docker-repo>
```

**Powershell**

```powershell
docker login
./auth-examples/push.ps1 <your-docker-repo>
```
***
## Environment variables

* QUEUE_NAME - This will be the path for the queue.  E.g. for **private queue** .\private$\TestQueue for **public queue** worker\TestQueue
* DIRECT_FORMAT_PROTOCOL - This will be the direct format protocol.  It can be something like OS, TCP, etc.  See the direct format naming for appropriate protocols.
* USER - This will search for a UPN to try to impersonate.