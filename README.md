Ansible Kubernetes
==================

Playbooks and roles to deploy a Kubernetes cluster using Ansible.

## Usage

An inventory file, like `inventory/aws` in this example, is required:

```ini
[aws]
ec2-18-206-239-18.compute-1.amazonaws.com
ec2-54-210-210-233.compute-1.amazonaws.com
```

The same roles are applied to both master and worker nodes, so there's no need to separate them in different files.

The nodes should run Ubuntu 16.04 LTS (Xenial Xerus) and the package `python-minimal` (for Python 2 support) is required. The roles can be applied using the playbook:

    $ ansible-playbook -i inventory/aws -u ubuntu playbooks/kubernetes.yml

It supports the following settings through playbook variables:

Variable | Description | Default value
-------- | ----------- | -------------
`kubernetes_version` | Kubernetes release that is going to be installed. | `1.9.8`

## Cluster bootstrap

After the playbook execution, the `init-cluster.sh` script should be run on the master node. The process shouldn't take more than a minute or two. If it takes longer, it has probably failed.

It supports the following settings through environment variables:

Environment Variable | Description | Default value
-------------------- | ----------- | -------------
`KUBE_MASTER` | User-friendly hostname of the master node that will be added to the TLS certificate. This is important if the server will not be accessed only by its IP. | `master.cluster.k8s`

When the script finishes its execution, a message similar to the following one will be shown:

```
Your Kubernetes master has initialized successfully!

(...)

You can now join any number of machines by running the following on each node
as root:

  kubeadm join --token <TOKEN> <IP>:6443 --discovery-token-ca-cert-hash sha256:<CERT-HASH>
```

Running the mentioned command on a worker node will yield a message like:

```
This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

And its status can be checked from the master node:

```
$ kubectl get node
NAME               STATUS    ROLES     AGE       VERSION
ip-172-31-41-85    Ready     <none>    1m        v1.9.8
ip-172-31-47-133   Ready     master    2m        v1.9.8
```

By default worker nodes doesn't have defined roles, so it may be interesting to add this information:

    kubectl label node ip-172-31-41-85 node-role.kubernetes.io/worker=
