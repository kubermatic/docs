+++
title = "AI"
linkTitle = "AI"
date = 2026-07-23T10:00:00+02:00
weight = 6
+++

KubeLB turns the management cluster into a multi-tenant AI gateway. Provider credentials stay in one place, tenants issue their own keys, and every token is metered and attributed so you know exactly who spent what.

The chapter is split by role:

- [AI & MCP Gateway]({{% relref "./gateway/" %}}) is for the platform admin: enable the data plane, wire up providers, and understand what KubeLB manages for you. It also covers using agentgateway directly for MCP and A2A traffic.
- [Budgets & Virtual Keys]({{% relref "./budgets-and-virtual-keys/" %}}) is for tenants and the admins who set their limits: self-service keys, token and dollar budgets, live spend, and what clients see when a limit trips.
