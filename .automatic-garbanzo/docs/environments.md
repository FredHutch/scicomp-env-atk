# Automation of Chef Environments

## Workflow

Environments are empty cookbooks with a `metadata.rb` file defining which
cookbooks are managed by the environment.  Environment cookbooks are notable as
the `Berksfile.lock` is checked into the environment cookbook repository.

Management of an environment is done by the Jenkins server on `whidby`.  A
multibranch pipeline is configured with the environment cookbook repository as
its branch source and webhooks on the environment cookbook repository set up to
send[1] events to the Jenkins server.  With this configuration, any branch
pushed to GitHub will be built by Jenkins.

An environment cookbook can have any number of branches for development work
but _must_ have a branch named `prod`. The logic of the build system checks the
branch name being built and uploads an environment to the Chef server based on
the cookbook name as defined in `metadata.rb`.  If the branch being pushed is
`prod`, the environment name is defined as the cookbook name.  Any other branch
name will be appended to the cookbook name and uploaded to the Chef server.
For example, if `metadata.rb` defines:

    name 'whizbang-app'

When the `prod` branch is pushed to GitHub, Jenkins will update an environment
named `whizbang-app`.  However, if the branch is something other than `prod`
then the branch name is appended to the environment name- for example, a branch
`dev` in the environment cookbook would have its information uploaded to an
environment named `whizbang-app-dev`.

Deleting a branch will delete the environment from the server

    git branch -d dev
    git push origin :dev

In practical steps, to develop a new feature ("featureX") using an environment cookbook:

 1. Create a branch called "featureX" and push to github `git push -u origin
    featureX`.  This will create the environment `whizbang-app-featureX`.
 2. Make changes to the environment and push.  Jenkins will update the
    environment using `berks` and `knife`.
 3. Check that changes have the desired effect.  Repeat 2-3 as necessary.
 4. When complete merge the `featureX` branch into `prod` and push. This will
    update the production environment (`whizbang-app`) with changes from
    `featureX` ## Defining The Environment 

## Environment Attributes

Environments have a number of other attributes.  These are taken from the
environment cookbook:

### Name and Description

These environment attributes are taken from the metadata file (note that `name` will be hashed with the branch name as described above).  The environmen description is taken verbatim from the `description` attribute in the metadata file.

### Attributes

Ruby (extension `.rb`) and JSON (`.json`) files in the `atttributes`
subdirectory of the environment cookbook will be processed and uploaded when
the environment is updated.

# Notes on Internals

## Updating the Environment

The stock `berks apply` simply uploads the contents of the `Berksfile.lock` as
elements in the `cookbook_versions` hash.  Adding other environment attributes
requires that we create a JSON file and upload it using `knife environment from
file`

When its time to update the environment, the garbanzo will:

  - generate the environment name
  - use `berks apply <environment name> --envfile=<tmpfile>`
  - parse `<tmpfile>` and update JSON with attributes, description, and name
  - write out updated `<tmpfile>` JSON
  - use `knife environment from file `<tmpfile>` to upload the updated
    environment

## Checking for Environment Cookbook

For a cookbook to be considered an "environment cookbook," it must have its `Berksfile.lock` checked into source control.  This command is used:

    git ls-files Berksfile.lock --error-unmatch

`--error-unmatch` is required to raise an error if the file is not found in
source control.


[1] Required events are `push` and `delete`
