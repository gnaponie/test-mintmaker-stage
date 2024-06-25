FROM registry.access.redhat.com/ubi9/ubi:9.3
RUN dnf -y install golang

WORKDIR /go/src/mikefarah/yq

COPY yq/ .

RUN CGO_ENABLED=0 go build -ldflags "-s -w" .

# RUN ./scripts/test.sh -- this too often times out in the github pipeline.
RUN ./scripts/acceptance.sh

# Rebase on ubi9
FROM registry.access.redhat.com/ubi9:latest@sha256:368ffd55e147ecc20713044bfd5c9299cedf824bad667e87a846b8d4635a1078

COPY --from=builder /go/src/mikefarah/yq/yq /usr/bin/yq

WORKDIR /workdir

RUN \
  groupadd -g 1000 yq; \
  useradd -u 1000 -g yq -s /bin/sh -d /home/yq yq

RUN chown -R yq:yq /workdir

USER yq

ENTRYPOINT ["/usr/bin/yq"]
