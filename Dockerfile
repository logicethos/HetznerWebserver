FROM ubuntu

ENV TZ=UTC 
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
                nginx certbot \
                python3 python3-pip \
                cron dnsutils joe
                

RUN pip install certbot-dns-hetzner

COPY getcerts.sh /getcerts.sh
COPY start.sh /start.sh
COPY getDomainList /getDomainList

RUN chmod +x /getcerts.sh
RUN chmod +x /start.sh
RUN chmod +x /getDomainList

RUN echo "42 0 1 * * /getcerts.sh >> /var/log/cron.log 2>&1" | crontab -

CMD ["/bin/bash", "/start.sh"]
