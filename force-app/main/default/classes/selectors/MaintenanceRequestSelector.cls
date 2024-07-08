public with sharing class MaintenanceRequestSelector {
    public static Map<Id, Case> getCasesClosedInTransaction(Set<Id> validIds) {
        return new Map<Id, Case>(
            [
                SELECT
                    Id,
                    Vehicle__c,
                    Equipment__c,
                    Equipment__r.Maintenance_Cycle__c,
                    (
                        SELECT Id, Equipment__c, Quantity__c
                        FROM Equipment_Maintenance_Items__r
                    )
                FROM Case
                WHERE Id IN :validIds
            ]
        );
    }

    public static AggregateResult[] getMaintenanceRequests(Set<Id> validIds) {
        return [
            SELECT
                Maintenance_Request__c,
                MIN(Equipment__r.Maintenance_Cycle__c) cycle
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :validIds
            GROUP BY Maintenance_Request__c
        ];
    }
}
