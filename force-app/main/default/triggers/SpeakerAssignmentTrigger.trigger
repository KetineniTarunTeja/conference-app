trigger SpeakerAssignmentTrigger on Speaker_Assignment__c (before insert) {

    Set<Id> speakerIds = new Set<Id>();
    Set<Id> sessionIds = new Set<Id>();

    for (Speaker_Assignment__c sa : Trigger.new) {
        if (sa.Speaker__c != null && sa.Session__c != null) {
            speakerIds.add(sa.Speaker__c);
            sessionIds.add(sa.Session__c);
        }
    }

    Map<Id, Session__c> sessionMap = new Map<Id, Session__c>(
        [SELECT Id, Session_Date__c, Start_Time__c, End_Time__c
         FROM Session__c
         WHERE Id IN :sessionIds]
    );

    List<Speaker_Assignment__c> existingAssignments = [
        SELECT Speaker__c,
               Session__r.Session_Date__c,
               Session__r.Start_Time__c,
               Session__r.End_Time__c
        FROM Speaker_Assignment__c
        WHERE Speaker__c IN :speakerIds
    ];

    for (Speaker_Assignment__c sa : Trigger.new) {

        Session__c newSession = sessionMap.get(sa.Session__c);

        for (Speaker_Assignment__c existing : existingAssignments) {

            if (existing.Speaker__c == sa.Speaker__c &&
                existing.Session__r.Session_Date__c == newSession.Session_Date__c) {

                Boolean isOverlap =
                    newSession.Start_Time__c < existing.Session__r.End_Time__c &&
                    newSession.End_Time__c > existing.Session__r.Start_Time__c;

                if (isOverlap) {
                    sa.addError('Speaker is already booked for this time.');
                }
            }
        }
    }
}