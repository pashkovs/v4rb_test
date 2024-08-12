# Use an ARM base image
FROM arm32v7/ubuntu:latest

RUN apt-get update && apt-get install -y \
    libglib2.0-0t64 \
    libunwind8 \
    && rm -rf /var/lib/apt/lists/*

COPY TestProjectConsole/ /opt/TestProjectConsole
COPY v4rb_armhf_32_lin.deb /opt/TestProjectConsole

RUN dpkg -i /opt/TestProjectConsole/v4rb_armhf_32_lin.deb

ENTRYPOINT ["/opt/TestProjectConsole/TestProjectConsole"]