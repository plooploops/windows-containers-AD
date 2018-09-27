# Remote Debugging

These notes are adapted from this [Remote Debugging](https://www.richard-banks.org/2017/02/debug-net-in-windows-container.html) article.

We can make sure that the script will sit in the dockerfile for the container we'd like to use for remote debugging.  Also, for simplification purposes, we'll assume that we're using the NAT network and that Visual Studio is on the container host.  This will assist in reaching the container for Visual Studio.  


Also, the visual studio remote monitoring application will use ports depending on [Visual Studio version](https://docs.microsoft.com/en-us/visualstudio/debugger/remote-debugger-port-assignments?view=vs-2017)

## Make sure the container has the tools running and ports open

Our Dockerfile for the container should have the following commands included.

```
EXPOSE 4020 4021 #ports depend on VS version
RUN Invoke-WebRequest -OutFile c:\rtools_setup_x64.exe -Uri https://aka.ms/vs/15/release/RemoteTools.amd64ret.enu.exe; `
    c:\rtools_setup_x64.exe /install /quiet
```

Separately, we could run them if we make sure to have the ports open.  Again, the port number will depend on the visual studio version.  Also, if we're running the container using NAT network and visual studio on the host, we may not need to with the port mapping as we could pick them up in the local network through msvsmon discovery.

```
docker run -it -p 4020:4020 -p 4021:4021 <image id>
```
And then exec into the container

```
docker exec -it <containerid>
```

And once inside the container, run the following PowerShell commands.

```
Invoke-WebRequest -OutFile c:\rtools_setup_x64.exe -Uri https://aka.ms/vs/15/release/RemoteTools.amd64ret.enu.exe
c:\rtools_setup_x64.exe /install /quiet
```

## Run the container with port mapping

Port 4020 and 4021 should be open.

```
docker run -d -p 4020:4020 -p 4021:4021 myrepo/myimage:mytag
```

## Make sure the appropriate processes are running

### Attachable Process
If we want to debug IIS, we'll want to make sure the w3wp process is running.  We can also attach to the app inside the container.  We may need to trigger this by hitting an endpoint exposed by the app so that the requests will be served and the process will appear.

This will return which processes are running in a given container.
```
docker exec -it <id/name> ps
```

### MSVSMON is running
In any case, we'll want to also make sure that the debugging monitor is running too.

```
docker exec -it <id/name> "C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64\msvsmon.exe" /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs
```

There's also an alternate way where we can run it directly in the folder while we've attached to the running container.

```
cd "C:\Program Files\Microsoft Visual Studio 15.0\Common7\IDE\Remote Debugger\x64"
.\msvsmon.exe /nostatus /silent /noauth /anyuser /nosecuritywarn /FallbackLoadRemoteManagedPdbs
```

## Attach to the container process from Visual Studio

Find the running container from Visual Studio.  If we have msvsmon running and the ports + container is network reachable from the host for Visual Studio, we should be able to see an option to attach to the remote address.

![Find Container.](../media/remote-debugging/remote-debugging-step-1.png 'Find Container')

Assuming that the process we want to debug is running in the container, we should be able to attach to it as well.  For IIS, we'll want to make sure that w3wp is running, and we can try to ping the container endpoint to make sure that the IIS process will respond.

![Attach Process.](../media/remote-debugging/remote-debugging-step-2.png 'Attach Process')

