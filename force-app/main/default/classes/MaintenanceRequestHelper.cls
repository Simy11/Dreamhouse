public with sharing class MaintenanceRequestHelper {
    public static void updateMaintenanceRequests(
        Case[] updatedCases,
        Map<Id, Case> nonUpdatedCases
    ) {
        Set<Id> validIds = new Set<Id>();

        for (Case updatedCase : updatedCases) {
            Case oldCase = nonUpdatedCases.get(updatedCase.Id);

            if (
                isRepairOrRoutineMaintenance(updatedCase) &&
                hasMaintenanceRequestClosed(updatedCase, oldCase)
            ) {
                validIds.add(updatedCase.Id);
            }
        }

        if (!validIds.isEmpty()) {
            AggregateResult[] results = MaintenanceRequestSelector.getMaintenanceRequests(
                validIds
            );

            Map<Id, Decimal> maintenanceCycles = new Map<ID, Decimal>();

            for (AggregateResult result : results) {
                maintenanceCycles.put(
                    (Id) result.get('Maintenance_Request__c'),
                    (Decimal) result.get('cycle')
                );
            }

            List<Case> newCases = new List<Case>();

            Map<Id, Case> casesClosedInTransaction = MaintenanceRequestSelector.getCasesClosedInTransaction(
                validIds
            );

            for (Case closedCase : casesClosedInTransaction.values()) {
                Case newCase = createNewRoutineMaintenance(
                    closedCase,
                    maintenanceCycles
                );

                newCases.add(newCase);
            }

            insert newCases;

            List<Equipment_Maintenance_Item__c> clonedEMIs = new List<Equipment_Maintenance_Item__c>();

            for (Case newCase : newCases) {
                Equipment_Maintenance_Item__c[] eMIsForCase = casesClosedInTransaction.get(
                        newCase.ParentId
                    )
                    .Equipment_Maintenance_Items__r;

                for (Equipment_Maintenance_Item__c eMI : eMIsForCase) {
                    Equipment_Maintenance_Item__c eMIClone = eMI.clone();
                    eMIClone.Maintenance_Request__c = newCase.Id;

                    clonedEMIs.add(eMIClone);
                }
            }

            insert clonedEMIs;
        }
    }

    private static Boolean isRepairOrRoutineMaintenance(Case updatedCase) {
        return updatedCase.Type == 'Repair' ||
            updatedCase.Type == 'Routine Maintenance';
    }

    private static Boolean hasMaintenanceRequestClosed(
        Case updatedCase,
        Case oldCase
    ) {
        return oldCase.Status != 'Closed' && updatedCase.Status == 'Closed';
    }

    private static Case createNewRoutineMaintenance(
        Case closedCase,
        Map<Id, Decimal> maintenanceCycles
    ) {
        Case newCase = new Case(
            ParentId = closedCase.Id,
            Status = 'New',
            Subject = 'Routine Maintenance',
            Type = 'Routine Maintenance',
            Vehicle__c = closedCase.Vehicle__c,
            Equipment__c = closedCase.Equipment__c,
            Origin = 'Web',
            Date_Reported__c = Date.Today()
        );

        Integer dateDueIncrement = maintenanceCycles.containskey(closedCase.Id)
            ? (Integer) maintenanceCycles.get(closedCase.Id)
            : (Integer) closedCase.Equipment__r.Maintenance_Cycle__c;

        newCase.Date_Due__c = Date.today().addDays(dateDueIncrement);

        return newCase;
    }
}
