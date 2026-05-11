FROM python:3.13

WORKDIR /workspace

RUN pip install uv

RUN uv pip install \
    mojo \
    --system

CMD ["bash"]