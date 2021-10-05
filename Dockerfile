FROM debian:buster

RUN apt-get update
RUN apt-get install --yes ca-certificates curl apt-transport-https lsb-release gnupg
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ buster main" | tee /etc/apt/sources.list.d/azure-cli.list
RUN apt-get update
RUN apt-get install --yes azure-cli

ADD azsqlfirewall.sh /azsqlfirewall.sh
RUN chmod +x /azsqlfirewall.sh
CMD ["/bin/bash", "/azsqlfirewall.sh"]
