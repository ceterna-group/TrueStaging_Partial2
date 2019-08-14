@isTest
private class BudgetTriggerHandlerTest 
{
	static testMethod void testBudgetUpdate()
	{
		ProductSelectorUtils util = new ProductSelectorUtils();
		Account acc = util.createAccount('Test Account');
		insert acc;
		
		Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Budget__c budgetNew = [Select Id, Opportunity__c from  Budget__c where Opportunity__c = :opp.Id limit 1];
        if(budgetNew == null)
        {
        	budgetNew = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        	insert budgetNew;
        }
        
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();    
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200); 
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};    
        
        OpportunityLineItem oppLine1 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice1.Id, 100, 200, 1);
        OpportunityLineItem oppLine2 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice2.Id, 200, 300, 1);
        insert new List<OpportunityLineItem> {oppLine1, oppLine2}; 
        
        Budget__c budget = [Select Id, Opportunity__c, Budget_Product_Total_Costs__c, Budget_Product_Total_Sales_Price__c 
        						from  Budget__c where Id = :budgetNew.Id limit 1];
        						
        System.assert(budget != null);
        //System.assertEquals(300, budget.Budget_Product_Total_Costs__c);
        //System.assertEquals(500, budget.Budget_Product_Total_Sales_Price__c);
        
        try
        {
        	budgetNew.Units__c = 2;
        	update budgetNew;
        }
        catch(Exception e)
        {
        	System.assert(false, 'update shouldnt fail');
        }
        
        Budget__c budget1 = [Select Id, Opportunity__c, Budget_Product_Total_Costs__c, Budget_Product_Total_Sales_Price__c 
        						from  Budget__c where Id = :budgetNew.Id limit 1];
        System.assert(budget1 != null);
        System.assertEquals(600, budget1.Budget_Product_Total_Costs__c);
        System.assertEquals(1000, budget1.Budget_Product_Total_Sales_Price__c);						
	}
    
}