public with sharing class GetAllInformation {

    @AuraEnabled
    public static List<WrapperClass> GetFieldsInformation(String nameObject, String nameLayout){
        try {
        String fullLayout = String.format('{0}-{1}', new String[]{nameObject, nameLayout});  
        Metadata.Layout myLayout = GetLayout(fullLayout);
        List<Challenge2__c> listForSecondObject = new List<Challenge2__c>();
        Challenge__c firstObject = new Challenge__c();
        insert firstObject;
        List<Metadata.LayoutItem> itemsList = new List<Metadata.LayoutItem>();
        for (Metadata.LayoutSection  sections : myLayout.layoutSections) {
            for (Metadata.LayoutColumn  columns : sections.layoutColumns) {
                if(columns.layoutItems != null ){
                    for (Metadata.LayoutItem items : columns.layoutItems) {
                        itemsList.add(items);
                    } 
                }
            } 
        }       
        for (Metadata.LayoutItem items : itemsList) {
            Challenge2__c secondObject = new Challenge2__c();
            secondObject.Name = items.field;
            secondObject.Challenge__c = firstObject.Id;
            Schema.SObjectType leadSchema = Schema.getGlobalDescribe().get(nameObject);   
            if (leadSchema.getDescribe().fields.getMap() != null) {
                Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                if (fieldMap.get(secondObject.Name) != null) {
                    secondObject.Labels__c = fieldMap.get(secondObject.Name).getDescribe().getLabel();
                    secondObject.Type__c = String.valueOf(fieldMap.get(secondObject.Name).getDescribe().getType());
                    secondObject.ReadAccess__c = String.valueOf(fieldMap.get(secondObject.Name).getDescribe().isAccessible());
                    secondObject.EditAccess__c = String.valueOf(fieldMap.get(secondObject.Name).getDescribe().isUpdateable());
                } 
            }
            listForSecondObject.add(secondObject);
        }
        if(listForSecondObject.size() > 0){
            insert listForSecondObject;
        }
        List<WrapperClass> wrapperList = new List<WrapperClass>();
        for(Challenge2__c fieldsFromObject : [SELECT Id, Name, Labels__c, Type__c, ReadAccess__c, EditAccess__c FROM Challenge2__c WHERE Challenge__c =: firstObject.Id ORDER BY Name ASC]){
            wrapperList.add(new WrapperClass(fieldsFromObject, true, 'OK', 'false'));
        }
        return wrapperList;
        } catch (Exception e) {
            System.debug(Logginglevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Metadata.Layout GetLayout(String layoutName){
        List<String> layoutList = new List<String>{layoutName};
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            return (Metadata.Layout)components[0];
    }
    
    public class WrapperClass {
        @AuraEnabled
        public WrapperData data;
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public String state, error;

        public WrapperClass(challenge2__c data, Boolean status, String state, String error) {
            this.data = new WrapperData(data);
            this.status = status;
            this.state = state;
            this.error = error;
        }
    }

    public class WrapperData {
        @AuraEnabled
        public String name, label, type, readAccess, editAccess;

        public WrapperData (challenge2__c data) {
            this.name = data.Name;
            this.label = data.Labels__c;
            this.type = data.Type__c;
            this.readAccess = data.ReadAccess__c;
            this.editAccess = data.EditAccess__c;
        }
    }
}
