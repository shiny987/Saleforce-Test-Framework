/**
 * @author Gabriele Basile
 * @date 03/2021
 * @description test cases for the SObjectFieldProviders class
 */
@isTest
public class SObjectBuilderTest {

    @isTest
    private static void objectsCreationTest() {
        final List<Account> myAccounts = new SObjectBuilder(Account.sObjectType, 'Business')
        .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider()) // Each account will get a different name
        .count(100).create().getRecords();

        final List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType)
        .put(Opportunity.AccountId, myAccounts) // Each opportunity will be assigned a different account.
        .count(myAccounts.size()).create().getrecords();
	     
        final SObjectBuilder oliBuilder = new SObjectBuilder(OpportunityLineItem.sObjectType)
        .put(OpportunityLineItem.OpportunityId, myOpportunities)
        .put(OpportunityLineItem.UnitPrice, 100)
        .count(myOpportunities.size());
        
        final List<OpportunityLineItem> products = oliBuilder.template('Product').build().getRecords();
        final List<OpportunityLineItem> services = oliBuilder.template('Service').build().getRecords();
        final List<OpportunityLineItem> servicesCloned = oliBuilder.cloneFieldsFrom(services).getRecords();


        System.assertEquals(300, products.size()+services.size()+servicesCloned.size(), 'There should be 300 Products created.');
    }

    @isTest
    private static void objectCreationAsAdminTest() {
        System.assertNotEquals(SObjectFactory.ADMIN_USER.Id, ((Account)new SObjectBuilder(Account.sObjectType)
        .putAll(new Map<Schema.SObjectField, Object> {
            Account.Name => new SObjectFieldProviders.UniqueStringProvider()
        }).metaBuild().createAsAdmin().getRecord()).OwnerId);
    }
}
