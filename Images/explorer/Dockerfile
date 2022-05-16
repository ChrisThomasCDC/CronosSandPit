
# Pretty much copy and paste from this legend, read link for detailed notes.
#https://chrissainty.com/containerising-blazor-applications-with-docker-containerising-a-blazor-webassembly-app/

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
EXPOSE 80

RUN git clone https://github.com/Nethereum/Nethereum-Explorer-Wallet-Template-Blazor.git .
RUN dotnet restore NethereumExplorer.ClientWasm/NethereumExplorer.ClientWasm.csproj
RUN dotnet build  NethereumExplorer.ClientWasm/NethereumExplorer.ClientWasm.csproj -c Release -o /app/build

FROM build AS publish
RUN dotnet publish  NethereumExplorer.ClientWasm/NethereumExplorer.ClientWasm.csproj -c Release -o /app/publish

FROM nginx:alpine AS final
WORKDIR /usr/share/nginx/html
COPY --from=publish /app/publish/wwwroot .
COPY nginx.conf /etc/nginx/nginx.conf

#docker run --rm -it --entrypoint bash bb-team/lightexplorer
#  docker build --no-cache -t bb-team/lightexplorer .
#  docker run --name explorer -d bb-team/lightexplorer