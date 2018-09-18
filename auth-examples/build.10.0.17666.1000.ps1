param (
    [string]$repo = "myplooploops"
)

#base images
docker build -f DotNetFrameworkBase/Dockerfile -t "$repo/dotnet-framework:4.7.2-runtime-windowsservercore-insider-10.0.17666.1000" DotNetFrameworkBase
docker build -f AspNetBase/Dockerfile -t "$repo/aspnet:4.7.2-windowsservercore-insider-10.0.17666.1000" AspNetBase
docker build -f IISBase/Dockerfile -t "$repo/iis:windowsservercore-insider-10.0.17666.1000" IISBase

# build the image to use for building apps
docker build -f web-builder/Dockerfile -t "$repo/4.7.2-windowsservercore-insider-10.0.17666.1000-builder" web-builder

#build individual apps
docker build -f no-auth/Dockerfile -t "$repo/windows-ad:no-auth-windowsservercore-insider-10.0.17666.1000" no-auth
docker build -f windows-auth-simple/Dockerfile -t "$repo/windows-ad:simple-windowsservercore-insider-10.0.17666.1000" .
docker build -f iis-simple/Dockerfile -t "$repo/windows-ad:iis-simple-windowsservercore-insider-10.0.17666.1000" iis-simple
docker build -f windows-auth-impersonate-frontend/Dockerfile -t "$repo/windows-ad:impersonate-frontend-windowsservercore-insider-10.0.17666.1000" .
docker build -f windows-auth-impersonate-backend/Dockerfile -t "$repo/windows-ad:impersonate-backend-windowsservercore-insider-10.0.17666.1000" .
docker build -f windows-auth-impersonate-explicit-frontend/Dockerfile -t "$repo/windows-ad:impersonate-explicit-frontend-windowsservercore-insider-10.0.17666.1000" .
docker build -f windows-auth-impersonate-groupupn-backend/Dockerfile -t "$repo/windows-ad:impersonate-groupupn-backend-windowsservercore-insider-10.0.17666.1000" .
docker build -f windows-auth-impersonate-globalasax-backend/Dockerfile -t "$repo/windows-ad:impersonate-globalasax-backend-windowsservercore-insider-10.0.17666.1000" .
