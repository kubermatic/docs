+++
title = "VirtualMachines Resources"
date = 2025-07-18T16:06:34+02:00
weight = 15
+++

## VirtualMachines
As the name suggests, a VirtualMachine(VM) represents a long-running, stateful virtual machine. It's similar to a 
Kubernetes Deployment for Pods, meaning you define the desired state (e.g., "this VM should be running," "it should 
have 2 CPUs and 4GB RAM") and Kubermatic-Virtualization ensures that state is maintained. It allows you to start, stop, and configure VMs. 

Here is an example of how users can create a VM:
```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-vm-with-http-data-volume
spec:
  runStrategy: RerunOnFailure
  template:
    metadata:
      labels:
        app: my-vm-with-http-data-volume
      annotations:
        kubevirt.io/allow-pod-bridge-network-live-migration: "true"
    spec:
      domain:
        cpu:
          cores: 1
        memory:
          guest: 2Gi
        devices:
          disks:
            - name: rootdisk
              disk:
                bus: virtio
          interfaces:
            - name: default
              masquerade: {}
      volumes:
        - name: rootdisk
          dataVolume:
            name: my-http-data-volume
      networks:
        - name: default
          pod: {}
  dataVolumeTemplates:
    - metadata:
        name: my-http-data-volume
      spec:
        sourceRef:
          kind: DataSource
          name: my-http-datasource
          apiGroup: cdi.kubevirt.io
        pvc:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 10Gi # <--- IMPORTANT: Adjust to your desired disk size
          # storageClassName: my-storage-class # <--- OPTIONAL: Uncomment and replace with your StorageClass name if needed
---
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  name: my-http-datasource
spec:
  source:
    http:
      url: "http://example.com/path/to/your/image.qcow2" # <--- IMPORTANT: Replace with the actual URL of your disk image
      # certConfig: # <--- OPTIONAL: Uncomment and configure if your HTTP server uses a custom CA
      #   caBundle: "base64encodedCABundle"
      #   secretRef:
      #     name: "my-http-cert-secret"
      #   cert:
      #     secretRef:
      #       name: "my-http-cert-secret"
      #   key:
      #     secretRef:
      #       name: "my-http-key-secret"
```
### 1. `VirtualMachine` (apiVersion: `kubevirt.io/v1`)

This is the main KubeVirt resource that defines your virtual machine.

- **`spec.template.spec.domain.devices.disks`**:  
  Defines the disk attached to the VM. We reference `rootdisk` here, which is backed by our DataVolume.

- **`spec.template.spec.volumes`**:  
  Links the `rootdisk` to a `dataVolume` named `my-http-data-volume`.

- **`spec.dataVolumeTemplates`**:  
  This is the crucial part. It defines a template for a DataVolume that will be created automatically when the VM is started.

---

### 2. `DataVolumeTemplate` (within `VirtualMachine.spec.dataVolumeTemplates`)

- **`metadata.name`**:  
  The name of the DataVolume that will be created (referenced in `spec.template.spec.volumes`).

- **`spec.sourceRef`**:  
  Points to a `DataSource` resource that defines the actual source of the disk image. A `DataSource` is used here to encapsulate HTTP details.

- **`spec.pvc`**:  
  Defines the characteristics of the PersistentVolumeClaim (PVC) that will be created for this DataVolume:

    - **`accessModes`**: Typically `ReadWriteOnce` for VM disks.
    - **`resources.requests.storage`**:  
      ⚠️ **Crucially, set this to the desired size of your VM's disk.** It should be at least as large as your source image.
    - **`storageClassName`**: *(Optional)* Specify a StorageClass if needed; otherwise, the default will be used.

---

### 3. `DataSource` (apiVersion: `cdi.kubevirt.io/v1beta1`)

This is a CDI (Containerized Data Importer) resource that encapsulates the details of where your disk image comes from.

- **`metadata.name`**:  
  The name of the `DataSource` (referenced in `dataVolumeTemplate.spec.sourceRef`).

- **`spec.source.http.url`**:  
  🔗 This is where you put the direct URL to your disk image (e.g., a `.qcow2`, `.raw`, etc. file).

- **`spec.source.http.certConfig`**: *(Optional)*  
  If your HTTP server uses a custom CA or requires client certificates, configure them here.

---

### VirtualMachinePools
KubeVirt's VirtualMachinePool is a powerful resource that allows you to manage a group of identical Virtual Machines (VMs)
as a single unit, similar to how a Kubernetes Deployment manages a set of Pods. It's designed for scenarios where you need
multiple, consistent, and often ephemeral VMs that can scale up or down based on demand.

Here's a breakdown of the key aspects of KubeVirt VirtualMachinePools:


```yaml
apiVersion: kubevirt.io/v1alpha1
kind: VirtualMachinePool
metadata:
  name: my-vm-http-pool
spec:
  replicas: 3 # <--- IMPORTANT: Number of VMs in the pool
  selector:
    matchLabels:
      app: my-vm-http-pool-member
  virtualMachineTemplate:
    metadata:
      labels:
        app: my-vm-http-pool-member
      annotations:
        kubevirt.io/allow-pod-bridge-network-live-migration: "true"
    spec:
      runStrategy: RerunOnFailure # Or Always, Halted, Manual
      domain:
        cpu:
          cores: 1
        memory:
          guest: 2Gi
        devices:
          disks:
            - name: rootdisk
              disk:
                bus: virtio
          interfaces:
            - name: default
              masquerade: {}
      volumes:
        - name: rootdisk
          dataVolume:
            name: my-pool-vm-data-volume # This name will have a unique suffix appended by KubeVirt
      networks:
        - name: default
          pod: {}
      dataVolumeTemplates:
        - metadata:
            name: my-pool-vm-data-volume # This name will be the base for the unique DataVolume names
          spec:
            sourceRef:
              kind: DataSource
              name: my-http-datasource
              apiGroup: cdi.kubevirt.io
            pvc:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 10Gi # <--- IMPORTANT: Adjust to your desired disk size for each VM
              # storageClassName: my-storage-class # <--- OPTIONAL: Uncomment and replace with your StorageClass name if needed
---
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataSource
metadata:
  name: my-http-datasource
spec:
  source:
    http:
      url: "http://example.com/path/to/your/image.qcow2" # <--- IMPORTANT: Replace with the actual URL of your disk image
      # certConfig: # <--- OPTIONAL: Uncomment and configure if your HTTP server uses a custom CA
      #   caBundle: "base64encodedCABundle"
      #   secretRef:
      #     name: "my-http-cert-secret"
      #   cert:
      #     secretRef:
      #       name: "my-http-cert-secret"
      #   key:
      #     secretRef:
      #       name: "my-http-key-secret"

```
### VirtualMachinePool (apiVersion: `kubevirt.io/v1alpha1`)

1. **`API Version`**
  - Use `apiVersion: kubevirt.io/v1alpha1` for `VirtualMachinePool`.
  - This is a slightly different API version than `VirtualMachine`.

2. **`spec.replicas`**
  - Specifies how many `VirtualMachine` instances the pool should maintain.

3. **`spec.selector`**
  - Essential for the `VirtualMachinePool` controller to manage its VMs.
  - `matchLabels` must correspond to the `metadata.labels` within `virtualMachineTemplate`.

4. **spec.virtualMachineTemplate**
  - This section contains the full `VirtualMachine` spec that serves as the template for each VM in the pool.

5. **`dataVolumeTemplates` Naming in a Pool**
  - `VirtualMachinePool` creates `DataVolumes` from `dataVolumeTemplates`.
  - A unique suffix is appended to the `metadata.name` of each `DataVolume` (e.g., `my-pool-vm-data-volume-abcde`), ensuring each VM gets a distinct PVC.

---

### How It Works (Similar to Deployment for Pods)

1. Apply the `VirtualMachinePool` manifest. KubeVirt ensures the `my-http-datasource` `DataSource` exists.
2. The `VirtualMachinePool` controller creates the defined number of `VirtualMachine` replicas.
3. Each `VirtualMachine` triggers the creation of a `DataVolume` using the specified `dataVolumeTemplate` and `my-http-datasource`.
4. CDI (Containerized Data Importer) downloads the image into a new unique `PersistentVolumeClaim` (PVC) for each VM.
5. Each `VirtualMachine` then starts using its dedicated PVC.

