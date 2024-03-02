/*********************************************
 * Service class for self-assessments
 * @date 2024
 *********************************************/
public with sharing class SelfAssessmentService {

    public Id selfAssessmentId {get; private set;}
    public List<Answer> answers {get; private set;}
    
    /**
     * Constructor accepts a self assessment record id and loads related answers
     */
    public SelfAssessmentService(Id selfAssessmentId) {
        this.selfAssessmentId = selfAssessmentId;
        this.answers = getAnswers();
    }

    /**
     * Creates Answer data wrapper objects for each Self-Assessment Answer sObject
     *  related to the instance's selfAssessmentId
     * Only fetches answers once, then returns from cache
     * @return Answer[]
     */
    private List<Answer> getAnswers() {
        if (answers == null) {
            answers = new List<Answer>();
            for (Self_Assessment_Answer__c obj : getAnswerSObjects()) {
                Answer ans = new Answer();
                ans.id = obj.Id;
                ans.selfAssessmentId = obj.Self_Assessment__c;
                ans.questionId = obj.Self_Assessment_Question__c;
                ans.question = obj.Question__c;
                ans.sortOrder = obj.Sort_Order__c;
                ans.questionType = obj.Question_Type__c;
                ans.helpText = obj.Help_Text__c;
                ans.required = obj.Required__c;
                ans.minValue = obj.Minimum_Value__c;
                ans.maxValue = obj.Maximum_Value__c;
                ans.step = obj.Step__c;
                ans.answerText = obj.Answer_Text_Area__c;
                ans.answerNumber = obj.Answer_Number__c;
                answers.add(ans);
            }
        }
        return answers;
    }

    /**
     * Query for Self-Assessment Answer sObjects related to 
     *  the instance's selfAssessmentId
     * @return Self_Assessment_Answer__c[]
     */
    private List<Self_Assessment_Answer__c> getAnswerSObjects() {
        return [
            SELECT Id, 
                   Self_Assessment__c, 
                   Self_Assessment_Question__c, 
                   Question__c, 
                   Sort_Order__c, 
                   Question_Type__c, 
                   Help_Text__c, 
                   Required__c, 
                   Minimum_Value__c, 
                   Maximum_Value__c, 
                   Step__c, 
                   Answer_Text_Area__c, 
                   Answer_Number__c
              FROM Self_Assessment_Answer__c 
             WHERE Self_Assessment__c = :selfAssessmentId
              WITH SYSTEM_MODE 
             ORDER BY Sort_Order__c ASC
             LIMIT 10000
        ];
    }

    /*********************************************
     * Data wrapper to represent Answers in lwc
     *********************************************/
     public class Answer {
        @AuraEnabled
        public Id id {get;set;}
        @AuraEnabled
        public Id selfAssessmentId {get;set;}
        @AuraEnabled
        public Id questionId {get;set;}
        @AuraEnabled
        public Decimal sortOrder {get;set;}
        @AuraEnabled
        public String questionType {get;set;}
        @AuraEnabled
        public String question {get;set;}
        @AuraEnabled
        public Boolean required {get;set;}
        @AuraEnabled
        public String helpText {get;set;}
        @AuraEnabled
        public Decimal maxValue {get;set;}
        @AuraEnabled
        public Decimal minValue {get;set;}
        @AuraEnabled
        public Decimal step {get;set;}
        @AuraEnabled
        public String answerText {get;set;}
        @AuraEnabled
        public Decimal answerNumber {get;set;}
    }

}