+++
title = "Contribute to the Docs"
date = 2018-04-28T12:07:15+02:00
weight = 15

draft = true
+++

## Contributing to Kubermatic Kubernetes Platform(KKP) Docs

The [KKP Docs](http://docs.kubermatic.io) source repository can be found on [Github](https://github.com/kubermatic/docs).

To generate the documentation you will need to download and install the [Hugo](https://gohugo.io/overview/installing/) static website engine.

Clone the repository to your local device and create a new feature branch.

```bash
git clone https://github.com/kubermatic/docs
git checkout -b my-new-contribution
```

Generate and serve the documentation at `localhost:1313`:

```bash
hugo server --buildDrafts --baseURL localhost:1313 --watch
```

## Repository Organization

The content in the [KKP/docs](https://github.com/kubermatic/docs) repository follows the organization of [Hugo directory structure](https://gohugo.io/getting-started/directory-structure/). Essentially, two folders at repository root level should be mentioned:

### /content

`content`: All content for [KKP/docs](https://github.com/kubermatic/docs) will live inside this directory. Each top-level folder in Hugo is considered a `content section`.


### /static

`static`: Stores all the static content for [KKP/docs](https://github.com/kubermatic/docs) website: images, CSS, JavaScript, etc. When Hugo builds the documentation, all assets inside your static directory are copied over as-is. The `/static` folder contains the `static/media` folder for root directory content media files, inside which are subfolders with the images for each documentation article. The article image folders are named identically to the article file, minus the `.md` file extension.

## Creating a New Article for KKP Docs

The basic structure for a new section in the documentation is as follows:

```bash
content
├── my-new-topic
│   ├── my-new-article
│   │   └── _index.en.md
│   ├── _index.en.md
```

A folder with the title of the new section must be created below the `/content` directory. An index file named `_index.en.md` is created in this folder, which has the following structure and metadata:

```markdown
+++
title = "my-new-section"
date =  yyyy-mm-ddThh:mm:ss+01:00     // timestamp information
weight = 5                            // Menu sorting
chapter = true                        // Mark this as a chapter
+++

### My New Chapter

# Concepts

Some content...
```

Within the folder with the new section, the individual chapters are created in subfolders; a file named `_index.en.md` is also stored in each subfolder.

```markdown
+++
title = "my-new-article"             // The display title of your section
date =  yyyy-mm-ddThh:mm:ss+01:00    // timestamp information
weight = 5                           // Menu sorting
+++

# My Headline

Some content...
```

To generate the static website files simply run the `hugo` command on the root directory. All files will be generated into the `/public` folder. For local development generate and serve the documentation at `localhost:1313`:

```bash
hugo server --baseURL localhost:1313 --watch
```

## How to Use Markdown to Format Your Topic

All the articles in this repository use GitHub flavored markdown. If you are not familiar with Markdown, see:

* [Markdown basics](https://help.github.com/articles/markdown-basics/)
* [Printable Markdown cheatsheet](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)
