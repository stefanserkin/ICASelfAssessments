/**
 * Test data factory for self assessments.
 * TODO - Break sobject types out into separate methods for more dynamic tests.
 */

@IsTest
public with sharing class SelfAssessmentTestDataFactory {
    
    /**
     * Set up all needed records for a single self-assessment that has not been started
     */
    public static void setupTestData() {
        // Template
        Self_Assessment_Template__c template = new Self_Assessment_Template__c(
            Name = 'Test Template'
        );
        insert template;

        // Questions of various types
        List<Self_Assessment_Question__c> lstQuestions = new List<Self_Assessment_Question__c>();
        Self_Assessment_Question__c ratingScaleQuestion = new Self_Assessment_Question__c(
            Question__c = 'Test much?',
            Self_Assessment_Template__c = template.Id,
            Sort_Order__c = 1.00,
            Type__c = SelfAssessmentService.QUESTION_TYPE_RATING_SCALE, 
            Display_Type__c = 'Radio',
            Minimum_Value__c = 1,
            Maximum_Value__c = 4,
            Step__c = 1,
            Required__c = true
        );
        lstQuestions.add(ratingScaleQuestion);

        Self_Assessment_Question__c textAreaQuestion = new Self_Assessment_Question__c(
            Question__c = 'Please explain',
            Self_Assessment_Template__c = template.Id,
            Sort_Order__c = 2.00,
            Type__c = SelfAssessmentService.QUESTION_TYPE_TEXT_AREA, 
            Help_Text__c = 'A little help'
        );
        lstQuestions.add(textAreaQuestion);

        Self_Assessment_Question__c picklistQuestion = new Self_Assessment_Question__c(
            Question__c = 'Pick a test',
            Self_Assessment_Template__c = template.Id,
            Sort_Order__c = 3.00,
            Type__c = SelfAssessmentService.QUESTION_TYPE_PICKLIST, 
            Picklist_Values__c = 'Option1;Option2;Option3',
            Help_Text__c = 'A little help'
        );
        lstQuestions.add(picklistQuestion);

        Self_Assessment_Question__c mspQuestion = new Self_Assessment_Question__c(
            Question__c = 'Pick a few tests',
            Self_Assessment_Template__c = template.Id,
            Sort_Order__c = 4.00,
            Type__c = SelfAssessmentService.QUESTION_TYPE_MULTI_SELECT_PICKLIST, 
            Picklist_Values__c = 'Option1;Option2;Option3',
            Help_Text__c = 'A little help'
        );
        lstQuestions.add(mspQuestion);

        insert lstQuestions;

        // Contacts to associate with self-assessment responses
        Contact ct = new Contact(FirstName = 'Juan', LastName = 'Lagares', Email = 'juan@testing.com');
        insert ct;

        // A self-assessment for the new contact
        Self_Assessment__c sa = new Self_Assessment__c(
            Contact__c = ct.Id, 
            Self_Assessment_Template__c = template.Id, 
            Status__c = 'Not Started',
            Contact_Role__c = 'Service Participant'
        );
        insert sa;

        // Answer creation is handled in flow and will not be active during deployments.
        // Check for records and create them if they're absent
        List<Self_Assessment_Answer__c> lstAnswers = [SELECT Id FROM Self_Assessment_Answer__c WHERE Self_Assessment__c = :sa.Id];

        if (lstAnswers.isEmpty()) {
            for (Self_Assessment_Question__c q : lstQuestions) {
                Self_Assessment_Answer__c ans = new Self_Assessment_Answer__c(
                    Self_Assessment__c = sa.Id,
                    Self_Assessment_Question__c = q.Id,
                    Question_Type__c = q.Type__c,
                    Question__c = q.Question__c
                );
                if (ans.Question_Type__c == 'Rating Scale') {
                    ans.Minimum_Value__c = q.Minimum_Value__c;
                    ans.Maximum_Value__c = q.Maximum_Value__c;
                    ans.Step__c = q.Step__c;
                }
                lstAnswers.add(ans);
            }
            insert lstAnswers;
        }
    }

    /**
     * Create test user with self-assessment perm sets
     * Valid permissionLevel values are 'Admin' and 'User'
     */
    public static User createTestUser(
        String firstName, 
        String lastName, 
        String permissionLevel
    ) {
        String orgId      = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User();
        u.IsActive          = true;
        u.TimeZoneSidKey    = UserInfo.getTimeZone().toString();
        u.LocaleSidKey      = UserInfo.getLocale();
        u.LanguageLocaleKey = UserInfo.getLocale();
        u.EmailEncodingKey  = 'ISO-8859-1';
        u.Username          = uniqueName + '@test' + orgId + '.org';
        u.Email             = uniqueName + '@test' + orgId + '.org';
        u.FirstName         = firstName;
        u.LastName          = lastName;
        u.Alias             = uniqueName.substring(18, 23);
        u.ProfileId         = profile.Id;
        insert u;

        // Assign permission set
        if (permissionLevel != null) {
            String permSetName = 'Self_Assessment_' + permissionLevel;
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1];
            insert new PermissionSetAssignment(
                AssigneeId = u.Id,
                PermissionSetId = permSet.Id
            );
        }
        return u;
    }

}