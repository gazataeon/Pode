FROM mcr.microsoft.com/powershell:preview-alpine-3.10
LABEL maintainer="Matthew Kelly (Badgerati)"
RUN mkdir -p /usr/local/share/powershell/Modules/Pode
COPY ./src/ /usr/local/share/powershell/Modules/Pode

# Install git, process tools
RUN apk update && apk add git && apk add procps

# Clean up
RUN rm -rf /var/lib/apt/lists/*
