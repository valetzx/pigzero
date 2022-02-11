FROM debian as builder

## Supports x86_64, x86, arm, and arm64

RUN apt-get update && apt-get install -y curl gnupg
RUN apt-key adv --keyserver pgp.mit.edu --recv-keys 0x1657198823e52a61  && \
    echo "deb http://download.zerotier.com/debian/buster buster main" > /etc/apt/sources.list.d/zerotier.list
RUN apt-get update && apt-get install -y zerotier-one=1.8.4
ADD main.sh /main.sh

FROM debian:buster-slim
LABEL version="1.8.4"
LABEL description="Containerized ZeroTier One for use on CoreOS or other Docker-only Linux hosts."

# ZeroTier relies on UDP port 9993
EXPOSE 9993/udp 80

RUN mkdir -p /var/lib/zerotier-one
COPY --from=builder /usr/sbin/zerotier-cli /usr/sbin/zerotier-cli
COPY --from=builder /usr/sbin/zerotier-idtool /usr/sbin/zerotier-idtool
COPY --from=builder /usr/sbin/zerotier-one /usr/sbin/zerotier-one
ADD main.sh /main.sh

RUN chmod a+x /main.sh
ENTRYPOINT ["/main.sh"]
CMD ["zerotier-one"]
