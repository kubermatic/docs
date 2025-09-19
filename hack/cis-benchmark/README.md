# How to create CIS Benchmark Results

## Running trivy

To install trivy, follow the instructions [here](https://trivy.dev/latest/getting-started/installation/).

Once installed, you can run the benchmark with the following command:

```bash
trivy k8s --compliance=k8s-cis-1.23 --report summary --timeout=1h --tolerations node-role.kubernetes.io/control-plane="":NoSchedule --format json --output result.json
```

It outputs the example [result.json](./result.json) file.

## Converting JSON to Markdown

Trivy generates a JSON file which is not very readable. Although we have an option to generate a "table" as well, it has the same issue.

Therefore, we use a script to convert the JSON to Markdown.

```bash
# ./generate_markdown.sh <KUBEONE_VERSION> <KUBERNETES_VERSION> <TRIVY_OUTPUT_JSON_FILE>
./generate_markdown.sh 1.11.0 1.33.4 result.json > /path/to/_index.en.md
```
