FROM debian:bullseye

RUN apt-get update
RUN apt-get install --yes python3 python3-pip

RUN apt-get install --yes libsodium-dev
RUN SODIUM_INSTALL=system pip install pynacl

RUN pip install azure-cli

RUN apt-get install --yes jq
RUN apt-get install --yes curl

ADD azsqlfirewall.sh /azsqlfirewall.sh
RUN chmod +x /azsqlfirewall.sh
CMD ["/bin/bash", "/azsqlfirewall.sh"]
