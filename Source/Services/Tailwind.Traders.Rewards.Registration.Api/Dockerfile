#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat 
ARG imageTag=4.7.2-windowsservercore-ltsc2019
FROM mcr.microsoft.com/dotnet/framework/wcf:${imageTag}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Windows components required for WCF service hosted on IIS
RUN Add-WindowsFeature NET-WCF-TCP-Activation45; \
Add-WindowsFeature NET-WCF-HTTP-Activation45; \
Add-WindowsFeature Web-WebSockets

# Enable net.tcp protocol for default web site on IIS 
RUN windows\system32\inetsrv\appcmd.exe set app 'Default Web Site/' /enabledProtocols:"http,net.tcp"

WORKDIR /inetpub/wwwroot
COPY obj/Docker/publish .

EXPOSE 80
