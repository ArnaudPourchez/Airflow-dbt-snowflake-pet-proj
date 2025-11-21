FROM dbeaver/cloudbeaver:24.2.3

USER root
RUN mkdir -p /opt/cloudbeaver/drivers/custom
COPY drivers/snowflake-jdbc-3.17.0.jar /opt/cloudbeaver/drivers/custom/
USER cloudbeaver
