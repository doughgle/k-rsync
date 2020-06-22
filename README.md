# k-rsync - kube-native parallel rsync 

A Helm Chart for parallel r-syncing from a source PVC to destination PVC.

## Usage

In the `value.yaml` file, specify the `claimName` of the `source` and `dest` PVCs.

```
$ helm install my-release <repo>/k-rsync 
```

k-rsync partitions source file tree with [fpart](https://github.com/martymac/fpart) in live mode.
Fpart's live mode requires specification of either:
 - the number of files per partition, or
 - the size (bytes) of a partition, or
 - both

For now, the implication is that the rsync job must be tuned for `completions` and `parallelism` based on initial 
execution of fpart 
(i.e. after initial installation, see logs from fpart job and update `completions` to equal the number of partitions).

## Typical process to copy contents from one PVC to another

 * Create a new PVC using the preferred storage backend
 * Shutdown app (scale replicas to zero)
 * Specify the `source` (read-only) and `dest` PVCs.
 * Install/Upgrade the Helm Chart to run sync process job
 * Edit Pod specs to use new PVC
 * Scale app back up
