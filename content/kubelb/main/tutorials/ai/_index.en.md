+++
title = "AI"
linkTitle = "AI"
date = 2026-07-23T10:00:00+02:00
description = "Run the management cluster as a multi-tenant AI gateway with centralized credentials, budgets, and metering."
weight = 35
enterprise = true
+++

KubeLB turns the management cluster into a multi-tenant AI gateway. Provider credentials stay in one place, tenants issue their own keys, and every token is metered and attributed per tenant and key.

The chapter is split by role:

- [AI & MCP Gateway]({{% relref "./gateway/" %}}) is for the platform admin: enabling the data plane, configuring providers, and what KubeLB manages. It also covers using agentgateway directly for MCP and A2A traffic.
- [Budgets & Virtual Keys]({{% relref "./budgets-and-virtual-keys/" %}}) is for tenants and the admins who set their limits: self-service keys, token and dollar budgets, live spend, and what clients see when a limit trips.

## Table of Contents

{{% children depth=1 %}}
{{% /children %}}
