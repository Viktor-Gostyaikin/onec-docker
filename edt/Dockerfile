# Используем базовый образ для скачивания
ARG DOWNLOADER_REGISTRY_URL=library
ARG DOWNLOADER_IMAGE=ubuntu
ARG DOWNLOADER_TAG=20.04

ARG DOCKER_REGISTRY_URL=bellsoft
ARG BASE_IMAGE=liberica-openjdk-debian
ARG BASE_TAG=11

FROM ${DOWNLOADER_REGISTRY_URL}/${DOWNLOADER_IMAGE}:${DOWNLOADER_TAG} as downloader

# Копирование скрипта скачивания и локальных дистрибутивов
COPY ./scripts/download_yard.sh /download.sh
COPY ./distr /distr
RUN chmod +x /download.sh

# Скачивание дистрибутива 1С с использованием вынесенного скрипта
ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG EDT_VERSION=2023.3.5

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

RUN /download.sh "$ONEC_USERNAME" "$ONEC_PASSWORD" "$EDT_VERSION" "edt"

# Переход к финальному образу
FROM ${DOCKER_REGISTRY_URL}/${BASE_IMAGE}:${BASE_TAG}
LABEL maintainer="Victor Gostyaikin <v.gostyaikin@itworks.group>, ITWorks Group"

ARG EDT_VERSION=2023.3.5
ARG downloads=downloads/DevelopmentTools10/${EDT_VERSION}
ENV LANG ru_RU.UTF-8

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    # downloader dependencies
    curl \
    # edt dependencies
    libgtk-3-0 \
    locales \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/* \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

COPY --from=downloader /tmp/${downloads} /tmp/${downloads}

# Install EDT

WORKDIR /tmp/${downloads}

RUN chmod +x ./1ce-installer-cli \
  && ./1ce-installer-cli install all --ignore-hardware-checks --ignore-signature-warnings\
  && rm -rf /tmp/* \
  && mv $(dirname $(find /opt/1C/1CE -name ring)) /opt/1C/1CE/components/1c-enterprise-ring
  
ENV EDT_PATH="/opt/1C/1CE/components/1c-edt-${EDT_VERSION}+10-x86_64"

ENV PATH="/opt/1C/1CE/components/1c-enterprise-ring:$PATH"
ENV PATH="$EDT_PATH:$PATH"

WORKDIR /
