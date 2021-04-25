/** 
 * 
 */
public with sharing virtual class SObjectBuilderBase {
    /** */
    @testVisible protected final Schema.SObjectType sObjectType;
    /** */
    @testVisible protected Integer recordCount;
    /** */
    @testVisible protected String template;
    /** */
    @testVisible protected final Map<Schema.SObjectField, Object> fieldToValue;
    /** */
    @testVisible protected List<SObject> records;

    /**
     * @description 	Creates a new SObjectBuilder which can be used to generate records of the passed in type.
     * @param  			sObjectType |The SObjectType of the records this SObjectBuilder will be generating.
     * @return 			
     */
    public SObjectBuilderBase(Schema.SObjectType sObjectType) {
        this.recordCount = 1;
        this.sObjectType = sObjectType;
        this.fieldToValue = new Map<Schema.SObjectField, Object>();
    }

    /**
     * @description 		Creates a new SObjectBuilder which can be used to generate records of the passed in type and template.
     *  @param 			sObjectType The SObjectType of the records this SObjectBuilder will be generating.
     *					template The template to use when generating these records.
     * @return
     */
    public SObjectBuilderBase(Schema.SObjectType sObjectType, String template) {
        this(sObjectType);
        this.template = template;
    }

    /**
	* @description 		Gets the first record generated with the last generate call. Singular SObjects do not automatically
						cast like a List<SObject> will, so you will likely need to cast this return value. To retrieve multiple
						records, use the getRecords() method.
    * @param
    * @return 			The first record generated as an SObject.
    */
    public SObject getRecord() {
        return this.records == null || this.records.isEmpty() ? this.sObjectType.newSObject() : this.records[0];
    }

    /**
     * @description 		Gets the records generated with the last generate calls. List<SObject> will automatically cast to
	 *					whatever list you are assigning it to, so you should not need to cast it yourself. To retrieve a single
	 *					record instead, consider using the getRecord() method.
     * @param
     * @return 			The list of records generated.
     */
    public List<SObject> getRecords() {
        return (this.records == null) ? new List<SObject>() : this.records;
    }

    /**
    * @description 		
    * @param
    * @return 			
    */
    @testVisible
    protected SObjectFactoryState getState() {
        return new SObjectFactoryState(this.recordCount, this.sObjectType, this.template);
    }
}