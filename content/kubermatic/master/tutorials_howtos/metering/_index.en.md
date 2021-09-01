+++
title = "Metering (EE)"
date = 2021-09-01T11:47:15+02:00
weight = 100

+++

KKP Enterprise Edition (EE) provides optional measuring tools to provide weekly reports about per-cluster CPU and memory utilization.
The tool will continuously collect information about all user clusters and create reports listing individual usage values.
The configuration and report files can be accessed from the dashboard.

## How it works
The metering tool will be deployed to each seed cluster.
From there it will monitor all user clusters and request their performance values every five minutes.
The collected information will be written to a CSV file which will be saved to a `PersistentVolume`.
At the end of the weekly collection period, a CronJob will be triggered so that all data can be evaluated and written to a report file.
All files in the volume will be mirrored to a S3 bucket, from where the reports will be accessible.
The dashboard provides a convenient way to list and download all available reports.

## Configuration

### Prerequisites

* S3 bucket
    - Any S3-compatible endpoint can be used
    - The bucket will be used to store continuous usage data and final reports

### Configuration from the Dashboard

Using the dashboard, configuring the Metering tool becomes a breeze.
Choose the **Metering** tab on the left side and click on **Configure Metering** on the following page.

![Metering User Interface](/img/kubermatic/master/tutorials/metering_disabled_state.png?classes=shadow,border "Metering User Interface")

A new form will open up and allow you to enable metering and define the required configuration values.
All values are required.
The `storageSize` should be chosen according to your environment (more user clusters result in increased storage usage).
Old usage data files and reports will not be deleted automatically.

![Metering Configuration](/img/kubermatic/master/tutorials/metering_configuration.png?classes=shadow,border "Metering Configuration")

Once the configuration values have been set and the metering has been enabled, the controller will take care of deploying the tool.

## Reports

Reports will be provided as [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) files.
The file names will include the reporting interval including the start and end timestamp, e.g. `report-WEEKLY--2021-09-06T00:00:00Z-2021-09-13T00:00:00Z.csv`.

### Accessing Reports
While the reports will be stored in your S3-bucket, they can also be accessed from the dashboard.
The metering overview will provide a list of all reports.
Click on the download button on the right side to save a specific report file.

![Metering Overview](/img/kubermatic/master/tutorials/metering_overview.png?classes=shadow,border "Metering Overview")

### Report Values
The following values will be written to the reports:

  - Project Id
  - Project labels
  - Cluster Id
  - Cluster labels
  - Average available CPU
  - Average used CPU
  - Average available memory (bytes)
  - Average used memory (bytes)
  - Average number of used nodes
  - First time seen (timestamp in RFC 3339 format)
  - Last time seen (timestamp in RFC 3339 format)
  - Cluster lifespan (seconds)
