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

### 4. Use terraform local to read json from a secret version

NOTE: This relies on at least v1 and v2 versions of the secrets being added and enabled.

Another option is to read secrets from Google Secrets Manager. This requires some setup by either creating the secrets by hand in the UI or in Terraform code.

This is great because now secrets are stored in a safe (secure and durable) datastore with fine grained access permissions as well as versioning to make for safer updates.

:warning: The resource I am using to demo this does not mark these values as sensitive and therefore they show in the plan. This is expected and depends on the resource you are pushing these variables to.

Based on commit: [7013a9fdfc9912b2498e0fe12394757a00c97b3c](https://github.com/abangser/example-tfvars-from-gsm/tree/7013a9fdfc9912b2498e0fe12394757a00c97b3c)

Documentation: https://www.terraform.io/docs/configuration/locals.html

<details>
<summary>Plan output with valid JSON secret</summary>
<p>

```
example-tfvars-from-gsm# terraform apply   
google_project_service.run: Refreshing state... [id=core-301515/run.googleapis.com]
google_project_service.secretmanager: Refreshing state... [id=core-301515/secretmanager.googleapis.com]
google_secret_manager_secret.secret_variables: Refreshing state... [id=projects/436514934743/secrets/secret_variables]
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

                  ~ env {
                        name  = "PRIVATE_VARIABLE"
                      + value = "super secret"
                    }


                    # (3 unchanged blocks hidden)
                }
            }
            # (1 unchanged block hidden)
        }

        # (2 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_cloud_run_service.my-service: Modifying... [id=locations/europe-west2/namespaces/core-301515/services/my-service]
google_cloud_run_service.my-service: Still modifying... [id=locations/europe-west2/namespaces/core-301515/services/my-service, 10s elapsed]
google_cloud_run_service.my-service: Modifications complete after 17s [id=locations/europe-west2/namespaces/core-301515/services/my-service]

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Outputs:

url = "https://my-service-6vezczbbrq-nw.a.run.app"
```

</p>
</details>

However, if you parse a json secret using [`jsondecode`](https://www.terraform.io/docs/configuration/functions/jsondecode.html) and the value is not valid json then the entire secret is printed to the terminal.

Based on commit: [f8255a585d0aeb52faa04f814781c919dd00c303](https://github.com/abangser/example-tfvars-from-gsm/tree/f8255a585d0aeb52faa04f814781c919dd00c303)

<details>
<summary>Plan output with invalid JSON</summary>
<p>

```
example-tfvars-from-gsm# terraform plan
google_project_service.secretmanager: Refreshing state... [id=core-301515/secretmanager.googleapis.com]
google_project_service.run: Refreshing state... [id=core-301515/run.googleapis.com]
google_secret_manager_secret.secret_variables: Refreshing state... [id=projects/436514934743/secrets/secret_variables]

Error: Error in function call

  on secrets.tf line 2, in locals:
   2:   secret_variables = jsondecode(data.google_secret_manager_secret_version.secret_variables.secret_data)
    |----------------
    | data.google_secret_manager_secret_version.secret_variables.secret_data is "{\n    \"secret_variable\": \"super secret\"\n"

Call to function "jsondecode" failed: EOF.
```

</p>
</details>

### 5. Use external datasource to parse json secrets

NOTE: This relies on at least v2 and v3 versions of the secrets being added and enabled.

Using the external datasource we parse the json using our own method which allows us to exit in a safe way

:warning: The resource I am using to demo this does not mark these values as sensitive and therefore they show in the plan. This is expected and depends on the resource you are pushing these variables to.

Based on commit: <SHA>

Documentation: https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source

<details>
<summary>Plan output valid JSON</summary>
<p>

Note: This is based on the value being changed to [`secrets_datafile_changed.json`](./data_files/secrets_datafile_changed.json)

```
example-tfvars-from-gsm# terraform plan
google_project_service.run: Refreshing state... [id=core-301515/run.googleapis.com]
google_project_service.secretmanager: Refreshing state... [id=core-301515/secretmanager.googleapis.com]
google_secret_manager_secret.secret_variables: Refreshing state... [id=projects/436514934743/secrets/secret_variables]
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

                  ~ env {
                        name  = "PRIVATE_VARIABLE"
                      ~ value = "super secret" -> "new super secret"
                    }


                    # (3 unchanged blocks hidden)
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
