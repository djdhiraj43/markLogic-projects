==== Requirement for harmonization of the data =========
Expected Template for Harmonization :

1. EmployeeID  - change the filed name as 'clientID' and add "ABN" with each ID
2. EmployeeName - EmployeeFirstName
3. ManagerName - supervisername
4. DOB- change the date format
5. if 
                Accout = ABN , change it to ABN AMRO
   if 
                Account = citi , change it to Citi Bank.


========================= changes in dmf tasks ================
add the flowName;harmonizeFlowName in all the dmf related task

1.dmfGenerateInputSDM
2.dmfGenerateHarmonizeSDM
3.dmfGenerateTemplate
4.dmfGenerateSchematron

===== steps to have xsd validation for harmonize document =====

1. add the entityName in dmfGenerateXSD
2. run gradle dmfGenerateXSD
		- X_TestEntity.xsd will get generated 
3. src/main/ml-schemas/xsd/core/group-extension.xsd
	make an entry in the group-extension.xsd	
		- <xs:include schemaLocation="/xsd/core/X_TestEntity.xsd" />
4. gradle mlLoadSchemas - to load the new schemas in the database

 
===============  steps to have dmf artifacts ================
  
-----run the gradle storeLoadMapping
which will call everything in the flow it should be run

  'dmfDeployEntities',
  'dmfGenerateCollectorTDE',
  'dmfGenerateCollectorSQL',
  'dmfGenerateCollectorCTS',
  'dmfGenerateSchematron',
  'dmfGenerateTemplate',
  'dmfGenerateInputSDM',
  'dmfGenerateHarmonizeSDM',
  'dmfDeployEntities',
  'dmfCompileRules'

============== and special req if you want to handle via creating a function =====
****** create a function in /ext/data-hub-lib/common-lib.xqy

(: Function to change the format of the date:)
declare function common:date-format-change($date){
  fn:format-dateTime(xdmp:parse-yymmdd('MM/dd/yyyy', $date), '[D01]-[MNn]-[Y0001]')
};


=================== Run Harmonize flow ================
gradle hubRunFlow -PentityName="TestEntityNew" -PflowName="TestEntityNewHarmonize" -PflowType="harmonize" -Pthrea
dCount=1 -PbatchSize=1 -PsourceDB=credits-dh-FINAL -PdestDB=credits-dh-FINAL -Pdhf.sourc
e="XYZ" -PmlUsername=admin -PmlPassword=admin -PmlRestAdminUsername=credits-dh-ingester
-PmlRestAdminPassword=1ng3st3r
