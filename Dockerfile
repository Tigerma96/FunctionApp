FROM ubuntu:latest

USER root

WORKDIR src/root

# ENV languageWorkers:python:defaultExecutablePath=/src/root/venv/bin/python3

RUN apt-get update
RUN apt-get install software-properties-common --yes
RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update
RUN apt-get install wget --yes
RUN apt-get install libicu-dev --yes
RUN apt-get install curl --yes
RUN apt-get install python3.11 --yes
RUN apt-get install vim --yes
RUN apt-get install python3-venv --yes
RUN apt install python3-pip --yes
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
# RUN pip install -r requirements.txt --break-system-packages
RUN python3.11 -m pip install -r requirements.txt

# Copy files from repo

COPY notionAPISourceToRaw/ notionAPISourceToRaw/
COPY host.json host.json
COPY local.settings.json local.settings.json

EXPOSE 80:80

CMD func start --python --port 80 --verbose
