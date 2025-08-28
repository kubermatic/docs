+++
title = "References"
date = 2024-03-06T12:00:00+02:00
weight = 50
+++

This section contains a reference of the Kubermatic KubeLB CLI commands and flags.

## kubelb

KubeLB CLI - Manage load balancers and create secure tunnels

### Synopsis

KubeLB CLI provides tools to manage KubeLB load balancers and create secure tunnels
to expose local services through the KubeLB infrastructure.

### Options

```
  -h, --help                help for kubelb
      --kubeconfig string   Path to the kubeconfig for the tenant
      --log-file string     Log to file instead of stderr
      --log-format string   Log format (cli, json, text) - defaults to cli
      --log-level string    Log level (error, warn, info, debug, trace) - overrides verbosity
  -q, --quiet               Suppress non-essential output (equivalent to --v=0)
  -t, --tenant string       Name of the tenant
      --timeout duration    Timeout for the command (e.g., 30s, 5m) (default 4m0s)
  -v, --v int               Verbosity level (0-4): 0=errors only, 1=basic info, 2=detailed status, 3=debug info, 4=trace (default 1)
```

### SEE ALSO

* [kubelb completion](commands/kubelb_completion)  - Generate the autocompletion script for the specified shell
* [kubelb docs](commands/kubelb_docs)  - Generate markdown documentation for all commands
* [kubelb expose](commands/kubelb_expose)  - Expose a local port via tunnel
* [kubelb loadbalancer](commands/kubelb_loadbalancer)  - Manage KubeLB load balancers
* [kubelb status](commands/kubelb_status)  - Display current status of KubeLB
* [kubelb tunnel](commands/kubelb_tunnel)  - Manage secure tunnels to expose local services
* [kubelb version](commands/kubelb_version)  - Print the version information
