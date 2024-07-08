@isTest
public class WarehouseSyncScheduleTest {
    @isTest
    static void WarehousescheduleTest() {
        String scheduleTime = '00 00 01 * * ?';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        String jobID = System.schedule(
            'Warehouse Time To Schedule to Test',
            scheduleTime,
            new WarehouseSyncSchedule()
        );
        Test.stopTest();

        CronTrigger cronTriggers = [
            SELECT Id
            FROM CronTrigger
            WHERE NextFireTime > today
        ];
        Assert.areEqual(jobID, cronTriggers.Id, 'Schedule ');
    }
}
