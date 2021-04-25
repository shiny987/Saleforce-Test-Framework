/**
 * @author Gabriele Basile
 * @date 03/2021
 * @description test cases for the SObjectFieldProviders class
 */
@isTest
private class SObjectFieldProvidersTest {
    
    @isTest
    private static void uniqueStringProviderTest1() {
        // Generate Opportunities with a unique name, starting with "Opportunity-"
        final List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
        .put(Opportunity.Name, new SObjectFieldProviders.UniqueStringProvider())
        .count(2).create().getRecords();
        
        System.assertEquals(2, myOpportunities.size(), 'Expected 2 Oppotunities.');
    }

    @isTest
    private static void uniqueStringProviderTest2() {
        // Generate Opportunities with a unique name, starting with "Opportunity-"
        final List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
        .put(Opportunity.Name, new SObjectFieldProviders.UniqueStringProvider('Opportunity-'))
        .count(22).create().getRecords();

        System.assertEquals(22, myOpportunities.size(), 'Expected 22 Oppotunities.');
    }

    @isTest
    private static void uniqueFixedLengthStringProviderTest1() {
        // Create a series of Products, each with a unique 12 digit serial number.
        final List<Product2> myProducts = new SObjectBuilder(Product2.sObjectType)
        .put(Product2.ProductCode, new SObjectFieldProviders.UniqueFixedLengthStringProvider(12))
        .count(3).create().getRecords();

        System.assertEquals(3, myProducts.size(), 'Expected 3 Products.');
    }
        
    @isTest
    private static void uniqueFixedLengthStringProviderTest2() {
        Boolean hasExFired = false;
        try {
            new SObjectBuilder(Product2.sObjectType)
            .put(Product2.ProductCode, new SObjectFieldProviders.UniqueFixedLengthStringProvider(12, '--'))
            .count(5).create();
        } catch(SObjectFieldProviders.FieldProviderException e) {
            hasExFired = true;
        }

        System.assert(hasExFired, 'Expected the Exception fired.');
    }

    @isTest
    private static void uniqueFixedLengthStringProviderTest3() {
        final List<Product2> myProducts = new SObjectBuilder(Product2.sObjectType)
        .put(Product2.ProductCode, new SObjectFieldProviders.UniqueFixedLengthStringProvider('TESTING',5))
        .count(4).create().getRecords();

        System.assertEquals(4, myProducts.size(), 'Expected 4 Products.');
    }

    @isTest
    private static void dummyIdProviderTest() {
        // Build a hundred cases, each with a fake Id, and a fake Account lookup.
        final List<Case> testCases = new SObjectBuilder(Case.sObjectType)
        .put(Case.Id, new SObjectFieldProviders.DummyIdProvider())
        .put(Case.AccountId, new SobjectFieldProviders.DummyIdProvider(Account.sObjectType))
        .put(Case.ContactId, new SobjectFieldProviders.DummyIdProvider(Contact.sObjectType.getDescribe().getKeyPrefix()))
        .put(Case.LEAP_ProspectId__c, new SobjectFieldProviders.DummyIdProvider())
        .count(4).build().getRecords();

        System.assertEquals(4, testCases.size(), 'Expected 4 Cases.');
    }
    @isTest
    private static void dummyIdProviderTest2() {
        Boolean hasExFired = false;
        try {
            new SObjectBuilder(Case.sObjectType)
            .put(Case.Subject, new SobjectFieldProviders.DummyIdProvider())
            .create();
        } catch(SObjectFieldProviders.FieldProviderException e) {
            hasExFired = true;
        }
        System.assert(hasExFired, 'Expected the Exception fired.');
    }

    @isTest
    private static void listProviderTest() {
        // Create 20 opportunities, with alternating stage names.
        final List<String> stages = new List<String>{ 'Closed/Won', 'Closed/Lost' };
        final List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
        .put(Opportunity.StageName, new SObjectFieldProviders.ListProvider(stages))
        .count(20).create().getRecords();

        System.assertEquals(20, myOpportunities.size(), 'Expected 20 Oppotunities.');
    }

    @isTest
    private static void repeatingProviderTest() {
        // Create 4 opportunities, with each combination of closed/won - closed/lost and enterprise - individual.
        final List<String> stages = new List<String>{ 'Closed/Won', 'Closed/Lost' };
        final List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
        .put(Opportunity.Type, new List<String>{ 'Enterprise', 'Individual' })
        .put(Opportunity.StageName, new SObjectFieldProviders.RepeatingProvider(stages, 2))
        .put(Opportunity.AccountId, new SObjectFieldProviders.RepeatingProvider(new SObjectFieldProviders.DummyIdProvider(), 2))
        .count(4).build().getRecords();

        System.assertEquals(4, myOpportunities.size(), 'Expected 4 Oppotunities.');
    }

    @isTest
    private static void profileProviderTest1() {
        // Build three standard users.
        final List<User> testUsers = new SObjectBuilder(User.sObjectType)
        .put(User.ProfileId, new SObjectFieldProviders.ProfileProvider('Standard User'))
        .count(3).build().getRecords();

        System.assertEquals(3, testUsers.size(), 'Expected 3 Users.');
    }

    @isTest
    private static void profileProviderTest2() {
        Boolean hasExFired = false;
        try {
            new SObjectBuilder(User.sObjectType)
            .put(User.ProfileId, new SObjectFieldProviders.ProfileProvider('MY USER'))
            .build();
        } catch(SObjectFieldProviders.FieldProviderException e) {
            hasExFired = true;
        }
        System.assert(hasExFired, 'Expected the Exception fired.');
    }

    @isTest
    private static void recordTypeProviderTest() {
        // Build three accounts with the "Business" record type.
        final List<Account> accounts = new SObjectBuilder(Account.sObjectType)
        .put(Account.RecordTypeId, new SObjectFieldProviders.RecordTypeProvider('IndustriesBusiness'))
        .count(3).build().getRecords();

        System.assertEquals(3, accounts.size(), 'Expected 3 Accounts.');
    }

    @isTest
    private static void pluckProviderTest() {
        // Test SObjectFieldProviders Constructor
        new SObjectFieldProviders();

        // Create 1 account with unique name.
        final List<Account> accounts = new SObjectBuilder(Account.sObjectType)
        .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider())
        .count(1).create().getRecords();
    
        // Creates 1 opportunity which have the same name as the previous account
        final List<Opportunity> opportunities = new SObjectBuilder(Opportunity.sObjectType)
        .put(Opportunity.Name, new SObjectFieldProviders.PluckProvider(Account.Name, accounts))
        .count(1).create().getRecords();

        System.assertEquals(accounts.get(0).Name, opportunities.get(0).Name, 'Expected same Names.');
    }
}