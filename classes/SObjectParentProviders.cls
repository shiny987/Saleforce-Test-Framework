/**
 * @author Gabriele Basile
 * @date 03/2021
 * @description This is a wrapper class which contains commonly used providers that work with SObjects.
 */
public without sharing class SObjectParentProviders {
    /** */
    private static final String ERROR_NO_RESULT = 'No records were returned by this specific parent query, Query: ';
    /** */
    private static final String ERROR_NON_LOOKUP = 'Dynamic parent providers can only be used on Lookup fields. "{0}.{1}" is not a lookup.';
	
	/**
	 * @author 
	 * @description 
	 */
    public class DynamicParentProviderException extends SObjectFieldProviders.FieldProviderException {
        DynamicParentProviderException(schema.SObjectType objectType, schema.SObjectField field) {
            this(String.format(ERROR_NON_LOOKUP, new List<String>{
                String.valueOf(objectType), String.valueOf(field)
            }));
        }
    }
  
  
    /**
     * @description Provides the Id of a specific record. Used for populating lookup
     * fields to a parent object. This is most often used when using @testSetup to create data.
     */
    public virtual class SpecificParentProvider implements IFieldProvider {
        /**
         *  @description 
         */
        public String query { get; protected set; }
        
        /**
         *  @description 
         */
        public SObject record { get; protected set; }

       
        /**
        * @description      Instantiates a new SpecificParentProvider which will provide the ID of the record returned by
        * @param            query The SOQL query to use to retrieve the specific parent.
        * @return           
        */   
        public SpecificParentProvider(String query) {
            this.query = query;
        }

         /**
        * @description      Instantiates a new SpecificParentProvider which will provide the ID of the record returned by
        * @param            query The SOQL query to use to retrieve the specific parent.
        * @return           
        */
        public SpecificParentProvider(SObject record) {
            this.record = record;
        }
		
		/**
		* @description 
		* @param  
		* @return 
		*/
        public virtual Object getValue() {
            if (this.record == null) {
                final List<SObject> records = Database.query(this.query);
                if (records.isEmpty()) {
                    throw new SObjectFieldProviders.FieldProviderException(ERROR_NO_RESULT + this.query);
                }
                this.record = records[0];
            }
            return this.record.Id;
        }
    }

 
    /**
     * @description Provides the Id of a record, which is created on demand. 
     * This is generally preferred over SpecificParentProvider,
     * as it will only perform DML if requied, and does not depend 
     * on a record already existing in the database.
     */
    public virtual class GenericParentProvider implements IFieldProvider {
        /**
         *  @description 
         */
        public Schema.SObjectType sObjectType { get; protected set; }
        /**
         *  @description 
         */
        public String template { get; protected set; }
        /**
         *  @description 
         */
        public SObject record { get; protected set; }
        
        /**
         * @description Instantiates a GenericParentProvider which will create records of 
         * the given sObjectType.
         * @param   sObjectType The SObjectType of the parent record to generate.         
         * @return           
         */
        public GenericParentProvider(Schema.SObjectType sObjectType) {
            this.sObjectType = sObjectType;
        }
        
        /**
         * @description Instantiates a GenericParentProvider which will create records of 
         * the given sObjectType and uses the provided template to fill the fields value.
         * @param   sObjectType The SObjectType of the parent record to generate. 
         * @param   template The template of field to be used.        
         * @return           
         */
        public GenericParentProvider(Schema.SObjectType sObjectType, String template) {
            this(sObjectType);
            this.template = template;
        }

        /**
        * @description      
        * @param            
        * @return           
        */
        public virtual Object getValue() {
            if (this.record == null) {
                this.record = SObjectFactory.create(sObjectType, template);
            }
            return this.record.Id;
        }
    }

 
    /**
     * @description  Similar to the generic parent provider, this provider will create
     * a given number of records, and use those record Ids to populate
     * lookup fields. This is used when you want to create a certain number
     * of records, to use as the parents for records.
     */
    public virtual class MultiParentProvider extends SObjectFieldProviders.ListProvider
        implements IDynamicProvider {
        /**
         *  @description 
         */
        public List<SObject> records { get; protected set; }
        /**
         *  @description 
         */
        public Schema.SObjectType sObjectType { get; protected set; }
        /**
         *  @description 
         */
        public String template { get; protected set; }
        /**
         *  @description 
         */
        public Integer count { get; protected set; }

       /**
        * @description  Creates a new instance of a MultiParentProvider, creating a fixed number of parent records.    
        * @param    count The number of parent records to create.        
        * @return           
        */
        public MultiParentProvider(Integer count) {
            super();
            this.count = count;
        }
       
        /**
         * @description  Creates a new instance of a MultiParentProvider, creating a fixed number of parent records of
         * @param   sObjectType The SObjectType of the parent records to create.     
         * @return           
         */
        public MultiParentProvider(Schema.SObjectType sObjectType, Integer count) {
            this(count);
            this.sObjectType = sObjectType;
        }
       
       
         /**
        * @description  Creates a new instance of a MultiParentProvider, creating a fixed number of parent records of
        * @param   sObjectType The SObjectType of the parent records to create.     
        * @return           
        */
        public MultiParentProvider(Schema.SObjectType sObjectType, String template, Integer count) {
            this(sObjectType, count);
            this.template = template;
        }

         /**
        * @description  Creates a new instance of a MultiParentProvider, creating a fixed number of parent records of
        * @param   sObjectType The SObjectType of the parent records to create.     
        * @return           
        */
        public MultiParentProvider(List<SObject> records) {
            this(records.getSObjectType(), records.size());
            this.records = records;
        }
         /**
        * @description  Creates a new instance of a MultiParentProvider, creating a fixed number of parent records of
        * @param   sObjectType The SObjectType of the parent records to create.     
        * @return           
        */
        public virtual void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            if (this.sObjectType == null) {
                final List<Schema.SObjectType> lookupTypes = field.getDescribe().getReferenceTo();
                if (lookupTypes.isEmpty()) {
                    throw new DynamicParentProviderException(state.sObjectType, field);
                }
                this.sObjectType = lookupTypes[0];
            }

            if (this.records == null) {
                this.records = SObjectFactory.create(this.count, this.sObjectType, this.template);
            }

            this.values = new List<Id>(new Map<Id, SObject>(this.records).keySet());
        }
    }

 	/**
     * @description This class is the same as MultiParentProvider, except it will
     * create a unique parent for every record being created.
     */
    public virtual class UniqueParentProvider extends MultiParentProvider
        implements IDynamicProvider {
         /**
        * @description 
        * @param   
        * @return           
        */
        public UniqueParentProvider() {
            super(0);
        }

        /**
         * @description Instantiates a provider which will create records of
         *   the given sObjectType and template. If sObjectType is not
         *   specified, then it will determine which sObjectType
         *   to create based on the field it is being assigned to.
         */
        public UniqueParentProvider(Schema.SObjectType sObjectType) {
            super(sObjectType, 0);
        }

        /**
         * @description Instantiates a provider which will create records of
         *   the given sObjectType and template. If sObjectType is not
         *   specified, then it will determine which sObjectType
         *   to create based on the field it is being assigned to.
         */
        public UniqueParentProvider(Schema.SObjectType sObjectType, String template) {
            super(sObjectType, template, 0);
        }
		
		/**
        * @description 
        * @param   
        * @return           
        */
        public override void initialize(SObjectFactoryState state, Schema.SObjectField field) {
            this.count = state.count;
            super.initialize(state, field);
        }
    }

    // Legacy Methods (If Installed)
    // End Legacy Methods
}