+++
title = "Multus-CNI Addon"
date = 2021-03-21T20:00:00+02:00
weight = 160
+++

The Multus-CNI Addon allows automated installation of [Multus-CNI](https://github.com/k8snetworkplumbingwg/multus-cni) in KKP user clusters.

{{< table_of_contents >}}

## About Multus-CNI
Multus-CNI enables attaching multiple network interfaces to pods in Kubernetes. It is not a standard CNI plugin - it acts as a CNI "meta-plugin", a CNI that can call multiple other CNI plugins. This implies that clusters still need a primary CNI to function properly.

In KKP, Multus can be installed into user clusters with any [supported CNI]({{< relref "../cni_cluster_network/" >}}). Multus addon can be deployed into a user cluster with a working primary CNI at any time.

## Installing Multus Addon in KKP
Before this addon can be deployed in a KKP user cluster, the KKP installation has to be configured to enable `multus` addon as an [accessible addon]({{< relref "../../../architecture/concept/kkp-concepts/addons/#accessible-addons" >}}). This needs to be done by the KKP installation administrator,
once per KKP installation.

As an administrator you can use the [AddonConfig](#multus-addonconfig) listed at the end of this page.

## Deploying Multus Addon in a KKP User Cluster
Once the Multus Addon is installed in KKP, it can be deployed into a user cluster via the KKP UI as shown below:

![Multus Addon](/img/kubermatic/master/ui/addon_multus.png?height=400px&classes=shadow,border "Multus Addon")

Multus will automatically configure itself with the primary CNI running in the user cluster. If the primary CNI is not yet running at the time of Multus installation, Multus will wait for it for up to 10 minutes.

## Using Multus-CNI
When Multus addon is installed, all pods will be still managed by the primary CNI. At this point, it is possible to define additional networks with `NetworkAttachmentDefinition` custom resources.

As an example, the following `NetworkAttachmentDefinition` defines a network named `macvlan-net` managed by the [macvlan CNI plugin](https://www.cni.dev/plugins/current/main/macvlan/) (a simple standard CNI plugin usually installed together with the primary CNIs):

```yaml
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: macvlan-net
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "macvlan",
      "master": "eth0",
      "mode": "bridge",
      "ipam": {
        "type": "host-local",
        "subnet": "192.168.1.0/24",
        "rangeStart": "192.168.1.200",
        "rangeEnd": "192.168.1.216",
        "routes": [
          { "dst": "0.0.0.0/0" }
        ],
        "gateway": "192.168.1.1"
      }
    }'
```

*NOTE:* If you want to try this example, modify the `master` interface name in the config (`eth0`) to match an interface name present on your worker nodes.

At this point, it is possible to create a pod that attaches an additional interface. The additional interface is requested by an annotation referring to the above `NetworkAttachmentDefinition`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: samplepod
  annotations:
    k8s.v1.cni.cncf.io/networks: macvlan-net
spec:
  containers:
  - name: samplepod
    command: ["/bin/ash", "-c", "trap : TERM INT; sleep infinity & wait"]
    image: alpine
```

After the pod is started, apart from the loopback interface (`lo`) and the primary network interface (`eth0`), the pod should also contain additional interface named `net1`:

```bash
$ kubectl exec -it samplepod -- ip address

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
3: eth0@if81: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 9001 qdisc noqueue state UP
    link/ether fe:ee:ac:ef:fc:1b brd ff:ff:ff:ff:ff:ff
    inet 172.25.0.75/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::fcee:acff:feef:fc1b/64 scope link
       valid_lft forever preferred_lft forever
4: net1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 9001 qdisc noqueue state UP
    link/ether 56:c8:02:ed:9e:07 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.200/24 brd 192.168.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fe80::54c8:2ff:feed:9e07/64 scope link
       valid_lft forever preferred_lft forever
```

## Multus AddonConfig
As an KKP administrator, you can use the following AddonConfig for Multus to display Multus logo in the addon list in KKP UI:

```yaml
apiVersion: kubermatic.k8c.io/v1
kind: AddonConfig
metadata:
  annotations:
  name: multus
spec:
  description: The Multus CNI allows pods to have multiple interfaces
    and using features like SR-IOV.
  shortDescription: Multus CNI
  logoFormat: "svg+xml"
  # The logo must be base64 encoded.
  logo: |+
    PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/Pgo8IURPQ1RZUEUgc3ZnIFBVQkxJQyAiLS8vVzNDLy9EVEQg
    U1ZHIDIwMDEwOTA0Ly9FTiIKICJodHRwOi8vd3d3LnczLm9yZy9UUi8yMDAxL1JFQy1TVkctMjAwMTA5MDQvRFREL3N2ZzEw
    LmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4wIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiB3aWR0aD0iMTMw
    LjAwMDAwMHB0IiBoZWlnaHQ9IjM0LjQ2ODAwMHB0IiB2aWV3Qm94PSIwIDAgODc1LjAwMDAwMCAyMzIuMDAwMDAwIgogcHJl
    c2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQgbWVldCI+CjxtZXRhZGF0YT4KQ3JlYXRlZCBieSBwb3RyYWNlIDEuMTYsIHdy
    aXR0ZW4gYnkgUGV0ZXIgU2VsaW5nZXIgMjAwMS0yMDE5CjwvbWV0YWRhdGE+CjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAu
    MDAwMDAwLDIzMi4wMDAwMDApIHNjYWxlKDAuMTAwMDAwLC0wLjEwMDAwMCkiCmZpbGw9IiMwMDAwMDAiIHN0cm9rZT0ibm9u
    ZSI+CjxwYXRoIGQ9Ik0yMjcxIDIwOTkgYy01MSAtMjYgLTgxIC03MCAtODEgLTEyMSAwIC02MSA1NCAtMTAzIDE1NSAtMTIw
    IDE1IC0yCjggLTEwIC0zMiAtMzYgLTcxIC00NiAtMTY1IC0xNDggLTE5OCAtMjE3IC0zNCAtNjkgLTM5IC0xNTIgLTEyIC0y
    MDcgMzcgLTc0CjEzOSAtMTE5IDI3NSAtMTIxIDUwIC0xIDgyIC01IDgyIC0xMiAwIC0yMSAtMTg5IC0xOTMgLTMyMCAtMjkx
    IC03NCAtNTUgLTIyMQotMTU3IC0zMjYgLTIyNiAtMzU4IC0yMzYgLTUwNSAtMzg4IC01MDggLTUyNCAtMSAtNTUgMTcgLTg3
    IDY4IC0xMTUgNTIgLTMwCjEzOSAtMzIgMTgwIC02IDM1IDIzIDQ1IDUyIDUyIDE0NiAyNSAzMDUgMjk0IDU2MCA4MjQgNzgx
    IDIxNSA4OSAzMTAgMTQxIDM3OAoyMDQgMTU3IDE0NSAwIDI4MyAtMjQ3IDIxNyAtNjcgLTE4IC04OSAtMjAgLTE0MCAtMTIg
    LTg2IDE0IC0xNTMgNTQgLTE5MSAxMTYKLTI4IDQ1IC0yNSA3OCAxMSAxMTkgNTcgNjYgMjIzIDEwNiA0MzUgMTA2IDExNiAw
    IDE1NiAxMCAxMDAgMjQgLTEzIDMgLTQ3IDMzCi03NiA2NSAtMjggMzMgLTYwIDYzIC03MSA2NiAtMTEgNCAtMTkgMTUgLTE5
    IDI5IDAgMzMgLTM5IDg2IC04OSAxMjEgLTM4IDI2Ci01MiAzMCAtMTI0IDMzIC02OSAzIC04OSAtMSAtMTI2IC0xOXogbTIy
    MSAtMjYgYzQxIC0yNCA3OCAtNzcgNzggLTExMyAwIC0yNAotNiAtMjkgLTU3IC00NCAtMzIgLTkgLTY0IC0yMCAtNzIgLTIz
    IC0xMSAtNCAtMTAgMCAyIDE4IDIxIDMwIDIyIDYwIDEgODUKLTE1IDE5IC0xNiAxOSAtOSAtMSA0IC0xMSA5IC0yNiAxMiAt
    MzIgMyAtNyAtOSAtMjYgLTI1IC00MyAtMjUgLTI0IC0zOSAtMzAKLTc1IC0zMCAtNTIgMCAtMTA3IDMyIC0xMjEgNzEgLTEy
    IDM2IDE2IDkwIDYyIDExOCAzMSAxOCA0OCAyMSAxMDQgMTggNDEgLTMKNzkgLTEyIDEwMCAtMjR6Ii8+CjxwYXRoIGQ9Ik0x
    Njg1IDE3NjMgYy01MCAtNiAtMTE1IC0zNCAtMTE1IC00OCAwIC0xOSAzMiAtMzUgNjkgLTM1IDI1IDAgMjY2CjQxIDQ2NiA3
    OCAzOCA3IC00IDEwIC0xNzAgOSAtMTIxIDAgLTIzMyAtMiAtMjUwIC00eiIvPgo8cGF0aCBkPSJNMjEwMCAxNzQzIGMtODgg
    LTkgLTMxNiAtNTUgLTM5MSAtNzkgLTEwOCAtMzQgLTE1NSAtNjAgLTE3MCAtOTYKLTI2IC02NCA0MSAtNzggMTEyIC0yNCA4
    NiA2OCAyNzYgMTQ2IDQyOCAxNzcgMzQgNyA2MSAxNyA2MSAyMSAwIDQgLTEgNyAtMiA2Ci0yIDAgLTE5IC0zIC0zOCAtNXoi
    Lz4KPHBhdGggZD0iTTIwMTcgMTY4MCBjLTIxNSAtNzIgLTM3MCAtMTY4IC0zODMgLTIzNiAtMTIgLTY1IDY2IC04NSAxMTEg
    LTI5IDY0CjgyIDk5IDExNCAxODAgMTY4IDUwIDMyIDEyMCA3NCAxNTggOTMgNjEgMzEgNzkgNDQgNjAgNDQgLTUgMCAtNjEg
    LTE4IC0xMjYKLTQweiIvPgo8cGF0aCBkPSJNMTI2OCAxNjUwIGMtMzAgLTE5IC0yMSAtMzUgNTkgLTEwMSA0MyAtMzUgMTEz
    IC05NyAxNTUgLTEzOCA0MyAtNDAKNzggLTcwIDc4IC02NiAwIDEzIC0xNDYgMjI4IC0xODEgMjY4IC0zNiA0MCAtODIgNTUg
    LTExMSAzN3oiLz4KPHBhdGggZD0iTTIwMzQgMTYyNCBjLTE4MCAtMTA4IC0yOTcgLTI0MiAtMjY0IC0zMDQgMTIgLTIzIDQ4
    IC0yNiA3MyAtNyA5IDYKMjYgMzkgMzcgNzIgMTEgMzMgMzYgODMgNTYgMTEyIDMzIDQ3IDEyNyAxMzUgMTU3IDE0NiA2IDIg
    OSA3IDYgMTEgLTMgMyAtMzIKLTEwIC02NSAtMzB6Ii8+CjxwYXRoIGQ9Ik0xMDg3IDE2MDMgYy00IC0zIC03IC0xNSAtNyAt
    MjUgMCAtMTMgMjkgLTMyIDEwMyAtNjkgODQgLTQzIDIzNgotMTI2IDM1NyAtMTk2IDMyIC0xOSAtNzQgODIgLTE2NSAxNTcg
    LTExOCA5NyAtMTkyIDE0MCAtMjQwIDE0MCAtMjMgMCAtNDUgLTMKLTQ4IC03eiIvPgo8cGF0aCBkPSJNMjAyOSAxNTUxIGMt
    NjggLTc0IC0xMzggLTE5MSAtMTQxIC0yMzQgLTMgLTI4IDAgLTMyIDI0IC0zNSAzMCAtNAo1OCAyOCA1OCA2NSAwIDM2IDM4
    IDEyNiA4MSAxOTMgMjIgMzQgMzggNjQgMzYgNjcgLTMgMiAtMjkgLTIzIC01OCAtNTZ6Ii8+CjxwYXRoIGQ9Ik05MjUgMTUz
    NiBjLTM4IC0yOCAtNyAtNDggMTU2IC0xMDMgODUgLTI5IDIyOSAtODAgMzIxIC0xMTMgOTIgLTMzCjE3MCAtNjAgMTc1IC02
    MCAxMSAwIC0xNTcgOTkgLTI4MSAxNjUgLTE5MiAxMDIgLTMyOCAxNDMgLTM3MSAxMTF6Ii8+CjxwYXRoIGQ9Ik00MjEwIDE0
    OTggYy0yMCAtNiAtNjIgLTcxIC0xOTAgLTI5MyAtOTAgLTE1NyAtMTY5IC0yODQgLTE3NCAtMjgyCi02IDIgLTgxIDEyNSAt
    MTY2IDI3NCAtODYgMTQ5IC0xNjEgMjc4IC0xNjkgMjg3IC0xOCAyMiAtNzQgMjEgLTk0IC0yIC0xNQotMTcgLTE3IC01OSAt
    MTcgLTM5NSBsMCAtMzc3IDY1IDAgNjUgMCAwIDIyNiBjMCAxNTYgMyAyMjUgMTEgMjIyIDYgLTIgNjYKLTEwMCAxMzMgLTIx
    OCA4MCAtMTQwIDEzMiAtMjIwIDE0OSAtMjMwIDQ3IC0yNyA2NSAtNyAxOTIgMjE2IDY1IDExNSAxMjMgMjE1CjEyOSAyMjMg
    OCAxMCAxMiAtNDUgMTYgLTIxMCBsNSAtMjI0IDY4IC0zIDY3IC0zIDAgMzc5IGMwIDM0OCAtMSAzODAgLTE3IDM5NAotMjYg
    MjIgLTQ1IDI2IC03MyAxNnoiLz4KPHBhdGggZD0iTTQ0NjIgMTI0MyBjMyAtMjQ4IDMgLTI0OCAzMSAtMzA5IDUyIC0xMTIg
    MTU4IC0xOTAgMjkxIC0yMTUgMzIgLTYKMTM4IC05IDIzOCAtNyAxNzUgMyAxODAgNCAxOTkgMjcgMTggMjIgMTkgNDQgMTkg
    Mzg3IGwwIDM2NCAtNzAgMCAtNzAgMCAtMgotMzE3IC0zIC0zMTggLTE1NiAwIGMtMTUzIDAgLTE1NiAwIC0yMTQgMzAgLTQ1
    IDIzIC02NiA0MiAtOTAgNzkgbC0zMCA0OSAtNQoyMzYgLTUgMjM2IC02OCAzIC02OSAzIDQgLTI0OHoiLz4KPHBhdGggZD0i
    TTU0MTQgMTQ3NyBjLTIgLTcgLTMgLTE3NCAtMiAtMzcwIDMgLTMyNiA0IC0zNTggMjEgLTM3NCAxNiAtMTcgNDUKLTE4IDM1
    NSAtMTggbDMzNyAwIDMgNjcgMyA2OCAtMjg4IDIgLTI4OCAzIC0zIDMxOCAtMiAzMTcgLTY1IDAgYy00NSAwIC02NwotNCAt
    NzEgLTEzeiIvPgo8cGF0aCBkPSJNNjA2NCAxNDc2IGMtMyAtNyAtNCAtMzUgLTIgLTYyIGwzIC00OSAxMzUgLTIgYzc0IC0y
    IDE0NSAtNSAxNTggLTgKbDIyIC01IDAgLTMyMSAwIC0zMjAgNjggMyA2NyAzIDUgMzIwIDUgMzIwIDE1MyAzIDE1MiAzIDAg
    NjQgMCA2NSAtMzgwIDAKYy0zMTQgMCAtMzgyIC0yIC0zODYgLTE0eiIvPgo8cGF0aCBkPSJNNjkzMCAxMjYyIGMwIC0yNTcg
    OCAtMzAyIDY2IC0zODggNDEgLTYxIDEwNCAtMTA4IDE4MiAtMTM3IDQ5IC0xOAo4NiAtMjEgMjU1IC0yNSAyMTQgLTQgMjQ2
    IDEgMjY2IDQ0IDcgMTcgMTEgMTM3IDExIDM3OSBsMCAzNTUgLTcwIDAgLTcwIDAgLTIKLTMxNyAtMyAtMzE4IC0xNTUgMCBj
    LTE1MiAwIC0xNTYgMSAtMjE1IDMwIC03MiAzNiAtMTEwIDg2IC0xMjUgMTY0IC01IDI5Ci0xMCAxNDEgLTEwIDI0NyBsMCAx
    OTQgLTY1IDAgLTY1IDAgMCAtMjI4eiIvPgo8cGF0aCBkPSJNNzk3NSAxNDcxIGMtODAgLTM3IC0xMjUgLTExMSAtMTI1IC0y
    MDYgMCAtOTQgNDIgLTE2NCAxMjUgLTIwOCAzNgotMTkgNjEgLTIyIDI1NyAtMjcgMjQzIC02IDI0NSAtNiAyNTUgLTc3IDQg
    LTMyIDEgLTQ1IC0yMCAtNjkgbC0yNSAtMjkgLTI5NAotNSAtMjkzIC01IDAgLTY1IDAgLTY1IDI3MCAtMyBjMjk5IC00IDM1
    MSAzIDQxNCA0OCAxMDEgNzMgMTE3IDIzOSAzMyAzMzMKLTY0IDcwIC05MCA3NyAtMzA4IDc3IC0yNDggMCAtMjc0IDkgLTI3
    NCA5NSAwIDQyIDEyIDY5IDM3IDgxIDEwIDUgMTMzIDExCjI3MyAxNCBsMjU1IDUgMCA2MCAwIDYwIC0yNzAgMiBjLTI0NSAz
    IC0yNzQgMSAtMzEwIC0xNnoiLz4KPHBhdGggZD0iTTc4MCAxNDU1IGMtMzMgLTQwIDI5IC03MiAyMDMgLTEwNSA2NSAtMTMg
    MTE2IC0yNSAxMTMgLTI3IC0zIC0zCi0zOCAxIC03OCA4IC05MCAxNiAtMjU4IDE2IC0zMTYgMCAtNTIgLTE1IC01MyAtMzUg
    LTQgLTY0IDI4IC0xNiA4MiAtMjQgMzMwCi00MyAzMTMgLTI0IDYwMiAtNTMgNjE1IC02MSA0IC0yIDcgMCA3IDUgMCA1IC0x
    MiAxMiAtMjcgMTYgLTY3IDE1IC0zODcgMTA1Ci0zNzUgMTA1IDYgMSA4NyAtMTcgMTc4IC0zOSA5MiAtMjIgMTcxIC00MCAx
    NzggLTQwIDE3IDEgLTE2MCA3NCAtMzU0IDE0NwotMjc0IDEwMiAtNDM4IDEzNyAtNDcwIDk4eiIvPgo8cGF0aCBkPSJNMTk5
    OSAxMjMwIGMtMTYzIC03IC0yMjcgLTIwIC0xODYgLTM2IDE5IC03IDE4NCAxIDI2NyAxMiAyNSA0IDQzIDQKNDAgMSAtMyAt
    MiAtNzUgLTE1IC0xNjAgLTI3IC0xNTIgLTIxIC0xOTEgLTMzIC0xNTYgLTQ2IDM5IC0xNSA0MjUgNjAgNDUxIDg4CjcgNyAw
    IDkgLTIzIDQgLTIxIC0zIC0zMSAtMiAtMjcgNCA0IDYgLTQgOSAtMTcgOCAtMTMgMCAtOTggLTQgLTE4OSAtOHoiLz4KPHBh
    dGggZD0iTTIzMzUgMTE3OSBjLTM4IC0yNiAtMTE4IC03MyAtMTc4IC0xMDYgLTE1NCAtODMgLTIyNyAtMTMwIC0yMjcKLTE0
    OCAwIC02MiAyNDMgNzQgNDIwIDIzNCAzNiAzMiA2MyA2MSA2MCA2MyAtMyAyIC0zNiAtMTcgLTc1IC00M3oiLz4KPHBhdGgg
    ZD0iTTYyMCAxMjA3IGMtMjggLTcgLTQ1IC0xOCAtNDUgLTI3IDAgLTIxIDYyIC00OSAxMTUgLTUxIDY4IC0zIDk0MQoxNCA5
    MzYgMTggLTQgNCAtMTk2IDI3IC00MTEgNDggLTIyMSAyMiAtNTM3IDI4IC01OTUgMTJ6Ii8+CjxwYXRoIGQ9Ik0yMjYwIDEx
    NzkgYy0yNSAtMTEgLTExNSAtNDcgLTIwMCAtODAgLTE3MyAtNjcgLTI0MCAtMTAyIC0yNDAgLTEyNgowIC0yNiA2MCAtMTAg
    MTgzIDUwIDIxNSAxMDQgNDIwIDIyOCAyNTcgMTU2eiIvPgo8cGF0aCBkPSJNMTUxMCAxMTIzIGMtNDU0IC02IC05NTcgLTIz
    IC05OTMgLTMzIC04NCAtMjUgLTcgLTU5IDEzMyAtNTkgNTIgMAoyNDggMTMgNDM1IDI5IDE4NyAxNiA0MDYgMzUgNDg4IDQy
    IDgxIDYgMTQ3IDE1IDE0NyAyMCAwIDQgLTEgNyAtMiA2IC0yIC0yCi05NSAtNCAtMjA4IC01eiIvPgo8cGF0aCBkPSJNMTM0
    NSAxMDY0IGMtNDMyIC0zMyAtNzIwIC03MSAtODU2IC0xMTMgLTc0IC0yMyAtMTAyIC00NiAtNzggLTYyCjI0IC0xNyAyMjUg
    LTIgMzU0IDI2IDI1MCA1NCAzNTQgNzQgNTc5IDExMCAzNDIgNTYgMzQzIDY2IDEgMzl6Ii8+CjxwYXRoIGQ9Ik0xNTcwIDEw
    MzMgYy0xNCAtMiAtMTEzIC0xOCAtMjIwIC0zNCAtNTAyIC03NiAtODIyIC0xNjcgLTg0NSAtMjQwCi0xNyAtNTEgMTYgLTQ2
    IDM4NCA2MiA0MzUgMTI4IDY1MiAxODkgNjkzIDE5NSAyMSA0IDM4IDEwIDM4IDE1IDAgOSAtNiA5IC01MAoyeiIvPgo8cGF0
    aCBkPSJNMTIyMCA4NzUgYy01NDcgLTE0NCAtNjc5IC0xODkgLTY4OCAtMjM2IC0zIC0xOCAzNyAtMzkgNzQgLTM5IDM0IDAK
    MTMyIDM1IDYyOSAyMjIgMjMxIDg2IDQxMSAxNTcgNDAwIDE1NyAtMTEgMCAtMTk4IC00NyAtNDE1IC0xMDR6Ii8+CjxwYXRo
    IGQ9Ik0xNDcwIDg0OSBjLTEwMiAtMzggLTI5NSAtMTA3IC00MzAgLTE1NSAtMjcwIC05NCAtMzU0IC0xMzEgLTM5NQotMTc0
    IC0zMiAtMzMgLTI4IC01NSAxMCAtNzAgNDYgLTE4IDE3MyAzNSA1OTUgMjQ4IDIyMyAxMTIgNDA3IDIwNiA0MDkgMjA4CjE3
    IDE2IC0yNyAzIC0xODkgLTU3eiIvPgo8cGF0aCBkPSJNMTU2NSA3ODQgYy03NyAtMzYgLTI1NyAtMTE4IC00MDAgLTE4MSAt
    MzQzIC0xNTMgLTQwNSAtMTk0IC00MDUKLTI2NiAwIC0yOSAxIC0zMCA0MCAtMjQgNDYgNiAxNTYgNTYgMjc1IDEyNCA2MiAz
    NiA2MjQgMzkzIDY0NCA0MTAgMTggMTQgLTM0Ci03IC0xNTQgLTYzeiIvPgo8cGF0aCBkPSJNMTgxMyA4MjUgYy0xMSAtOCAt
    MTU0IC04OCAtMzE2IC0xNzkgLTE2MiAtOTAgLTMzMyAtMTg5IC0zODAgLTIyMAotMTM5IC05MyAtMjAzIC0xNzYgLTE2NiAt
    MjEzIDIxIC0yMSAxMTIgMjAgMjQ1IDEwOSA2OCA0NiA1NzIgNDQ2IDYyOSA0OTkgMjMKMjMgMTggMjUgLTEyIDR6Ii8+Cjxw
    YXRoIGQ9Ik0xOTEyIDU4NiBjLTgwIC0yNDMgLTg4IC0yODQgLTcwIC0zNTYgMTEgLTQ1IDE4IC01NiA0MSAtNjQgMjQgLTkK
    MzEgLTYgNTUgMTcgMjYgMjcgMjcgMzEgMjUgMTMwIDAgNTYgMyAxODIgOSAyODAgNSA5OCA4IDE4MCA3IDE4MSAtMiAyIC0z
    MgotODIgLTY3IC0xODh6Ii8+CjxwYXRoIGQ9Ik0xODkwIDY5MyBjLTg0IC05MyAtMTg4IC0yNTEgLTIxNiAtMzI5IC0zMiAt
    ODYgLTMzIC0xODUgLTMgLTIxNSA0OAotNDggODMgMCAxMTAgMTUxIDI4IDE2NCA3MiAyOTUgMTI2IDM3NyAyNCAzNyA0NyA3
    MSA0OSA3NiAxNiAyNCAtMTIgLTIgLTY2Ci02MHoiLz4KPHBhdGggZD0iTTIwMTUgNTkzIGMtMTMgLTI2NCA2IC0zODMgNjIg
    LTM5MSA0OCAtNyA1NCA2NyAxNSAyMDkgLTExIDQyIC0yOQoxMzUgLTM5IDIwNyAtMTAgNzMgLTIxIDEzMiAtMjQgMTMyIC00
    IDAgLTEwIC03MSAtMTQgLTE1N3oiLz4KPC9nPgo8L3N2Zz4K
```
