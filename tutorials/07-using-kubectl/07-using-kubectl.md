See the [Official kubectl Install Instructions](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for a tutorial on how to install kubectl on your system. Once you have it installed, [download the kubeconfig](../06-download-kubeconfig/06-download-kubeconfig.md) and export it to your environment:

```bash
$ export KUBECONFIG=~/Downloads/kubeconfig-fhgbvx12xg
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.5", GitCommit:"...", GitTreeState:"clean", BuildDate:"...", GoVersion:"go1.9.7", Compiler:"gc", Platform:"darwin/amd64"}
Server Version: version.Info{Major:"1", Minor:"10", GitVersion:"v1.10.3", GitCommit:"...", GitTreeState:"clean", BuildDate:"...", GoVersion:"go1.9.3", Compiler:"gc", Platform:"linux/amd64"}
```