FROM registry.access.redhat.com/ubi9/ubi-minimal:9.2

RUN --mount=type=tmpfs,destination=/var/cache\
    --mount=type=tmpfs,destination=/root/.cache\
    --mount=type=cache,target=/var/cache/yum\
    --mount=type=cache,target=/var/cache/dnf\
    --mount=type=cache,target=/root/.cache\
    microdnf update -y &&\
    microdnf install -y\
    python3\
    python3-pip\
    &&\
    python3 -m pip install --upgrade pip

COPY requirements.txt .
RUN --mount=type=tmpfs,destination=/root/.cache\
    --mount=type=cache,target=/root/.cache\
    python3 -m pip install -r requirements.txt

COPY . ./
RUN python3 -m pip install .

ENTRYPOINT ["auto_report"]
