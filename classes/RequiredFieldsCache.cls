/* @author 
*
*
* @description This class defines fields which are required, or very common, between different records of the same
    type. When the SObjectFactory is creating a new record, it will first get the fields and values from this class.
       This class, unlike other classes in the SObjectBuilder package, is ment to be modified. Whenever a developer
       tries to create a new record and encounters an required field exception, or a failed validation rule, an entry
       should be added to the REQUIRED_FIELDS map to prevent that error from happening.
*/
public class RequiredFieldsCache {
    /** */
    public static final String TEMPLATE_ERROR_MSG = 'The template "{0}" for {1} does not exist in RequiredFieldsCache. Please add it before using it in a test.';
    /** */
    static final Date DEFAULT_DATE = Date.today().addDays(20);
    /**
     * @description It is used to create test user for testmethod below
     * @param   template (Optional) The template for this sObjectType you want.
     * @return  Default field to value map for the given sObjectType and template.
     */
    @testVisible
    private static final Map<Schema.SObjectType, Map<Schema.SObjectField, Object>> REQUIRED_FIELDS =
        new Map<Schema.SObjectType, Map<Schema.SObjectField, Object>> {
            Account.sObjectType => new Map<Schema.SObjectField, Object> {
                Account.BillingCity => 'Jan is Awesome Town',
                Account.BillingStreet => 'Jan is Awesome Street',
                Account.BillingPostalCode => '10315'
            },
            Contact.sObjectType => new Map<Schema.SObjectField, Object> {
                Contact.LastName => new SObjectFieldProviders.UniqueStringProvider('Contact')
            },
            Lead.sObjectType => new Map<Schema.SObjectField, Object> {
                Lead.LastName => new SObjectFieldProviders.UniqueStringProvider('Lead'),
                Lead.LEAP_Preferred_Method_Contact__c => 'Email'
            },
            Event.sObjectType => new Map<Schema.SObjectField, Object> {
                Event.DurationInMinutes => 30,
                Event.ActivityDateTime => DEFAULT_DATE
            },
            Group.sObjectType => new Map<Schema.SObjectField, Object> {
                Group.Name => new SObjectFieldProviders.UniqueStringProvider('Group')
            },
            Pricebook2.sObjectType => new Map<Schema.SObjectField, Object> {
                Pricebook2.Name => new SObjectFieldProviders.UniqueStringProvider('Pricebook2')
            },
            PricebookEntry.sObjectType => new Map<Schema.SObjectField, Object> {
                PricebookEntry.Pricebook2Id => Test.getStandardPricebookId(),
                PricebookEntry.UnitPrice => 7,
                PricebookEntry.isActive => true
            },
            Product2.sObjectType => new Map<Schema.SObjectField, Object> {
                Product2.Name => new SObjectFieldProviders.UniqueStringProvider('Product2'),
                Product2.ProductCode => 'SOB',
                Product2.isActive => true
            },
            Opportunity.sObjectType => new Map<Schema.SObjectField, Object> {
                Opportunity.StageName => 'Stage',
                Opportunity.Name => new SObjectFieldProviders.UniqueStringProvider('Opportunity'),
                Opportunity.CloseDate => DEFAULT_DATE
            },
            User.sObjectType => new Map<Schema.SObjectField, Object> {
                User.IsActive => true,
                User.LastName => 'Doe',
                User.LocaleSidKey => 'en_US',
                User.LanguageLocaleKey => 'en_US',
                User.EmailEncodingKey => 'ISO-8859-1',
                User.Email => 'testxxx000@novartis.com',
                User.TimeZoneSidKey => 'America/New_York',
                User.ProfileId => new SObjectFieldProviders.ProfileProvider('System Administrator'),
                User.Alias => new SObjectFieldProviders.UniqueFixedLengthStringProvider('abc', 7),
                User.CommunityNickname => new SObjectFieldProviders.UniqueStringProvider('johndoe'),
                User.Username => new SObjectFieldProviders.UniqueStringProvider('test_xyz=exmaple@example.com')
            }
        };
    /**
     * @description It is used to create test user for testmethod below
     * @param   template (Optional) The template for this sObjectType you want.
     * @return  Default field to value map for the given sObjectType and template.
     */
    @testVisible
    private static final Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>> TEMPLATES =
        new Map<Schema.SObjectType, Map<String, Map<Schema.SObjectField, Object>>> {
            Account.sObjectType => new Map<String, Map<Schema.SObjectField, Object>> {
                'Business' => new Map<Schema.SObjectField, Object> {
                    Account.Name => new SObjectFieldProviders.UniqueStringProvider('Business'),
                    Account.RecordTypeId => new SObjectFieldProviders.RecordTypeProvider('IndustriesBusiness')
                }
            },
            OpportunityLineItem.sObjectType => new Map<String, Map<Schema.SObjectField, Object>> {
                'Service' => new Map<Schema.SObjectField, Object> {
                    OpportunityLineItem.Description => 'Service'
                },
                'Product' => new Map<Schema.SObjectField, Object> {
                    OpportunityLineItem.Description => 'Product'
                }
            }
        };
    /** */
    private RequiredFieldsCache() {}

    /**
     * @description It is used to create test user for testmethod below
     * @param   template (Optional) The template for this sObjectType you want.
     * @return  Default field to value map for the given sObjectType and template.
     */
    public static Map<Schema.SObjectField, Object> get(Schema.SObjectType sObjectType, String template) {
        final Map<Schema.SObjectField, Object> fieldToValue = REQUIRED_FIELDS.containsKey(sObjectType) ?
            REQUIRED_FIELDS.get(sObjectType).clone() : new Map<Schema.SObjectField, Object>();

        if (String.isNotBlank(template)) {
            if (TEMPLATES.containsKey(sObjectType) && TEMPLATES.get(sObjectType).containsKey(template)) {
                fieldToValue.putAll(TEMPLATES.get(sObjectType).get(template));
            } else {
                throw new RequiredFieldsCacheException(String.format(TEMPLATE_ERROR_MSG, new List<String>{ 
                    template, sObjectType.getDescribe().getName() 
                }));
            }
        }

        return fieldToValue;
    }

    /** */
    public class RequiredFieldsCacheException extends Exception { }
}