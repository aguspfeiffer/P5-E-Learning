public class UnitResponseTrigger{
    public static void onBeforeUpdate(List<Unit_Response__c> unitRespList, Map<Id,Unit_Response__c> oldUnitRespMap){
        List<Unit_Response__c> answeredUnitRespList = new List<Unit_Response__c>();
        
        for(Unit_Response__c unitResp : unitRespList){
            
            if(unitResp.Stage_Unit_Response__c == 'Answered' && oldUnitRespMap.get(unitResp.Id).Stage_Unit_Response__c == 'Draft'){
                answeredUnitRespList.add(unitResp);
            }
        }
        validateAnswers(answeredUnitRespList);
    }

    public static void onAfterUpdate(List<Unit_Response__c> unitRespList, Map<Id,Unit_Response__c> oldUnitRespMap){
        List<Unit_Response__c> completedUnitRespList = new List<Unit_Response__c>();
        
        for(Unit_Response__c unitResp : unitRespList){
            
            if(unitResp.IsCompleted__c && !oldUnitRespMap.get(unitResp.Id).IsCompleted__c){
                completedUnitRespList.add(unitResp);
            }   
        }
        updateUserPoints(completedUnitRespList);
    }

    private static void updateUserPoints (List<Unit_Response__c> completedUnitRespList){
        //Recolecto UsersIDs en un SET
        Set<Id> usersIds = new Set<Id>();
       
        for(Unit_Response__c unitResp: completedUnitRespList){
            usersIds.add(unitResp.UserID__c);
        }

        //Buscamos usuarios relacionados a las units repsonses
        Map<Id, User> usersMap = new Map<Id, User>([SELECT Id, Accumulated_Score__c FROM User WHERE Id =: usersIds]);

        for(Unit_Response__c unitResp: completedUnitRespList){
            User user = usersMap.get(unitResp.UserID__c);
            user.Accumulated_Score__c += unitResp.Score__c;
        }
        update usersMap.values();
    }

    private static void validateAnswers (List<Unit_Response__c> unitRespList){

        Map<Id,Unit_Response__c> unitRespFromDbMap = new Map<Id,Unit_Response__c>([SELECT Id, Unit__r.Unit_Score__c, (SELECT Id, Option__r.Is_Correct__c FROM Questions_Response__r) FROM Unit_Response__c WHERE Id IN : unitRespList]);


        for(Unit_Response__c unitResp : unitRespList){
            Unit_Response__c unitRespFromDb = unitRespFromDbMap.get(unitResp.Id);

            unitResp.IsCompleted__c = true;
            unitResp.Stage_Unit_Response__c = 'Success';
            for (Question_Response__c questionResp : unitRespFromDb.Questions_Response__r){
                if(!questionResp.Option__r.Is_Correct__c){
                    unitResp.IsCompleted__c = false;
                    unitResp.Stage_Unit_Response__c = 'Fail';
                    break;
                }
            }

            //Seteo los puntos en caso que sea correcta
            if(unitResp.IsCompleted__c){
                if(unitResp.Number_Tries__c == 1){
                    unitResp.Score__c = unitRespFromDb.Unit__r.Unit_Score__c;
                } else if(unitResp.Number_Tries__c == 2){
                    unitResp.Score__c = unitRespFromDb.Unit__r.Unit_Score__c / 2;
                }else {
                    unitResp.Score__c = unitRespFromDb.Unit__r.Unit_Score__c / 4;
                }
            }

        }   
    }
}