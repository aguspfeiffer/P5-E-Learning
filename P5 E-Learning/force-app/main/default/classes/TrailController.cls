public without sharing class TrailController {
    @AuraEnabled(cacheable=true)
    
    public static Trail__c getTrail(Id trailId) {

        UnitService service = new UnitService();
        return service.getTrailWrapper(trailId).trail;
    }
}
