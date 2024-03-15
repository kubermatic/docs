import json
import sys

# master.json file was created w/ below command on the master node:
# ./kube-bench -D ./cfg/ run --targets=controlplane,master,etcd,node --benchmark=cis-1.8 --json --outputfile master.json

with open('master.json', 'r') as jsonfile:
    data = json.load(jsonfile)

kubeone_version = sys.argv[1]
kubernetes_patch_version = sys.argv[2]

benchmark_version = data['Controls'][0]['version']
kubernetes_version = data['Controls'][0]['detected_version']

details_filename = 'additional_details_{}.json'.format(benchmark_version)
with open(details_filename, 'r') as nafile:
    additional_details = json.load(nafile)

configurablefilename = 'configurable_controls_{}.json'.format(benchmark_version)
with open(configurablefilename, 'r') as cfgfile:
    configurable_controls = json.load(cfgfile)

# print the header
print('''+++
title = "Benchmark on Kubernetes {} with KubeOne {}"
date = 2024-03-06T12:01:00+02:00
+++
'''.format(kubernetes_version, kubeone_version))

# print introduction
print('''This guide helps you evaluate the security of a Kubernetes cluster created using KubeOne against each control in the CIS Kubernetes Benchmark.

This guide corresponds to the following versions of KubeOne, CIS Benchmarks, and Kubernetes:

| KubeOne Version  | Kubernetes Version | CIS Benchmark Version |
| ---------------- | ------------------ | --------------------- |
| {}               | {}                 | {}                    |
'''.format(kubeone_version, kubernetes_patch_version, benchmark_version.upper()))

# print testing methodology
print('''## Testing Methodology

Each control in the CIS Kubernetes Benchmark was evaluated. These are the possible results for each control:

🟢 **Pass:** The cluster passes the audit/control outlined in the benchmark.

🔵 **Pass (Additional Configuration Required):** The cluster passes the audit/control outlined in the benchmark with some extra configuration. The documentation is provided.

🔴 **Fail:** The audit/control will be fixed in a future KubeOne release.
''')

# print results from the json file
for controls in data['Controls']:
    print("## Control Type: {}".format(controls['node_type']))
    for test in controls['tests']:
        print('### {}. {}'.format(test['section'], test['desc']))
        for t in test['results']:
            print('#### {}: {}\n'.format(t['test_number'], t['test_desc']))
            if t['test_number'] in additional_details.keys():
                result, text = additional_details[t['test_number']]
                color = '🟢' if result == 'Pass' else '🔴'
                print('**Result:** {} {}\n'.format(color, result))
                print('**Details:** {}\n'.format(text))
                print('---')
                continue
            if t['test_number'] in configurable_controls.keys():
                print('**Result:** 🔵 Pass (Additional Configuration Required)\n')
                print('**Details:** {}\n'.format(configurable_controls[t['test_number']]))
                print('---')
                continue
            match t['status']:
                case 'PASS':
                    print('**Result:** 🟢 Pass\n')
                case 'WARN' | 'FAIL':
                    print('**Result:** 🔴 Fail\n')
                    print('_The issue is under investigation to provide a fix in a future KubeOne release_\n')
                case _:
                    print('**Result:** {}\n'.format(t['status'].title()))
            print('---')

# print references
print('''
[audit-logging]: {{< ref "../../../tutorials/creating-clusters-oidc/#audit-logging" >}}
[encryption-providers]: {{< ref "../../../guides/encryption-providers/" >}}
[oidc]: {{< ref "../../../tutorials/creating-clusters-oidc/" >}}
[anon-req]: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#anonymous-requests
[eventratelimit]: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#eventratelimit
[securitycontextdeny]: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#securitycontextdeny''')
