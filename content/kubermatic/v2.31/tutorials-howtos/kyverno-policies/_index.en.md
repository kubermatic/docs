+++
title = "Kyverno Policies"
date = 2025-06-11T12:00:00+02:00
weight = 16
enterprise = true
+++

KKP 2.28 introduces a new feature to integrate Kyverno. Kyverno is a cloud-native policy engine originally built for Kubernetes. 

## Overview 

The Kyverno Policies feature enables enforcement of custom policies on user clusters. Both admins and project owners can create reusable policy templates to define security, compliance, and configuration rules.

Once templates are created, they can be applied to user clusters by creating policy bindings. These bindings link the templates to user clusters and ensure that the defined policies are enforced.

This feature provides a flexible and scalable way to manage cluster-level security and governance using Kyverno.

## Enabling Kyverno

You need to enable **Kyverno Policy Management** when creating the cluster. You can do this in the cluster creation step, under the **Specification** section.

![enable kyverno](images/enable-kyverno-cluster-creating.png?classes=shadow,border "Enable Kyverno")

You can also enable or disable it after creation from the **Edit Cluster** dialog.

![edit cluster](images/enable-kyverno-edit-cluster.png?classes=shadow,border "Edit Cluster")

## Policy Templates Admin View

Admins can manage global policy templates directly from the **Kyverno Policies** page in the **Admin Panel.**

![kyverno policies admin panel](images/kyverno-policies-admin-panel.png?classes=shadow,border "Kyverno Policies Admin Panel")

From this page, Admins can create new policy templates.

![create policy](images/creat-policy-template-admin-panel.png?classes=shadow,border "Create Policy")

From the same dialog, you can select specific clusters or projects using label selectors.

![labe selector](images/label-selector-policy-spec.png?classes=shadow,border "Label Selector")

Inside the `PolicySpec` is the policy specification of the Kyverno policy we want to apply to the cluster. The structure of this spec should follow the rules defined in the Kyverno  [Writing Policies Docs](https://release-1-13-0.kyverno.io/docs/writing-policies/).

## Policy Templates Project View

Project owners can also manage policies in their own projects from the **Kyverno Policies** page within their project.

![kyverno policies project page](images/kyverno-policies-project-page.png?classes=shadow,border "Kyverno Policies Project Page")

From this page, project owners can manage policy templates within their scope the same way admins do, but limited to their own project. They can also view any available global scope templates and make copies of them.

## Policy Binding

Admins and project owners can add and delete policies on user clusters from the user cluster detail page.

![policy binding list](images/policy-binding-list.png?classes=shadow,border "Policy Binding List")

This page displays a list of all applied policies. You can also create a policy binding from a template.

![add policy binding](images/add-policy-binding.png?classes=shadow,border "Add Policy Binding")

You can choose a template from the list of all available templates. Note that templates already applied will not be available.
