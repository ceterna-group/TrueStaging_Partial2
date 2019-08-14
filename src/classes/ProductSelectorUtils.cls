public with sharing class ProductSelectorUtils 
{
    public Account createAccount(String sName)
    {
    	Account acc = new Account(Name=sName);
    	return acc;
    }
    
    public Opportunity createOpportunity(String oName, Id accountId)
    {
    	 Opportunity opp = new Opportunity(Name = oName, 
    	 														AccountId=accountId, 
    	 														StageName='Closed Won', 
    	 														CloseDate=System.today(), 
    	 														Expected_Install_Month__c = 'June', 
    	 														Year__c = String.valueOf(System.today().Year())
    	 );
    	 return opp;
    }
    
    public Budget__c createBudget(Id oppId, String headline, String bType)
    {
    	Budget__c budget = new Budget__c(Opportunity__c = oppId, 
    															Headline_Information__c = headline, 
    															Budget_Type__c = bType, 
    															Description__c = 'Main stage',
    															Units__c = 1);
    	return budget;
    }
    
    public Project__c createProject(Id oppId, String eventName)
    {    	
        	Project__c proj = new Project__c(Opportunity__c=oppId, Event_Name__c=eventName);
        	return proj;
    }
    
    public Product2 createProduct(String pName, String family, String productCode, String productType)
    {
    	Product2 prod = new Product2(
          Name = pName, 
    	  Family = family, 
    	  ProductCode = productCode, 
    	  Product_Type__c =productType, 
    	  IsActive = true,
          Product_Markup__c = 1.6
        );
    	return 	prod;											
    }
    
    public PricebookEntry createPricebookEntry(Id pricebookId, Id prodId, Decimal unitPrice)
    {
    	PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prodId, UnitPrice = unitPrice, 
    																					IsActive = true, UseStandardPrice = false);
    	return standardPrice;
    }
    
    public OpportunityLineItem createOpportunityLineItem(String oppId, String budgetId, String pbeId, Decimal costprice, Decimal salesprice, Decimal quantity)
    {
    	OpportunityLineItem oppLine = new OpportunityLineItem(
            OpportunityId = oppId,
            Budget__c = budgetId,
            PricebookEntryId = pbeId,
            Quantity = quantity,
            UnitPrice = salesprice,
            New_Individual_Cost__c = costprice
        ); 
        return  oppLine;
    }
    
}