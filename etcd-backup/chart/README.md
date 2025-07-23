This Helm chart deploys a Kubernetes CronJob that backs up etcd data periodically.

## Features
- Configurable backup time and retention policy
- Backups stored on host path with compression
- Uses `etcdctl` with TLS authentication

## Configuration
| Key | Description | Default |
|-----|-------------|---------|
| `schedule` | Cron schedule in UTC | `0 17 * * *` (KST 02:00) |
| `timeZone` | Timezone (Kubernetes 1.27+) | `Asia/Seoul` |
| `image.repository` | etcdctl image | `bitnami/etcd` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Pull policy | `IfNotPresent` |
| `backup.path` | Mount path inside pod | `/backup` |
| `backup.hostPath` | Host path for backups | `/data/etcd-backup` |
| `backup.retentionDays` | Number of days to retain backups | `5` |
| `etcd.endpoints` | etcd endpoint | `https://127.0.0.1:2379` |
| `etcd.certs.ca` | Path to CA cert | `/etc/kubernetes/pki/etcd/ca.crt` |
| `etcd.certs.cert` | Path to client cert | `/etc/kubernetes/pki/etcd/server.crt` |
| `etcd.certs.key` | Path to client key | `/etc/kubernetes/pki/etcd/server.key` |
| `etcd.certs.mountPath` | Mount path inside pod | `/etc/kubernetes/pki/etcd` |
| `etcd.certs.hostPath` | Host path on node | `/etc/kubernetes/pki/etcd` |

## Usage
```bash
helm install my-etcd-backup ./etcd-backup -n kube-system
```