public with sharing class AccountTriggerHandler {
    public static void CreateAccounts(Account[] accounts) {
        for (Account account : accounts) {
            account.ShippingState = account.BillingState;
        }
    }
}
