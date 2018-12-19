FROM microsoft/azure-cli:2.0.53

ADD azsqlfirewall.sh /azsqlfirewall.sh
RUN chmod +x /azsqlfirewall.sh
CMD ["/bin/bash", "/azsqlfirewall.sh"]