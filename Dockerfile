FROM ubuntu:24.04 AS builder

ARG RUNNER_VERSION=2.329.0
ARG NODE_VERSION=24

WORKDIR /opt/action-runner

COPY ./entrypoint.sh ./entrypoint.sh

RUN apt-get update \
    && apt-get -qq install -y curl git jq libicu-dev lsb-release \
    ca-certificates gnupg build-essential maven \
    && curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get -y install nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && cd /opt/action-runner \
    && curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm -f ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && apt-get autoremove -y \
    && apt-get clean

RUN groupadd -g 1100 action-runner \
    && useradd -m -s /bin/bash -u 1100 -g 1100 action-runner \
    && chown -R action-runner:action-runner /opt/action-runner

USER action-runner
ENTRYPOINT ["sh", "./entrypoint.sh"]
CMD ["sh", "./run.sh"]
