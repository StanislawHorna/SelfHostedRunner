# SelfHostedRunner

Docker container to run [GitHub self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners).
GitHub Runner can be assigned to both entire GitHub organization or particular personal repository.
GitHub does not support assigning runner to the entire User Profile.

## How to use it
1. Build docker image:

        docker build -t gh-runner-image .

2. Run docker container:

        docker run \
            --detach \
            --env GITHUB_OBJECT=<YOUR-GITHUB-ORGANIZATION-OR-PERSONAL-REPOSITORY> \
            --env ACCESS_TOKEN=<YOUR-GITHUB-ACCESS-TOKEN> \
            --volume /var/run/docker.sock:/var/run/docker.sock \
            --name GH-runner \
            gh-runner-image

    - `GITHUB_OBJECT` - The name of the organization, or repository path in format: `OWNER/REPO` (example: `StanislawHornaGitHub/SelfHostedRunner`)
    - `ACCESS_TOKEN` - The github access token. This token must have the permissions to register self-hosted runner