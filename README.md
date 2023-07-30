# InfraAsCodeAzure
#Terraform code for simple application in Azure

Building an internal portal for the company abc.Company has decide to use completely MICROSOFT AZURE platform to host this application and use the AZURE PaaS service no IaaS. Frontend appliaction will be hosted in one app service and web api will be hosted in another app service. Both the App service will be under one app service plan. APp service will be auto scale based on the Cpu utilization. When CPU utlization goes abhove 75 % it will add the Vm instance and when cpu utilization come below 75% it will remove the Vm instance. In the backend AZure sql database and Azure blob storage will be used. All the sensitive data like database connection strinng, storage access key etc will be kept in the key vault. All the pass service will only be accessed using service end point from the azure vnet. All the outbound communication from the frontend app service will traverse through the azure vnet in reaching the api server.The api server i.e backend app service will be only accessible from the private network i.e Vnet. App service will communicate to the key vault using managed identity for getting the secret from the key vault. Network rule will be applied on the storage account and sql database to make it only private accessible. All the infra structure will be created in IAC using terraform. All the logs and application telemetery data will be send to azure application insights for monitoring.
Following azure resources are required to set up the entire infrastructure as per the architecture.

1. App service Plan
2. App service
3. Key vault
4. Storage account
5. Azure sql database
6. Vnet/Subnet #one subnet for vnet integration in the frontend and another subnet for the servcie end point.
7. Nsg 
8. Application insight.

Steps of execution.
1. run the ps script tf_Powershell.ps1 under the folder Psfile
2. terraformexecution.ps1 

# Architecture Digram

![image](https://github.com/kumar-rakesh23/IAAC-Azure/assets/33743858/9d9c4f62-57fd-46f8-a623-ee5404f96a27)

