import { LightningElement, api, wire } from 'lwc';
import getTrail from '@salesforce/apex/TrailController.getTrail';

export default class TrailView extends LightningElement {
    trailName;
    trailDescription;
    trailTime;
    trailScore;
    trailCompleted;
    progressTrail;
    modulesWrapps;

  @api recordId;
  @wire(getTrail, {trailId : '$recordId'})
  trail({data, error}){
   
      if(data){
        this.trailName = data.trail.Name;
        this.trailDescription = data.trail.Description__c;
        this.trailTime = data.trail.Trail_Time__c;
        this.trailScore = data.trail.Trail_Score__c;
        if(data.progressTrail) {this.progressTrail = data.progressTrail};
        if(data.progressTrail == 100) this.trailCompleted = true;
        if(data.modulesWrapps) this.modulesWrapps = data.modulesWrapps;
      } else if(error) {
          console.log('entramos en error', error)
      }
  }    
}   
