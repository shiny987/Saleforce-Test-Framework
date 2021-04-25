/**
 * @author Gabriele Basile
 * @date 03/2021
 * @description test cases for the SObjectFactory class
 */
@isTest
public class SObjectFactoryTest {

    @isTest
    private static void objectsCreationTest() {
        final Account record = (Account)SObjectFactory.create(Account.sObjectType, 'Business');
        System.assertNotEquals(null, record.Id);
    }

    @isTest
    private static void objectsCreationExceptionTest() {
        Boolean exFired = false;
        try {
            SObjectFactory.create(
                new SObjectFactoryState(1, Account.sObjectType, 'Business'), 
                new Map<Schema.SObjectField, Object> {
                    Account.Id => new SObjectFieldProviders.DummyIdProvider(Account.sObjectType)  
                });
        } catch(DmlException e) {
            exFired = true; 
        }

        System.assert(exFired, 'An Exception should fire.');
    }
}