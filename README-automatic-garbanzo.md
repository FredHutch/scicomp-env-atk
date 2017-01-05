Release: 

# Installing the Garbanzo

## Add the Garbanzo to your Cookbook:

1. Download a .tgz release from the github release page
1. Extract into the top level of your cookbook with this command:

    tar -x --strip-components=1 -f automatic-garbanzo-<version>.tgz

This will extract the Jenkinsfile and Rakefile from the release.  Add it
to any (existing) branches you want built automatically.

## Configure Jenkins

Log into Jenkins and create a multibranch pipeline project.  Configure the
_branch source_ for the project to be your repository.  Add credentials as
necessary.

## Configure GitHub Webhooks

To have Jenkins build your cookbook when you push on a branch, its necessary to
configure Webhooks to notify Jenkins.  In the automatic-garbanzo toolkit (in
`.automatic-garbanzo/tools` subdirectory) there is a script which will add the
necessary configuration to your repository.

1. set the environment variable `USER` to your GitHub username
2. (optional) set the environment variable `PW` to the password for that
   account
3. `cd` into the tools directory and run the script `configure.sh
   \<organization\> \<repository\>`.

The configure script will configure a webhook sending all events to the Jenkins
server as well as adding a key to allow the build automation user (btb) to pull
and push to your cookbook repository.

# Notes

## The Rakefile

It is possible for you to use the Rakefile directly for building cookbooks, but I do not suggest that at this time- primarily because you may not have access to upload to the supermarket if the build automation is handling that.

However, one of the `rake` targets I do recommend you use: the `test` target
which runs foodcritic and rubocop.  These will show any problems with your code
before you upload to github, preventing needless build failures on Jenkins


