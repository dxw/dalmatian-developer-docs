# AWS account first time setup

If you have provided us with an AWS user ARN, you will be given access to a role within the AWS account in which your infrastructure is launched. You can then assume the role from your existing AWS account.

If you do not have an existing AWS user, one will be provided for you.

Note: you will only be allowed access to the AWS account if your infrastructure is in a dedicated AWS account, not if your application runs on a shared infrastructure.

When you recieve your username and password, you will need to configure MFA for the user account. This will allow you to switch roles, which will give you the required permissions needed to access resources in the AWS account.

## Logging in

1. Go to the [AWS Sign in page](https://console.aws.amazon.com/console/home?nc2=h_ct&src=header-signin)

2. Select 'IAM user'

3. Enter the AWS Account ID provided to you (this is the AWS account alias or AWS account number) then click 'Next'

4. Enter your AWS Username and Password, and click 'Sign in'

## Configuring 2FA

1. Click the 'username @ account-name' drop down menu (top right)

2. Select 'My security credentials'

3. Select 'Assign MFA device'

4. Select 'Virtual MFA device' and click continue

5. Set up the MFA device using your preferred MFA application, then click 'Assign MFA device'

6. Sign out and log back in

## Switching roles

When you log in, your user account will not have permissions to do anything (other than setting up MFA).

You will be provided a role name to switch to, which will have permissions to provide access to the required AWS resources.

1. Click the 'username @ account-name' drop down menu (top right)

2. Select 'Switch Role'

3. Enter the 'Account' and 'Role' provided and select 'Switch Role'

## Reset password

If you are still using the password that was originally supplied, you will need to reset the password.

When you log into your user account, you will not have permissions to do anything (other than configuring MFA).

1. Click the 'username @ account-name' drop down menu (top right)

2. Select 'My security credentials'

3. Select 'Change Password' to change your password
