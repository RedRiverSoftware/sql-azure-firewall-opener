FROM mcr.microsoft.com/azure-cli

ADD azsqlfirewall.sh /azsqlfirewall.sh
RUN chmod +x /azsqlfirewall.sh
CMD ["/bin/bash", "/azsqlfirewall.sh"]
