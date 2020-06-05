# Migrating to Dalmatian

## GovPress

### Transferring to GitHub

#### 1. Clone the repository

You'll need to clone a local copy of the repository from GovPress GitLab.

#### 2. Check for secrets

For each branch that you want to move to GitHub, do the following:

1. Create a file `exclude_patterns.txt` in the root of the repository containing

   ```
   (.*/)?.+\.lock
   (.*/)?.+-lock\.json
   (.*/)?.+\.min\..+
   ```

1. Run `truffleHog` on the repository to sniff out secrets in the Git history

   ```
   docker run --volume /path/to/repo:/proj dxa4481/trufflehog --regex --exclude_paths exclude_patterns.txt .
   ```

1. If `truffleHog` find real secrets, invalidate them on whatever services they
   refer to, and add commits to remove them

   Don't rewrite the Git history to remove secrets.

#### 3. Set up GitHub

1. Create the repository on GitHub

   Use the naming convention `client-project` for the repository.

   Make the repository private unless the client and technical operations team
   have okayed making it public.

1. Change the `origin` remote to the new GitHub repository

   ```
   git remote set-url origin git@github.com:dxw/client-project.git
   ```

1. Push each branch to the new GitHub repository.

   ```
   git checkout branch-name
   git push --set-upstream origin branch-name
   ```
