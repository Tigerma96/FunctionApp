FROM ubuntu:latest

USER root

WORKDIR src/root

# RUN echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs 2>/dev/null)-prod $(lsb_release -cs 2>/dev/null) main" > /etc/apt/sources.list.d/dotnetdev.list
RUN apt-get update
RUN apt-get install wget --yes
RUN apt-get install libicu-dev --yes
RUN apt-get install curl --yes
RUN apt-get install python3 --yes
RUN apt-get install vim --yes
RUN apt-get install python3-venv --yes
RUN python3 -m venv venv
RUN wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install azure-functions-core-tools-4

# Calculate dependencies

COPY setup.py setup.py
COPY build-dependencies.txt build-dependencies.txt
RUN venv/bin/pip install -r build-dependencies.txt
RUN venv/bin/pip-compile -o requirements.txt setup.py

# Copy files from repo

COPY hello_world.py hello_world.py


CMD sleep infinity
