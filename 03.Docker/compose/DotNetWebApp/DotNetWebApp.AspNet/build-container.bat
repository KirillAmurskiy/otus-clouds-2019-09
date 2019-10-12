dotnet restore
dotnet publish -c Release
docker build -t dotnetwebapp .