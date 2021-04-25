/**
* @author Gabriele Basile
*
*
* @description 	This class can be used to generate one or more records of any given SObjectType, provided the
       RequiredFieldsCache class is kept up to date. This will make use of the required fields cache to get default
       values, but will allow the developer to override them as necessary. SObjectBuilder makes use of a fluid API to
       keep calls simple, yet powerful. Each call is generally terminated with a getRecord() or getRecords() call. It
       is also worth noting that SObjectBuilders can be reused, when creating multiple similar records.
 		@example
	       // Create a user to own each of these accounts.
	       User parentUser = (User)new SObjectBuilder(User.sObjectType)
           .create().getRecord();
	 
	       // Create 400 accounts, each owned by the parent user.
	       List<Account> myAccounts = new SObjectBuilder(Account.sObjectType)
           .put(Account.OwnerId, parentUser) // Each account will be owned by the parentUser
           .put(Account.Name, new SObjectFieldProviders.UniqueStringProvider()) // Each account will get a different name
           .count(400).create().getRecords();
	 
	       // Create 400 opportunities, using the 'EnterpriseOpp' template, each related to a different account.
	      List<Opportunity> myOpportunities = new SObjectBuilder(Opportunity.sObjectType, 'EnterpriseOpp')
           .put(Opportunity.AccountId, myAccounts) // Each opportunity will be assigned a different account.
           .count(myAccounts.size()).create().getrecords();
	       // Build two opportunity line items for each opportunity, both with a value of $100, using the "Product"
	       // template for one, and the "Service" template for the other.
	       SObjectBuilder oliBuilder = new SObjectBuilder(OpportunityLineItem.sObjectType)
           .put(OpportunityLineItem.OpportunityId, myOpportunities)
           .put(OpportunityLineItem.UnitPrice, 100)
           .count(myOpportunities.count());
	       List<OpportunityLineItem> products = oliBuilder.template('Product').build().getRecords();
	       List<OpportunityLineItem> services = oliBuilder.template('Service').build().getRecords();
*/
public class SObjectBuilder extends SObjectBuilderBase {
 
    /**
    * @description 		Creates a new SObjectBuilder which can be used to generate records of the passed in type.
    * @param  			sObjectType |The SObjectType of the records this SObjectBuilder will be generating.
    * @return 			
    */
    public SObjectBuilder(Schema.SObjectType sObjectType) {
        super(sObjectType);
    }

    /**
    * @description 		Creates a new SObjectBuilder which can be used to generate records of the passed in type and template.
    *  @param 			sObjectType The SObjectType of the records this SObjectBuilder will be generating.
    					template The template to use when generating these records.
    * @return
    */
    public SObjectBuilder(Schema.SObjectType sObjectType, String template) {
        super(sObjectType, template);
    }

    /**
    * @description 		Changes the number of records which will be generated to the passed in recordCount.
    * @param 			recordCount The number of records this SObjectBuilder will generate.    					
    * @return			This SObjectBuilder.
    */
    public SObjectBuilder count(Integer recordCount) {
        this.recordCount = recordCount;
        return this;
    }

    /**
     * @description     Copies all fields from the given list of records, typically used when creating an old map. This method depends on all records in the list having the same set of fields assigned.
     * @param 		    records A list of records to copy all fields from.    					
     * @return
     */
    public SObjectBuilder cloneFieldsFrom(List<SObject> records) {
        Map<String, SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        for (String field : records[0].getPopulatedFieldsAsMap().keySet()) {
            SObjectField fieldRef = fieldMap.get(field);
            this.fieldToValue.put(fieldRef, new SObjectFieldProviders.PluckProvider(fieldRef, records));
        }
        return this;
    }

    /**
     * @description 	Sets a field on each record to the passed in value. This method accepts primitives, lists (Each
     *      			record gets the next element in the list), sObjects (Uses its Id), and IFieldProviders. Any value set here
     *      			will override any value provided by the required fields cache.
     * @param 			field The SObjectField to set.
     *					value The primitive, list, sObject, or IFieldProvider to assign this field to.   					
     * @return			This SObjectBuilder.
     */
    public SObjectBuilder put(Schema.SObjectField field, Object value) {
        this.fieldToValue.put(field, value);
        return this;
    }

    /**
     * @description 	Sets multiple fields on each record to the passed in value. This method accepts primitives, lists
     *			     	(Each record gets the next element in the list), sObjects (Uses its Id), and IFieldProviders. Any value set
     *					here will override any value provided by the required fields cache.
     * @param 			fieldMap A map of SObjectField to Value, where value is a primitive, list, sObject, or IFieldProvider.
     * @return 			This SObjectBuilder.
     */
    public SObjectBuilder putAll(Map<Schema.SObjectField, Object> fieldMap) {
        this.fieldToValue.putAll(fieldMap);
        return this;
    }

    /**
    * @description 		Changes the template being used by this SObjectBuilder. Note that this does not change any of thefields assigned so far.
    * @param 			template The new template to use when generating the records.
    * @return 			This SObjectBuilder.
    */
    public SObjectBuilder template(String template) {
        this.template = template;
        return this;
    }

    /**
    * @description 		Uses the provided fields and values, plus the required fields cache to build a series of records.
          				These records will be fully set up and ready to insert, but will not be inserted into the database. To
           				retrieve the built records, call getRecord() or getRecords().
    * @param
    * @return 			This SObjectBuilder.
    */
    public SObjectBuilder build() {
        this.records = SObjectFactory.build(getState(), this.fieldToValue);
        return this;
    }

    /**
    * @description 		Uses the provided fields and values, plus the required fields cache to create a series of records.
    					These records will be fully set up and inserted into the database. To retrieve the created records, call getRecord() or getRecords().
    * @param
    * @return 			This SObjectBuilder.
    */
    public SObjectBuilder create() {
        this.records = SObjectFactory.create(getState(), this.fieldToValue);
        return this;
    }

    /**
	* @description 		Uses the provided fields and values, plus the required fields cache to create a series of records
    					as an administrator. These records will be fully set up and inserted into the database. To retrieve the
     					created records, call getRecord() or getRecords().
    * @param
    * @return 			This SObjectBuilder.
    */
    public SObjectBuilder createAsAdmin() {
        System.runAs(SObjectFactory.ADMIN_USER) {
            this.create();
        }
        return this;
    }

    /**
    * @description 		Uses the provided fields and values, plus the required fields cache to build a series of records.
    					Unlike the standard build method, metaBuild() uses JSON transformations to build the records in a way that
    					allows you to set read-only fields. This is ideal for when you need to create custom metadata records, set
    					a readonly field such as CreatedDate, or a formula field. Records built this way can not typically be inserted.
     					metaBuild() uses a lot more CPU time to run, so should only be used when necessary. To retrieve the built
    					records, call getRecord() or getRecords().
    * @param
    * @return 			This SObjectBuilder.
    */
    public SObjectBuilder metaBuild(){
        this.records = SObjectFactory.metaBuild(getState(), this.fieldToValue);
        return this;
    }

    // <Legacy Methods> (If Installed)
    // End Legacy Methods
}