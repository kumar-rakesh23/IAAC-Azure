<# Replace the param $RESOURCE_GROUP_NAME and STORAGE_ACCOUNT_NAME  with your own value.#>
[CmdletBinding()]
param(
       [string] $RESOURCE_GROUP_NAME="TerraformRg"
       [string] $STORAGE_ACCOUNT_NAME="tfstate1726232610"
)

<#
 Fetch the storage access key assigned it to the environment variable.This key is used to access the tf state file from the azure blob.
#>
$ACCOUNT_KEY=(Get-AzStorageAccountKey -ResourceGroupName $RESOURCE_GROUP_NAME -Name $STORAGE_ACCOUNT_NAME)[0].value
$env:ARM_ACCESS_KEY=$ACCOUNT_KEY

if(-not (Get-Command -Name terraform -CommandType Application -ErrorAction SilentlyContinue))
{
   throw "terraform tool is not available in the system."
}
<#
 Run terraform init to initialise the terraform directory. It looks through all the .tf file and automatically 
 download the provider required for them.

#>

terraform init

<#
  Run terraform validate to validate the terrafrom configuration file.
#>

terraform validate

<#
  run terraform plan to produce plan for changing resources to match the current configuration.
#>

terraform plan

<# 
 Run terraform aply to aply the changes described by plan.
#>
 terraform apply -auto-approve

 <#
 Run terraform destroy to delete the entire infrastructure set.
 #>
 #terraform destroy
