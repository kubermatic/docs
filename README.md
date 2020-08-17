# Kubermatic Documentation

Kubermatic is a Cluster-as-a-Service that provides managed Kubernetes for your infrastructure.

With Kubermatic, you can set up Kubernetes clusters deployed at the click of button. While Kubermatic makes sure that your cluster is available and up-to-date at all times, you can focus on developing your services.

## Generate Kubermatic Docs locally

To generate the documentation you will need to download and install the [hugo](https://gohugo.io/overview/installing/) static website engine. **Please note:** you need to install the extended version of Hugo for building a website locally.

Clone the repository to your local device and create a new feature branch.

```
git clone https://github.com/kubermatic/docs
git checkout -b my-new-contribution
```

Generate and serve the documentation at `localhost:1313`:

```
hugo server -b localhost:1313 -w
```

For further information please have a look at our contribution guide [here](/content/contributing).

## Contributing

Thanks for taking the time to join our community and start contributing!

Feedback and discussion are available on [the mailing list][11].

### Before you start

* Please familiarize yourself with the [Code of Conduct][4] before contributing.
* See [CONTRIBUTING.md][2] for instructions on the developer certificate of origin that we require.
* Read how [we're using ZenHub][13] for project and roadmap planning

### Pull requests

* We welcome pull requests. Feel free to dig through the [issues][1] and jump in.



[1]: https://github.com/kubermatic/docs/issues
[2]: https://github.com/kubermatic/docs/blob/master/CONTRIBUTING.md
[4]: https://github.com/kubermatic/docs/blob/master/CODE_OF_CONDUCT.md

[11]: https://groups.google.com/forum/#!forum/kubermatic-dev
[13]: https://github.com/kubermatic/docs/blob/master/docs/zenhub.md
