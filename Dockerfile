FROM ubuntu:latest

# Update and install necessary packages
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

ENV LANG en_US.utf8

#ARG Ngrok
ARG Password

ENV Password=${Password}
#ENV Ngrok=${Ngrok}

# Install SSH, wget, unzip, and sudo
RUN apt install ssh wget unzip sudo -y > /dev/null 2>&1

# Clean up apt cache
RUN apt clean

# Download ngrok and cloudflared
#RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN wget -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Install cloudflared
RUN dpkg -i cloudflared.deb

# Unzip ngrok
#RUN unzip ngrok.zip

# Add ngrok authtoken and start command to script
#RUN echo "./ngrok config add-authtoken ${Ngrok} &&" >>/1.sh
#RUN echo "./ngrok tcp 22 &>/dev/null &" >>/1.sh

# Add cloudflared service install command to script
RUN echo "cloudflared service install eyJhIjoiNTI2OGZiMjc5YTg1ZTVmNmYzY2I5NWJhZTAyYzkzNDQiLCJ0IjoiMzBlYTdlMjUtMGVlMC00MDRmLTgzYTYtOTMzYWQzMWFkNWUxIiwicyI6IlpqZGlOMlJtTWpRdFptVm1ZaTAwWlRjMExUbGpaR1l0WW1Ga1lqQXlZMk5rTXpZMCJ9 &&" >>/1.sh

# Setup SSH server
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/1.sh
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:${Password}|chpasswd
RUN service ssh start

# Make the script executable
RUN chmod 755 /1.sh

# Expose necessary ports
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Add commands to download and execute ooklaserver.sh
RUN wget https://install.speedtest.net/ooklaserver/ooklaserver.sh
RUN chmod a+x ooklaserver.sh

# Start the script
CMD /1.sh
