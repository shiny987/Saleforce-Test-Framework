/**
 * @author Gabriele Basile
 * @date 03/2021
 * @description test cases for the SObjectParentProviders class
 */
@isTest
private class SObjectParentProvidersTest {
    /** */
    private static final String ACC_MSG = 'Expected an Account id.'; 
    /** */
    private static final String LEAD_MSG = 'Expected an Prospect id.'; 
    /** */
    private static final String ACC_TEMPLATE = 'Business'; 

    @testSetup
    static void makeData() {
        new SObjectBuilder(Account.sObjectType, ACC_TEMPLATE)
        .put(Account.Name, 'Test Setup Account')
        .create();
    }

    @isTest
    private static void specificParentProviderTest1() {
        // Generate a case related to an Account.
        final Case testCase = (Case) new SObjectBuilder(Case.sObjectType)
        .put(Case.AccountId, new SObjectParentProviders.SpecificParentProvider('SELECT Id FROM Account LIMIT 1'))
        .create().getRecord();

        System.assertEquals([SELECT Id FROM Account LIMIT 1].get(0).Id, testCase.AccountId, 'Expected the same Account id.');
    }

    @isTest
    private static void specificParentProviderTest2() {
        Boolean hasExFired = false;
        try {
            new SObjectBuilder(Case.sObjectType)
            .put(Case.AccountId, new SObjectParentProviders.SpecificParentProvider('SELECT Id FROM Account WHERE Name = \'A\''))
            .create();
        } catch(SObjectFieldProviders.FieldProviderException e) {
            hasExFired = true;
        }

        System.assert(hasExFired, 'Expected the Exception fired.');
    }

    @isTest
    private static void specificParentProviderTest3() {
        // Generate a case related to an Account.
        final Case testCase = (Case) new SObjectBuilder(Case.sObjectType)
        .put(Case.AccountId, new SObjectParentProviders.SpecificParentProvider(new SObjectBuilder(Account.sObjectType, ACC_TEMPLATE).create().getRecord()))
        .create().getRecord();

        System.assertNotEquals(null, testCase.AccountId, ACC_MSG);
    }

    @isTest
    private static void genericParentProviderTest() {
        // Generate a case related to an Account.
        final Case testCase = (Case) new SObjectBuilder(Case.sObjectType)
        .put(Case.AccountId, new SObjectParentProviders.GenericParentProvider(Account.sObjectType, ACC_TEMPLATE))
        .create().getRecord();

        System.assertNotEquals(null, testCase.AccountId, ACC_MSG);
    }

    @isTest
    private static void multiParentProviderTest1() {
        // Generate 20 cases related to 20 Accounts.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.AccountId, new SObjectParentProviders.MultiParentProvider(Account.sObjectType, ACC_TEMPLATE, 20))
        .count(20).create().getRecords();

        System.assertNotEquals(null, testCases.get(5).AccountId, ACC_MSG);
    }

    @isTest
    private static void multiParentProviderTest2() {
        // Generate 20 accounts with the "Business" record type.
        final List<Account> accounts = new SObjectBuilder(Account.sObjectType, ACC_TEMPLATE)
        .count(20).create().getRecords();

        // Generate 20 cases related to 20 Accounts.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.AccountId, new SObjectParentProviders.MultiParentProvider(accounts))
        .count(20).create().getRecords();

        System.assertNotEquals(null, testCases.get(5).AccountId, ACC_MSG);
    }

    @isTest
    private static void multiParentProviderTest3() {
        Boolean hasExFired = false;
        try {
            new SObjectBuilder(Case.sObjectType)
            .put(Case.Subject, new SObjectParentProviders.MultiParentProvider(20))
            .count(20).create();
        } catch(SObjectParentProviders.DynamicParentProviderException e) {
            hasExFired = true;
        }

        System.assert(hasExFired, 'Expected the Exception fired.');
    }

    @isTest
    private static void multiParentProviderTest4() {
        // Generate 20 cases related to 20 Contacts.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.LEAP_ProspectId__c, new SObjectParentProviders.MultiParentProvider(20))
        .count(20).create().getRecords();

        System.assertNotEquals(null, testCases.get(5).LEAP_ProspectId__c, LEAD_MSG);
    }

    @isTest
    private static void uniqueParentProviderTest1() {
        // Generate 20 casea related to 20 unique Accounts.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.AccountId, new SObjectParentProviders.UniqueParentProvider(Account.sObjectType, ACC_TEMPLATE))
        .count(20).create().getRecords();

        System.assertNotEquals(null, testCases.get(5).AccountId, ACC_MSG);
    }

    @isTest
    private static void uniqueParentProviderTest2() {
        // Generate 20 casea related to 20 unique Accounts.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.LEAP_ProspectId__c, new SObjectParentProviders.UniqueParentProvider(Lead.sObjectType))
        .count(20).create().getRecords();

        System.assertNotEquals(null, testCases.get(5).LEAP_ProspectId__c, LEAD_MSG);
    }

    @isTest
    private static void uniqueParentProviderTest3() {
        // Generate 20 casea related to 20 unique Accounts.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.LEAP_ProspectId__c, new SObjectParentProviders.UniqueParentProvider())
        .count(20).create().getRecords();

        System.assertNotEquals(null, testCases.get(5).LEAP_ProspectId__c, LEAD_MSG);
    }
}
