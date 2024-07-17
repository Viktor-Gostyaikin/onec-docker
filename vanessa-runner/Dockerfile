ARG BASE_IMAGE=ubuntu:20.04

FROM $BASE_IMAGE
LABEL maintainer="Anton Kvashenkin <anton.jugatsu@gmail.com> (@jugatsu)"

# Installing mono and oscript dependencies
ARG MONO_VERSION=6.12.0.122

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      gnupg \
      dirmngr \
      wget \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian stable-buster main" > /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get clean

  
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    mono-runtime \
    ca-certificates-mono \
    libmono-i18n4.0-all \
    libmono-system-runtime-serialization4.0-cil \
  && rm -rf /etc/apt/sources.list.d/mono-official-stable.list \
  && apt-get update \
  && cert-sync --user /etc/ssl/certs/ca-certificates.crt \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/* \
  && apt-get clean
  
# remove DST Root CA X3 cert if it exists
# COPY ./scripts/remove-dst-root-ca-x3.sh /remove-dst-root-ca-x3.sh
# RUN chmod +x /remove-dst-root-ca-x3.sh \
#   && /remove-dst-root-ca-x3.sh \
#   && rm /remove-dst-root-ca-x3.sh

RUN apt-get update \
  && apt-get install -y \
    locales \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ru_RU.UTF-8 \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
# Установка переменных окружения для корректной работы локали
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

# Installing oscript
ARG OVM_REPOSITORY_OWNER=oscript-library
ARG OVM_VERSION=v1.0.0-RC16
ARG ONESCRIPT_VERSION=1.9.1
ARG runner_ver=2.2.22
ARG ONESCRIPT_PACKAGES="add gitsync vanessa-runner@$runner_ver stebi"

RUN set -x \
  && wget https://github.com/${OVM_REPOSITORY_OWNER}/ovm/releases/download/${OVM_VERSION}/ovm.exe \
  && mv ovm.exe /usr/local/bin/ \
  && echo 'mono /usr/local/bin/ovm.exe "$@"' | tee /usr/local/bin/ovm \
  && chmod +x /usr/local/bin/ovm \
  && ovm use --install ${ONESCRIPT_VERSION}

ENV OSCRIPTBIN=/root/.local/share/ovm/current/bin
ENV PATH="$OSCRIPTBIN:$PATH"

# Update and prepare oscript packages
RUN opm install opm \
  && opm update --all

RUN opm install ${ONESCRIPT_PACKAGES}

RUN if echo "$ONESCRIPT_PACKAGES" | grep -q "gitsync"; then \
    gitsync plugins init \
    && gitsync plugins enable limit \
    && gitsync plugins disable limit; \
  fi

COPY ./oscript/docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh \
  && chmod +x /docker-entrypoint.sh

# RUN opm install vanessa-runner@$runner_ver
ENV VRUNNER_ROOT=/root/.local/share/ovm/${ONESCRIPT_VERSION}/lib/vanessa-runner
RUN echo 'export VRUNNER_ROOT=$VRUNNER_ROOT' >> ~/.bashrc

# ENTRYPOINT ["runner"]
