FROM ubuntu:22.04

RUN apt update && apt install -y python3.11 python3.11-venv python3-pip
