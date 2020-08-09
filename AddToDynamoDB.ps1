# PowerShell script file to be executed as a AWS Lambda function.
#
# When executing in Lambda the following variables will be predefined.
#   $LambdaInput - A PSObject that contains the Lambda function input data.
#   $LambdaContext - An Amazon.Lambda.Core.ILambdaContext object that contains information about the currently running Lambda environment.
#
# The last item in the PowerShell pipeline will be returned as the result of the Lambda function.
#
# To include PowerShell modules with your Lambda function, like the AWS.Tools.S3 module, add a "#Requires" statement
# indicating the module and version. If using an AWS.Tools.* module the AWS.Tools.Common module is also required.
#
# This example demonstrates how to process an SQS Queue:
# SQS Queue -> Lambda Function

# To send messages

# 1..5 | % {Send-SQSMessage -QueueUrl https://sqs.ap-southeast-2.amazonaws.com/998516739712/let
#     scode.fifo -MessageBody (@{Id = $_; Name = "Product$_" ; Price = (Get-Random -Minimum 10 -Maximum 1000)} | ConvertTo-Json) -MessageDeduplicationId 
#     (New-Guid).Guid -MessageGroupId (New-Guid).Guid ; Start-Sleep -Seconds 1 }

Import-Module AWS.Tools.DynamoDBv2
#Requires -Modules @{ModuleName='AWS.Tools.Common';ModuleVersion='4.0.6.0'}
#Requires -Modules @{ModuleName='AWS.Tools.DynamoDBv2';ModuleVersion='4.0.6.0'}

# Uncomment to send the input event to CloudWatch Logs
# Write-Host (ConvertTo-Json -InputObject $LambdaInput -Compress -Depth 5)
$region = [Amazon.RegionEndpoint]::APSoutheast2



$client = New-Object -TypeName Amazon.DynamoDBv2.AmazonDynamoDBClient -ArgumentList $region

$table = [Amazon.DynamoDBv2.DocumentModel.Table]::LoadTable($client, "Products")


foreach ($message in $LambdaInput.Records) {
    # TODO: Add logic to handle each SQS Message
    $document = [Amazon.DynamoDBv2.DocumentModel.Document]::FromJson($message.body)
    $table.PutItemAsync($document)
   
}

