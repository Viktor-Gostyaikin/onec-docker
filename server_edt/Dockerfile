ARG ONES_REGISTRY_URL
ARG ONES_IMAGE
ARG ONES_TAG
ARG ONEC_VERSION=8.3.23.2040

ARG EDT_REGISTRY_URL
ARG EDT_IMAGE
ARG EDT_TAG

ARG OSCRIPT_REGISTRY_URL
ARG OSCRIPT_IMAGE
ARG OSCRIPT_TAG

ARG REGISTRY_URL=bellsoft
ARG IMAGE=liberica-openjdk-debian
ARG TAG=11

# Используем образ сервера 1С
FROM ${ONES_REGISTRY_URL}/${ONES_IMAGE}:${ONES_TAG} as image_1C

# Используем образ 1С EDT
FROM ${EDT_REGISTRY_URL}/${EDT_IMAGE}:${EDT_TAG} as image_edt

# Используем образ OSCRIPT
# FROM ${OSCRIPT_REGISTRY_URL}/${OSCRIPT_IMAGE}:${OSCRIPT_TAG} as image_oscript

# Переход к финальному образу
FROM ${REGISTRY_URL}/${IMAGE}:${TAG}
LABEL maintainer="Victor Gostyaikin <v.gostyaikin@itworks.group>, ITWorks Group"

ARG EDT_TAG
ARG EDT_VERSION=$EDT_TAG
## Настройка 1С

ARG ONEC_VERSION
ENV ONEC_VERSION=$ONEC_VERSION

COPY --from=image_1C /opt/1cv8 /opt/1cv8
RUN echo 'export PATH=$PATH:/opt/1cv8/x86_64/${ONEC_VERSION}' >> /root/.bashrc

RUN set -xe \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
      iproute2 \
      imagemagick \
      fontconfig \
      ca-certificates \
  && rm -rf /var/lib/apt/lists/* /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG ru_RU.UTF-8

## Настройка EDT
COPY --from=image_edt /opt/1C /opt/1C

ENV EDT_VERSION=$EDT_VERSION
ENV PATH="/opt/1C/1CE/components/1c-enterprise-ring:$PATH"
ENV PATH="/opt/1C/1CE/components/1c-edt-${EDT_VERSION}+10-x86_64:$PATH"


## Настройка OScript


ENTRYPOINT ["/bin/bash"]