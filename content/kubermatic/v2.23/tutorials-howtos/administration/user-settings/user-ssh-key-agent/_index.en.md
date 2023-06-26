+++
title = "User SSH Key Agent"
date = 2021-02-10T12:12:00+02:00
weight = 6

+++

## Overview
The user ssh key agent is responsible for syncing the defined user ssh keys to the worker nodes, when users
attach ssh keys to the user clusters. When users choose to add a user ssh key to a cluster after it was created
the agent will sync those keys to the worker machines by fetching the ssh keys and write them to the `authorized_keys`
file on each worker node. The agent runs as a daemonset in the cluster. If a user changes the `authorized_keys` file
manually via logging into machine and change the content of the file the agent will reject the changes and will rewrite
the content of the file based on the attached user ssh keys.

![SSH Key Agent Checkbox](/img/kubermatic/v2.23/ui/sshkey_agent.png?height=300px&classes=shadow,border "SSH Key Agent Checkbox")

The agent is deployed to the user clusters by default and it is not possible to change whether to deploy it or not once
the cluster has been created. The reason behind that is, once the agent is deployed after the cluster is created, any
previously added ssh keys in the worker nodes(except the keys that have been added during the cluster creation) will be
deleted. If the user was can disable the agent after the cluster creation, any pre-existing keys won't be cleaned up.
Due to the previously mentioned reasons, the agent state cannot be changed once the cluster is created. If users decide
to disable the agent(during cluster creation), they should take care of adding ssh keys to the worker nodes by themselves.

**Note:**
During the user cluster creation steps(at the second step), the users have the possibility to add a user ssh key and it
is not affected by the agent, whether it was deployed or not.

## Migration
Starting from KKP 2.16.0 on-wards, it was made possible to enable and disable the user ssh key agent during cluster creation. Users can
enable the agent in KKP dashboard as it is mentioned above, or by enabling the newly added `enableUserSSHKeyAgent: true`
in the cluster spec. For user clusters which were created using KKP 2.15.x and earlier, this has introduced an issue, due to
the absence of that field. User ssh key agent is enabled by default if that field is missing. However, this wasn't visible
in the dashboard. To display the agent as enabled in user clusters dashboard created prior KKP 2.16.0, users should add the
`enableUserSSHKeyAgent: true` field to the cluster spec manually.
