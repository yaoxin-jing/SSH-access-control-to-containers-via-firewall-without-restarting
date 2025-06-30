FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    apt-get clean

# Create new group to avoid "group operator exists" issue
RUN groupadd sshusers && useradd -m -s /bin/bash -g sshusers operator

# Prepare SSH server and authorized_keys
RUN mkdir -p /home/operator/.ssh && \
    mkdir -p /var/run/sshd && \
    echo "AllowUsers operator" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config

# Copy your public key
COPY id_rsa.pub /home/operator/.ssh/authorized_keys

# Set permissions
RUN chown -R operator:sshusers /home/operator/.ssh && \
    chmod 700 /home/operator/.ssh && \
    chmod 600 /home/operator/.ssh/authorized_keys

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]