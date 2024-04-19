FROM ubuntu:latest
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ARG Ngrok
ARG Password
ENV Password=${Password}
ENV Ngrok=${Ngrok}
RUN apt install ssh wget unzip -y > /dev/null 2>&1
RUN apt clean
RUN apt install curl sudo -y
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN wget -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
RUN dpkg -i cloudflared.deb
RUN unzip ngrok.zip
RUN echo "./ngrok config add-authtoken ${Ngrok} &&" >>/1.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/1.sh
RUN echo "cloudflared service install eyJhIjoiNTI2OGZiMjc5YTg1ZTVmNmYzY2I5NWJhZTAyYzkzNDQiLCJ0IjoiMzBlYTdlMjUtMGVlMC00MDRmLTgzYTYtOTMzYWQzMWFkNWUxIiwicyI6IlpqZGlOMlJtTWpRdFptVm1ZaTAwWlRjMExUbGpaR1l0WW1Ga1lqQXlZMk5rTXpZMCJ9 &&" >>/1.sh
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/1.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:${Password}|chpasswd
RUN service ssh start
RUN chmod 755 /1.sh
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306
CMD  /1.sh
