# Используем базовый образ для скачивания
ARG DOCKER_REGISTRY_URL
ARG DOWNLOADER_IMAGE
ARG ONEC_VERSION

FROM ${DOWNLOADER_IMAGE} as downloader

# Копирование скрипта скачивания и локальных дистрибутивов
COPY ./scripts/download_yard.sh /download.sh
COPY ./distr /distr
RUN chmod +x /download.sh

# Скачивание дистрибутива 1С с использованием вынесенного скрипта
ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION

WORKDIR /tmp

# Установка необходимых пакетов и генерация локали
RUN apt-get update \
  && apt-get install -y \
          locales \
          p7zip-rar \
          p7zip-full \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ru_RU.UTF-8 \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

# Установка переменных окружения для корректной работы локали
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

RUN /download.sh "$ONEC_USERNAME" "$ONEC_PASSWORD" "$ONEC_VERSION" "client"

# Начало основной стадии сборки
FROM ubuntu:20.04 as base

# Копируем скрипты и файлы установки
ARG ONEC_VERSION
ARG gosu_ver=1.11
ARG nls_enabled=false
ENV nls=$nls_enabled
ENV distrPath=/tmp/downloads/Platform83/${ONEC_VERSION}
ENV installer_type=client

# RUN set -xe \
#   && chmod 777 -R /tmp \
#   && apt-get update \
#   && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
#       libwebkit2gtk

COPY ./scripts/install_new.sh /install.sh
COPY --from=downloader /tmp/ /tmp/
WORKDIR ${distrPath}      

SHELL ["/bin/bash", "-c"]
RUN ls . \
  && chmod +x /install.sh \
  && sync; /install.sh

# create symlink to current 1c:enterprise directory
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh

COPY ./configs/client/current/ /opt/1cv8/current/

FROM ubuntu:20.04
LABEL maintainer="Anton Kvashenkin <anton.jugatsu@gmail.com> (@jugatsu)"

ARG ONEC_VERSION
ARG onec_uid="999"
ARG onec_gid="999"

COPY --from=base /opt /opt

RUN set -xe \
  && chmod 777 -R /tmp \
  && apt-get update \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y --no-install-recommends \
  ca-certificates \
  libgtk2.0-0 \
  libwebkit2gtk-4.0-37 \
  libfontconfig1 \
  libgsf-1-114 \
  libglib2.0-0 \
  libmagickwand-6.q16-6 \
  libenchant-2-2 \
  dbus-x11 \
  at-spi2-core \
  && apt-get clean

RUN ln -s /usr/lib/x86_64-linux-gnu/libenchant-2.so.2 /usr/lib/libenchant.so.1

RUN apt-get install -y --no-install-recommends \
  locales \
  && apt-get clean \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

RUN apt-get install -y --no-install-recommends \
  libodbc1 \  
  libkrb5-dev \
  libgssapi-krb5-2 \
  ttf-mscorefonts-installer \
  && apt-get clean

RUN apt-get install -y --no-install-recommends \
  xvfb \
  && apt-get clean
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

RUN groupadd -r grp1cv8 --gid=$onec_gid \
  && useradd -r -g grp1cv8 --uid=$onec_uid --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8/

ENV ONEC_VERSION=$ONEC_VERSION

RUN echo export PATH=$PATH:/opt/1cv8/x86_64/${ONEC_VERSION} >> ~/.bashrc

RUN echo "DisableUnsafeActionProtection=.*" >> /opt/1cv8/x86_64/${ONEC_VERSION}/conf/conf.cfg

ENV DISPLAY=:99
RUN echo export DISPLAY=${DISPLAY} >> ~/.bashrc \
  && echo "Xvfb :99 -ac &" >> ~/.bashrc

ENTRYPOINT /bin/bash
