dotnet restore DotNetWebApp/DotNetWebApp.AspNet
dotnet publish -c Release DotNetWebApp/DotNetWebApp.AspNet
docker build -t dotnetwebapp -f Dockerfile.DotNetApp .
docker build -t nginx-reverseproxy -f Dockerfile.Nginx .