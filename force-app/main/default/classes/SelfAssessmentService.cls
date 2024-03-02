/*********************************************
 * Service class for self-assessments
 * @date 2024
 *********************************************/
public with sharing class SelfAssessmentService {

    public Id selfAssessmentId {get; private set;}
    public SelfAssessment selfAssessment {get; private set;}
    
    /**
     * Constructor accepts a self assessment record id and loads related answers
     */
    public SelfAssessmentService(Id selfAssessmentId) {
        this.selfAssessmentId = selfAssessmentId;
        this.selfAssessment = getAssessment();
    }

    /**
     * Returns a SelfAssessment object with child answers
     */
    public SelfAssessment getAssessment() {
        if (selfAssessment == null) {
            Self_Assessment__c obj = queryForAssessmentWithAnswers();
            selfAssessment = wrapSelfAssessment(obj);
        }
        return selfAssessment;
    }

    private SelfAssessment wrapSelfAssessment(
        Self_Assessment__c selfAssessment
    ) {
        SelfAssessment sa = new SelfAssessment(selfAssessment.Id);
        sa.templateName = selfAssessment.Self_Assessment_Template__r.Name;
        sa.introMessage = selfAssessment.Self_Assessment_Template__r.Intro_Message__c;
        sa.thankYouMessage = selfAssessment.Self_Assessment_Template__r.Thank_You_Message__c;

        // Create answer data wrappers
        List<SelfAssessment.Answer> answers = new List<SelfAssessment.Answer>();
        for (Self_Assessment_Answer__c saa : selfAssessment.Self_Assessment_Answers__r) {
            SelfAssessment.Answer ans = new SelfAssessment.Answer();
            ans.id = saa.Id;
            ans.selfAssessmentId = saa.Self_Assessment__c;
            ans.questionId = saa.Self_Assessment_Question__c;
            ans.question = saa.Question__c;
            ans.sortOrder = saa.Sort_Order__c;
            ans.questionType = saa.Question_Type__c;
            ans.helpText = saa.Help_Text__c;
            ans.required = saa.Required__c;
            ans.minValue = saa.Minimum_Value__c;
            ans.maxValue = saa.Maximum_Value__c;
            ans.step = saa.Step__c;
            ans.answerText = saa.Answer_Text_Area__c;
            ans.answerNumber = saa.Answer_Number__c;
            answers.add(ans);
        }

        sa.answers = answers;
        return sa;
    }

    /**
     * Combined query with messaging from parent template and answers from child records
     * @return Self_Assessment__c
     */
    private Self_Assessment__c queryForAssessmentWithAnswers() {
        return [
            SELECT Id, 
                   Self_Assessment_Template__r.Name, 
                   Self_Assessment_Template__r.Intro_Message__c, 
                   Self_Assessment_Template__r.Thank_You_Message__c, 
                   (SELECT Id, 
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
                      FROM Self_Assessment_Answers__r
                     ORDER BY Sort_Order__c ASC
                     LIMIT 10000)
              FROM Self_Assessment__c
             WHERE Id = :selfAssessmentId
              WITH SYSTEM_MODE
             LIMIT 1
        ];
    }

}