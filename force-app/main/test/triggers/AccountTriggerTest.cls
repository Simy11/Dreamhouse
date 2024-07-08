@isTest
private class AccountTriggerTest {
    @isTest
    static void TestCreateNewAccountInBulk() {
        List<Account> expectedAccounts = new List<Account>();

        for (Integer i = 0; i < 200; i++) {
            Account acct = new Account(Name = 'Test Account ' + i);
            expectedAccounts.add(acct);
        }

        Test.startTest();
        insert expectedAccounts;
        Test.stopTest();

        List<Account> actualAccounts = [SELECT Id FROM Account];
        Assert.areEqual(
            200,
            actualAccounts.size(),
            'Incorrect number of Accounts Created'
        );

        List<Opportunity> actualOpps = [SELECT Id FROM Opportunity];
        Assert.areEqual(
            200,
            actualOpps.size(),
            'Incorrect number of Opportunities Created'
        );
    }

    @isTest
    static void TestCreateAccounts() {
        List<Account> expectedAccounts = new List<Account>();

        for (Integer i = 0; i < 200; i++) {
            Account acct = new Account(
                Name = 'Test Account ' + i,
                BillingState = 'CA'
            );
            expectedAccounts.add(acct);
        }

        Test.startTest();
        insert expectedAccounts;
        Test.stopTest();

        List<Account> actualAccounts = [SELECT Id, ShippingState FROM Account];
        Assert.areEqual(
            200,
            actualAccounts.size(),
            'Incorrect number of Accounts Created'
        );

        for (Account account : actualAccounts) {
            Assert.areEqual(
                'CA',
                account.ShippingState,
                'Incorrect Shipping state assigned'
            );
        }
    }
}
