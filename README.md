# Wasabi Prometheus Exporter

> Forked from [mipapo/wasabi-stats-exporter](https://github.com/mipapo/wasabi-stats-exporter) (MIT licensed) and maintained here with a Docker/Helm release pipeline.

This project is a Prometheus exporter for Wasabi bucket statistics. It fetches bucket utilization data from the Wasabi API and exposes it as Prometheus metrics.

## Features
- Periodically fetches Wasabi bucket statistics.
- Exposes bucket storage and API usage metrics via a Prometheus-compatible `/metrics` endpoint.
- Supports multiple Wasabi accounts.
- Handles API pagination for large datasets.
- Disables default Prometheus metrics to expose only relevant Wasabi statistics.
- Some API Call Informations are skipped as they are always empty at the moment

## Metrics Exported
The exporter exposes the following metrics for each bucket:
- `wasabi_raw_storage_bytes` - Total raw storage bytes used per bucket.
- `wasabi_deleted_storage_bytes` - Total deleted storage bytes per bucket.
- `wasabi_padded_storage_bytes` - Total padded storage bytes per bucket.
- `wasabi_metadata_storage_bytes` - Total metadata storage bytes per bucket.
- `wasabi_orphaned_storage_bytes` - Total orphaned storage bytes per bucket.
- `wasabi_storage_wrote_bytes` - Total bytes written to storage per bucket.
- `wasabi_storage_read_bytes` - Total bytes read from storage per bucket.
- `wasabi_api_calls_total` - Total number of API calls per bucket.
- `wasabi_upload_bytes` - Total bytes uploaded per bucket.
- `wasabi_download_bytes` - Total bytes downloaded per bucket.
- `wasabi_num_billable_objects` - Total number of billable objects per bucket.
- `wasabi_num_billable_deleted_objects` - Total number of billable deleted objects per bucket.

## Setup and Usage

### 1. Build and Run
#### Using Go
```sh
export WASABI_API_KEYS="account1=API_KEY_1,account2=API_KEY_2"
go build -o wasabi_exporter
./wasabi_exporter
```

#### Using Docker
```sh
docker build -t wasabi-prometheus-exporter .
docker run -e WASABI_API_KEYS="account1=API_KEY_1,account2=API_KEY_2" -p 8080:8080 wasabi-prometheus-exporter
```

### 2. Access Metrics
After running the service, Prometheus can scrape metrics from:
```
http://localhost:8080/metrics
```

## Environment Variables
- `WASABI_API_KEYS`: A comma-separated list of `account_name=AccessKeyID:SecretAccessKey`
  pairs. There is no separate "Stats API key" concept in Wasabi — the value after
  `=` is your normal Wasabi access key ID and secret access key, colon-joined,
  exactly as required by [Wasabi's Stats API authentication](https://docs.wasabi.com/apidocs/stats-api-get-v1standalone-utilizations)
  (`Authorization: AccessKeyID:SecretAccessKey`). The same key pair used for S3
  access works here, as long as it has the required permissions (see below).

## Setup in Wasabi account

No special "API key" needs to be generated — reuse (or create) a normal Wasabi
access key from **Wasabi Console → Access Keys → Create Access Key**, either a
Root account key or a sub-user key. If using a sub-user, attach the
`WasabiAccountStatsAccess` and/or `WasabiBucketStatsAccess` policies (Wasabi's
own policy names — there is no AWS-style IAM JSON policy to write, that only
applies to real AWS accounts). See
[Generating a Wasabi Stats API Key](https://docs.wasabi.com/apidocs/generating-a-wasabi-stats-api-key)
for the console walkthrough. Then set `WASABI_API_KEYS` to
`account_name=<AccessKeyID>:<SecretAccessKey>`.

## Container image

Published to GHCR on every `vX.Y.Z` tag push:

```
ghcr.io/letsconvert-io/wasabi-stats-exporter:<version>
```

## Helm chart

A production-ready Helm chart lives in [`charts/wasabi-stats-exporter`](./charts/wasabi-stats-exporter),
published as an OCI artifact on every `vX.Y.Z` tag push:

```sh
helm install wasabi-stats-exporter oci://ghcr.io/letsconvert-io/charts/wasabi-stats-exporter \
  --version <version> \
  --set wasabiApiKeys.accounts[0].name=<label> \
  --set wasabiApiKeys.accounts[0].existingSecret=<secret-name>
```

`wasabiApiKeys.accounts` points the chart at an *existing* Secret that already
holds a normal Wasabi access key/secret key pair (e.g. one you already use for
S3 access) — no new secret needs to be created just for this exporter. See the
[chart README](./charts/wasabi-stats-exporter/README.md) for the full
configuration reference, including the `serviceMonitor.enabled` toggle for
Prometheus Operator scraping.

## Known limitations

- No HTTP health/readiness endpoint — the Helm chart's liveness/readiness
  probes use a TCP socket check against the metrics port as a safe default.
- Minimal error handling if a Wasabi Stats API call fails (logged, not
  retried) — the background poller just tries again on its next hourly tick.

## License
This project is licensed under the MIT License. See [LICENSE](./LICENSE).
Originally authored by [Michael Pohl](https://github.com/mipapo).

