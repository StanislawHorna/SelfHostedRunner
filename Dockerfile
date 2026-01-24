FROM ubuntu:24.04

LABEL version="1.0.1"
LABEL repository="https://github.com/StanislawHornaGitHub/SelfHostedRunner"

ARG RUNNER_VERSION="2.331.0"
ARG PWSH_VERSION="7.4.3"

ENV ACCESS_TOKEN="xxx"
ENV GITHUB_OBJECT="xxx"
ENV LABELS=""


RUN apt-get update -y \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl wget jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip libicu-dev \
    ca-certificates gnupg lsb-release

####################################
#  Install Docker CLI              #
####################################
# This allows the runner to call 'docker' commands
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli

WORKDIR /usr/bin/actions-runner

###################################
#  Install the Github SelfRunner  #
###################################
RUN mkdir actions-runner \
    && cd actions-runner 
RUN wget -q https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar -xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && /usr/bin/actions-runner/bin/installdependencies.sh


####################################
#  Install PowerShell (Binary)     #
####################################
# Using tar.gz allows installation on Ubuntu 24.04 where the .deb 
# libicu dependencies (libicu72 or older) conflict with the system's libicu74.
RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/v$PWSH_VERSION/powershell-$PWSH_VERSION-linux-x64.tar.gz \
    && mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf powershell-$PWSH_VERSION-linux-x64.tar.gz -C /opt/microsoft/powershell/7 \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh \
    && rm powershell-$PWSH_VERSION-linux-x64.tar.gz


COPY ./start.sh ./healthcheck.sh /usr/bin/actions-runner/

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=1 \
  CMD /usr/bin/actions-runner/healthcheck.sh

CMD ["./start.sh"]