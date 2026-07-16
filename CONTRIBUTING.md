# Contributing to docker-node

Thank you for your contribution. Here are a set of guidelines for contributing to the docker-node project.

## Governance and decision making

Project governance uses consensus seeking. See [GOVERNANCE.md](./GOVERNANCE.md) for
roles and the decision process.

For governance-sensitive or potentially contentious changes, open a PR (or issue)
with rationale and allow time for async feedback.

If a final decision cannot be reached via consensus seeking, escalation goes to
the Node.js TSC as final arbiter.

## Discussion Areas

<!-- markdown-link-check-disable -->
You can use Node.js channels (prefixed by `#nodejs-`) in the [OpenJSF Slack](https://slack-invite.openjsf.org/) workspace for discussions.
<!-- markdown-link-check-enable -->

- [#nodejs-distributions](https://openjs-foundation.slack.com/archives/C0ALS3UDE8G) covers discussions for this repo (`docker-node`).

- [#nodejs-release](https://openjs-foundation.slack.com/archives/C019MGJQ8RH) is linked to the [Node.js Release Working Group](https://github.com/nodejs/release#readme) responsible for the upstream releases of Node.js used by this repo.

## Version Updates

New **Node.js** releases are released as soon as possible.

New **npm** releases are not tracked. We simply use the npm version bundled in the corresponding Node.js release.

**[Yarn v1 Classic](https://classic.yarnpkg.com/)** is no longer maintained upstream, and it is removed when constructing Dockerfiles
from templates starting with the Node 26 images.

**[Alpine Linux](https://alpinelinux.org/releases/)** latest two releases are used.
When Alpine Linux makes a new branch available, which is planned for May and November each year,
this branch is adopted as a new base image and it becomes the default
for each supported Node.js release line.
The lowest previously used Alpine Linux release is dropped for future image builds,
so that only the two latest releases are maintained.

### Image Creation Automation

1. Every 15 minutes, the [automatic-updates](https://github.com/nodejs/docker-node/blob/main/.github/workflows/automatic-updates.yml) workflow
   checks for new versions of Node.js published to https://nodejs.org/download/release and which are referenced in the release site's
   [index.json](https://nodejs.org/download/release/index.json) file using
   [build-automation.mjs](https://github.com/nodejs/docker-node/blob/main/build-automation.mjs).
  - If any new versions is found, it also checks for matching `linux-x64-musl` builds on
    https://unofficial-builds.nodejs.org/download/release using the
    [index.json](https://unofficial-builds.nodejs.org/download/release/index.json) file of that site.
  - If new versions are found, the
    [update.sh](https://github.com/nodejs/docker-node/blob/main/update.sh) script runs, which updates individual
    `Dockerfile` instances for each Node.js version / architecture combination.
  - The [automatic-updates](https://github.com/nodejs/docker-node/blob/main/.github/workflows/automatic-updates.yml) workflow continues
    by opening a pull request under the user
    [nodejs-github-bot](https://github.com/nodejs-github-bot) in a branch named `update-branch`.
1. The resulting PR with title `feat: Node.js <list of versions>` is reviewed by repo team members, approved and merged.
1. The workflow [official-pr](https://github.com/nodejs/docker-node/blob/main/.github/workflows/official-pr.yml) then detects the merger of the above pull request,
   pushes a commit to
   [nodejs/official-images](https://github.com/nodejs/official-images) and opens a pull request in the parent repo
   [docker-library/official-images](https://github.com/docker-library/official-images).
1. The official images are built and published according to the
   [`docker library` process](https://github.com/docker-library/faq#an-images-source-changed-in-git-now-what), resulting in the new images being available on
   [Docker Hub](https://hub.docker.com/_/node).

### Image Creation Manually

Image updates for existing Node.js release lines are created automatically as described above.
If there is a problem with the automated process, it may be necessary to create an update PR manually.
If you believe there is a need for a manual PR, and you are not a member of the
[Docker Maintainers](./README.md#docker-maintainers) or
[Collaborators](./README.md#collaborators) team of this repo,
please first open an issue to describe the update problem
and your suggestion to resolve it.

To set up a version update PR, follow these instructions:

1. [Fork this project.](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
1. [Clone the forked repository.](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
1. Create a branch for the update PR. For example, `git checkout main; git checkout -b version-update`.
1. Run `./update.sh`. You can see additional options by using the built-in help documentation with `./update.sh -h`. This script will automatically update the appropriate files with the latest versions and checksums.
1. Commit the modified files to the `version-update` branch and push the branch to your fork.
1. [Create a PR to merge the branch from your fork into this project's default branch.](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork).

From this point, team members review, approve and merge the PR.
The merged files are detected by the workflow [official-pr](https://github.com/nodejs/docker-node/blob/main/.github/workflows/official-pr.yml)
and the process continues, similar to the related steps described above in
[Image Creation Automation](#image-creation-automation).

When a new Node.js release line is expected, additional preparation is necessary, including updates to the
[versions.json](./versions.json) file and creation of a major version directory, populated with generated files.
This task is undertaken by members of the repo team above.

## Adding dependencies to the base images

NodeJS is a big ecosystem with a variety of different use cases. The docker images for node are designed to provide the minimum for running core node.  Additional dependencies (including dependencies for npm or yarn such as git) will not be included in these base images and will need to be included in descendent image.
