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
    public list<WrapperProduct> lstWrapperProduct  {get;set;} // The list of wrapper class for products
    public map<Id, Product2> mapProductIdToProduct = new map<Id, Product2>();
    public List<Question__c> lstQuestions   {get;set;} // Thi list is used to store Questions and answers. 
    public list<Answer__c> lstAnswers		{get;set;}
    public Integer AnsweredQuestions    {get;set;}
    public Integer UnansweredQuestions  {get;set;}  
    /* End - Page Variables */
    
    /* Start - Class Variables*/
    Id opportunityId;
    map<Id, Question__c> mapQuestionIdToQuestion = new map<Id, Question__c>();
    List<Id> lstProductId = new List<Id>();
    List<Id> lstQuestionId = new List<Id>();
    List<Id> lstProductGroupId = new List<Id>();
    list<Answer__c> lstAnswerToInsert = new list<Answer__c>(); 
    Map<Id,Id> mapPGIdToPrdId = new Map<Id,Id>();
    
    /* End - Class Variables*/
    
	/*
       @ClassName: WrapperCompany
       @Description: Wrapper class for the Call Report Company
    */
    public class WrapperProduct
    {
        public Product2 objProduct	    								{get;set;}
        public map<Id, List<Question__c>> mapProductIdToListOfQustions	{get;set;}
    	public map<Id, Answer__c> mapQuestionIdToAnswer					{get;set;}
        
        /* Start - Constructor */
        public WrapperProduct(Product2 objProduct , map<Id, List<Question__c>> mapProductIdToListOfQustions , map<Id, Answer__c> mapQuestionIdToAnswer)
        {
            this.objProduct = objProduct;
            this.mapProductIdToListOfQustions = mapProductIdToListOfQustions;
            this.mapQuestionIdToAnswer = mapQuestionIdToAnswer;
        }
        /* End - Constructor */
    }
    
    /* Start - Constructor */
    public TBN_OpportunityProductController(ApexPages.StandardController stdController)
    {
        opportunityId = stdController.getId();
        lstAnswers = new List<Answer__c>();
        lstWrapperProduct = new List<WrapperProduct>();
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
        lstQuestions = new List<Question__c>();
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
        for(OpportunityLineItem objOLI : [SELECT Product2Id,Product2.Id ,  Product2.Product_Group__c FROM OpportunityLineItem WHERE OpportunityId =: opportunityId])
        {
            lstProductGroupId.add(objOLI.Product2.Product_Group__c);
            lstProductId.add(objOLI.Product2.Id);
        }
		
		for(Product2 objProduct : [SELECT Id, Name, Product_Group__c  FROM Product2 WHERE Id IN: lstProductId])
		{
			mapProductIdToProduct.put(objProduct.Id, objProduct);
			mapPGIdToPrdId.put(objProduct.Product_Group__c, objProduct.Id);
		}
        for(Question__c objQus : [Select Id, Question_Type__c, Question__c, Product_Group__c From Question__c WHERE Product_Group__c IN: lstProductGroupId])
        {
            lstQuestions.add(objQus);
            mapQuestionIdToQuestion.put(objQus.Id , objQus);
        }
        
        //map<Id , Question__c> mapIdToQuestions = new map<Id , Question__c>([Select Id, Question_Type__c, Question__c, Product_Group__c From Question__c WHERE Product_Group__c IN: lstProductGroupId]);
        //map<Question__c , Answer__c> mapQuestionToAnswer = new map<Question__c , Answer__c>();
        
        for(Answer__c objAnswer : [SELECT Question__c, 
        								  Question__r.Question__c,
        								  Question__r.Question_Type__c,
                                          Product__c,
                                          Product__r.Name, 
                                          Opportunity__r.Name, 
                                          Answers__c 
                                     From Answer__c 
                                     WHERE Opportunity__c =: opportunityId
                                       AND Product__c IN: lstProductId
                                       AND Question__c IN: lstQuestions])
        {
            //mapQuestionToAnswer.put(mapIdToQuestions.get(objAnswer.Question__c) , objAnswer);
            lstAnswers.add(objAnswer);
            //lstWrapperProduct.add(new WrapperProduct(mapProductIdToProduct.get(objAnswer.Product__c), (mapProductIdToListOfQustions.containsKey(objAnswer.Product__c)) ? (mapProductIdToListOfQustions.get(objAnswer.Product__c).add(mapQuestionIdToQuestion.get(objAnswer.Question__c))) : (mapProductIdToListOfQustions.put(objAnswer.Product__c, new List<Question__c>{mapQuestionIdToQuestion.get(objAnswer.Question__c)})), mapQuestionIdToAnswer.put(objAnswer.Question__c, objAnswer)));	
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
        system.debug('======'+lstQuestions);
        if(!lstQuestions.isEmpty())
            update lstQuestions; 
        //return new Pagereference('/'+opportunityId);
    }
    
    public void onPageLoad()
    {
        for(Question__c objQus : [Select Id, (Select Id From Answers__r), Question_Type__c, Question__c, Product_Group__c From Question__c WHERE Product_Group__c IN: lstProductGroupId])
        {
            if(objQus.Answers__r.isEmpty())
            {
            	lstAnswers.add(new Answer__c(Question__c = objQus.Id, Product__c = mapPGIdToPrdId.get(objQus.Product_Group__c), Opportunity__c = opportunityId));	
            }
        }
        
        for(Answer__c objAns : lstAnswers)
        {
        	if(objAns.Id == null)
        	{
        		lstAnswerToInsert.add(objAns);
        	}
        	if(objAns.Answers__c == null || objAns.Answers__c == '')
        		UnansweredQuestions = UnansweredQuestions+1;
        	else
        		AnsweredQuestions = AnsweredQuestions+1;	
        }
        insert lstAnswerToInsert;
       	
    }
    
}