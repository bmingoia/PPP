public with sharing class UnitService {

    public static void getUnitIds(Id unitId, String jsonAnswer) {

        // parseamos el jsonAnswer a un map.
        Map<Id, Id> questionsMap = (Map<Id, Id>) JSON.deserializeStrict(jsonAnswer, Map<Id, Id>.class);

        //Tengo un list que almacena los ids de mis options(respuestas de mis preguntas en list questions).
        List<Answer__c> options = New List<Answer__c>();


        //busco la unidad con el id "unitId" en la base de datos
        Unit__c unit = [SELECT module__c FROM Unit__c WHERE Id=:unitId];
        //busco el modulo relacionado con el id de unidad asociados al usuario, si no existe , signfica que es la primera pregunta , creo el UserModule
        //veo si existe el userModule , sino lo creo
        //uso userInfo.getUserId() para obtener el id del usuario actual
        UserModule__c module;
        try{
            module = [SELECT Id FROM UserModule__c WHERE Module__c = :unit.Module__c  AND User__c = :UserInfo.getUserId() AND Status__c = 'In Progress'];
            }catch (Exception e){

            module = new UserModule__c(User__c = userInfo.getUserId(),
            Module__c = unit.Module__c,
            Status__c = 'In Progress');
            insert module;
            } 
        //creo el UserUnit en estado draft
        UserUnit__c unitResp = new UserUnit__c(
            Unit__c = unitId,
            UserModule__c = module.Id,
            Status__c = 'Draft',
            User__c = UserInfo.getUserId()
            );

          //Tengo un list que almacena los ids de mis questions.
        List<UserQuestion__c> questions = New List<UserQuestion__c>();

            for(Id q : questionsMap.keySet()) {
            // Código a ejecutar para cada key del mapa
            UserQuestion__c questionKey = new UserQuestion__c(Unit__c=unitId, Question__c=q);

            questions.add(questionKey);
        }

        insert questions;
    }


    //


    @AuraEnabled(cacheable = false)
    public static TrailWrapper getTrailWrapper(Id trailId) {
        TrailWrapper wrapper = new TrailWrapper();
        
        wrapper.trail = [SELECT Name, Description__c, TotalPoints__c, TotalTime__c, TrailModule__r.timeTrailModule__c 
                FROM Trail__c 
                WHERE Id = :trailId];
        
        // Obtener los registros de Trail_Module__c que están relacionados con el trailId dado
        List<Trail_Module__c> trailModules = [SELECT Module__c FROM Trail_Module__c WHERE Trail__c = :trailId];

        List<Id> moduleIds = new List<Id>();
        for (Trail_Module__c tm : trailModules) {
            moduleIds.add(tm.Module__c);
        }

        // Obtener los módulos relacionados a través de la relación Module__c en los registros de Trail_Module__c
        //List<Module__c> modules = [SELECT Id, Name, Description__c FROM Module__c WHERE Id IN :moduleIds];
        List<Module__c> modules = [SELECT Id, Name, Description__c, (SELECT Id, Name, Time__c, Points__c FROM Units__r) FROM Module__c WHERE Id IN :moduleIds];
        wrapper.modules = modules;

        List<UserUnit__c> userUnits = [SELECT Id, Status__c, Unit__c FROM UserUnit__c WHERE Unit__c IN (SELECT Id FROM Unit__c WHERE Module__c IN :modules) AND User__c = :UserInfo.getUserId() AND Status__c = 'Success'];



        Set<Id> passedModuleIds = new Set<Id>();
        Set<Id> passedUnitIds = new Set<Id>();

        // Iterar por los registros de UserUnit__c para obtener los módulos y unidades aprobadas
        for (UserUnit__c userUnit : userUnits) {
            passedModuleIds.add(userUnit.Unit__r.Module__c); // Agregar el Id del módulo aprobado al conjunto de passedModuleIds
            passedUnitIds.add(userUnit.Unit__c); // Agregar el Id de la unidad aprobada al conjunto de passedUnitIds
        }

        wrapper.passedModuleIds = passedModuleIds;
        wrapper.passedUnitIds = passedUnitIds;
    
        wrapper.progressTrail = Math.round((100.0 * passedUnitIds.size()) / wrapper.modules.size());

        return wrapper;
    }

/*    
    @AuraEnabled(cacheable = false)    
    public static UnitWrapper getUnitWrapper(Id unitId) {
        UnitWrapper wrapper = new UnitWrapper();
    
        // Query for Unit__c record and populate wrapper.unit
        wrapper.unit = [SELECT Id, Name, Description__c FROM Unit__c WHERE Id = :unitId];
    
        // Query for related Question__c records and their related Answers__c records and populate wrapper.questions
        wrapper.questions = [SELECT Id, Name, Content__c,
            (SELECT Id, Content__c, Correct__c FROM Answers__r)
            FROM Question__c WHERE Unit__c = :unitId];
        
        System.debug(wrapper);
        return wrapper;
    }
*/

}



/*
        for (Module__c module : modules) {
            for (Unit__c unit : module.Units__r) {
                for (UserUnit__c userUnit : userUnits) {
                    if (userUnit.Unit__c == unit.Id) {
                        passedModuleIds.add(module.Id);
                        passedUnitIds.add(unit.Id);
                        break;
                    }
                }
            }
        }*/