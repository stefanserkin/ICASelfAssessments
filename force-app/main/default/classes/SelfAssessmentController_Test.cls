@IsTest
private class SelfAssessmentController_Test {

    @TestSetup
    static void makeData() {
        // Set up all data needed for a single self-assessment
        SelfAssessmentTestDataFactory.setupTestData();
    }
    
    @IsTest 
    static void testGetAssessment() {
        // Get self-assessment
        Self_Assessment__c sa = [
            SELECT Id, Status__c, Self_Assessment_Template__r.Name, 
                   (SELECT Id FROM Self_Assessment_Answers__r) 
              FROM Self_Assessment__c 
             LIMIT 1
        ];

        // SelfAssessment object to receive from service
        SelfAssessment assessment;
        
        User u = SelfAssessmentTestDataFactory.createTestUser('Rey', 'Ordonez', 'Admin');

        Test.startTest();
        System.runAs(u) {
            assessment = SelfAssessmentController.getSelfAssessment(sa.Id);
        }
        Test.stopTest();

        Assert.areEqual(sa.Id, assessment.id, 'Should have received the original assessment');
        Assert.areEqual(sa.Status__c, assessment.status, 'Statuses should be equal');
        Assert.areEqual(sa.Self_Assessment_Template__r.Name, assessment.templateName, 'Should have received the name of the original template');
        Assert.areEqual(sa.Self_Assessment_Answers__r.size(), assessment.answers.size(), 'Should have received an answer for each assessment answer record');
    }

    @IsTest
    static void testSubmitSelfAssessment() {
        Decimal numberAnswer = 4.00;
        String textAnswer = 'Option1';

        // Get self-assessment
        Self_Assessment__c sa = [
            SELECT Id, Status__c, Self_Assessment_Template__c, 
                   (SELECT Id FROM Self_Assessment_Answers__r) 
              FROM Self_Assessment__c 
             LIMIT 1
        ];

        Assert.isFalse(sa.Self_Assessment_Answers__r.isEmpty(), 'Expected to find answers associated with the assessment');

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

        String result;
        Test.startTest();
        System.runAs(u) {
            result = SelfAssessmentController.submitSelfAssessment(sa.Id, JSON.serialize(assessment.answers), true);
        }
        Test.stopTest();

        Assert.areEqual('success', result, 'Should have received a successful response');

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

    @IsTest
    static void testGetAssessmentWithException() {
        String invalidId = 'BogusId';
        Boolean testHasException = false;
                
        User u = SelfAssessmentTestDataFactory.createTestUser('Rey', 'Ordonez', 'Admin');

        Test.startTest();
        System.runAs(u) {
            try {
                SelfAssessment assessment = SelfAssessmentController.getSelfAssessment(invalidId);
                Assert.fail('Should have received an exception');
            } catch (Exception e) {
                testHasException = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(testHasException, 'Should have received an exception');
    }

    @IsTest
    static void testGetSubmitAssessmentWithException() {
        Self_Assessment__c sa = [SELECT Id FROM Self_Assessment__c LIMIT 1];
        String badJson = '{"questionId":"InvalidId","answerOptionId":"InvalidId"}';
        Boolean testHasException = false;

        User u = SelfAssessmentTestDataFactory.createTestUser('Rey', 'Ordonez', 'Admin');

        Test.startTest();
        System.runAs(u) {
            try {
                String result = SelfAssessmentController.submitSelfAssessment(sa.Id, badJson, true);
                Assert.fail('Should have received an exception');
            } catch (Exception e) {
                testHasException = true;
            }
        }
        Test.stopTest();

        Assert.isTrue(testHasException, 'Should have received an exception');
    }

}