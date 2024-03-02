/*********************************************
 * Controller for self-assessments in lwc
 * @date 2024
 *********************************************/
public with sharing class SelfAssessmentController {

    /***************************************************
     * Get self-assessment
     * @param String Record id of the self assessment
     * @return SelfAssessment with child Answer objects
     ***************************************************/
    @AuraEnabled(cacheable=true)
    public static SelfAssessment getSelfAssessment(
        Id recordId
    ) {
        try {
            SelfAssessmentService serv = new SelfAssessmentService(recordId);
            return serv.selfAssessment;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    /************************************************************************
     * Save survey response and child survey answers
     * @param sObject[] records - Collection of answer objects to save
     * @return Id - Survey response id
     ************************************************************************/

    /*
    @AuraEnabled(cacheable=false)
    public static Id submitSurvey(
        String recordId, 
        String contactId, 
        List<sObject> answers
     ) {
        try {
            Survey_Response__c sr = new Survey_Response__c();
            sr.Survey__c = recordId;
            sr.Contact__c = contactId;
            Database.insert(
                sr, 
                false, 
                AccessLevel.USER_MODE
            );

            // Cast generic sObject to list of application answers
            List<Survey_Answer__c> lstAnswers = (List<Survey_Answer__c>) answers;
            for (Survey_Answer__c ans : lstAnswers) {
                ans.Survey_Response__c = sr.Id;
                // Convert lightning data type back to valid picklist value
                ans.Data_Type__c = DataTypesUtil.getDataTypeFromLightningInputType(ans.Data_Type__c);
            }

            // Update application answers
            Database.insert(
                lstAnswers,
                false,
                AccessLevel.USER_MODE
            );
            return sr.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    */

}