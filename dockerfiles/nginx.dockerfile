FROM nginx:stable-alpine

ARG UID
ARG GID
ARG PROJECT_NAME

ENV UID=${UID}
ENV GID=${GID}
ENV PROJECT_NAME=${PROJECT_NAME}

# MacOS staff group's gid is 20
RUN delgroup dialout

RUN addgroup -g ${GID} --system ${PROJECT_NAME}
RUN adduser -G ${PROJECT_NAME} --system -D -s /bin/sh -u ${UID} ${PROJECT_NAME}
RUN sed -i "s/user  nginx/user ${PROJECT_NAME}/g" /etc/nginx/nginx.conf

ADD ./services_config/web_service/default.conf /etc/nginx/conf.d/

RUN mkdir -p /var/www/html