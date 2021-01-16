# Example for tfvars from gsm

A progressive example of using secrets with terraform starting with user entry and moving to reading from Google Secrets Manager (GSM) after parsing with an external provider.

:warning: This is not meant for recreation! Run at own risk! :warning:

This repo was written to have examples for a blog post. If you would like to use this there are a lot of "offline" steps to get started. Here are some that may help, but all these steps and the rest of this code should be used at your own risk including GCP resource billing.

1. Have 2 existing GCP projects, an "orchestrator" and "target" project
2. Create a service account in the "orchestrator" projects
3. In IAM for the "target" project, provide the service account owner privileges

From here, you will still need to do more things like enable APIs, but these should be driven by trying to plan and apply each commit in order.

## Examples

Options 1 through 3 are to set a baseline, 4 and beyond are examples for a blog post.

### 1. Command line input

The most simple version of secrets management is to enter them as terraform asks on run. This is not repeatable nor scalable and so is often not even a step on most projects journey.

Based on commit: [d4e174faa3eeb0cad506e82f86dd44d6cbae6140](https://github.com/abangser/example-tfvars-from-gsm/tree/d4e174faa3eeb0cad506e82f86dd44d6cbae6140)

<details>
<summary>Plan output</summary>
<p>

```
example-tfvars-from-gsm# terraform plan
var.private_variable
  Enter a value: super secret

google_project_service.run: Refreshing state... [id=core-301515/run.googleapis.com]
google_cloud_run_service.my-service: Refreshing state... [id=locations/europe-west2/namespaces/core-301515/services/my-service]
google_cloud_run_service_iam_member.allusers: Refreshing state... [id=v1/projects/core-301515/locations/europe-west2/services/my-service/roles/run.invoker/allusers]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # google_cloud_run_service.my-service will be updated in-place
  ~ resource "google_cloud_run_service" "my-service" {
        id                         = "locations/europe-west2/namespaces/core-301515/services/my-service"
        name                       = "my-service"
        # (4 unchanged attributes hidden)


      ~ template {

          ~ spec {
                # (2 unchanged attributes hidden)

              ~ containers {
                    # (3 unchanged attributes hidden)

                  + env {
                      + name  = "PUBLIC_VARIABLE"
                      + value = "insecure"
                    }
                  + env {
                      + name  = "PRIVATE_VARIABLE"
                      + value = "super secret"
                    }


                    # (2 unchanged blocks hidden)
                }
            }
            # (1 unchanged block hidden)
        }

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

</p>
</details>

### 2. Envrioment variables

Terraform can read directly from environment variables. This is a step up because it does not require manual intervention. But how these environment variables are created, stored, and shared still leaves a lot to be desired.

Based on commit: [d4e174faa3eeb0cad506e82f86dd44d6cbae6140](https://github.com/abangser/example-tfvars-from-gsm/tree/d4e174faa3eeb0cad506e82f86dd44d6cbae6140)

Documentation: https://www.terraform.io/docs/commands/environment-variables.html

<details>
<summary>Plan output</summary>
<p>

```
example-tfvars-from-gsm# export TF_VAR_private_variable="super secret" && terraform plan
google_project_service.run: Refreshing state... [id=core-301515/run.googleapis.com]
google_cloud_run_service.my-service: Refreshing state... [id=locations/europe-west2/namespaces/core-301515/services/my-service]
google_cloud_run_service_iam_member.allusers: Refreshing state... [id=v1/projects/core-301515/locations/europe-west2/services/my-service/roles/run.invoker/allusers]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # google_cloud_run_service.my-service will be updated in-place
  ~ resource "google_cloud_run_service" "my-service" {
        id                         = "locations/europe-west2/namespaces/core-301515/services/my-service"
        name                       = "my-service"
        # (4 unchanged attributes hidden)


      ~ template {

          ~ spec {
                # (2 unchanged attributes hidden)

              ~ containers {
                    # (3 unchanged attributes hidden)

                  + env {
                      + name  = "PUBLIC_VARIABLE"
                      + value = "insecure"
                    }
                  + env {
                      + name  = "PRIVATE_VARIABLE"
                      + value = "super secret"
                    }


                    # (2 unchanged blocks hidden)
                }
            }
            # (1 unchanged block hidden)
        }

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

</p>
</details>

### 3. Input file

This is both where we start to get to repeatable and scalable solutions and also where we first hit a security risk. These values are now no more protected than directly putting them in the `terraform.tfvars` file depending on where you store the faile and how it is shared.

Based on commit: [d4e174faa3eeb0cad506e82f86dd44d6cbae6140](https://github.com/abangser/example-tfvars-from-gsm/tree/d4e174faa3eeb0cad506e82f86dd44d6cbae6140)

Documentation: https://www.terraform.io/docs/configuration/variables.html#variable-definitions-tfvars-files

<details>
<summary>Init and plan output</summary>
<p>

```
example-tfvars-from-gsm# export TF_VAR_private_variable=""                              
example-tfvars-from-gsm# echo $TF_VAR_private_variable

example-tfvars-from-gsm# terraform plan -var-file="terraform-secret.tfvars" 
google_project_service.run: Refreshing state... [id=core-301515/run.googleapis.com]
google_cloud_run_service.my-service: Refreshing state... [id=locations/europe-west2/namespaces/core-301515/services/my-service]
google_cloud_run_service_iam_member.allusers: Refreshing state... [id=v1/projects/core-301515/locations/europe-west2/services/my-service/roles/run.invoker/allusers]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # google_cloud_run_service.my-service will be updated in-place
  ~ resource "google_cloud_run_service" "my-service" {
        id                         = "locations/europe-west2/namespaces/core-301515/services/my-service"
        name                       = "my-service"
        # (4 unchanged attributes hidden)


      ~ template {

          ~ spec {
                # (2 unchanged attributes hidden)

              ~ containers {
                    # (3 unchanged attributes hidden)

                  + env {
                      + name  = "PUBLIC_VARIABLE"
                      + value = "insecure"
                    }
                  + env {
                      + name  = "PRIVATE_VARIABLE"
                      + value = "super secret"
                    }


                    # (2 unchanged blocks hidden)
                }
            }
            # (1 unchanged block hidden)
        }

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

</p>
</details>
