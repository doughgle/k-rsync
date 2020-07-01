# k-rsync - kube-native parallel rsync 

A Helm Chart for parallel r-syncing from a source PVC to destination PVC.

## Usage

In the `value.yaml` file, specify the `claimName` of the `source` and `dest` PVCs.
By default, k-rsync partitions the source PVC into 2 sub-trees (`partitions: 2`) and runs 2 rsync pods in parallel to completion (`parallelism: 2`).
It's parallel by default!   

```
$ helm install my-release <repo>/k-rsync 
```

## Chart Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| fpartOpts | string | `"-zz -x .zfs -x .snapshot* -x .ckpt"` | Override default fpart(1) options. |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"doughgle/fpart-amqp-tools"` |  |
| image.tag | string | `"latest"` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| parallelism | int | `2` |  |
| partitions | int | `2` |  |
| podSecurityContext | object | `{}` |  |
| pvc.dest.claimName | string | `"dest-pvc"` |  |
| pvc.source.claimName | string | `"source-pvc"` |  |
| queue | string | `"file.list.part.queue"` |  |
| rabbitmq.image.pullPolicy | string | `"IfNotPresent"` |  |
| rabbitmq.image.repository | string | `"rabbitmq"` |  |
| rabbitmq.image.tag | string | `"latest"` |  |
| rabbitmq.service.port | int | `5672` |  |
| rabbitmq.service.type | string | `"ClusterIP"` |  |
| resources | object | `{}` |  |
| rsyncOpts | list | `["--archive","--compress-level=9","--numeric-ids"]` | Override default rsync(1) options. Use this option with care as             certain options are incompatible with a parallel usage (e.g.  --delete). |
| securityContext | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `nil` |  |
| tolerations | list | `[]` |  |

## Description

It's basically fpsync using the kubernetes Job scheduler.

1. k-rsync `partitions` the source PVC into sub-trees with [fpart](https://github.com/martymac/fpart).
Each partition contains a list of files and directories.
1. It publishes the partition messages to a `queue`.
1. It schedules [rsync](https://linux.die.net/man/1/rsync) pods with `parallism` to sync each of the sub-tree partitions.
1. That's it!  

## Typical process to copy contents from one PVC to another

 * Create a new PVC using the preferred storage backend
 * Shutdown app (scale replicas to zero)
 * Specify the `source` (read-only) and `dest` PVCs.
 * Install/Upgrade the Helm Chart to run sync process job
 * Edit Pod specs to use new PVC
 * Scale app back up

---

#### Note: fpart in live mode

Fpart's live mode requires specification of either:
 - the number of files per partition, or
 - the size (bytes) of a partition, or
 - both

The implication of using live mode is that you need to know how many `partitions` will be produced
for a chosen files limit or size limit so that the kube Job controller can know how many `completions` to shoot for.