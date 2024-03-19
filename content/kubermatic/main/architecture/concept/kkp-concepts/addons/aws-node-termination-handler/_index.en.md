+++
title = "AWS Node Termination Handler"
date = 2021-01-27T14:07:00+02:00
weight = 6

+++

## AWS Spot Instances

Kubermatic Kubernetes Platform (KKP) is capable of creating different machine types in more than ten different cloud providers.
One of those providers is AWS.

AWS cloud provider supports special instances that are called spot instances. Spot instances(according to aws official
documentation) are instances that use spare EC2 capacity that is available for less than the On-Demand price.
Because Spot Instances enable you to request unused EC2 instances at steep discounts, you can lower your Amazon EC2 costs significantly.
The hourly price for a Spot Instance is called a Spot price.

Kubermatic Kubernetes Platform supports the creation of aws spot instances and use them as worker nodes for any aws user cluster.
Spot Instances are very good choice in case of cost-effectiveness if you can be flexible about when your applications run and if
your applications can be interrupted.

{{% notice warning %}}
Due to the nature of spot instances, they should not be used as stateful workloads, as those workloads can be interrupted
and terminated at any given time.
{{% /notice %}}

Once a spot instance interruption is announced, a notification will be emitted from aws, stating that a specific spot instance
is scheduled for termination two minutes prior the actual termination. AWS node termination handler receives this notification
and start the process of node draining for the instance which is being scheduled for the termination.

AWS node termination handler is deployed with any aws user cluster created by KKP to ensure the resilience of the user
cluster once the spot instance is interrupted.

## AWS Spot Instances Creation
To create a user cluster which runs some spot instance machines, the user can specify the machine type whether it's a spot
instance or not at the step number four (Initial Nodes). A checkbox that has the label "Spot Instance" should be checked.

![AWS spot instance selection](spot-instance-selection.png?height=350px&classes=shadow,border "AWS spot instance selection")
