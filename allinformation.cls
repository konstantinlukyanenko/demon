public with sharing class allinformation {

    @AuraEnabled
    public static List<challenge2__c> getinfo( String obj, String lay ){
        try {
        String objlayy = obj + '-' + lay + ' ' + 'Layout';

        Metadata.Layout la = getLayout(objlayy);

        List<challenge2__c> listsecondobject = new List<challenge2__c>();
        challenge__c firstobject = new challenge__c();
        insert firstobject;

            for (Metadata.LayoutSection  sections: la.layoutSections ) {
                    for (Metadata.LayoutColumn  columns: sections.layoutColumns) {
                        if( columns.layoutItems != null ){
                            for (Metadata.LayoutItem items: columns.layoutItems) {

                                challenge2__c secondobject = new challenge2__c();
                                secondobject.Name = items.field;
                                secondobject.challenge__c = firstobject.Id;
                                
                                if ( items.behavior != null ){
                                    secondobject.fls__c = String.valueOf(items.behavior);
                                }
    
                                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                Schema.SObjectType leadSchema = schemaMap.get(obj);

                                if ( leadSchema.getDescribe().fields.getMap() != null) {
                                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
                                    if ( fieldMap.get(secondobject.Name) != null) {
                                        secondobject.labels__c = fieldMap.get(secondobject.Name).getDescribe().getLabel();
                                        secondobject.type__c = String.valueOf(fieldMap.get(secondobject.Name).getDescribe().getType());
                                    } 
                                } 
                                listsecondobject.add(secondobject);
                            }
                        } 
                    }
                
                
            }
        

        if( listsecondobject.size() > 0){
            insert listsecondobject;
        }

        return [SELECT Id, Name, labels__c, type__c, fls__c  FROM challenge2__c WHERE challenge__c =: firstobject.Id ];
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Metadata.Layout getLayout(String layoutName){

        List<String> layoutList = new List<String>{layoutName};
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            if( components.size() > 0){
                return (Metadata.Layout)components[0];
            }else {
                return null;
        }
    }
}
