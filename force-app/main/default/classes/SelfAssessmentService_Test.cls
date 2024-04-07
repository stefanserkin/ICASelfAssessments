@IsTest
private class SelfAssessmentService_Test {

    @TestSetup
    static void makeData() {
        // Set up all data needed for a single self-assessment
        SelfAssessmentTestDataFactory.setupTestData();
    }
    
    @IsTest 
    static void testGetAssessment() {
        // Get self-assessment
        Self_Assessment__c sa = [
            SELECT Id, Status__c, Self_Assessment_Template__c, 
                   (SELECT Id FROM Self_Assessment_Answers__r) 
              FROM Self_Assessment__c 
             LIMIT 1
        ];

        // SelfAssessment object to receive from service
        SelfAssessment assessment;
        
        User u = SelfAssessmentTestDataFactory.createTestUser('Rey', 'Ordonez', 'Admin');
        Test.startTest();
        System.runAs(u) {
            SelfAssessmentService service = new SelfAssessmentService(sa.Id);
            assessment = service.getAssessment();
        }
        Test.stopTest();

        Assert.areEqual(sa.Id, assessment.id, 'Should have received the original assessment');
        Assert.areEqual(sa.Status__c, assessment.status, 'Statuses should be equal');
        Assert.areEqual(sa.Self_Assessment_Answers__r.size(), assessment.answers.size(), 'Should have received an answer for each assessment answer record');
    }

    @IsTest
    static void testSaveAnswers() {
        Decimal numberAnswer = 4.00;
        String textAnswer = 'Option1';

        // Get self-assessment
        Self_Assessment__c sa = [
            SELECT Id, Status__c, Self_Assessment_Template__c, 
                   (SELECT Id FROM Self_Assessment_Answers__r) 
              FROM Self_Assessment__c 
             LIMIT 1
        ];

        Assert.isFalse(sa.Self_Assessment_Answers__r.isEmpty(), 'Should have received answers with the self-assessment');

        // Get SelfAssessment obj with child answers from service
        SelfAssessmentService service = new SelfAssessmentService(sa.Id);
        SelfAssessment assessment = service.getAssessment();

        // Fill in answers
        for (SelfAssessment.Answer ans : assessment.answers) {
            if (ans.questionType == SelfAssessmentService.QUESTION_TYPE_RATING_SCALE) {
                 ans.answerNumber = numberAnswer;
            } else {
                ans.answerText = textAnswer;
            }
        }
        
        User u = SelfAssessmentTestDataFactory.createTestUser('Rey', 'Ordonez', 'Admin');
        Test.startTest();
        System.runAs(u) {
            service.saveAnswers(assessment.answers);
        }
        Test.stopTest();

        // Get refreshed data
        List<Self_Assessment_Answer__c> refreshedAnswers = [
            SELECT Id, Self_Assessment_Question__c, Self_Assessment__c, Answer_Number__c, Answer_Text_Area__c, Question_Type__c
              FROM Self_Assessment_Answer__c
             WHERE Self_Assessment__c = :sa.Id
        ];

        for (Self_Assessment_Answer__c refAns : refreshedAnswers) {
            if (refAns.Question_Type__c == SelfAssessmentService.QUESTION_TYPE_RATING_SCALE) {
                Assert.areEqual(numberAnswer, refAns.Answer_Number__c, 'Should have received the updated number answer value');
            } else {
                Assert.areEqual(textAnswer, refAns.Answer_Text_Area__c, 'Should have received the updated text answer value');
            }
        }
    }

}