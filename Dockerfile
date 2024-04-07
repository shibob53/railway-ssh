FROM ubuntu:latest

# Update packages and install necessary tools
RUN apt update -y > /dev/null 2>&1 \
    && apt upgrade -y > /dev/null 2>&1 \
    && apt install locales ssh wget unzip sudo -y > /dev/null 2>&1 \
    && apt clean

# Set locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Set arguments and environment variables
ARG Password
ENV Password=${Password}

# Install ZeroTier
RUN apt-get install -y curl > /dev/null 2>&1 \
    && curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import \
    && curl -s 'https://install.zerotier.com/' | gpg --output - >/tmp/zt-install.sh \
    && bash /tmp/zt-install.sh > /dev/null 2>&1

# Join ZeroTier network
RUN zerotier-cli join 233ccaac27a7ce9f > /dev/null 2>&1

# Configure SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo root:${Password} | chpasswd \
    && service ssh restart

# Enable RDP
RUN apt-get install -y xrdp > /dev/null 2>&1 \
    && systemctl enable xrdp

# Expose ports
EXPOSE 22 80 443 3306 3389

# Start SSH and RDP services
CMD /usr/sbin/sshd -D && /etc/init.d/xrdp start
