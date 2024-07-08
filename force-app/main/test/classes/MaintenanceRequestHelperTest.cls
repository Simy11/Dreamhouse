@istest
public with sharing class MaintenanceRequestHelperTest {
    @istest
    private static void testMaintenanceRequestHappyPath() {
        Vehicle__c vehicle = createVehicle();
        insert vehicle;

        Product2 equipment = createEquipment();
        insert equipment;

        Case maintenanceRequest = createMaintenanceRequest(
            vehicle.Id,
            equipment.Id,
            'Repair'
        );
        insert maintenanceRequest;

        Equipment_Maintenance_Item__c eMI = createEMI(
            equipment.Id,
            maintenanceRequest.Id
        );
        insert eMI;

        test.startTest();
        maintenanceRequest.status = 'Closed';
        update maintenanceRequest;
        test.stopTest();

        Case createdMaintenanceRequest = [
            SELECT
                Id,
                Subject,
                Type,
                Equipment__c,
                Date_Reported__c,
                Vehicle__c,
                Date_Due__c
            FROM Case
            WHERE Status = 'New'
        ];

        Equipment_Maintenance_Item__c eMIs = [
            SELECT Id
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c = :createdMaintenanceRequest.Id
        ];

        Assert.isTrue(eMIs != null, 'Equipment Maintenance Item is null');
        Assert.isTrue(
            createdMaintenanceRequest.Subject != null,
            'createdMaintenanceRequest is null'
        );
        Assert.areEqual(
            createdMaintenanceRequest.Type,
            'Routine Maintenance',
            'Wrong Type given'
        );
        Assert.areEqual(
            createdMaintenanceRequest.Equipment__c,
            equipment.Id,
            'Wrong Equipment Id given'
        );
        Assert.areEqual(
            createdMaintenanceRequest.Vehicle__c,
            vehicle.Id,
            'Wrong Vehicle Id given'
        );
        Assert.areEqual(
            createdMaintenanceRequest.Date_Reported__c,
            system.today(),
            'Wrong Date Reported given'
        );
    }

    @istest
    private static void testMaintenanceRequestNegative() {
        Vehicle__c vehicle = createVehicle();
        insert vehicle;

        Product2 equipment = createEquipment();
        insert equipment;

        Case maintenanceRequest = createMaintenanceRequest(
            vehicle.Id,
            equipment.Id,
            'Repair'
        );
        insert maintenanceRequest;

        Equipment_Maintenance_Item__c eMI = createEMI(
            equipment.Id,
            maintenanceRequest.Id
        );
        insert eMI;

        test.startTest();
        maintenanceRequest.Status = 'Working';
        update maintenanceRequest;
        test.stopTest();

        Case[] actualMaintenanceRequests = [
            SELECT id
            FROM Case
        ];

        Equipment_Maintenance_Item__c actualEMI = [
            SELECT id
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c = :maintenanceRequest.Id
        ];

        Assert.isTrue(actualEMI != null, 'Equipment Maintenance Item is null');
        Assert.isTrue(
            actualMaintenanceRequests.size() == 1,
            'Wrong Number of Maintenance Requests updated'
        );
    }

    @istest
    private static void testMaintenanceRequestBulk() {
        Vehicle__c[] vehicles = new List<Vehicle__c>();
        Product2[] equipmentList = new List<Product2>();
        Equipment_Maintenance_Item__c[] eMIs = new List<Equipment_Maintenance_Item__c>();
        Case[] maintenanceRequests = new List<Case>();
        Id[] oldRequestIds = new List<Id>();

        for (integer i = 0; i < 300; i++) {
            vehicles.add(createVehicle());
            equipmentList.add(createEquipment());
        }
        insert vehicles;
        insert equipmentList;

        for (integer i = 0; i < 300; i++) {
            String maintenanceRequestType = Math.mod(i, 2) == 0
                ? 'Repair'
                : 'Routine Maintenance';

            maintenanceRequests.add(
                createMaintenanceRequest(
                    vehicles.get(i).id,
                    equipmentList.get(i).id,
                    maintenanceRequestType
                )
            );
        }
        insert maintenanceRequests;

        for (integer i = 0; i < 299; i++) {
            eMIs.add(
                createEMI(
                    equipmentList.get(i).id,
                    maintenanceRequests.get(i).id
                )
            );
        }
        insert eMIs;

        test.startTest();
        for (case req : maintenanceRequests) {
            req.Status = 'Closed';
            oldRequestIds.add(req.Id);
        }
        update maintenanceRequests;
        test.stopTest();

        Case[] actualMaintenanceRequests = [
            SELECT Id
            FROM Case
            WHERE Status = 'New'
        ];

        Equipment_Maintenance_Item__c[] workParts = [
            SELECT Id
            FROM Equipment_Maintenance_Item__c
            WHERE Maintenance_Request__c IN :oldRequestIds
        ];

        Assert.isTrue(
            actualMaintenanceRequests.size() == 300,
            'Should have created 300 requests'
        );
    }

    private static Vehicle__c createVehicle() {
        return new Vehicle__c(name = 'Big Boi');
    }

    private static Product2 createEquipment() {
        return new Product2(
            name = 'Good Equipment',
            lifespan_months__c = 12,
            maintenance_cycle__c = 12,
            replacement_part__c = true
        );
    }

    private static Case createMaintenanceRequest(
        Id vehicleId,
        Id equipmentId,
        String maintenanceRequestType
    ) {
        return new Case(
            Type = maintenanceRequestType,
            Status = 'New',
            Origin = 'Web',
            Subject = 'Test subject',
            Equipment__c = equipmentId,
            Vehicle__c = vehicleId
        );
    }

    private static Equipment_Maintenance_Item__c createEMI(
        Id equipmentId,
        Id requestId
    ) {
        return new Equipment_Maintenance_Item__c(
            Equipment__c = equipmentId,
            Maintenance_Request__c = requestId
        );
    }
}
