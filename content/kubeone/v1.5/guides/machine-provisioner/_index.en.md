+++
title = "Machine-Controller as infrastructure provisioner"
date = 2022-10-13T14:00:00+02:00
enableToc = true
+++

When starting a Kubernetes-cluster from scratch, you need machines that become control-plane nodes. 
Our recommended way would be to use the [Terraform integration][terraform-integration] of KubeOne. 

Problem: The usability when provisioning machines via Terraform can vary from provider to provider.
Machine-controller already contains full-featured provisioning logic for many providers. KubeOne and KKP clusters use Machine-controller on a wide variety of providers in diverse setups. It has proven its flexibility and stability.

So, why not leverage that? 

With machine-provisioner, we make this functionality accessbile as CLI. Define your machines in YAML, Machine-provisioner CLI turns them into running instances. 

## Usage

Kubermatic machine-provisioner CLI allows you to define nodes as Machine objects, in e.g. machines.yaml.

```
- apiVersion: cluster.k8s.io/v1alpha1
  kind: Machine
  metadata:
    name: machine
  spec:
    metadata:
      name: machine
    providerSpec:
      value:
        cloudProvider: aws
        cloudProviderSpec:
          region: eu-central-1
          securityGroupIDs:
            - sg-09371d37c71ec286b
          subnetId: subnet-0cfda22f6b09ee38b
          vpcId: vpc-819f62e9
        operatingSystem: ubuntu
        sshPublicKeys:
          - ...
    versions:
      kubelet: 1.23.12
```

Then you run Kubermatic machine-provisioner CLI to create those machines:

```
machine-provisioner create --machine-config ./machines.yaml
```

Kubermatic machine-provisioner CLI works only with the 
[natively-supported][supported-providers] providers by Machine Controller. If your provider is
natively-supported, we highly recommend using machine-provisioner for initial control-plane provisioning. Otherwise, you can use [KubeOne Static Workers][static-workers].

The generated json output looks something like this:

```
{
	"machines": [
		{
			"name": "machine-a",
			"id": "aws:///eu-central-1a/i-0e0ac21dccd51c989",
			"public_address": "3.76.9.200",
			"private_address": "172.31.87.89",
			"internal_dns": "ip-172-31-87-89.eu-central-1.compute.internal",
			"external_dns": "ec2-3-76-9-200.eu-central-1.compute.amazonaws.com"
		}
	]
}
```

## Input to KubeOne

KubeOne can use the output of machine-provisioner CLI to bootstrap these machines and join them to a Kubernetes cluster. 

```
kubeone apply --mcjson machine-provisioner.json
```

[machine-controller]: https://github.com/kubermatic/machine-controller
[cluster-api]: {{< ref "../../architecture/concepts#cluster-api" >}}
[machine-deployments]: {{< ref "../../architecture/concepts#machinedeployments" >}}
[supported-providers]: {{< ref "../../architecture/compatibility#supported-providers" >}}
[static-workers]: {{< ref "../static-workers" >}}
[terraform-integration]: {{< ref "../../architecture/requirements/infrastructure-management/#terraform-integration" >}}
[terraform-integration-workers]: {{< ref "../../references/terraform-integration/#kubeone_workers-reference" >}}
[machine-controller-requirements]: {{< ref "../../architecture/requirements/machine-controller" >}}
