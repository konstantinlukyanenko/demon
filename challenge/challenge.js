import { LightningElement, wire, track, api } from 'lwc';
import getinformation from '@salesforce/apex/allinformation.getinfo';


export default class Challenge extends LightningElement {
    object = 'challenge__c';
    layout = 'challenge';
    @track fields;
    @track error;

    objectHandler(event) {

        this.object = event.target.value;
      }

    layoutHandler(event) {
        this.layout = event.target.value;
      }

      clickOnButton(){
        console.log(this.object);
        getinformation({ obj: this.object ,  lay: this.layout } )
        .then(result => {
            this.fields = result;
        })
        .catch(error => {
            this.error = error.body.message;
        });
      }

}