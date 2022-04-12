trigger UnitResponses on Unit_Response__c (before update, after update) {
    if(Trigger.isBefore){
        UnitResponseTrigger.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    } else{
        UnitResponseTrigger.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}