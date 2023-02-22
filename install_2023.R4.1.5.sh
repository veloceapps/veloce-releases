#! /bin/bash
set -e
echo "Make sure sfdx is installed using NodeJS (uninstall if installed differently):"
echo "https://nodejs.org/en/download/current/"
echo "Install SFDX Globally"
echo "npm install --global sfdx-cli"
echo "Login into salesforce and note the alias"
echo "sfdx auth:web:login --setalias my-alias --instanceurl https://test.salesforce.com"
read -p "Press enter when ready" UNUSED
echo "Installing veloce-sfdx plugin"
echo y | sfdx plugins:install veloce-sfdx
echo "Installing veloce-sfdx plugin"
read -p "Please enter salesforce alias:" TARGET
if [ -z "$TARGET" ]
then
  echo "alias is empty"
  exit 255
fi
echo Installing packages
sfdx force:package:installed:list -u $TARGET | fgrep 14.5.0-88206b5d-04t6g000008nzZAAAY || sfdx force:package:install --noprompt -u $TARGET --package 14.5.0-88206b5d-04t6g000008nzZAAAY -w 15
sfdx force:user:permset:assign -u $TARGET --permsetname "VeloceCPQAdmin" || echo "Already assigned, ignoring"
sfdx force:user:permset:assign -u $TARGET --permsetname "VeloceCPQAdminReadonly" || echo "Already assigned, ignoring"
sfdx force:user:permset:assign -u $TARGET --permsetname "VeloceCPQRuntime" || echo "Already assigned, ignoring"
sfdx force:package:installed:list -u $TARGET | fgrep 14.4.0-88206b5d-04t6g000008nzZFAAY || sfdx force:package:install --noprompt -u $TARGET --package 14.4.0-88206b5d-04t6g000008nzZFAAY -w 15
sfdx force:package:installed:list -u $TARGET | fgrep 14.5.0-88206b5d-04t6g000008nzZKAAY || sfdx force:package:install --noprompt -u $TARGET --package 14.5.0-88206b5d-04t6g000008nzZKAAY -w 15
echo Installing data

cat << EOF > ./sfdx-project.json
{
  "packageDirectories": [
    {
      "path": "unused",
      "package": "custom-integration",
      "versionNumber": "0.0.0",
      "default": true
    }
  ],
  "namespace": "",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "51.0"
}
EOF

cat << EOF > ./VELOCPQ__Picklist__c.csv
Id,Name,VELOCPQ__Description__c,VELOCPQ__ListCode__c,VELOCPQ__ReferenceId__c
a0S0R000002m22IUAQ,Charge Types,This Picklist is used to keep Charge Types,CHARGE_TYPES,a0S0R000002m22IUAQ
a0S0R000002m22DUAQ,Unit Of Measure,This Picklist is used to keep Units Of Measure,UNIT_OF_MEASURE,a0S0R000002m22DUAQ
EOF

cat << EOF > ./VELOCPQ__PicklistValue__c.csv
Id,Name,VELOCPQ__DisplayValue__c,VELOCPQ__PicklistId__c,VELOCPQ__ReferenceId__c,VELOCPQ__ValueCode__c
a0R0R000002enCoUAI,PLV-000000000,Mile,a0S0R000002m22DUAQ,a0R0R000002enCoUAI,UOM_MILE
a0R0R000002enCtUAI,PLV-000000001,Pound,a0S0R000002m22DUAQ,a0R0R000002enCtUAI,UOM_POUND
a0R0R000002enCyUAI,PLV-000000002,License Subscriptions,a0S0R000002m22IUAQ,a0R0R000002enCyUAI,SUBSCRIPTION_CHARGE
a0R0R000002enD3UAI,PLV-000000003,Implementation Charge,a0S0R000002m22IUAQ,a0R0R000002enD3UAI,IMPLEMENTATION_CHARGE
a0R0R000002enD8UAI,PLV-000000004,Standard Charge,a0S0R000002m22IUAQ,a0R0R000002enD8UAI,STANDARD_CHARGE
a0R0R000002enDDUAY,PLV-000000005,Installation Charge,a0S0R000002m22IUAQ,a0R0R000002enDDUAY,INSTALLATION_CHARGE
EOF

cat << EOF > ./VELOCPQ__UITemplate__c.csv
CreatedDate,Id,Name,VELOCPQ__Description__c,VELOCPQ__TemplateType__c,VELOCPQ__ReferenceId__c
2022-01-24T07:39:27.000+0000,a130R000001hx8tQAA,Test_Template,Git-stored template,CONFIGURATION_UI,a130R000001hx8tQAA
2022-03-04T11:13:44.000+0000,a138D000000CryGQAS,Default,Default Configuration UI Template,CONFIGURATION_UI,a138D000000CryGQAS
EOF

cat << EOF > ./VELOCPQ__UIComponent__c.csv
CreatedDate,Id,Name,VELOCPQ__UITemplateId__c,VELOCPQ__ComponentType__c,VELOCPQ__Description__c,VELOCPQ__ReferenceId__c
2022-01-28T09:51:05.000+0000,a120R000003KAmOQAW,Dropdown,a130R000001hx8tQAA,GENERAL,,a120R000003KAmOQAW
2022-03-04T11:17:58.000+0000,a128D0000008p52QAA,AttributesSidebar,a138D000000CryGQAS,GENERAL,,a128D0000008p52QAA
2022-03-04T11:22:25.000+0000,a128D0000008p5CQAQ,BasicAttribute,a138D000000CryGQAS,ATTRIBUTE,,a128D0000008p5CQAQ
2022-03-04T11:19:58.000+0000,a128D0000008p57QAA,PortsSidebar,a138D000000CryGQAS,GENERAL,,a128D0000008p57QAA
2022-03-04T11:28:58.000+0000,a128D0000008p5MQAQ,RootType,a138D000000CryGQAS,TYPE,,a128D0000008p5MQAQ
2022-03-04T11:15:43.000+0000,a128D0000008p4xQAA,PortsViewer,a138D000000CryGQAS,GENERAL,,a128D0000008p4xQAA
2022-03-04T11:27:49.000+0000,a128D0000008p5HQAQ,TablePort,a138D000000CryGQAS,PORT,,a128D0000008p5HQAQ
EOF

cat << EOF > ./VELOCPQ__UIComponentStory__c.csv
CreatedDate,Id,Name,VELOCPQ__UIComponentId__c,VELOCPQ__Description__c,VELOCPQ__ReferenceId__c
2022-02-02T20:43:42.000+0000,a110U000001EGkMQAW,Blue,a120R000003KAmOQAW,,a110U000001EGkMQAW
2022-02-02T20:43:42.000+0000,a110U000001EGkHQAW,Default,a120R000003KAmOQAW,,a110U000001EGkHQAW
2022-02-02T20:43:42.000+0000,a110U000001EGkRQAW,Disabled,a120R000003KAmOQAW,,a110U000001EGkRQAW
EOF

sfdx veloce:apexload  --upsert -u $TARGET -s VELOCPQ__Picklist__c -i VELOCPQ__ReferenceId__c -o OwnerId,LastReferencedDate,LastViewedDate,SystemModstamp,LastModifiedById,CreatedById,CreatedDate,LastModifiedDate --idmap=${TARGET}-idmap.json -f ./VELOCPQ__Picklist__c.csv
sfdx veloce:apexload  --upsert -u $TARGET -s VELOCPQ__PicklistValue__c -i VELOCPQ__ReferenceId__c -o Name,OwnerId,LastReferencedDate,LastViewedDate,SystemModstamp,LastModifiedById,CreatedById,CreatedDate,LastModifiedDate --idmap=${TARGET}-idmap.json -f ./VELOCPQ__PicklistValue__c.csv
sfdx veloce:load -b 20 --strict --upsert -u $TARGET -s VELOCPQ__UITemplate__c -i VELOCPQ__ReferenceId__c -o OwnerId,LastReferencedDate,LastViewedDate,SystemModstamp,LastModifiedById,CreatedById,CreatedDate,LastModifiedDate --idmap=${TARGET}-idmap.json -f ./VELOCPQ__UITemplate__c.csv
sfdx veloce:load -b 20 --strict --upsert -u $TARGET -s VELOCPQ__UIComponent__c -i VELOCPQ__ReferenceId__c -o OwnerId,LastReferencedDate,LastViewedDate,SystemModstamp,LastModifiedById,CreatedById,CreatedDate,LastModifiedDate --idmap=${TARGET}-idmap.json -f ./VELOCPQ__UIComponent__c.csv
sfdx veloce:load -b 20 --strict --upsert -u $TARGET -s VELOCPQ__UIComponentStory__c -i VELOCPQ__ReferenceId__c -o OwnerId,LastReferencedDate,LastViewedDate,SystemModstamp,LastModifiedById,CreatedById,CreatedDate,LastModifiedDate --idmap=${TARGET}-idmap.json -f ./VELOCPQ__UIComponentStory__c.csv
echo Installation Successful!
