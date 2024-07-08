@isTest
private class WarehouseCalloutServiceTest {
    @isTest
    static void testWarehouseCallout() {
        Test.startTest();
        Test.setMock(HTTPCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService.runWarehouseEquipmentSync();
        Test.stopTest();

        Integer numberOfEquipmentSynced = [SELECT COUNT() FROM Product2];

        Assert.areEqual(
            1,
            numberOfEquipmentSynced,
            'Expected 1 equipment to be synced'
        );
    }
}
