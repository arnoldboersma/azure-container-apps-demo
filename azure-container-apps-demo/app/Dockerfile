#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["app/app.csproj", "app/"]
RUN dotnet restore "app/app.csproj"
COPY . .
WORKDIR "/src/app"
RUN dotnet build "app.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "app.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
RUN pwd
RUN ls
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "app.dll"]