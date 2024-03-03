/*********************************************
 * Service class for self-assessments
 * @date 2024
 *********************************************/
public with sharing class SelfAssessmentService {

    private static final String QUESTION_TYPE_RATING_SCALE = 'Rating Scale';
    private static final String QUESTION_TYPE_TEXT_AREA = 'Text Area';
    private static final String STATUS_COMPLETED = 'Completed';

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
     * Get a SelfAssessment object with child answers for the instance's selfAssessmentId
     * @return SelfAssessment
     */
    public SelfAssessment getAssessment() {
        if (selfAssessment == null) {
            Self_Assessment__c obj = queryForAssessmentWithAnswers();
            selfAssessment = wrapSelfAssessment(obj);
        }
        return selfAssessment;
    }

    /**
     * Save a collection of answers for the instance's assessment
     * @param SelfAssessment.Answer[] Collection of answers to save
     */
    public void saveAnswers(
        List<SelfAssessment.Answer> answers
    ) {
        // Update answer records
        List<Self_Assessment_Answer__c> lstAnswers = new List<Self_Assessment_Answer__c>();
        for (SelfAssessment.Answer obj : answers) {
            Self_Assessment_Answer__c answer = new Self_Assessment_Answer__c();
            answer.Id = obj.id;
            if (obj.questionType == QUESTION_TYPE_RATING_SCALE) {
                answer.Answer_Number__c = obj.answerNumber;
            } else if (obj.questionType == QUESTION_TYPE_TEXT_AREA) {
                answer.Answer_Text_Area__c = obj.answerText;
            }
            lstAnswers.add(answer);
        }
        Database.update(lstAnswers, AccessLevel.SYSTEM_MODE);

        // Update assessment status and datetime submitted
        Self_Assessment__c sa = new Self_Assessment__c();
        sa.Id = selfAssessmentId;
        sa.Status__c = STATUS_COMPLETED;
        sa.Date_Time_Completed__c = Datetime.now();
        Database.update(sa, AccessLevel.SYSTEM_MODE);
    }

    /**
     * Creates a data wrapper for a self-assessment with child answers
     * @param Self_Assessment__c Self-assessment with answer records
     * @return SelfAssessment
     */
    private SelfAssessment wrapSelfAssessment(
        Self_Assessment__c selfAssessment
    ) {
        SelfAssessment sa = new SelfAssessment(selfAssessment.Id);
        sa.status = selfAssessment.Status__c;
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
            ans.required = saa.Required__c;
            ans.minValue = saa.Minimum_Value__c;
            ans.maxValue = saa.Maximum_Value__c;
            ans.step = saa.Step__c;
            ans.answerText = saa.Answer_Text_Area__c;
            ans.answerNumber = saa.Answer_Number__c;
            ans.displayType = saa.Self_Assessment_Question__r.Display_Type__c;
            ans.helpText = saa.Self_Assessment_Question__r.Help_Text__c;
            answers.add(ans);
        }

        sa.answers = answers;
        return sa;
    }

    /**
     * Combined query on self-assessment gets messaging from parent template 
     *  and answers from child records
     * @return Self_Assessment__c
     */
    private Self_Assessment__c queryForAssessmentWithAnswers() {
        return [
            SELECT Id, 
                   Status__c, 
                   Self_Assessment_Template__r.Name, 
                   Self_Assessment_Template__r.Intro_Message__c, 
                   Self_Assessment_Template__r.Thank_You_Message__c, 
                   (SELECT Id, 
                           Self_Assessment__c, 
                           Self_Assessment_Question__c, 
                           Question__c, 
                           Sort_Order__c, 
                           Question_Type__c, 
                           Required__c, 
                           Minimum_Value__c, 
                           Maximum_Value__c, 
                           Step__c, 
                           Answer_Text_Area__c, 
                           Answer_Number__c, 
                           Self_Assessment_Question__r.Display_Type__c, 
                           Self_Assessment_Question__r.Help_Text__c
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