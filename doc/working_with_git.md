# Working with Git

## Github
Rudy source lives in [Github](https://github.com/bunnybuy/rudy).

### Set up Git with Github
Follow [Set up Git](https://help.github.com/articles/set-up-git) and set up your git locally.

## Fork Master
You **should not** work on master. Instead, fork the repository on Github into your own workspace and work on your own branch. Once you have forked the repo into you own work space, follow the Git workflow section below to develop features. See [Fork a Repo](https://help.github.com/articles/fork-a-repo) for more details.

```bash
# step 1: Click the fork button to fork the repo on Github

# step 2: Clone your fork
$ git clone https://github.com/<your_username>/rudy.git

# step 3: Configure remotes
$ cd rudy
$ git remote add upstream https://github.com/bunnybuy/rudy.git
$ git pull upstream
```

## Git workflow
We use _fork and pull_ collaborative model on Github. See [Using Pull Requests](https://help.github.com/articles/using-pull-requests) for references.

### Working on a feature
Please follow the steps when you are working on a feature.

1. Create a local branch for your feature

   ```bash
   $ git checkout -b some-new-feature
   ```

2. Working on your features in that branch

   ```bash
   # make your changes
   $ git add .
   $ git status
   $ git commit -m"blah blah blah"
   
   # repeat above until the feature is done
   ```

3. Push the branch to your fork (origin)

   ```bash
   $ git push origin some-new-feature
   ```

4. When it is ready to be merged, send a pull request on Github

   Follow [Creating a Pull Request](https://help.github.com/articles/creating-a-pull-request) the send a pull request and ask someone to review and merge your branch.

   Please include _@reviewer_usename_ in the title to notify someone to review and merge it. For example, **@starsirius: Add this awesome feature**. Use _@anyone_ if it is a minor change.

5. After the branch is merged, pull the latest master into your fork, and delete your local branch

   ```bash
   $ git checkout master
   $ git pull upstream master
   $ git branch -d some-new-feature

   # delete your remote branch in your fork (origin)
   $ git push origin :some-new-feature
   ```
