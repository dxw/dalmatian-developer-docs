# Dalmatian Developer Docs

This set of documentation describes how to deploy and manage applications on the Dalmatian platform.

## Getting Started

The Dalmatian platform runs on AWS. For some tasks, you may require access to resources within AWS.

You will be provided with AWS credentials that provide the access permissions required to complete these tasks.

You will need to set up your AWS account the first time you log in. Follow the [AWS account First time setup](aws-account-first-time-setup.md) documentation when you recieve your credentials.

To set up your local environment for AWS, follow the [Setting up AWS credentials on your local environment](setting-up-aws-credentials-on-your-local-environment.md)

## Deploying to Dalmatian

There are 2 environments for each service running on Dalmatian - `staging` and `prod`

Deployments are automated, triggered when a branch is merged in, or a commit pushed to the application's GitHub repository.

The `staging` environemnt tracks the `develop` branch, and the `prod` environemnt tracks the `master` branch.

The deployment is controlled by AWS CodePipeline. To view the status of the pipeline or manually trigger a deployment, follow the [Deployment Pipelines](deployment-pipelines.md) documentation.

## Application environment variables

Application environment variables are managed through AWS Parameter Store.

Follow the [application-environment-variables.md](Application environment variables) documentation to view or change environment variables on the running applications.

## Accessing a running container

Access to the containers may be needed for debugging purposes.

Use the `container-shell.sh` script in the `tooling` directory to run a shell on a running container:

```
./container-shell.sh -i <infrastructure_name> -s <service-name> -e <environment> -p <aws-profile>
```
