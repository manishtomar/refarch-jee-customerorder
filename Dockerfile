FROM websphere-liberty:webProfile7

# Install dockerize to wait for DB containers to load before connecting
#RUN apt-get update && apt-get install -y wget
ENV DOCKERIZE_VERSION v0.6.0
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
&& rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# Install db2cli to bootstrap the DB
ADD v10.5fp9_linuxx64_odbc_cli.tar.gz /opt/ibm
ENV LD_LIBRARY_PATH /opt/ibm/odbc_cli/clidriver/lib

RUN /opt/ibm/wlp/bin/installUtility install  --acceptLicense \
    appSecurity-2.0 \
    ejbLite-3.1 \
    ldapRegistry-3.0 \
    localConnector-1.0 \
    jaxrs-1.1 \
    jdbc-4.1 \
    jpa-2.0 \
    jsp-2.3 \
    servlet-3.1

ADD https://artifacts.alfresco.com/nexus/content/repositories/public/com/ibm/db2/jcc/db2jcc4/10.1/db2jcc4-10.1.jar /db2lib/db2jcc4.jar

ADD http://download.osgeo.org/webdav/geotools/com/ibm/db2jcc_license_cu/9/db2jcc_license_cu-9.jar /db2lib/db2jcc_lisence_cu.jar

COPY Common/server.xml /config/server.xml
COPY Common/server.env /config/server.env
COPY CustomerOrderServicesApp/target/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /config/apps

COPY Common/*.sql /config/

EXPOSE 9080
