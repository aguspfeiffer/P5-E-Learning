public without sharing class TrailController {
    @AuraEnabled(cacheable=true)
    public static UnitService.TrailWrapper getTrail(Id trailId) {
        UnitService service = new UnitService();
        return service.getTrailWrapper(trailId);
    }
}
