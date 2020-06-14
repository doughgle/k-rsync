# k-rsync - kube-native rsync 

A Kubernetes rsync Job for syncing PVC filesystem trees, packaged as a Helm Chart 
for templating and versioning.

# Process to copy contents from one PVC to another

I created this to allow me to migrate from different storage backends for a given project. The process would be:

 * Create a new PVC using the preferred storage backend
 * Shutdown app (scale replicas to zero)
 * Specify the `source` (read-only) and `dest` PVCs.
 * Install/Upgrade the Helm Chart to run sync process job
 * Edit Pod specs to use new PVC
 * Scale app back up

### Usage
```
$ helm install my-release <repo>/k-rsync 
```
