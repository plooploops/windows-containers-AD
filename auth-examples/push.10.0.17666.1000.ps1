#MSMQ
param (
    [string]$repo = "myplooploops"
)

#base images
docker push "$repo/dotnet-framework:4.7.2-runtime-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/aspnet:4.7.2-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/iis:windowsservercore-insider-10.0.17666.1000"

# build the image to use for building apps
docker push "$repo/4.7-windowsservercore-1709-builder"

#IIS
docker push "$repo/windows-ad:no-auth-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:simple-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:iis-simple-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:impersonate-frontend-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:impersonate-backend-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:impersonate-explicit-frontend-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:impersonate-groupupn-backend-windowsservercore-insider-10.0.17666.1000"
docker push "$repo/windows-ad:impersonate-globalasax-backend-windowsservercore-insider-10.0.17666.1000"