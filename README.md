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

The same roles are applied to both master and worker nodes, so there's no need to separate them in different inventory files.

The nodes should run Ubuntu 18.04 LTS (Bionic Beaver). The roles can be applied using the playbook:

    $ ansible-playbook -i inventory/aws -u ubuntu playbooks/kubernetes.yml

It supports the following settings through playbook variables:

Variable | Description | Default value
-------- | ----------- | -------------
`kubernetes_version` | Kubernetes release that is going to be installed. | `1.17.2`

## Firewall

The following connectivity between nodes should be allowed within the cluster:

Port | Protocol | Scope | Description
---- | -------- | ----- | -----------
`80` | `TCP` | `worker` | HTTP ingress.
`6443` | `TCP` | `master` | [Kubernetes API][kubernetes-api] server.
`8472` | `UDP` | `all` | [Flannel][flannel] VXLAN backend used for pod networking.
`10250` | `TCP` | `all` | [Kubelet][kubelet] agent.

External connections are use-case dependant. For instance, all internet HTTP traffic could be forbidden, but allowed from a proper HTTPS load balancer. In the same way, it probably makes sense to allow internet connections to the Kubernetes API server in order to allow developers to use `kubectl` from their workstations.

## Cluster bootstrap

After the playbook execution, the `init-cluster.sh` script should be run on the master node. The process shouldn't take more than a minute or two. If it takes longer, it has probably failed.

It supports the following settings through environment variables:

Environment Variable | Description | Default value
-------------------- | ----------- | -------------
`KUBE_MASTER` | User-friendly hostname of the master node that will be added to the TLS certificate. This is important if the server will not be accessed only by its IP. | `master.cluster.k8s`

When the script finishes its execution, a message similar to the following one will be shown:

```
Your Kubernetes control-plane has initialized successfully!

(...)

Then you can join any number of worker nodes by running the following on each
as root:

kubeadm join <IP>:6443 --token <TOKEN> \
    --discovery-token-ca-cert-hash sha256:<HASH>
```

Running the mentioned command as root on a worker node will yield a message like:

```
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

And its status can be checked from the master node:

```
$ kubectl get node
NAME               STATUS    ROLES     AGE       VERSION
ip-172-31-41-85    Ready     <none>    1m        v1.17.2
ip-172-31-47-133   Ready     master    2m        v1.17.2
```

By default worker nodes doesn't have any defined roles, so it may be interesting to add this information:

    kubectl label node ip-172-31-41-85 node-role.kubernetes.io/worker=


[flannel]: https://coreos.com/flannel/docs/latest/
[kubelet]: https://kubernetes.io/docs/concepts/overview/components/#node-components
[kubernetes-api]: https://kubernetes.io/docs/concepts/overview/components/#master-components
