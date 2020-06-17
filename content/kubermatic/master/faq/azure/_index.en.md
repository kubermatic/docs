+++
title = "Frequently asked questions about Azure"
date = 2019-07-16T12:07:15+02:00
weight = 20
pre = "<b></b>"
+++

## General

 - **How are the sizes of VM downloaded and why some of the types are not on the list?**
 
   The Azure API client is used to retrieve VM sizes. The VM sizes are filtered. The final result
   contains all types available for your Subscription and selected location. Because virtual machines are used to spin up
   Kubernetes cluster they must suitable for Azure Container Service. Azure Container Service allows you to quickly
   deploy a production ready Kubernetes, DC/OS, or Docker Swarm cluster. The Azure API model delivers a set of valid VM 
   size types for container purpose and they are also used to get the final result list of VM sizes.
