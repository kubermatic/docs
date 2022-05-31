+++
title = "Troubleshoot GitHub Actions Pipeline"
weight = 30
+++

In case that some step failed in the pipeline, go to the **Actions** or **CI/CD** menu and open a specific pipeline run,
see the details of the failed step, see the GitHub example below.

![Failed Pipeline](failed_pipeline.png?width=700px&classes=shadow,border "Failed Pipeline")

There may be various root causes inside the pipeline, in the above step you can see that the `GITHUB_TOKEN`
was not set properly (missing secret definition).

Other examples of the issues may be:
* Missing credentials or invalid permissions - would cause a failure of terraform plan or apply job
* Invalid paths or no such file errors - probably caused by updating the structure and not properly updating the workflow
* Unable to update DNS - this means that in your AWS account, you don’t have a managed zone that is matching the KKP endpoint
* Flux fails on bootstrap - see the options of the `flux bootstrap` command, your repository may be public and managed
  by organization, not personal one and private. Just update the parameters in the `flux-bootstrap` job 

Example command when repository is public and managed by organization:
```bash
flux bootstrap github --owner=<org-name> --repository=<repo-name> --branch=main --personal=false \
  --private=false --path flux/clusters/master`
```

In general in case of any failure, we recommend trying the steps locally (following the instructions in
`README-local-(github|gitlab|bitbucket).md`) and find the right cause of the problem.