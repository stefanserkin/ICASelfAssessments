// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

Self_Assessment__c sa = [SELECT Id FROM Self_Assessment__c LIMIT 1];
System.debug('::::::: sa id --> ' + sa.Id);

List<SelfAssessmentService.Answer> lstAnswers;
lstAnswers = SelfAssessmentController.getAnswers(sa.Id);
System.debug('::::::: answers --> ' + lstAnswers);