import { LightningElement, wire, track, api } from 'lwc';
import getInformationAboutFields from '@salesforce/apex/GetInformationAboutFields.getFieldsInformation';

export default class Challenge extends LightningElement {
    objectName = 'Challenge2__c';
    layoutName = 'challenge2 Layout';
    @track fields;
    @track error;

    objectNameHandler(event) {
        this.objectName = event.target.value;
      }

      layoutNameHandler(event) {
        this.layoutName = event.target.value;
      }

    clickOnButton(){
      getInformationAboutFields({objectName: this.objectName ,layoutName: this.layoutName})
      .then(result => {
          this.fields = result;
      })
      .catch(error => {
          this.error = error.body.message;
      });
    }
}
