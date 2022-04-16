import { LightningElement, api, wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import NAME_FIELD from '@salesforce/schema/Trail__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Trail__c.Description__c';
import TRAILTIME_FIELD from '@salesforce/schema/Trail__c.Trail_Time__c';
import TRAILSCORE_FIELD from '@salesforce/schema/Trail__c.Trail_Score__c'; 
import getTrail from '@salesforce/apex/TrailController.getTrail';
import getTrailProgress from '@salesforce/apex/TrailController.getTrailProgress';


export default class TrailView extends LightningElement {
    
  @api recordId;

  @wire(getTrail, {trailId : '$recordId'})
  trail;        

    get name() {
    return this.trail.data? getSObjectValue(this.trail.data, NAME_FIELD) : '';
    } 

    get description() {
        return this.trail.data ? getSObjectValue(this.trail.data, DESCRIPTION_FIELD) : '';
    }

    get trailTime() {
        return this.trail.data ? getSObjectValue(this.trail.data, TRAILTIME_FIELD) : '';
    }

    get trailScore() {
        return this.trail.data ? getSObjectValue(this.trail.data, TRAILSCORE_FIELD) : '';
    }

    @wire(getTrailProgress, {trailId : '$recordId'})
    trailProgress;  

   get progress(){
    if(this.trailProgress.data > 0 && this.trailProgress.data < 100)
        return this.trailProgress.data;   
   }

   get moduleStarted() {
    if(this.trailProgress.data==0){
        return false;
        } else if(this.trailProgress.data==100){
        return true;
        }
    }
}   
