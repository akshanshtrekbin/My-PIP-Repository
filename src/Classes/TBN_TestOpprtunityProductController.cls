/**
* \arg ClassName      : TBN_OpportunityProductController
* \arg CreatedOn      : 18/April/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Akshansh
* \arg ModifiedBy 
*/
@isTest (seeAllData=true)
private class TBN_TestOpprtunityProductController 
{
    static testMethod void myUnitTest() 
    {
		List<Question__c> lstQuestions;
		List<Answer__c> lstAnswers;
		List<Product2> lstProduct;  
		List<Product_Group__c> lstProductGrp;
		List<PricebookEntry> lstPricebookEntry;
		List<OpportunityLineItem> lstOLI;
		
		Opportunity objOpportunity = new Opportunity(Name='TestOpp1',CloseDate= Date.today(), StageName='Closed Lost');
		insert objOpportunity;
		
		RecordType paraRT = [select id,Name from RecordType where SobjectType='Question__c' and Name='Paragraph'];
		RecordType radioRT = [select id,Name from RecordType where SobjectType='Question__c' and Name='Radio'];
		
		lstProductGrp = new List<Product_Group__c>{
													new Product_Group__c(Name='TestProductGrp1'),
													new Product_Group__c(Name='TestProductGrp2')
												  };
		insert lstProductGrp;
		
		lstProduct = new List<Product2>{
									       new Product2(Name='TestProduct1', Product_Group__c=lstProductGrp[0].Id),
									       new Product2(Name='TestProduct2', Product_Group__c=lstProductGrp[0].Id),
									       new Product2(Name='TestProduct3', Product_Group__c=lstProductGrp[1].Id)
									   };
		insert lstProduct;
		
		Pricebook2 stdpb = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        if (!stdpb.isActive) {
            stdpb.isActive = true;
            update stdpb;
        }
        
        lstPricebookEntry = new List<PricebookEntry>{
        												new PricebookEntry(Pricebook2Id=stdpb.Id, Product2Id=lstProduct[0].Id, IsActive=true, UnitPrice=100.0, UseStandardPrice = false),
        												new PricebookEntry(Pricebook2Id=stdpb.Id, Product2Id=lstProduct[1].Id, IsActive=true, UnitPrice=120.0, UseStandardPrice = false)
        											};
        insert lstPricebookEntry;
        
        lstOLI = new List<OpportunityLineItem>{
        										new OpportunityLineItem(UnitPrice=100, Quantity=3, OpportunityId=objOpportunity.Id, PricebookEntryId=lstPricebookEntry[0].id),
        										new OpportunityLineItem(UnitPrice=200, Quantity=3, OpportunityId=objOpportunity.Id, PricebookEntryId=lstPricebookEntry[1].id)
        									  };
       	insert lstOLI;
        
        lstQuestions = new List<Question__c>{
        										new Question__c(Name='TestQuestion1', recordTypeId=paraRT.id, Question__c='How are You', Product_Group__c=lstProductGrp[0].Id),
        										new Question__c(Name='TestQuestion2', recordTypeId=radioRT.id, Question__c='Do you use soap' , Product_Group__c=lstProductGrp[0].Id),
        									    new Question__c(Name='TestQuestion3', recordTypeId=paraRT.id, Question__c='Do you use shampoo' , Product_Group__c=lstProductGrp[0].Id)
        									};
        insert lstQuestions;

        lstAnswers = new List<Answer__c>();
        insert lstAnswers;
        
        ApexPages.StandardController sc = new ApexPages.standardController(objOpportunity);  
        TBN_OpportunityProductController objController = new TBN_OpportunityProductController(sc);
        objController.getIsSelectedRadio();
        objController.dummy();
        objController.save();
        objController.onPageLoad();	
        List<Answer__c> lstAns = [select id, Product__c, Opportunity__c from Answer__c where Product__c IN:lstProduct AND Opportunity__c =: objOpportunity.Id AND Question__c IN:lstQuestions];
        System.assertEquals(lstAns.size(), 6);
        
    }
}