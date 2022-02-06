FROM arm32v7/python:3.7.6-alpine3.11

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

# Prequisites
RUN apk update && apk --no-cache add --virtual mydependencies gcc musl-dev linux-headers \
    libffi-dev libxml2-dev libxslt-dev libressl-dev curl gnupg  libc-dev g++ \
    libxml2 unixodbc-dev mariadb-dev postgresql-dev

##Download the desired package(s)
#RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.1.1-1_amd64.apk
##RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.1.2-1_amd64.apk
#
#
##(Optional) Verify signature, if 'gpg' is missing install it using 'apk add gnupg':
#RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/msodbcsql17_17.5.1.1-1_amd64.sig
##RUN curl -O https://download.microsoft.com/download/e/4/e/e4e67866-dffd-428c-aac7-8d28ddafb39b/mssql-tools_17.5.1.2-1_amd64.sig
#
#RUN curl https://packages.microsoft.com/keys/microsoft.asc  | gpg --import -
#RUN gpg --verify msodbcsql17_17.5.1.1-1_amd64.sig msodbcsql17_17.5.1.1-1_amd64.apk
##RUN gpg --verify mssql-tools_17.5.1.2-1_amd64.sig mssql-tools_17.5.1.2-1_amd64.apk
#
#
##Install the package(s)
#RUN apk add --allow-untrusted msodbcsql17_17.5.1.1-1_amd64.apk
##RUN apk add --allow-untrusted mssql-tools_17.5.1.2-1_amd64.apk
#
## expose port when not using docker-compose
#EXPOSE 9000

##prometheus metrics
#ENV prometheus_multiproc_dir /tmp
#ENV PROMETHEUS_PORT 9200

WORKDIR /app
COPY requirements.txt /app
#RUN pip install -r requirements.txt
RUN pip install \
        --no-cache-dir \
        --compile \
        --global-option=build_ext \
        --global-option="-j 4" \
        -r requirements.txt
RUN pip install uwsgi
RUN apk del mydependencies
COPY . /app
CMD [ "uwsgi", "uwsgi.ini" ]
