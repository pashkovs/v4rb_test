# Use an ARM base image
FROM arm32v7/ubuntu:latest

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy your script into the container
COPY v4rb_install_test_linux_armhf.sh /usr/local/bin/v4rb_install_test_linux_armhf.sh

# Make the script executable
RUN chmod +x /usr/local/bin/v4rb_install_test_linux_armhf.sh

# Set the entrypoint to your script
ENTRYPOINT ["/usr/local/bin/v4rb_install_test_linux_armhf.sh"]