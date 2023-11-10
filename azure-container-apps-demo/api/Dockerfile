#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY "azure-container-apps-demo.sln" "azure-container-apps-demo.sln"
COPY "docker-compose.dcproj" "docker-compose.dcproj"

COPY "app/app.csproj", "app/app.csproj"
COPY "api/api.csproj" "api/api.csproj"
COPY "appblazor/appblazor/Appblazor.csproj" "appblazor/appblazor/Appblazor.csproj"
COPY "appblazor/appblazor.Client/Appblazor.Client.csproj" "appblazor/appblazor.Client/Appblazor.Client.csproj"

#COPY "Directory.Packages.props" "Directory.Packages.props"
#COPY "Directory.Build.props" "Directory.Build.props"
COPY "stylecop.ruleset" "stylecop.ruleset"
COPY "NuGet.config" "NuGet.config"

RUN dotnet restore "azure-container-apps-demo.sln"
COPY . .
WORKDIR "/src/api"
RUN dotnet build "api.csproj" --no-restore -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "api.csproj" --no-restore -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "api.dll"]