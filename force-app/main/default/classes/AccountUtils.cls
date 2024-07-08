public with sharing class AccountUtils {
    public static Account[] accountsByState(String stateAbbreviation) {
        Account[] accountsFound = [
            SELECT Id
            FROM Account
            WHERE BillingState = :stateAbbreviation
        ];

        return accountsFound;
    }
}
