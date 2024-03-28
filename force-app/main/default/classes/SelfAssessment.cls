/*********************************************
 * Data wrapper to represent a self-assessment
 *  Includes parent details from the self-assessment template
 *  and any child self-assessment answers
 * @date 2024
 *********************************************/
public with sharing class SelfAssessment {

    @AuraEnabled
    public Id id {get; private set;}

    public SelfAssessment(Id selfAssessmentId) {
        this.id = selfAssessmentId;
    }

    @AuraEnabled
    public String templateName {get;set;}

    @AuraEnabled
    public String status {get;set;}

    @AuraEnabled
    public String introMessage {get;set;}

    @AuraEnabled
    public String thankYouMessage {get;set;}

    @AuraEnabled
    public List<Answer> answers {get;set;}

    /*********************************************
     * Answer inner class
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

        @AuraEnabled
        public String displayType {get;set;}

        @AuraEnabled
        public String picklistValues {get;set;}
        
    }

}