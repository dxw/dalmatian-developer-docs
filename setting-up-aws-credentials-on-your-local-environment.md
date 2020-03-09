# Setting up AWS credentials on your local environment

To access the AWS account from your local machine, you will need to generate a set of access keys and configure awscli.

## Generating AWS access keys

1. Log into the AWS account

2. Click the 'username @ account-name' drop down menu (top right)

3. Select 'Create access key'

4. These need to be stored in the file `~/.aws/credentials`, with the following format:

```
[default]
aws_access_key_id=XXXXX
aws_secret_access_key=XXXXX
```

## Using MFA to access the account

MFA is required to access the account.

When using MFA, a second set of temporary credentials are provided, which by default last 12 hours.

There is a `aws-2fa.sh` script in the `tooling` directory to help set up these temporary credentials.

Run the `aws-2fa.sh` script to request the temporary credentials and automatically modify the `~/.aws/credentials` file:

```
./aws-2fa.sh -m $MFA_CODE
```

The `~/.aws/credentials` file will then look like this:

```
[default]
aws_access_key_id=XXXXX
aws_secret_access_key=XXXXX
[mfa]
aws_access_key_id=XXXXX
aws_secret_access_key=XXXXX
aws_session_token=XXXXX
```

## Setting up AWS profiles

We need to configure an AWS profile which will use the MFA credentials and assume the role which provides the required permissions.

In the `~/.aws/config` file:

```
[default]
region=$DEFAULT_REGION
cli_follow_urlparam=false

[profile $PROFILE_NAME]
role_arn = arn:aws:iam::$AWS_ACCOUNT_NUMBER:role/$ROLE_NAME
source_profile = mfa
```

`$DEFAULT_REGION` is the AWS region where the infrastructure is launched.
`$PROFILE_NAME` can be set to anything of your choosing, ideally it would include the account name and role for easy identification.
`$AWS_ACCOUNT_NUMBER` is the AWS account number of where the infrastructure is launched
`$ROLE_NAME` is the name of the role you wish to assume

Now when running `awscli` commands, include the profile name, eg.:

```
aws sts get-caller-identity --profile $PROFILE_NAME
```
