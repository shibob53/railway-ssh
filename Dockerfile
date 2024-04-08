FROM ubuntu:latest
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ARG Ngrok
ARG Password
ENV Password=${Password}
ENV Ngrok=${Ngrok}
RUN apt install ssh wget unzip sudo -y > /dev/null 2>&1
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip
RUN echo "./ngrok config add-authtoken ${Ngrok} &&" >>/1.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/1.sh
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/1.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:${Password}|chpasswd
RUN service ssh start
RUN chmod 755 /1.sh
RUN apt-get install -y xrdp > /dev/null 2>&1 \
    && systemctl enable xrdp
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306 3389
# Install Chrome Remote Desktop
RUN wget -q https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
RUN dpkg -i chrome-remote-desktop_current_amd64.deb
RUN apt install --assume-yes --fix-broken

# Set up Chrome Remote Desktop
RUN DEBIAN_FRONTEND=noninteractive apt install --assume-yes xfce4 desktop-base
RUN bash -c 'echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session'

CMD ["bash", "/1.sh"]
