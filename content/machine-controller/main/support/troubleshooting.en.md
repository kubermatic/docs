+++
title = "Troubleshooting"
date = 2024-05-31T07:00:00+02:00
weight = 5
+++

This guide helps you diagnose and resolve common issues with machine-controller.

## General Debugging

### Check Machine-Controller Logs

View the machine-controller logs to identify errors:

```bash
kubectl logs -n kube-system deployment/machine-controller -f
```

For more verbose logging, increase the log level by editing the deployment:

```bash
kubectl edit deployment machine-controller -n kube-system
```

Change the `-v` flag to a higher value (e.g., `-v=6` for debug level).

### Inspect Machine Status

Check the status of a specific machine:

```bash
kubectl describe machine <machine-name> -n kube-system
```

Look for:
- **Status conditions**: Indicates provisioning state
- **Events**: Shows recent operations and errors
- **Provider status**: Cloud provider-specific information

### List All Machines

```bash
kubectl get machines -n kube-system -o wide
```

Check for machines stuck in provisioning or with error states.

## Common Issues and Solutions

### Machine Stuck in "Provisioning" State

**Symptoms:**
- Machine remains in provisioning state for extended period
- Node doesn't appear in `kubectl get nodes`

**Possible Causes and Solutions:**

1. **Cloud Provider Credentials Invalid**
   ```bash
   kubectl logs -n kube-system deployment/machine-controller | grep -i auth
   ```
   Solution: Verify credentials are correct and have necessary permissions

2. **Instance Creation Failure**
   ```bash
   kubectl describe machine <machine-name> -n kube-system
   ```
   Check events for cloud provider errors (quota limits, invalid instance type, etc.)

3. **Network Connectivity Issues**
   - Ensure security groups/firewall rules allow required traffic
   - Verify subnet has internet access for downloading packages
   - Check if cloud-init can reach necessary endpoints

4. **User Data Script Errors**
   Access the instance via cloud provider console and check:
   ```bash
   sudo journalctl -u cloud-init-output
   ```

### Machine Creation Fails Immediately

**Symptoms:**
- Machine enters error state quickly
- Events show validation or creation errors

**Common Solutions:**

1. **Invalid Configuration**
   ```bash
   kubectl get machine <machine-name> -n kube-system -o yaml
   ```
   Verify all required fields are present and valid

2. **Unsupported Operating System**
   Check the [operating system support matrix]({{< ref "../references/operating-systems/" >}})

3. **Cloud Provider Quota Exceeded**
   - Check cloud provider dashboard for quota limits
   - Request quota increase if needed

### Node Not Joining Cluster

**Symptoms:**
- Cloud instance is created successfully
- Instance appears in cloud provider console
- Node doesn't appear in `kubectl get nodes`

**Debugging Steps:**

1. **Check kubelet status on the instance**
   SSH into the instance:
   ```bash
   systemctl status kubelet
   journalctl -u kubelet -f
   ```

2. **Verify bootstrap token**
   Check if the token is valid:
   ```bash
   kubectl get secrets -n kube-system | grep bootstrap-token
   ```

3. **Check network connectivity**
   From the instance, test connectivity to API server:
   ```bash
   curl -k https://<api-server>:6443
   ```

4. **Review cloud-init logs**
   ```bash
   sudo cat /var/log/cloud-init.log
   sudo cat /var/log/cloud-init-output.log
   ```

### Machine Stuck in "Deleting" State

**Symptoms:**
- Machine remains in deleting state
- Cloud instance may or may not exist

**Solutions:**

1. **Check for finalizers**
   ```bash
   kubectl get machine <machine-name> -n kube-system -o yaml | grep finalizers
   ```

2. **Force delete if necessary** (use with caution)
   ```bash
   kubectl patch machine <machine-name> -n kube-system -p '{"metadata":{"finalizers":[]}}' --type=merge
   ```

3. **Manually delete cloud resources**
   If cloud instance still exists, delete it via cloud provider console/CLI

### MachineDeployment Not Creating Machines

**Symptoms:**
- MachineDeployment exists but no MachineSets or Machines are created

**Solutions:**

1. **Check MachineDeployment events**
   ```bash
   kubectl describe machinedeployment <name> -n kube-system
   ```

2. **Verify selector matches template labels**
   ```yaml
   spec:
     selector:
       matchLabels:
         name: my-workers  # Must match template labels
     template:
       metadata:
         labels:
           name: my-workers
   ```

3. **Check for validation errors**
   Look for events indicating schema validation failures

### Rolling Update Stuck

**Symptoms:**
- MachineDeployment update doesn't complete
- Some old machines remain running

**Solutions:**

1. **Check update strategy**
   ```bash
   kubectl get machinedeployment <name> -n kube-system -o yaml
   ```
   Verify `maxSurge` and `maxUnavailable` settings

2. **Check machine creation errors**
   New machines might be failing to provision:
   ```bash
   kubectl get machines -n kube-system | grep <deployment-name>
   ```

3. **Manually delete problematic machines**
   If machines are stuck, delete them to allow new ones to be created

## Cloud Provider Specific Issues

### AWS

**Issue: Instance creation fails with "unauthorized" error**
- Verify IAM user/role has correct permissions
- Check if instance profile is properly configured
- Ensure AWS credentials are correctly set

**Issue: Instances created in wrong subnet**
- Verify `subnetId` in cloud provider spec
- Check if subnet exists in specified availability zone

### Azure

**Issue: Authentication failures**
- Verify `tenantID`, `clientID`, `clientSecret`, and `subscriptionID`
- Ensure service principal has contributor role on resource group

**Issue: VM size not available**
- Check VM size availability in the specified region
- Use `az vm list-sizes --location <region>` to see available sizes

### DigitalOcean

**Issue: Rate limiting errors**
- DigitalOcean API has rate limits
- Reduce machine-controller worker count if hitting limits

**Issue: Droplet creation fails with "region not available"**
- Verify region slug is correct
- Check if desired droplet size is available in that region

### Google Cloud Platform

**Issue: Service account decoding errors**
- Ensure service account JSON is properly base64 encoded
- Use `cat sa.json | base64 -w0` (Linux) or `cat sa.json | base64` (macOS)

**Issue: Quota exceeded errors**
- Check GCP quotas in the console
- Request quota increase if needed

### Hetzner Cloud

**Issue: Location or server type not found**
- Verify location and server type names are correct
- Use Hetzner Cloud API or CLI to list available options

**Issue: Network attachment fails**
- Ensure network exists in the same location as the server
- Verify network ID is correct

### OpenStack

**Issue: Authentication failures**
- Verify all OpenStack credentials are correct
- Check if domain and project/tenant names match

**Issue: Flavor or image not found**
- Ensure flavor and image IDs/names are valid in your OpenStack deployment
- Check if user has permissions to access these resources

### VMware vSphere

**Issue: VM creation fails**
- Verify vSphere credentials and datacenter configuration
- Check if template/image exists and is accessible
- Ensure sufficient resources (CPU, memory, storage) are available

**Issue: Network configuration errors**
- Verify network name matches vSphere configuration
- Check if IP address pool (if using static IPs) has available addresses

## Performance Issues

### Slow Machine Provisioning

**Possible Causes:**

1. **Cloud Provider API Rate Limits**
   - Reduce machine-controller worker count
   - Implement backoff strategies

2. **Low Worker Count**
   Increase workers in machine-controller deployment:
   ```bash
   kubectl edit deployment machine-controller -n kube-system
   ```
   Change `-worker-count` flag to a higher value (e.g., `-worker-count=20`)

3. **Slow Image Downloads**
   - Use images closer to your cloud provider region
   - Consider pre-baking images with required packages

### High Memory or CPU Usage

**Solutions:**

1. **Reduce worker count** if managing too many concurrent operations
2. **Increase resource limits** on machine-controller deployment
3. **Check for leaked resources** in cloud provider

## Debugging Techniques

### Enable Debug Logging

Edit machine-controller deployment:
```bash
kubectl edit deployment machine-controller -n kube-system
```

Change logging level:
```yaml
args:
- -logtostderr
- -v=6  # Debug level
```

### Collect Diagnostic Information

Create a diagnostic bundle:
```bash
# Machine-controller logs
kubectl logs -n kube-system deployment/machine-controller --tail=1000 > mc-logs.txt

# All machines
kubectl get machines -n kube-system -o yaml > machines.yaml

# All machinesets
kubectl get machinesets -n kube-system -o yaml > machinesets.yaml

# All machinedeployments
kubectl get machinedeployments -n kube-system -o yaml > machinedeployments.yaml

# Events
kubectl get events -n kube-system --sort-by='.lastTimestamp' > events.txt
```

## Getting Help

If you're still experiencing issues:

1. **Check GitHub Issues**: Search [existing issues](https://github.com/kubermatic/machine-controller/issues)
2. **Open a New Issue**: Provide:
   - Machine-controller version
   - Kubernetes version
   - Cloud provider and version
   - Relevant logs and error messages
   - Machine YAML (sanitized)
3. **Community Support**: Join the [Kubermatic Slack](https://kubermatic.slack.com)

## Preventive Measures

1. **Test in staging** before production deployments
2. **Monitor cloud provider quotas** and limits
3. **Set up alerts** for machine provisioning failures
4. **Keep machine-controller updated** to latest stable version
5. **Document custom configurations** for team reference
6. **Regular audit** of MachineDeployments and cloud resources
7. **Implement proper RBAC** to control machine creation

## Additional Resources

- [Machine-Controller GitHub Repository](https://github.com/kubermatic/machine-controller)
- [Cluster API Documentation](https://cluster-api.sigs.k8s.io/)
- [Cloud Provider Documentation]({{< ref "../references/cloud-providers/" >}})
- [Operating System Guide]({{< ref "../references/operating-systems/" >}})

