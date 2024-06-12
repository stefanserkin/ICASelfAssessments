public class ParticipantScorecardController {
    public Id programEngagementId { get; set; }
    public pmdm__ProgramEngagement__c programEngagement { get; set; }
    public List<Self_Assessment__c> selfAssessments { get; set; }
    public List<pmdm__ServiceDelivery__c> serviceDeliveries { get; set; }

    public ParticipantScorecardController() {
        programEngagementId = ApexPages.currentPage().getParameters().get('id');
        if (programEngagementId != null) {
            loadData();
        }
    }

    private void loadData() {
        programEngagement = [
            SELECT Id, Name
              FROM pmdm__ProgramEngagement__c
             WHERE Id = :programEngagementId
             LIMIT 1
        ];

        selfAssessments = [
            SELECT Id, Name, Service_Schedule_Name__c, Service_Session__r.Name,
                   (SELECT Id, Question__c, Answer_Number__c, Answer_Text_Area__c, Question_Type__c
                      FROM Self_Assessment_Answers__r)
              FROM Self_Assessment__c
             WHERE Program_Engagement__c = :programEngagementId
        ];

        serviceDeliveries = [
            SELECT Id, Name, pmdm__DeliveryDate__c, pmdm__AttendanceStatus__c
              FROM pmdm__ServiceDelivery__c
             WHERE pmdm__ProgramEngagement__c = :programEngagementId
        ];
    }
}
