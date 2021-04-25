/**
 * @author Gabriele Basile
 *
 *
 * @description This class can be used as a low level API to build or create SObjects of any given type. It provides
 *       the core functionality behind SObjectBuilder, and can be used in cases where SObjectBuilder is too complicated
 *     or overkill. Similarly to SObjectBuilder, this class can accept IFieldProviders in place of primitives when
 *      assigning fields.
 */
public with sharing class SObjectFactory {
    /** */
    private final static String ID_FIELD = 'Id';
    /** */
    private static final String CREATE_ERROR = 'SObjectFactory Create failed. State: {0}, Cause: {1}';
    /**
     *  @description 
     */
    public static final User ADMIN_USER {
        get {
            if (ADMIN_USER == null) {
                ADMIN_USER = [
                    SELECT Id FROM User
                    WHERE Profile.PermissionsModifyAllData = true
                    AND IsActive = true
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
            }
            return ADMIN_USER;
        }
        private set;
    }
    /**
     * 
     */
    private SObjectFactory() {}
    
    /**
     * @description : 
     * @param :      
     * @return:      
     */
    public static SObject create(Schema.SObjectType objectType, String template) { return create(1, objectType, template)[0]; }
  
    /**
     * @description : 
     * @param :      
     * @return:      
     */
    public static List<SObject> create(Integer recordCount, Schema.SObjectType objectType, String template) {
        return create(new SObjectFactoryState(recordCount, objectType, template), null /*fieldToValue*/);
    }

    /**
     * @description description Builds and inserts one or more records using the properties defined in the SObjectFactory state
     * @param       state The FactoryState to use when creating these records.
     *              fieldToValue The map of SObjectField to Object that defines which fields are assigned to which values.
     * @return:     a List<SObject> of the records created.
     */
    public static List<SObject> create(SObjectFactoryState state, Map<Schema.SObjectField, Object> fieldToValue) {
        final List<SObject> records = build(state, fieldToValue);
        try {
            Database.insert(records);
            return records;
        } catch (DmlException ex) {
            ex.setMessage(String.format(CREATE_ERROR, new List<String>{ state.toString(), ex.getMessage() }));
            throw ex;
        }
    }

  
    /**
     * @description     Builds but does not insert one or more records using the properties defined in the SObjectFactory
     *                   state which is passed in. This method should not be called directly, and instead should only be used by theSObjectBuilder class
     * @param :         state The FactoryState to use when building these records.
     *                  fieldToValue The map of SObjectField to Object that defines which fields are assigned to which values.
     * @return:         a List<SObject> of the records built.
     */
    public static List<SObject> build(SObjectFactoryState state, Map<Schema.SObjectField, Object> fieldToValue) {
        final Map<Schema.SObjectField, Object> fieldMap = RequiredFieldsCache.get(state.sObjectType, state.template);
        if (fieldToValue != null) {
            fieldMap.putAll(fieldToValue);
        }
        initializeDynamicProviders(fieldMap, state);

        final List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < state.count; i++) {
            records.add(buildRecord(state.sObjectType, fieldMap));
        }
        return records;
    }

   
    /**
     * @description : Metabuilds a record with JSON methods, allowing typically read-only fields to be set.
     * @param :      SObjectFactoryState,Map<Schema.SObjectField, Object>
     * @return:       
     */
    public static List<SObject> metaBuild(SObjectFactoryState state, Map<Schema.SObjectField, Object> fieldToValue) {
        final System.Type recordClass = System.Type.forName(String.valueOf(state.sObjectType));

        final Map<Schema.SObjectField, Object> fieldMap = RequiredFieldsCache.get(state.sObjectType, state.template);
        if (fieldToValue != null) {
            fieldMap.putAll(fieldToValue);
        }
        initializeDynamicProviders(fieldMap, state);

        final List<SObject> records = new List<SObject>();
        for (Integer i = 0; i < state.count; i++) {
            records.add(metaBuildRecord(recordClass, fieldMap));
        }
        return records;
    }
    
    /**
     * @description : 
     * @param :     
     * @return:       
     */
    @testVisible
    private static SObject buildRecord(Schema.SObjectType sObjectType, Map<Schema.SObjectField, Object> fieldMap) {
        Id recordId;
        final SObject record = sObjectType.newSObject();
        for (Schema.SObjectField field : fieldMap.keySet()) {
            if (ID_FIELD == String.valueOf(field)) {
                recordId = (Id)handleProviders(fieldMap.get(field));
            } else {
                record.put(field, handleProviders(fieldMap.get(field)));
            }
        }

        // Id is set last to prevent a -bug- feature where setting the Id on a record will make any non-reparentable
        // master detail relationships read-only.
        record.Id = recordId;
        return record;
    }
    /**
     * @description : 
     * @param :     
     * @return:       
     */
    @testVisible
    private static SObject metaBuildRecord(System.Type sObjectType, Map<Schema.SObjectField, Object> fieldMap) {
        final Map<Schema.SObjectField, Object> metaFieldToValue = new Map<Schema.SObjectField, Object>();
        for (Schema.SObjectField field : fieldMap.keySet()) {
            metaFieldToValue.put(field, handleProviders(fieldMap.get(field)));
        }
        return (SObject)JSON.deserialize(JSON.serialize(metaFieldToValue), sObjectType);
    }
    /**
     * @description : 
     * @param :     
     * @return:       
     */
    @testVisible
    private static void initializeDynamicProviders(Map<Schema.SObjectField, Object> fieldToValue, SObjectFactoryState state) {
        Object value;
        for (Schema.SObjectField field : fieldToValue.keySet()) {
            value = fieldToValue.get(field);
            if (value != null) {
                if (value instanceof IDynamicProvider) {
                    ((IDynamicProvider)value).initialize(state, field);
                } else if (value instanceof List<Object>) {
                    fieldToValue.put(field, new SObjectFieldProviders.ListProvider((List<Object>)value));
                }
            }
        }
    }
   /**
     * @description : 
     * @param :     
     * @return:       
     */
    @testVisible
    private static Object handleProviders(Object value) {
        if (value != null) {
            if (value instanceof IFieldProvider) {
                value = ((IFieldProvider)value).getValue();
            }
            if (value instanceof SObject) {
                value = ((SObject)value).Id;
            }
        }
        return value;
    }

    // <Legacy Methods> (If Installed)
    // End Legacy Methods
}