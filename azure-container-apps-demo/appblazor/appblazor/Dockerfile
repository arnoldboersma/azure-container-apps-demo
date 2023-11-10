#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY "azure-container-apps-demo.sln" "azure-container-apps-demo.sln"
COPY "docker-compose.dcproj" "docker-compose.dcproj"

COPY "app/app.csproj", "app/app.csproj"
COPY "api/api.csproj" "api/api.csproj"
COPY "appblazor/appblazor/Appblazor.csproj" "appblazor/appblazor/Appblazor.csproj"
COPY "appblazor/appblazor.Client/Appblazor.Client.csproj" "appblazor/appblazor.Client/Appblazor.Client.csproj"

COPY "Directory.Packages.props" "Directory.Packages.props"
#COPY "Directory.Build.props" "Directory.Build.props"
COPY "stylecop.ruleset" "stylecop.ruleset"
COPY "NuGet.config" "NuGet.config"

RUN dotnet restore "azure-container-apps-demo.sln"
COPY . .
WORKDIR "/src/appblazor/appblazor"
RUN dotnet build "./Appblazor.csproj" --no-restore -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Appblazor.csproj" --no-restore -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "appblazor.dll"]