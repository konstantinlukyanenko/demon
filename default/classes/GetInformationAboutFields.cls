public with sharing class GetInformationAboutFields {

    @AuraEnabled
    public static List<ServerRespondWrapper> getFieldsInformation(String objectName, String layoutName){
        try {
            Helper helper = new Helper();
            Metadata.Layout actualLayout = helper.getLayout(objectName, layoutName);
            List<Metadata.LayoutItem> allItemsFromLayout = helper.getItemsFromLayout(actualLayout);
            List<Challenge2__c> filledObjects = helper.createAndGetObjects(allItemsFromLayout, objectName);
            List<Challenge2__c> requestedObjects = helper.insertObjectsAndRequestTheir(filledObjects);

            List<ServerRespondWrapper> respondData = new List<ServerRespondWrapper>();
            for(Challenge2__c requestedObject : requestedObjects){
                respondData.add(new ServerRespondWrapper(requestedObject, true, 'OK', 'false'));
            }
            return respondData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class Helper{
        
        public Metadata.Layout getLayout(String objectName, String layoutName){
            String totalLayoutName = String.format('{0}-{1}', new String[]{objectName, layoutName}); 
            List<String> layoutList = new List<String>{totalLayoutName};
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, layoutList);
            return (Metadata.Layout)components[0];
        }

        public List<Metadata.LayoutItem> getItemsFromLayout(Metadata.Layout actualLayout){
            List<Metadata.LayoutItem> allItemsFromLayout = new List<Metadata.LayoutItem>();

            for (Metadata.LayoutSection  section : actualLayout.layoutSections) {
                for (Metadata.LayoutColumn  column : section.layoutColumns) {
                    if(column.layoutItems != null ){
                        for (Metadata.LayoutItem item : column.layoutItems) {
                            allItemsFromLayout.add(item);
                        } 
                    }
                } 
            } 
            return allItemsFromLayout;
        }

        public List<Challenge2__c> createAndGetObjects(List<Metadata.LayoutItem> allItemsFromLayout, String objectName){
            List<Challenge2__c> listWithChallengeObjects = new List<Challenge2__c>();

            for (Metadata.LayoutItem item : allItemsFromLayout) {
                Challenge2__c challengeObject = new Challenge2__c();
                challengeObject.Name = item.field;

                Schema.SObjectType leadSchema = Schema.getGlobalDescribe().get(objectName);   
                if (leadSchema.getDescribe().fields.getMap() != null) {

                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                    if (fieldMap.get(item.field) != null) {
                        challengeObject.Labels__c = fieldMap.get(item.field).getDescribe().getLabel();
                        challengeObject.Type__c = String.valueOf(fieldMap.get(item.field).getDescribe().getType());
                        challengeObject.ReadAccess__c = String.valueOf(fieldMap.get(item.field).getDescribe().isAccessible());
                        challengeObject.EditAccess__c = String.valueOf(fieldMap.get(item.field).getDescribe().isUpdateable());
                    } 
                }
                listWithChallengeObjects.add(challengeObject);
            }
            return listWithChallengeObjects;
        }

        public List<Challenge2__c> insertObjectsAndRequestTheir(List<Challenge2__c> filledObjects){
            Challenge__c principalObject = new Challenge__c();
            insert principalObject;

            for (Challenge2__c minorObject: filledObjects) {
                minorObject.Challenge__c = principalObject.Id;
            }
            if(filledObjects.size() > 0){
                insert filledObjects;
            }
            return [SELECT Id, Name, Labels__c, Type__c, ReadAccess__c, EditAccess__c FROM Challenge2__c WHERE Challenge__c =: principalObject.Id];
        }
    }
  
    public class ServerRespondWrapper {
        @AuraEnabled
        public WrapperData data;
        @AuraEnabled
        public Boolean status;
        @AuraEnabled
        public String state, error;

        public ServerRespondWrapper(challenge2__c data, Boolean status, String state, String error) {
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
