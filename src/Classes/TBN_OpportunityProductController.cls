/**
* \arg ClassName      : TBN_OpportunityProductController
* \arg CreatedOn      : 13/April/2015
* \arg LastModifiedOn : 18/April/2015
* \arg CreatededBy    : Akshansh
* \arg ModifiedBy     : 
* \arg Description    : This class is the controller for TBN_OpportunityProduct Page and is used to display questions ans answers based on product group.
*/
public with sharing class TBN_OpportunityProductController 
{
    /* Start - Page Variables */  
    public Integer AnsweredQuestions    				{get;set;} // The variable will store the Count of answered questions
    public Integer UnansweredQuestions  				{get;set;} // The variable will store the Count of unanswered questions
    public list<WrapperQuestionAnswer> lstWrapperQA  	{get;set;} // The list of wrapper class to store questions and answers
    public list<WrapperProduct> lstWrapperProduct	 	{get;set;} // The list of wrapper class to store product and its questions and answers    
    /* End - Page Variables */
    
    /* Start - Class Variables*/
    list<Question__c> lstQuestions = new list<Question__c>();
    map<Id,Id> mapProductIdToPGId = new map<Id,Id>();
    map<Id,List<Id>> mapPGIdTolstOfPrdId = new map<Id,List<Id>>();
    map<Id,String> mapProdIdToProdName = new map<Id,String>();
    map<Id,List<Id>> mapPGIdTolstOfQusId = new map<Id,List<Id>>();
    map<Id,List<Id>> mapPrdIdTolstOfQusId = new map<Id,List<Id>>();
    map<Id,Question__c> mapQuestionIdToQuestion = new map<Id, Question__c>();
    map<Id,list<WrapperQuestionAnswer>> mapPrdIdTolstWrapperQA = new map<Id,list<WrapperQuestionAnswer>>();
    set<Id> setProductId = new set<Id>();
    Id opportunityId;
    
    
    /* End - Class Variables*/
    
	/*
       @ClassName: WrapperCompany
       @Description: Wrapper class for the Call Report Company
    */
    public class WrapperProduct
    {
		public String strProductName	    							{get;set;}
       	public List<WrapperQuestionAnswer> lstWrapperQuesAns			{get;set;}
        
        /* Start - Constructor */
        public WrapperProduct(String strProductName, List<WrapperQuestionAnswer> lstWrapperQuesAns)  
        {
            this.strProductName = strProductName;
            this.lstWrapperQuesAns = lstWrapperQuesAns;
        }
        /* End - Constructor */
    }
    
    public class WrapperQuestionAnswer
    {
        public Question__c objQuestion	    							{get;set;}
        public Answer__c objAnswer	    								{get;set;}
        
        /* Start - Constructor */
        public WrapperQuestionAnswer(Question__c objQuestion , Answer__c objAnswer)
        {
            this.objQuestion = objQuestion;
            this.objAnswer = objAnswer;
        }
        /* End - Constructor */
    }
    
    /* Start - Constructor */
    public TBN_OpportunityProductController(ApexPages.StandardController stdController)
    {
        opportunityId = stdController.getId();
        initialize();
        fillmap();
    }
    /* End - Constructor */
    
    
    /*
        @MethodName: initialize
        @param None
        @Description: Initialize the global variables.
    */
    private void initialize()
    {
        AnsweredQuestions = 0;
        UnansweredQuestions= 0;
        lstWrapperQA = new List<WrapperQuestionAnswer>();
        lstWrapperProduct = new list<WrapperProduct>();
    }  
    
    private void fillmap()
    {
        for(OpportunityLineItem objOLI : [SELECT Product2Id, 
        										 Product2.Name, 
        										 Product2.Product_Group__c 
        									FROM OpportunityLineItem 
        								   WHERE OpportunityId =: opportunityId])
        {
            mapProductIdToPGId.put(objOLI.Product2Id,objOLI.Product2.Product_Group__c);
            mapProdIdToProdName.put(objOLI.Product2Id,objOLI.Product2.Name);
            if(mapPGIdTolstOfPrdId.containsKey(objOLI.Product2.Product_Group__c))
            {
            	mapPGIdTolstOfPrdId.get(objOLI.Product2.Product_Group__c).add(objOLI.Product2Id);
            }
            else
            {
            	mapPGIdTolstOfPrdId.put(objOLI.Product2.Product_Group__c , new list<Id>{objOLI.Product2Id});
            }
        }
        for(Question__c objQuestion : [SELECT Id, 
        									  Questions_for_Picklist__c, 
        									  Question__c, 
        									  RecordType.Name,
        									  Product_Group__c 
        							     From Question__c 
        							    WHERE Product_Group__c IN:mapPGIdTolstOfPrdId.keyset()])
        {
        	mapQuestionIdToQuestion.put(objQuestion.Id,objQuestion);
        }
        
        for(Product_Group__c objPrdGrp : [SELECT Id, 
        										(SELECT Id From Questions__r) 
        									From Product_Group__c 
        								   where Id IN:mapPGIdTolstOfPrdId.keyset()])
        {
        	lstQuestions.addAll(objPrdGrp.Questions__r);  
        	if(!objPrdGrp.Questions__r.isEmpty())
        	{
            	for(Question__c objQuestion : objPrdGrp.Questions__r)
            	{
    	        	if(mapPGIdTolstOfQusId.containsKey(objPrdGrp.Id))
    	        	{
    	        		mapPGIdTolstOfQusId.get(objPrdGrp.Id).add(objQuestion.Id);	
    	        	}
    	        	else
    	        	{
    	        		mapPGIdTolstOfQusId.put(objPrdGrp.Id , new list<Id>{objQuestion.Id});
    	        	}
            	}
            	for(Id ProductId : mapPGIdTolstOfPrdId.get(objPrdGrp.Id))
            	{
            		mapPrdIdTolstOfQusId.put(ProductId, mapPGIdTolstOfQusId.get(objPrdGrp.Id));
            	}
        	}
        }
    }
    
    /*
        * MethodName   : ShowQuestions
        * Param        : 
        * Description  : This method is used to validate whether the user belongs to coverage team members of Account or not
    */
    public void ShowQuestions()
    {
        for(Answer__c objAnswer : [SELECT Id,
										  Question__c,
                                          Product__c,
                                          Answers__c,
                                          Opportunity__c 
                                     From Answer__c 
                                    WHERE Opportunity__c =: opportunityId
                                      AND Product__c IN: mapProductIdToPGId.keyset()])
        {
            if(mapPrdIdTolstWrapperQA.containsKey(objAnswer.Product__c))
            {
			    mapPrdIdTolstWrapperQA.get(objAnswer.Product__c).add(new WrapperQuestionAnswer(mapQuestionIdToQuestion.get(objAnswer.Question__c),objAnswer));
            }
            else
            {
                mapPrdIdTolstWrapperQA.put(objAnswer.Product__c , new List<WrapperQuestionAnswer>{new WrapperQuestionAnswer(mapQuestionIdToQuestion.get(objAnswer.Question__c),objAnswer)});
            }
        }
        
        for(Id ProductId : mapProductIdToPGId.keyset())
        {
        	mapProdIdToProdName.get(ProductId);
        	lstWrapperProduct.add(new WrapperProduct(mapProdIdToProdName.get(ProductId), mapPrdIdTolstWrapperQA.get(ProductId)));
        }
		
        for(Question__c objQus : [Select Id, RecordType.Name, Questions_for_Picklist__c, Question__c, Product_Group__c From Question__c WHERE Product_Group__c IN: mapPGIdTolstOfPrdId.keyset()])
        {
            mapQuestionIdToQuestion.put(objQus.Id , objQus);
        }
    }

    public List<Selectoption> getIsSelectedRadio()
    {
        return new List<Selectoption>{new Selectoption('Yes','Yes'), new Selectoption('No','No')};
    }
    
    /*
        * MethodName   : save
        * Param        : 
        * Description  : This method will save all the records of answer
    */
    public void save()
    {
        list<WrapperQuestionAnswer> lstQAToUpdate =	new list<WrapperQuestionAnswer>(); 
        set<Answer__c> setAnswers = new set<Answer__c>();
        list<Answer__c> lstAnswersToUpdate = new list<Answer__c>();
        if(!lstWrapperProduct.isEmpty())
        {
        	for(WrapperProduct objWrapperProduct : lstWrapperProduct)
        	{
        		if(objWrapperProduct.lstWrapperQuesAns != null)
        		lstQAToUpdate.addAll(objWrapperProduct.lstWrapperQuesAns);
        	}
        }
        for(WrapperQuestionAnswer objWrapperQA : lstQAToUpdate)	
    	{
    		setAnswers.add(objWrapperQA.objAnswer);
    	}
    	if(!setAnswers.isEmpty())
    	{
			lstAnswersToUpdate.addAll(setAnswers);    		
    		update lstAnswersToUpdate;
    	}
    }
    
    /*
        * MethodName   : onPageLoad
        * Param        : 
        * Description  : This method will call on pageload and is used to call ShowQuestions function 
    */
    public void dummy()
    {
        ShowQuestions();
    }
    /*
        * MethodName   : onPageLoad
        * Param        : 
        * Description  : This method will create answer records of unanswered question and leave its answer field as blank
    */
    public void onPageLoad()
    {
        UnansweredQuestions = 0;
        AnsweredQuestions = 0;
        list<Answer__c> lstAnswerToInsert = new list<Answer__c>(); 
        set<string> setUniqueAns = new set<string>();
        try
        {
            for(Answer__c objAnswer : [SELECT Id,
            								  Question__c,
            								  Product__c,
            								  Opportunity__c
                                         From Answer__c 
                                        WHERE Opportunity__c =: opportunityId
                                          AND Product__c IN: mapProductIdToPGId.keyset()
                                          AND Question__c IN: mapQuestionIdToQuestion.keyset()])
            {
                setUniqueAns.add(objAnswer.Question__c + '_' + objAnswer.Product__c + '_' + objAnswer.Opportunity__c);
            }
            
            for(Id productId : mapPrdIdTolstOfQusId.keyset())
            {
            	for(Question__c objQus : [Select Id, Question__c, RecordType.Name, Product_Group__c From Question__c WHERE Id IN: mapPrdIdTolstOfQusId.get(productId)])
            	{
                	if(!setUniqueAns.contains(objQus.Id + '_' + productId + '_'+ opportunityId) )	
                	{
                		lstAnswerToInsert.add(new Answer__c(Question__c = objQus.Id, Product__c = productId, Opportunity__c = opportunityId));
                	}
            	}
            }
            insert lstAnswerToInsert;	
            
            for(Answer__c objAnswer : [SELECT Id,
            								  Answers__c
                                         From Answer__c 
                                        WHERE Opportunity__c =: opportunityId
                                          AND Product__c IN: mapPrdIdTolstOfQusId.keyset()
                                          AND Question__c IN: lstQuestions])
            {
            	if(objAnswer.Answers__c == null || objAnswer.Answers__c == '')
            	{
            		UnansweredQuestions = UnansweredQuestions+1;
            	}
            	else
            	{
            		AnsweredQuestions = AnsweredQuestions+1;
            	}	
            }
        }
        catch(Exception ex)
        {
            System.debug('=================='+ex.getMessage()+'=============='+ex.getLineNumber());
        }
    }
    
}