FROM xhofe/alist:v3.44.0

SHELL ["/bin/bash", "-c"]

COPY run.sh /run.sh
RUN chmod +x /run.sh
RUN find / -name alist -type f
ENTRYPOINT ["/run.sh"]


