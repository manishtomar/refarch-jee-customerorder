FROM maven:latest AS builder

WORKDIR /app
COPY CustomerOrderServices/ CustomerOrderServices/
COPY CustomerOrderServicesProject/ CustomerOrderServicesProject/
COPY CustomerOrderServicesApp/ CustomerOrderServicesApp/
COPY CustomerOrderServicesTest/ CustomerOrderServicesTest/
COPY CustomerOrderServicesWeb/ CustomerOrderServicesWeb/
RUN cd /app/CustomerOrderServicesProject && mvn clean package

FROM websphere-liberty:webProfile7

# Install db2cli to bootstrap the DB
RUN apt-get update && apt-get install -y libxml2
ADD v10.5fp9_linuxx64_odbc_cli.tar.gz /opt/ibm

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
COPY --from=builder /app/CustomerOrderServicesApp/target/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /config/apps

COPY Common/*.sql /config/

COPY docker_entrypoint.sh /
CMD ["/docker_entrypoint.sh", "/opt/ibm/wlp/bin/server", "run", "defaultServer"]

EXPOSE 9080
