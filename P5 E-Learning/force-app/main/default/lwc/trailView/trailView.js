import { LightningElement, api, wire } from 'lwc';
import getTrail from '@salesforce/apex/TrailController.getTrail';


export default class TrailView extends LightningElement {
    trailName;
    trailDescription;
    trailTime;
    trailScore;
    trailCompleted;
    progressTrail;
    modules;

  @api recordId;
  @wire(getTrail, {trailId : '$recordId'})
  trail({data, error}){
      if(data){
          console.log('DATA--> ',data)
         
        this.trailName = data.trail.Name;
        this.trailDescription = data.trail.Description__c;
        this.trailTime = data.trail.Trail_Time__c;
        this.trailScore = data.trail.Trail_Score__c;
        if(data.progressTrail) {this.progressTrail = data.progressTrail};
        if(data.progressTrail == 100) {this.trailCompleted = true};
        console.log('trailompleted--> ',this.trailCompleted)
        console.log('datamodule--> ',data.modules)
        this.modules = data.modules;
        
      } else if(error) {
          console.log('entramos en error', error)
      }
  }    
 
  //>>>>>>>>>>>>>>>>>METODOS GETTERS UTILIZANDO EL .TRAIL en EL TRAILCONTROLLER<<<<<<<<<<<<<<<<<<<<
    /* get name() {
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
    } */


    //>>>>>>>>>>>>>>>>>>>>>TRAIL PROGRESS<<<<<<<<<<<<<<<<<<<<<<<
  /*   @wire(getTrailProgress, {trailId : '$recordId'})
    trailProgress;  

   get progress(){
    if(this.trailProgress.data > 0 && this.trailProgress.data < 100)
        return this.trailProgress.data;   
   }

 */
}   
