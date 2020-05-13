import { LightningElement, wire, track, api } from 'lwc';
import getinformation from '@salesforce/apex/GetAllInformation.GetFieldsInformation';

export default class Challenge extends LightningElement {
    nameObject = 'Challenge2__c';
    nameLayout = 'Challenge2 Layout';
    @track fields;
    @track error;

    objectHandler(event) {
        this.nameObject = event.target.value;
      }
    layoutHandler(event) {
        this.nameLayout = event.target.value;
      }
    clickOnButton(){
      getinformation({ nameObject: this.nameObject ,  nameLayout: this.nameLayout } )
      .then(result => {
          this.fields = result;
      })
      .catch(error => {
          this.error = error.body.message;
      });
    }
}
