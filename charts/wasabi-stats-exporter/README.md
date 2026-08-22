# wasabi-stats-exporter

A Helm chart for the [Wasabi Prometheus stats exporter](https://github.com/LetsConvert-IO/wasabi-stats-exporter).

## Installing

```sh
helm install wasabi-stats-exporter oci://ghcr.io/letsconvert-io/charts/wasabi-stats-exporter \
  --version <version> \
  --set wasabiApiKeys.accounts[0].name=prd \
  --set wasabiApiKeys.accounts[0].existingSecret=wasabi-secret
```

The preferred way to supply credentials is `wasabiApiKeys.accounts`: a list of
`{name, existingSecret, accessKeyIdKey, secretAccessKeyKey}` entries, each
pointing at an *existing* Secret that already holds a normal Wasabi access
key/secret key pair (e.g. one already used for S3 access — there is no
separate "Stats API key" concept in Wasabi, see the main repo README for
details and required permissions). `accessKeyIdKey`/`secretAccessKeyKey`
default to `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`. The chart composes the
required `AccessKeyID:SecretAccessKey` value in-container, so the source
Secret is never duplicated or re-encoded. `name` is only the Prometheus
`account_name` label used to tell accounts apart in metrics — pick something
readable (e.g. `prd`), not Wasabi's account ID.

Two fallbacks exist for cases where `accounts` doesn't fit:
`wasabiApiKeys.existingSecret`/`existingSecretKey` point at a Secret that
already contains a fully composed, comma-separated
`account_name=AccessKeyID:SecretAccessKey` list; `wasabiApiKeys.value` sets
that same string inline for local testing only, which the chart renders into
a Secret it manages — do not do this for anything that lands in git.

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
