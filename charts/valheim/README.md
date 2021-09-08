# Valheim

Helm chart to deploy [valheim-server](https://github.com/lloesche/valheim-server-docker) to your Kubernetes cluster

## TL;DR

```bash
helm repo add nifares https://nifares.github.io/helm-charts
helm install my-release nifares/valheim
```

## Introduction

This chart bootstraps a [valheim-server](https://github.com/lloesche/valheim-server-docker) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.12+
- Helm 3.1.0
- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm repo add nifares https://nifares.github.io/helm-charts
helm install my-release nifares/valheim
```

These commands deploy `valheim-server` on the Kubernetes cluster with the default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` chart:

```bash
helm uninstall my-release
```

## Parameters

| Name                              | Description                                                                                                      | Value                 |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------- | --------------------- |
| `server.name`                     | Server name                                                                                                      | `myServer`            |
| `server.worldName`                | World name                                                                                                       | `kubernetes`          |
| `server.public`                   | Set to `true` to list server in the server browser                                                               | `true`                |
| `server.statusPage`               | Set to `true` to enable [status web server](https://github.com/lloesche/valheim-server-docker#status-web-server) | `false`               |
| `server.supervisorPage`           | Set to `true` to enable [supervisor](https://github.com/lloesche/valheim-server-docker#supervisor)               | `false`               |
| `server.serverPassword`           | Server password, generated automatically if empty and no existing secret provided                                | `""`                  |
| `server.serverPasswordSecret`     | Existing server passsword secret name                                                                            | `""`                  |
| `server.serverPasswordKey`        | Server password secret key                                                                                       | `"serverPassword"`    |
| `server.supervisorUser`           | Supervisor page user name                                                                                        | `"admin"`             |
| `server.supervisorPassword`       | Supervisor password, generated automatically if empty and no existing secret provided)                           | `""`                  |
| `server.supervisorPasswordSecret` | Existing supervisor password secret name                                                                         | `""`                  |
| `server.supervisorPasswordKey`    | Supervisor password secret key                                                                                   | `"supevisorPassword"` |


## To do

1. Improve documentation
