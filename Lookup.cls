/**
 * @Author		:		Jitendra Zaa
 * @Date		:		4-Jul-2017
 * @Desc		:		Controller for Lookup Lightning Component
 * */
global class Lookup {

    /**
     * Returns JSON of list of ResultWrapper to Lex Components
     * @objectName - Name of SObject
     * @fld_API_Text - API name of field to display to user while searching
     * @fld_API_Val - API name of field to be returned by Lookup COmponent
     * @lim   - Total number of record to be returned
     * @fld_API_Search - API name of field to be searched
     * @searchText - text to be searched
     * */
    @AuraEnabled 
    global static String searchDB(String objectName,String fld_API_Text,String fld_API_Val,Integer lim,String fld_API_Search,String searchText ){
        
        searchText='\'%' + String.escapeSingleQuotes(searchText.trim()) + '%\'';

        
        String query = 'SELECT '+fld_API_Text+' ,'+fld_API_Val+
            			' FROM '+objectName+
            				' WHERE '+fld_API_Search+' LIKE '+searchText+ 
            			' LIMIT '+lim;
        system.debug(query);
        List<sObject> sobjList = Database.query(query);
        List<ResultWrapper> lstRet = new List<ResultWrapper>();
        system.debug(sobjList);
        for(SObject s : sobjList){
            ResultWrapper obj = new ResultWrapper();
            obj.objName = objectName;
            System.debug(fld_API_Text);
            String[] returnfields = fld_API_Text.split(',');
            system.debug(returnfields);
            String value;
            String[] subField;
            List<String> subValue = new List<String>();
            for(Integer i = 0; i < returnfields.size(); i++){
                System.debug(returnfields[i]);
                if(returnfields[i].contains('.')){
                    subField = returnfields[i].split('\\.');
                    system.debug(subField);
                    SObject subObject = s.getSObject(subField[0]);
                    if(subObject != null){
                        subField.remove(0);
                        while(subField.size() > 1){
                            subObject = subObject.getSObject(subField[0]);
                            subField.remove(0);
                        }
                        value = String.valueOf(subObject.get(subField[0]));
                    }
                }
                else{
                    System.debug(s);
                    system.debug(returnfields[i]);
                    value = String.valueOf(s.get(returnfields[i]));
                }
                if(i == 0) obj.text = value;
                else{
                    subValue.add(value);
                }        
            }
            System.debug(obj.text);
            obj.val = String.valueOf(s.get(fld_API_Val));
            obj.subText = subValue;
            lstRet.add(obj);
        } 
         return JSON.serialize(lstRet) ;
    }
    
    global class ResultWrapper{
        public String objName {get;set;}
        public String text{get;set;}
        public String[] subText{get;set;}
        public String val{get;set;}
    }
}