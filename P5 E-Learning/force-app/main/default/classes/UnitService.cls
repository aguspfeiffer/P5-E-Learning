public class UnitService{
    public class CustomException extends Exception{}
    
    public static Boolean registerUnitResponse (Id unitId, String jsonAnswer){

            Savepoint sp = Database.setSavepoint();

        try{
            //Select Unit From DB
            Unit__c unit = [SELECT Module__c, (SELECT Id FROM Questions__r), (SELECT Id, Number_Tries__c FROM Units_Response__r WHERE Student_Module__r.User__c =: UserInfo.getUserId() ORDER BY Number_Tries__c DESC LIMIT 1) FROM Unit__c WHERE Id =: unitId];

            //Check If Module Resp Exist
            Student_Module__c studentMod = [SELECT Id FROM Student_Module__c WHERE Module__c =: unit.Module__c AND User__c =: Userinfo.getUserId() AND Status__c = 'In Progress'];
            
            //If not exist, I create it
            if(studentMod == null){
               studentMod = new Student_Module__c(User__c = Userinfo.getUserId(), Module__c = unit.Module__c, Status__c = 'In Progress');
                insert studentMod;      
            }          

            //Create & Insert of Unit Response
            Unit_Response__c unitResp = new Unit_Response__c(Unit__c = unitId, Student_Module__c = studentMod.Id, Stage_Unit_Response__c = 'Draft');
           
            //Add number of tries
            unitResp.Number_Tries__c = !unit.Units_Response__r.isEmpty() ? unit.Units_Response__r[0].Number_Tries__c + 1 : 1;
            insert unitResp;

            //Create & Insert of Questions Response
            Map<Id,Id> answerMap = (Map<Id,Id>)JSON.deserializeStrict(jsonAnswer, Map<Id,Id>.class);

            List<Question_Response__c> questionRespList = new List<Question_Response__c>();

            for(Question__c question : unit.Questions__r){
                if(answerMap.containsKey(question.Id)){
                    Question_Response__c questionResp = new Question_Response__c(Question__c = question.Id, Unit_Response__c = unitResp.Id, Option__c = answerMap.get(question.Id));
                questionRespList.add(questionResp);
                }else{
                    throw new CustomException('La pregunta'
                    + question.Name + 'no fue respondida y es requerida!');
                }
            
            }
            
            insert questionRespList;
        
            //Update Unit Response with a stage 'Answered' to shoot the Trigger

            unitResp.Stage_Unit_Response__c = 'Answered';
            
            update unitResp;
            
            //ES NECESARIA LA QUERY?? O PODRIMOS SOLO RETORNAR unitResp?
            return [SELECT IsCompleted__c FROM Unit_Response__c WHERE Id =: unitId].IsCompleted__c;

        }catch(Exception e){
            Database.rollback(sp);
            throw e;
        }

    }


    //>>>>>>>>>>>>>>>>>> CLASS TRAIL WRAPPER  !!<<<<<<<<<<<<<<<<<<<
    public class TrailWrapper{
        //Configuration
        public Trail__c trail;
        public List<Module__c> modules;
        
        //Transactional
        public Set<Id> passedModuleIds;
        public Set<Id> passedUnitIds;
        public Double progressTrail;

         //CONSTRUCTOR!
        public TrailWrapper(Trail__c trail, List<Module__c> modules, Set<Id> passedModuleIds, Set<Id> passedUnitIds){
            this.trail = trail;
            this.modules = modules;
            this.passedModuleIds = passedModuleIds;
            this.passedUnitIds = passedUnitIds;
            this.progressTrail = (Double) passedModuleIds.size()*100 /  (Double) modules.size();
        }
    }

    //------------------------ METHODS------------------------
    //___________________PUBLIC___________________

    public TrailWrapper getTrailWrapper(Id trailId){
            //New Instance of TrailWrapper
            TrailWrapper trailWrap = new TrailWrapper([SELECT Name, Description__c, Trail_Time__c, Trail_Score__c FROM Trail__c WHERE Id =: trailId], getModules(trailId), getModuleIdsCompleted(trailId), getUnitIdsCompleted(trailId));
    
            return trailWrap;
        }
    
    //___________________PRIVATE___________________
        private List<Module__c> getModules(Id trailId){
            //Search related modules
            List<Trail_Module__c> trailModules = [SELECT Module__c FROM Trail_Module__c WHERE Trail__c =: trailId];
            
            Set<Id> moduleIds = new Set<Id>();
            for(Trail_Module__c trailModule : trailModules){
                moduleIds.add(trailModule.Module__c);
            }
            return [SELECT Name, (SELECT Name FROM Units__r) FROM Module__c WHERE Id in : moduleIds];
        }
    
        private Set<Id> getModuleIdsCompleted(Id trailId){
            List<Student_Module__c> moduleResponses = [SELECT Module__c FROM Student_Module__c WHERE Status__c = 'Completed' AND Module__c IN : getModules(trailId) AND User__c =: Userinfo.getUserId()];
            Set<Id> completedModuleIds = new Set<Id>();
            for(Student_Module__c moduleResp : moduleResponses){
                completedModuleIds.add(moduleResp.Module__c);
            }
    
            return completedModuleIds;
        }
        private Set<Id> getUnitIdsCompleted(Id trailId){
            List<Unit_Response__c> unitResponses = [SELECT Unit__c FROM Unit_Response__c WHERE IsCompleted__c = true AND UserID__c =: Userinfo.getUserId() AND Unit__r.Module__c IN : getModules(trailId)];
            Set<Id> completedUnitIds = new Set<Id>();
            for(Unit_Response__c unitResp : unitResponses){
                completedUnitIds.add(unitResp.Unit__c);
            }
    
            return completedUnitIds;    
        }

    
    //>>>>>>>>>>>>>>>>>>>> CLASS UNIT WRAPPER  !!<<<<<<<<<<<<<<<<<<<
    public class UnitWrapper{
        //Variables
        public Unit__c unit;
        public List<Question__c> questions;

        //CONSTRUCTOR!
        public UnitWrapper(Unit__c unit, List<Question__c> questions){
            this.unit = unit;
            this.questions = questions;
        }
    }


    //------------------------ METHODS------------------------
    //___________________PUBLIC___________________
    public UnitWrapper getUnitWrapper(Id unitID){

        Unit__c unit = [SELECT Id, Name, Content__c, Time_Estimate__c, Unit_Score__c, Challenge_Type__c FROM Unit__c WHERE Id = :unitID];

        List<Question__c> listQuestions = [SELECT Id, Name, (SELECT Id, Name, Description__c,Is_Correct__c FROM Options__r) FROM Question__c WHERE Unit__c =: unitID];

        return new UnitWrapper(unit, listQuestions);
    }
}