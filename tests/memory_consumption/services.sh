#!/bin/bash


# prometheus
podman run --rm --name prometheus -d \
-p 9080:9090 \
--network memory \
-v ./prometheus.yml:/etc/prometheus/prometheus.yml:z \
docker.io/prom/prometheus

# exporter
podman run --rm -d \
--name exporter \
-p 9882:9882 \
--network memory \
-e CONTAINER_HOST=unix:///run/podman/podman.sock \
-v $XDG_RUNTIME_DIR/podman/podman.sock:/run/podman/podman.sock \
--userns=keep-id --security-opt label=disable \
quay.io/navidys/prometheus-podman-exporter -a


# rulebook
podman run --rm \
-v ../:/workdir:z -w /workdir -m 200m \
quay.io/aizquier/ansible-rulebook:main ansible-rulebook \
--rulebook /workdir/memory_consumption/run_playbook.yml -S /workdir/sources -i /workdir/playbooks/inventory.yml
