public with sharing class getAllInformation {

    @AuraEnabled
    public static List<wrapperClass> getFieldsInformation( String nameObject, String nameLayout ){
        try {

        String fullLayoutName = String.format('{0}-{1}', new String[]{nameObject, nameLayout});  

        Metadata.Layout myLayout = getLayout(fullLayoutName);

        List<challenge2__c> listForSecondObject = new List<challenge2__c>();
        challenge__c firstObject = new challenge__c();
        insert firstObject;

        List<Metadata.LayoutItem> itemsList = new List<Metadata.LayoutItem>();

        for (Metadata.LayoutSection  sections: myLayout.layoutSections ) {
            for (Metadata.LayoutColumn  columns: sections.layoutColumns) {
                if( columns.layoutItems != null ){
                    for (Metadata.LayoutItem items: columns.layoutItems) {

                        itemsList.add(items);
                    } 
                }
            } 
        }       
        
        Boolean hasReadPermission = false;
        Boolean hasEditPermission = false;
            
        for (Metadata.LayoutItem items: itemsList) {
            challenge2__c secondObject = new challenge2__c();
            secondObject.Name = items.field;
            secondObject.challenge__c = firstObject.Id;
            


            Schema.SObjectType leadSchema = Schema.getGlobalDescribe().get(nameObject);   
            if ( leadSchema.getDescribe().fields.getMap() != null) {
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            
                if ( fieldMap.get(secondObject.Name) != null) {
                    secondObject.Labels__c = fieldMap.get(secondObject.Name).getDescribe().getLabel();
                    secondObject.Type__c = String.valueOf(fieldMap.get(secondObject.Name).getDescribe().getType());
                    hasReadPermission = fieldMap.get(secondObject.Name).getDescribe().isAccessible();
                    hasEditPermission = fieldMap.get(secondObject.Name).getDescribe().isUpdateable();
                } 
            }

            secondObject.FLS__c = String.format('Read Access - {0}, Edit Access - {1}', new Boolean[]{hasReadPermission, hasEditPermission});

            listForSecondObject.add(secondObject);
        }

        if( listForSecondObject.size() > 0){
            insert listForSecondObject;
        }

        List<wrapperClass> wrapperList = new List<wrapperClass>();
        for(challenge2__c fieldsFromObject: [SELECT Id, Name, Labels__c, Type__c, FLS__c  FROM challenge2__c WHERE challenge__c =: firstObject.Id ORDER BY Name ASC ]){
            wrapperList.add(new wrapperClass(fieldsFromObject, true, 'OK', 'false'));
        }
        
        return wrapperList;

        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Metadata.Layout getLayout(String layoutName){

        List<String> layoutList = new List<String>{layoutName};
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            return (Metadata.Layout)components[0];
        }
    
    public class wrapperClass {

        @AuraEnabled
        public challenge2__c Data;
        @AuraEnabled
        public Boolean Status;
        @AuraEnabled
        public String State;
        @AuraEnabled
        public String Error;

        public wrapperClass(challenge2__c data, Boolean status, String state, String error  ) {
            this.Data = data;
            this.Status = status;
            this.State = state;
            this.Error = error;
        }

    }
}
