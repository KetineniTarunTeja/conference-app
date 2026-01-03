public with sharing class SpeakerController {

    @AuraEnabled(cacheable=true)
    public static List<Speaker__c> searchSpeakers(String name, String speciality) {

        String searchName = '%' + name + '%';

        if (String.isBlank(speciality)) {
            return [
                SELECT Id, Name, Email__c, Bio__c, Speciality__c
                FROM Speaker__c
                WHERE Name LIKE :searchName
                ORDER BY Name
            ];
        }
        else {
            return [
                SELECT Id, Name, Email__c, Bio__c, Speciality__c
                FROM Speaker__c
                WHERE Name LIKE :searchName
                AND Speciality__c = :speciality
                ORDER BY Name
            ];
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Session__c> getFutureSessions() {
        return [
            SELECT Id, Name, Title__c, Session_Date__c
            FROM Session__c
            WHERE Session_Date__c >= :Date.today()
            ORDER BY Session_Date__c
        ];
    }

    @AuraEnabled
public static Boolean checkAvailability(Id speakerId, Id sessionId) {

    // ✅ Defensive null check (prevents runtime errors)
    if (speakerId == null || sessionId == null) {
        return false;
    }

    Session__c newSession = [
        SELECT Session_Date__c, Start_Time__c, End_Time__c
        FROM Session__c
        WHERE Id = :sessionId
        LIMIT 1
    ];

    List<Speaker_Assignment__c> conflicts = [
        SELECT Id
        FROM Speaker_Assignment__c
        WHERE Speaker__c = :speakerId
        AND Session__r.Session_Date__c = :newSession.Session_Date__c
        AND Session__r.Start_Time__c < :newSession.End_Time__c
        AND Session__r.End_Time__c > :newSession.Start_Time__c
        LIMIT 1
    ];

    return conflicts.isEmpty();
}

    @AuraEnabled
    public static void createAssignment(Id speakerId, Id sessionId) {

        insert new Speaker_Assignment__c(
            Speaker__c = speakerId,
            Session__c = sessionId
        );
    }
}