FROM  maven:3.6.3-jdk-8  as builder
WORKDIR  /root
COPY ./* /root
RUN  mvn clean package -Dmaven.test.skip -Denv=release


FROM canal/osbase:v2
# install canal
COPY docker/image/ /tmp/docker/
COPY /root/target/canal.deployer-*.tar.gz /home/admin/

RUN \
    cp -R /tmp/docker/alidata /alidata && \
    chmod +x /alidata/bin/* && \
    mkdir -p /home/admin && \
    cp -R /tmp/docker/app.sh /home/admin/  && \
    cp -R /tmp/docker/admin/* /home/admin/  && \
    /bin/cp -f alidata/bin/lark-wait /usr/bin/lark-wait && \

    mkdir -p /home/admin/canal-server && \
    tar -xzvf /home/admin/canal.deployer-*.tar.gz -C /home/admin/canal-server && \
    /bin/rm -f /home/admin/canal.deployer-*.tar.gz && \

    tar zxvf /tmp/node_exporter.tar.gz -C /home/admin && \
    ln -s /home/admin/node_exporter-0.18.1.linux-arm64 /home/admin/node_exporter && \

    mkdir -p home/admin/canal-server/logs  && \
    chmod +x /home/admin/*.sh  && \
    chmod +x /home/admin/bin/*.sh  && \
    chown admin: -R /home/admin && \
    yum clean all && \
    true

# 11110 admin , 11111 canal , 11112 metrics, 9100 exporter
EXPOSE 11110 11111 11112 9100

WORKDIR /home/admin

ENTRYPOINT [ "/alidata/bin/main.sh" ]
CMD [ "/home/admin/app.sh" ]
