+++
title = "Storage"
date = 2025-07-18T16:06:34+02:00
weight = 15
+++

At its heart, Kubermatic Virtualization uses KubeVirt, a Kubernetes add-on. KubeVirt allows you to run virtual machines 
(VMs) right alongside your containers, and it's built to heavily use Kubernetes' existing storage model. The Container 
Storage Interface (CSI) driver is a crucial component in this setup because it allows KubeVirt to leverage the vast and 
diverse storage ecosystem of Kubernetes for its VMs.

The Container Storage Interface (CSI) is a standard for exposing arbitrary block and file storage systems to containerized 
workloads on Container Orchestration Systems (COs) like Kubernetes. Before CSI, storage integrations were tightly coupled 
with Kubernetes' core code. CSI revolutionized this by providing a pluggable architecture, allowing storage vendors to 
develop drivers that can integrate with Kubernetes without modifying Kubernetes itself.

# KubeVirt + CSI Drivers: How It Works

KubeVirt’s integration with CSI (Container Storage Interface) drivers is fundamental to how it manages VM storage. This document explains how CSI enables dynamic volume provisioning, image importing, and advanced VM disk features in KubeVirt.

---

## 1. Dynamic Volume Provisioning for VM Disks

### PersistentVolumeClaims (PVCs)
KubeVirt does not directly interact with the underlying storage backend (e.g., SAN, NAS, cloud block storage). Instead, it uses Kubernetes’ PVC abstraction. When a VM is defined, KubeVirt requests a PVC.

### StorageClasses
PVCs reference a `StorageClass`, which is configured to use a specific CSI driver as its "provisioner".

### Driver’s Role
The CSI driver associated with the `StorageClass` handles the provisioning of persistent storage by interfacing with external systems (e.g., vCenter, Ceph, cloud providers).

### VM Disk Attachment
Once the PV is bound, KubeVirt uses the `virt-launcher` pod to attach the volume as a virtual disk to the VM.

---

## 2. Containerized Data Importer (CDI) Integration

### Importing VM Images
KubeVirt works with the CDI project to import disk images (e.g., `.qcow2`, `.raw`) from HTTP, S3, and other sources into PVCs.

### CSI Uses CSI
CDI relies on CSI drivers to provision the PVCs that will store the imported images. After import, KubeVirt consumes the PVC as a disk.

### DataVolume Resource
KubeVirt’s `DataVolume` custom resource simplifies image importing and ties CDI with PVC creation in a declarative way.

---

## 3. Advanced Storage Features (via CSI Capabilities)

CSI drivers allow powerful features previously complex for VM setups:

- **Snapshots**: If supported, KubeVirt can create `VolumeSnapshot` objects for point-in-time backups.
- **Cloning**: Allows fast provisioning of VM disks from existing PVCs without re-importing.
- **Volume Expansion**: Resize VM disks dynamically with `allowVolumeExpansion`.
- **ReadWriteMany (RWX) Mode**: Enables live migration by allowing shared access across nodes.
- **Block vs. Filesystem Modes**: CSI supports both `Filesystem` and `Block`. Choose based on workload performance needs.

---

## 4. Example Scenario
Admin creates a `StorageClass`:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: my-fast-storage
provisioner: csi.my-storage-vendor.com # This points to the specific CSI driver
parameters:
  type: "ssd"
volumeBindingMode: WaitForFirstConsumer # Important for VM scheduling
allowVolumeExpansion: true
```
User defines a `VirtualMachine` with a `DataVolume`:
```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: my-vm
spec:
  dataVolumeTemplates:
    - metadata:
        name: my-vm-disk
      spec:
        storageClassName: my-fast-storage # References the StorageClass
        source:
          http:
            url: "http://example.com/my-vm-image.qcow2"
        pvc:
          accessModes:
            - ReadWriteOnce # Or ReadWriteMany for live migration
          resources:
            requests:
              storage: 20Gi
  template:
    spec:
      domain:
        devices:
          disks:
            - name: my-vm-disk
              disk:
                bus: virtio
        # ... other VM specs
      volumes:
        - name: my-vm-disk
          dataVolume:
            name: my-vm-disk
```
In this flow:

- KubeVirt sees the DataVolumeTemplate and requests a PVC (my-vm-disk) using my-fast-storage.

- The my-fast-storage StorageClass directs the request to csi.my-storage-vendor.com (the CSI driver).

- The CSI driver provisions a 20Gi volume on the backend storage.

- CDI then imports my-vm-image.qcow2 into this newly provisioned PVC.

- Once the data import is complete, KubeVirt starts the VM, and the PVC is attached as the VM's disk.

---

## Summary

KubeVirt uses CSI to:
- Abstract storage provisioning and attachment.
- Enable features like cloning, snapshots, and expansion.
- Import images using CDI with CSI-provisioned PVCs.
- Support enterprise-grade live migration and scalability.

