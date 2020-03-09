# Application environment variables

Application environment variables are stored within AWS Parameter Store.

The path of the environment variable will be:

```
/<infrastructure-name>/<service-name>/<environment>/<variable-name>
```

## Accessing Parameter Store

To access Parameter Store:

1. Log in and ensure you have switched to a role that provides the required permissions.

2. Click the 'Services' drop down (top left) and select 'Systems Manager'

3. Select 'Parameter Store' from the left navigation section

## Viewing parameters

1. Within Parameter Store, select the paraeter you wish to view

2. If it is encrypted, the value will be hidden. Select 'Show' to see the current value.

## Changing parameters

1. Whilst viewing a parameter, select 'Edit'

2. Enter the new value in the 'Value' text area

Note: if the parameter is encrypted, the current value will not appear in the text area. You will need to 'Show' and copy the current value on the previous page if you need it.

3. Click 'Save Changes'

4. Redeploy the application for changes to take effect. The process for this is documented in [Deployment Pipelines](deployment-pipelines.md)

## Adding parameters

Make note of the Parameter Store path that is needed for the service that is to use the environment variable.

1. Within Parameter Store, select 'Create Parameter'

2. For the name, enter the path for the parameter, eg `/<parameter-store-path/ENVIRONMENT_VARIABLE_NAME`

3. Select 'SecureString'

4. Select the environment's KMS Key alias used to encrypt the parameter from the 'KMS Key ID' drop down

5. Select 'Create Parameter'

6. Redeploy the application for changes to take effect. The process for this is documented in [Deployment Pipelines](deployment-pipelines.md)
