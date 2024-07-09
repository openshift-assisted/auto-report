FROM registry.access.redhat.com/ubi9/ubi-minimal:9.2

ARG release=main
ARG version=latest

LABEL com.redhat.component auto-report
LABEL description "Automatically generates reports from OpenSearch data"
LABEL summary "Automatically generates reports from OpenSearch data"
LABEL io.k8s.description "Automatically generates reports from OpenSearch data"
LABEL distribution-scope public
LABEL name auto-report
LABEL release ${release}
LABEL version ${version}
LABEL url https://github.com/openshift-assisted/auto-report
LABEL vendor "Red Hat, Inc."
LABEL maintainer "Red Hat"

# License
COPY LICENSE /licenses/

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

USER 1001:1001

ENTRYPOINT ["auto_report"]
