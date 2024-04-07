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
        String recordId
    ) {
        try {
            SelfAssessmentService serv = new SelfAssessmentService(recordId);
            return serv.selfAssessment;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /***************************************************
     * Save survey response and child survey answers
     * @param sObject[] records - Collection of answer objects to save
     * @return Id - Survey response id
     ***************************************************/

    @AuraEnabled(cacheable=false)
    public static String submitSelfAssessment(
        String selfAssessmentId, 
        String jsonAnswerString
    ) {
        try {
            List<SelfAssessment.Answer> lstAnswers = (List<SelfAssessment.Answer>) JSON.deserialize(
                jsonAnswerString, 
                List<SelfAssessment.Answer>.class
            );
            SelfAssessmentService serv = new SelfAssessmentService(selfAssessmentId);
            serv.saveAnswers(lstAnswers);
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}