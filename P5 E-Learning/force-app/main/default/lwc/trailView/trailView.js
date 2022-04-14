import { LightningElement, api, wire } from 'lwc';
import { getSObjectValue } from '@salesforce/apex';
import NAME_FIELD from '@salesforce/schema/Trail__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/Trail__c.Description__c';
import TRAILTIME_FIELD from '@salesforce/schema/Trail__c.Trail_Time__c';
import TRAILSCORE_FIELD from '@salesforce/schema/Trail__c.Trail_Score__c'; 
import getTrail from '@salesforce/apex/TrailController.getTrail';


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
} 