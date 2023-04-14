public with sharing class LwcController {
    @AuraEnabled(cacheable=true)
    public static TrailWrapper getTrailWrapper(Id trailId) {
        // Llamada al método del servicio UnitService
        TrailWrapper wrapper = UnitService.getTrailWrapper(trailId);
        return wrapper;
    }


    /*
    @AuraEnabled(cacheable=true)
    public static TrailWrapper getUnitWrapper(Id unitId) {
        // Llamada al método del servicio UnitService
        TrailWrapper wrapper = UnitService.getUnitWrapper(ModuleId);
        return wrapper;
    }
    */

}