# wasabi-stats-exporter

A Helm chart for the [Wasabi Prometheus stats exporter](https://github.com/LetsConvert-IO/wasabi-stats-exporter).

## Installing

```sh
helm install wasabi-stats-exporter oci://ghcr.io/letsconvert-io/charts/wasabi-stats-exporter \
  --version <version> \
  --set wasabiApiKeys.existingSecret=wasabi-stats-exporter-keys
```

The referenced Secret must contain a key `WASABI_API_KEYS` with a
comma-separated `account_name=API_KEY` list (see the main repo README for how
to generate a Wasabi Stats API key). For local testing only, you can instead
set `wasabiApiKeys.value` directly, which the chart will render into a
Secret it manages — do not do this for anything that lands in git.

## Enabling metrics scraping

Set `service.enabled=true` (default) to expose the metrics endpoint via a
ClusterIP Service, and `serviceMonitor.enabled=true` to have the chart create
a Prometheus Operator `ServiceMonitor`. The ServiceMonitor is disabled by
default — this is deliberate, since not every consumer of this chart runs
Prometheus Operator, and some Operator installs gate ServiceMonitor discovery
by namespace label rather than by label selector. If yours selects by label,
set `serviceMonitor.labels` accordingly (e.g. `release: kube-prometheus-stack`).

## Values

See [values.yaml](./values.yaml) for the full set of configurable values,
including resource requests/limits, autoscaling, ingress, pod security
context, and probe configuration.

## Known limitations (upstream)

- The exporter has no HTTP health endpoint, so probes default to a TCP
  socket check against the metrics port. Once/if an HTTP health route is
  added upstream, switch `livenessProbe`/`readinessProbe` to `httpGet`.
