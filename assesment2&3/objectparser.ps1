function Get-ValuefromJsonObj{
     [cmdletBinding()]
     param(
         [Parameter(Mandatory=$true)]
         $Jsondata,
         [Parameter(Mandatory=$true)]
         [string] $key
     
     )
    try 
    {
        $data= $Jsondata  | ConvertFrom-Json 
        $validJson = $true     
    }
    catch 
    {
        $validJson = $false;
    }
    if($validJson)
    {
        $data=$Jsondata  | ConvertFrom-Json
        $array_key=$key.trim('/') -split '/'     
        if($array_key.length -ne 0)
        {
            $array_key | ForEach-Object {
                $key= $_
                $data= $data.$($_)
            }
            return $data
        }   
     }
     else 
     {
        Write-Host "Provided input is not a valid json object."
        return $null
     }
}

$JSON = @'
    {
        "Rule": [{
            "MPName": "ManagementPackProject",
            "Request": "Apply",
            "Category": "Rule",
            "RuleId": {
                "1300": "false",
                "1304": "true"
            },
            "test":[      
            {
                "Abcd": "cdf",
                "abgd": "hjg"
            },
            {
                "gvgcgfhh": "fagfgfgf",
                "ggfgf": "true"
            }
           ]
        }]
    }
'@


#test case1 passing key rule/ruleid
$result=Get-ValuefromJsonObj $JSON 'Rule/RuleID'
Write-Output ($result | ConvertTo-Json)

#test case2 passing key rule/category
$result=Get-ValuefromJsonObj $JSON 'Rule/Category'
Write-Output ($result | ConvertTo-Json)

#test case3 passing key 'rule/abcd'
$result=Get-ValuefromJsonObj $JSON 'Rule/test'
Write-Output ($result | ConvertTo-Json)

#test case 4 passing key 'rule1'
$result=Get-ValuefromJsonObj $JSON 'Rule1'
Write-Output ($result | ConvertTo-Json) 

$metadata=@'
{
    "compute": {
        "azEnvironment": "AZUREPUBLICCLOUD",
        "extendedLocation": {
            "type": "edgeZone",
            "name": "microsoftlosangeles"
        },
        "evictionPolicy": "",
        "isHostCompatibilityLayerVm": "true",
        "licenseType":  "Windows_Client",
        "location": "westus",
        "name": "examplevmname",
        "offer": "WindowsServer",
        "osProfile": {
            "adminUsername": "admin",
            "computerName": "examplevmname",
            "disablePasswordAuthentication": "true"
        },
        "osType": "Windows",
        "placementGroupId": "f67c14ab-e92c-408c-ae2d-da15866ec79a",
        "plan": {
            "name": "planName",
            "product": "planProduct",
            "publisher": "planPublisher"
        },
        "platformFaultDomain": "36",
        "platformSubFaultDomain": "",        
        "platformUpdateDomain": "42",
        "priority": "Regular",
        "publicKeys": [{
                "keyData": "ssh-rsa 0",
                "path": "/home/user/.ssh/authorized_keys0"
            },
            {
                "keyData": "ssh-rsa 1",
                "path": "/home/user/.ssh/authorized_keys1"
            }
        ],
        "publisher": "RDFE-Test-Microsoft-Windows-Server-Group",
        "resourceGroupName": "macikgo-test-may-23",
        "resourceId": "/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/macikgo-test-may-23/providers/Microsoft.Compute/virtualMachines/examplevmname",
        "securityProfile": {
            "secureBootEnabled": "true",
            "virtualTpmEnabled": "false"
        },
        "sku": "2019-Datacenter",
        "storageProfile": {
            "dataDisks": [{
                "bytesPerSecondThrottle": "979202048",
                "caching": "None",
                "createOption": "Empty",
                "diskCapacityBytes": "274877906944",
                "diskSizeGB": "1024",
                "image": {
                  "uri": ""
                },
                "isSharedDisk": "false",
                "isUltraDisk": "true",
                "lun": "0",
                "managedDisk": {
                  "id": "/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/macikgo-test-may-23/providers/Microsoft.Compute/disks/exampledatadiskname",
                  "storageAccountType": "StandardSSD_LRS"
                },
                "name": "exampledatadiskname",
                "opsPerSecondThrottle": "65280",
                "vhd": {
                  "uri": ""
                },
                "writeAcceleratorEnabled": "false"
            }],
            "imageReference": {
                "id": "",
                "offer": "WindowsServer",
                "publisher": "MicrosoftWindowsServer",
                "sku": "2019-Datacenter",
                "version": "latest"
            },
            "osDisk": {
                "caching": "ReadWrite",
                "createOption": "FromImage",
                "diskSizeGB": "30",
                "diffDiskSettings": {
                    "option": "Local"
                },
                "encryptionSettings": {
                    "enabled": "false"
                },
                "image": {
                    "uri": ""
                },
                "managedDisk": {
                    "id": "/subscriptions/xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx/resourceGroups/macikgo-test-may-23/providers/Microsoft.Compute/disks/exampleosdiskname",
                    "storageAccountType": "StandardSSD_LRS"
                },
                "name": "exampleosdiskname",
                "osType": "Windows",
                "vhd": {
                    "uri": ""
                },
                "writeAcceleratorEnabled": "false"
            },
            "resourceDisk": {
                "size": "4096"
            }
        },
        "subscriptionId": "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx",
        "tags": "baz:bash;foo:bar",
        "userData": "Zm9vYmFy",
        "version": "15.05.22",
        "virtualMachineScaleSet": {
            "id": "/subscriptions/xxxxxxxx-xxxxx-xxx-xxx-xxxx/resourceGroups/resource-group-name/providers/Microsoft.Compute/virtualMachineScaleSets/virtual-machine-scale-set-name"
        },
        "vmId": "02aab8a4-74ef-476e-8182-f6d2ba4166a6",
        "vmScaleSetName": "crpteste9vflji9",
        "vmSize": "Standard_A3",
        "zone": ""
    },
    "network": {
        "interface": [{
            "ipv4": {
               "ipAddress": [{
                    "privateIpAddress": "10.144.133.132",
                    "publicIpAddress": ""
                }],
                "subnet": [{
                    "address": "10.144.133.128",
                    "prefix": "26"
                }]
            },
            "ipv6": {
                "ipAddress": [
                 ]
            },
            "macAddress": "0011AAFFBB22"
        }]
    }
}
'@

$result=Get-ValuefromJsonObj $metadata 'compute/location'
Write-Output ($result | ConvertTo-Json)

#test case2 passing key rule/category
$result=Get-ValuefromJsonObj $metadata 'compute/storageProfile/osDisk/encryptionSettings'
Write-Output ($result | ConvertTo-Json)