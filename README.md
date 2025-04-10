# BSS Infrastructure

This repository exists to hold the infrastructure config for the BSS project.

## Table of Contents

- [BSS Infrastructure](#bss-infrastructure)
  - [Table of Contents](#table-of-contents)
  - [Setup](#setup)
    - [Prerequisites](#prerequisites)
    - [Configuration](#configuration)
  - [Usage](#usage)
    - [Testing](#testing)
  - [Contributing](#contributing)
  - [Contacts](#contacts)
  - [Licence](#licence)

## Setup

To use this repository first you will need to clone it down to your local machine, you should use the `ssh` option for this if you wish to contribute back to the project.

Once you have downloaded this repository you will need to run the Python script to generate the s3 bucket which is required to hold the Terraform state and lock files.

I would suggest first creating a virtual environment to isolate the Python dependancies from your wider system, this can be achieved with the following command:

```bash
python -m venv venv
```

That command will take a few seconds to create a virtual environment in a directory called `venv` you can then assume that virtual environment with the following command on mac or linux, the command may work on windows too, but if not a quick google search should show the correct command to assume the venv:

```bash
source venv/bin/activate
```

now that you have assumed the virtual environment you can install the dependancies with the following command:

```bash
pip install -f requirements.txt
```

that will take a few mins while it installs boto3 and its dependancies which is the most common Python library to interact with AWS. Once it has finished you will need to set the credentials that you will use to authorise chances to your AWS account.

To do that go to your aws login screen in a browser. you should see a list of the accounts you have access to. There are two buttons under the account name, one should be your role that you click on to access the web GUI, the other should say `Access Keys` when you click on that a popup will appear with credential commands. select the tab that matches your OS and then copy and paste the `export` or `SET` commands into the browser (depending if using windows or mac/linux)

with those credentials set you can now use the script to create the initial s3 setup required by Terraform:

```bash
python scripts/aws-initial-setup.py
```

that will build you the s3 bucket you need and setup the initial file structure. If you get an error about authentication then your token has probably expired and you need to copy over the export commands from the aws console into your terminal and re-try, you may need to refresh the browser for a new key.

### Prerequisites

The following software packages, or their equivalents, are expected to be installed and configured:

- [GNU make](https://www.gnu.org/software/make/) 3.82 or later,
- [Python](https://www.python.org/) for initial setup script,

### Configuration

For initial Terraform use you will need to cd to the stack you intend to use and run `terraform init` that will download the depenancies and setup everything you need to run Terraform from your local machine.

## Usage

To run Terraform you will need to ensure you are targeting the correct aws account, any manual deployments should only go into the CICD environment, any higher environments will be managed by pipelines.

cd into the stack you want to configure, for example eks would be:

```bash
cd infrastructure/stacks/eks
```

Then you would select the appropriate workspace, this will be your Short Code. If your Short Code was ABCD1 then you would select this with:

```bash
terraform workspace select ABCD1
```

> Note \
> If you have not yet got a workspace you can create one with:

```bash
terraform workspace new ABCD1
```

then to run a plan you would run:

```bash
terraform plan -var-file='../../environments/01-DEV/main.tfvars'
```

that will show the changes that your local files will make to the environment.

### Testing

There are `make` tasks for you to configure to run your tests. Run `make test` to see how they work. You should be able to use the same entry points for local development as in your CI pipeline.

## Contributing

If you find any problems or would like to request a new feature please raise an [issue](https://github.com/NHSDigital/screening-terraform-bss/issues)

## Contacts

Maintainers are:\
[Andrew Cleveland](https://github.com/andrew-cleveland)

## Licence

> The [LICENCE.md](./LICENCE.md) file will need to be updated with the correct year and owner

Unless stated otherwise, the codebase is released under the MIT License. This covers both the codebase and any sample code in the documentation.

Any HTML or Markdown documentation is [© Crown Copyright](https://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/uk-government-licensing-framework/crown-copyright/) and available under the terms of the [Open Government Licence v3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/).
