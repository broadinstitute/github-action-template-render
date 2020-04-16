# github-action-template-render

This action will render Consul template formatted files that are written in version 0.13.X or earlier format.

To use this action:
* First acquire a vault token if template files are written to read values from vault
* Set the following env variables in your step.  Also if your template files require any other environment variables in order to render properly (ie ENV) add them to the env section.
  * VAULT_TOKEN (if the template files read from vault)
  * DEST_PATH the path to the files to render.  This path needs to be a path that exists inside the docker container used by this runner.  NOTE: /github/workspace is automatically mounted in the counter.

Ex:

    - name: render
      uses: broadinstitute/github-action-template-render@master
      env:
        VAULT_TOKEN: ${{ env.VAULT_TOKEN }}
        DEST_PATH: /github/workspace/<path-in-git-repo>/<from-checkout-step>

Future work:
* base docker image has newer consul template software installed.  Add flag to allow to select the newer version
* base docker image has gomplate template support.  Add flag to allow selecting that for rendering
* Add reference to the base image repo and possibly add base image Dockerfile so it is clear
* Fold in base image building into this repo with a new action that manages the build and release of the base image seperate from action Dockerfile.

NOTE:
I use a base image that is built outside of this action primarily to make the action quicker. I did not want to have to go through the entire process of downloading all the software for every run.
