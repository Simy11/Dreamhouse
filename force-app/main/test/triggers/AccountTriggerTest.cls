@isTest
private class AccountTriggerTest {
    @isTest
    static void TestCreateNewAccountInBulk() {
        List<Account> accts = new List<Account>();

        for (Integer i = 0; i < 200; i++) {
            Account acct = new Account(Name = 'Test Account ' + i);
            accts.add(acct);
        }

        Test.startTest();
        insert accts;
        Test.stopTest();

        List<Account> verifyAccts = [SELECT Id FROM Account];
        Assert.areEqual(
            200,
            verifyAccts.size(),
            'Incorrect number of Accounts Created'
        );

        List<Opportunity> verifyOpps = [SELECT Id FROM Opportunity];
        Assert.areEqual(
            200,
            verifyOpps.size(),
            'Incorrect number of Opportunities Created'
        );
    }
}
