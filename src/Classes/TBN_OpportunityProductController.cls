/**
* \arg ClassName      : TBN_OpportunityProductController
* \arg CreatedOn      : 2015-04-13
* \arg LastModifiedOn : 2015-03-15
* \arg CreatededBy    : Akshansh
* \arg ModifiedBy     : 
* \arg Description    : This class is the controller for TBN_OpportunityProduct Page and is used to display questions ans answers based on product group.
*/
public with sharing class TBN_OpportunityProductController 
{
    /* Start - Page Variables */
    
    public list<WrapperQuestionAnswer> lstWrapperQA  {get;set;} // The list of wrapper class for products
    public list<WrapperProduct> lstWrapperProduct	 {get;set;}	
    public Integer AnsweredQuestions    {get;set;}
    public Integer UnansweredQuestions  {get;set;}  
    /* End - Page Variables */
    
    /* Start - Class Variables*/
    list<Question__c> lstQuestions = new list<Question__c>();
    map<Id,Id> mapProductIdToPGId = new map<Id,Id>();
    map<Id,List<Id>> mapPGIdTolstOfPrdId = new map<Id,List<Id>>();
    map<Id,String> mapProdIdToProdName = new map<Id,String>();
    map<Id,List<Id>> mapPGIdTolstOfQusId = new map<Id,List<Id>>();
    map<Id,Question__c> mapQuestionIdToQuestion = new map<Id, Question__c>();
    map<Id,list<WrapperQuestionAnswer>> mapPrdIdTolstWrapperQA = new map<Id,list<WrapperQuestionAnswer>>();
    set<Id> setProductId = new set<Id>();
    
    Id opportunityId;
    List<Id> lstProductId = new List<Id>();
    list<Answer__c> lstAnswerToInsert = new list<Answer__c>(); 
    Map<Id,Id> mapPGIdToPrdId = new Map<Id,Id>();
    
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
        lstWrapperQA = new List<WrapperQuestionAnswer>();
        lstWrapperProduct = new list<WrapperProduct>();
        initialize();
        ShowQuestions();
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
    }  
    
    /*
        * MethodName   : getShowQuestions
        * Param        : 
        * Description  : This method is used to validate whether the user belongs to coverage team members of Account or not
    */
    public void ShowQuestions()
    {
        for(OpportunityLineItem objOLI : [SELECT Product2Id, Product2.Name, Product2.Product_Group__c FROM OpportunityLineItem WHERE OpportunityId =: opportunityId])
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
        
        for(Question__c objQuestion : [SELECT Questions_for_Picklist__c, Question__c, Question_Type__c, Product_Group__c, Id From Question__c WHERE Product_Group__c IN:mapPGIdTolstOfPrdId.keyset()])
        {
        	mapQuestionIdToQuestion.put(objQuestion.Id,objQuestion);
        }
        
        /*for(Product_Group__c objPrdGrp : [SELECT Id, (SELECT Id, Question_Type__c, Question__c, Questions_for_Picklist__c From Questions__r) From Product_Group__c where Id IN:mapPGIdTolstOfPrdId])
        {
        	lstQuestions.add(objPrdGrp.Questions__r);
        	if(mapPGIdTolstOfQusId.containsKey(objPrdGrp.Id))
        	{
        		mapPGIdTolstOfQusId.get(objPrdGrp.Id).add(objPrdGrp.Questions__r);	
        	}
        	else
        	{
        		mapPGIdTolstOfQusId.put(objPrdGrp.Id , new list<Id>(objPrdGrp.Questions__r));
        	}
        }*/
        
        
        for(Answer__c objAnswer : [SELECT Id,
										  Question__c, 
                                          Product__c,
                                          Answers__c,
                                          Opportunity__c 
                                     From Answer__c 
                                    WHERE Opportunity__c =: opportunityId
                                      AND Product__c IN: mapProductIdToPGId.keyset()])
        {
	    	for(Id productId : mapProductIdToPGId.keyset())
	    	{
				if(objAnswer.Product__c == productId )
				{	    		
	        		lstWrapperQA.add(new WrapperQuestionAnswer(mapQuestionIdToQuestion.get(objAnswer.Question__c),objAnswer));	
					mapPrdIdTolstWrapperQA.put(objAnswer.Product__c,lstWrapperQA);
				}
				else
					lstWrapperQA.clear();	
	    	}	/*if(mapPrdIdTolstWrapperQA.containsKey(objAnswer.Product__c))
				{
					lstWrapperQA.add(new WrapperQuestionAnswer(mapQuestionIdToQuestion.get(objAnswer.Question__c),objAnswer));	
					mapPrdIdTolstWrapperQA.get(objAnswer.Product__c).addAll(lstWrapperQA);
				}
				else
				{
					mapPrdIdTolstWrapperQA.put(objAnswer.Product__c , new lstWrapperQA<WrapperQuestionAnswer>(mapQuestionIdToQuestion.get(objAnswer.Question__c),objAnswer));  
				}*/
        }
        
        
        for(Id ProductId : mapProductIdToPGId.keyset())
        {
        	mapProdIdToProdName.get(ProductId);
        	lstWrapperProduct.add(new WrapperProduct(mapProdIdToProdName.get(ProductId), mapPrdIdTolstWrapperQA.get(ProductId)));
        	system.debug('==lstWrapperProduct='+lstWrapperProduct);
        }
		
		for(Product2 objProduct : [SELECT Id, Name, Product_Group__c  FROM Product2 WHERE Id IN: mapProductIdToPGId.keyset()])
		{
			mapPGIdToPrdId.put(objProduct.Product_Group__c, objProduct.Id);
		}
		
        for(Question__c objQus : [Select Id, Question_Type__c, Question__c, Product_Group__c From Question__c WHERE Product_Group__c IN: mapPGIdTolstOfPrdId.keyset()])
        {
            lstQuestions.add(objQus);
            mapQuestionIdToQuestion.put(objQus.Id , objQus);
        }
    }
    
    public List<SelectOption> getOptionList()
    {
        return new List<Selectoption>{new Selectoption('--None--','--None--'), new Selectoption('Easy','Easy'), new Selectoption('Normal','Normal'), new Selectoption('Difficult','Difficult')};
    }
    
    public List<Selectoption> getIsSelectedRadio()
    {
        return new List<Selectoption>{new Selectoption('Yes','Yes'), new Selectoption('No','No')};
    }
    
    /*
        * MethodName   : Cancel
        * Param        : 
        * Description  : This method is used for returning back on Company detail page.
    */
    public void save()
    {
        system.debug('======'+lstWrapperProduct);
        if(!lstWrapperProduct.isEmpty())
        {
        }
            //update lstWrapperProduct; 
        //return new Pagereference('/'+opportunityId);
    }
    
    public void onPageLoad()
    {
        map<Id,Id> mapQuestionIdToAnswerId = new map<Id,Id>();
        for(Answer__c objAnswer : [SELECT Id,
        								  Question__c
                                     From Answer__c 
                                     WHERE Opportunity__c =: opportunityId
                                       AND Product__c IN: mapProductIdToPGId.keyset()
                                       AND Question__c IN: mapQuestionIdToQuestion.keyset()])
        {
            mapQuestionIdToAnswerId.put(objAnswer.Question__c,objAnswer.Id);
        }
        
        for(Question__c objQus : [Select Id, Question_Type__c, Question__c, Product_Group__c From Question__c WHERE Product_Group__c IN: mapProductIdToPGId.values()])
        {
            if(mapQuestionIdToAnswerId.get(objQus.Id) == null)
            {
            	lstAnswerToInsert.add(new Answer__c(Question__c = objQus.Id, Product__c = mapPGIdToPrdId.get(objQus.Product_Group__c), Opportunity__c = opportunityId));
            }
        }
        insert lstAnswerToInsert;
        
        
        for(Answer__c objAnswer : [SELECT Id,
        								  Answers__c
                                     From Answer__c 
                                     WHERE Opportunity__c =: opportunityId
                                       AND Product__c IN: mapProductIdToPGId.keyset()
                                       AND Question__c IN: mapQuestionIdToQuestion.keyset()])
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
    
}