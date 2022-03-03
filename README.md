# Contents
- buildspec.yml
- Dockerfile
- terraform (folder)


### buildspec.yml
This contains a standard build specification file. 
When this is run the CodeBuild is triggered which will build the code in the repository. 

*Line 11: REPOSITORY_URI=513836189211.dkr.ecr.us-east-1.amazonaws.com/angular-app is referencing an ecr cluster. 
This ideally will be changed to another created ECR cluster URI for this to work.*

`Running the teerraform CODE will create and Output an ECR  URL which can be updated here.`

### Dockerfile
When the code build is run, the docker file will build a docker image - Starting an nginx server for the application. 

### terrafrom folder
This contains infrastructure as code, separated into different files for readability. 

This will Provision the ECS Cluster Managed by AWS Fargate. I also provisions, the target groups, ALB's and Task definitions for the cluster. Along with associated securtiy groups.

The ECR Repository is also created and the URL will be output once the code is run. ECR repository is Encrupted using AWS KMS.

This also creates a CodeBuild Pipeline directed at this github account. `This can be changed by changing the personal access token and github repo in the tfvars file`. 

# Running the project
**Assumption: AWS CLI is configured**

- clone repository
- cd to terraform folder and run `terraform init` command to initialise and download required providers.
- Run `terraform plan` to see execution plan
- Run `terraform apply` to apply changes required and provision the infrastrucsture
- Enter 'yes' to confirm when prompted. Run `terraform apply --auto-approve` to skip this step
- The ECR URL will be output which can then be updated in the buildspec.yml file
- Run `terraform destroy` to destroy the terrafrorm managed infrastructure

The infrastructure will now be created and will be ready for code to be updated to production for continuous deployment once pushed to github *if all tests are passed*

The CodeBuild can be run manually to trigger the build.


<br />

