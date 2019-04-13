# Active Directory with Windows Containers

Examples for getting started with Windows containers and AD.  The commands below have been adopted by following basic steps in this [gist to configure AD properly](https://gist.github.com/PatrickLang/27c743782fca17b19bf94490cbb6f960). 

Unless otherwise noted, the majority of these scenarios have been tested using SAC 1709 and 1803, running as windows server containers (process isolation, not hyper-v containers).  

Keep in mind the following points when using container versions earlier that 1809 (Windows Server 2019).

1. The container host VMs must be *equal to or greater* than the version of the container running. If the container host VMs is running a version greater than the container itself, the container must be run in hyper-v isolation mode. (For these scenarios, we matched our containers to the container host VMs, as GMSAs do not work when using hyper-v isolation for 1709/1803 containers.)
2. Prior to Server 2019, GMSA functionality required them to be matched 1:1 to each container.  This limits the ability to scale a containerized application easily. All these scenarios assume only one container per GMSA will be running. 

To get started:

1. Clone this repo. The commands below where written and run from the WSL.

2. Set up AD
    - [Create Domain Controller](AD/ad-new-forest-domain/README.md)
    - [Create Domain Joined VM](AD/vm-domain-join/README.md)
    - [Configure AD with gMSA](AD/create-gmsa/README.md)
3. Run Samples
    - [IIS](Scenarios-Read-Me/README-IIS.md)
    - [IIS on Azure Service Fabric](Scenarios-Read-Me/README-IIS-SF-Cluster.md)
    - [MSMQ Monolith](Scenarios-Read-Me/README-Monolith.md)
    - [MSMQ Persistent Volume on Host](Scenarios-Read-Me/README-Persistent-Volume.md)
    - [MSMQ Persistent Volume on Host with Azure File SMB](Scenarios-Read-Me/README-Persistent-Volume-Azure-Files.md)
     - [MSMQ Persistent Volume on Host with Azure File SMB with Multiple Hosts](Scenarios-Read-Me/README-Persistent-Volume-Azure-Files-Multiple-Hosts.md)


## Links

References to concepts and additional supporting documentation. 

1. [Windows Containers Networking](https://blogs.technet.microsoft.com/virtualization/2016/05/05/windows-container-networking/)
1. [Windows Containers Volumes](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/container-storage)
1. [IIS on Docker Hub](https://hub.docker.com/r/microsoft/iis/)
1. [GMSA Windows Containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/manage-containers/manage-serviceaccounts)
1. [Deploying Windows Containers](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/deploy-containers-on-server)
1. [Version Compatibility](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility)
1. [NSG Ports](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/nsg-quickstart-portal)
1. [GMSA Set up Reference](https://gist.github.com/PatrickLang/27c743782fca17b19bf94490cbb6f960)
1. [Remote Debugging](https://www.richard-banks.org/2017/02/debug-net-in-windows-container.html)
1. [SQL Server Setup Notes](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/connect-to-sql-server-when-system-administrators-are-locked-out?view=sql-server-2017
)

## Remote Debugging (Optional)

Remote debugging by installing VS debugger in the container. (Blog post in reference list above.)

## Samples

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

### Environment variables for MSMQ Samples

* QUEUE_NAME - This will be the path for the queue.  E.g. for **private queue** .\private$\TestQueue for **public queue** worker\TestQueue
* DIRECT_FORMAT_PROTOCOL - This will be the direct format protocol.  It can be something like OS, TCP, etc.  See the direct format naming for appropriate protocols.
* USER - This will search for a UPN to try to impersonate.