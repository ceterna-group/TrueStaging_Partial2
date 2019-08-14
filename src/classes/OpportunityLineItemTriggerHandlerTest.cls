@isTest
private class OpportunityLineItemTriggerHandlerTest 
{
    static testMethod void testOpportunityInsert()
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
        
        Product2 prod1 = util.createProduct( 'Test product1',  'Lobour',  '1000',  'Site Labour');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        Product2 prod3 = util.createProduct( 'Test product3',  'Lobour',  '1002',  'Workshop Labour'); 
        Product2 prod4 = util.createProduct( 'Test product4',  'Lobour',  '1003',  'Workshop Labour'); 
        Product2 prod5 = util.createProduct( 'Test product5',  'Lobour',  '1004',  'Site Labour');     
        insert new List<Product2>{prod1, prod2, prod3, prod4, prod5};
        
        Id pricebookId = Test.getStandardPricebookId();    
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200); 
        PricebookEntry standardPrice3 = util.createPricebookEntry(pricebookId, prod3.Id, 300); 
        PricebookEntry standardPrice4 = util.createPricebookEntry(pricebookId, prod4.Id, 400); 
        PricebookEntry standardPrice5 = util.createPricebookEntry(pricebookId, prod5.Id, 500); 
        insert new List<PricebookEntry>{standardPrice1, standardPrice2, standardPrice3, standardPrice4, standardPrice5};    
        
        OpportunityLineItem oppLine1 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice1.Id, 100, 200, 2);
        OpportunityLineItem oppLine2 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice2.Id, 200, 300, 4);
        OpportunityLineItem oppLine3 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice3.Id, 100, 200, 1);
        OpportunityLineItem oppLine4 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice4.Id, 200, 300, 2);
        OpportunityLineItem oppLine5 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice5.Id, 200, 300, 3);
        insert new List<OpportunityLineItem> {oppLine1, oppLine2, oppLine3, oppLine4, oppLine5}; 
        
        Opportunity opp1 = [Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c from Opportunity where Id = :opp.Id];
        System.assert(opp1 != null);
        System.assertEquals(5, opp1.Total_Quantity_for_Site__c);
        System.assertEquals(3, opp1.Total_Quantity_for_Workshop__c);        
    }
    
    static testMethod void testOpportunityUpdate()
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
        
        Product2 prod1 = util.createProduct( 'Test product1',  'Lobour',  '1000',  'Site Labour');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        Product2 prod3 = util.createProduct( 'Test product3',  'Lobour',  '1002',  'Workshop Labour'); 
        Product2 prod4 = util.createProduct( 'Test product4',  'Lobour',  '1003',  'Workshop Labour'); 
        Product2 prod5 = util.createProduct( 'Test product5',  'Lobour',  '1004',  'Site Labour');     
        insert new List<Product2>{prod1, prod2, prod3, prod4, prod5};
        
        Id pricebookId = Test.getStandardPricebookId();    
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200); 
        PricebookEntry standardPrice3 = util.createPricebookEntry(pricebookId, prod3.Id, 300); 
        PricebookEntry standardPrice4 = util.createPricebookEntry(pricebookId, prod4.Id, 400); 
        PricebookEntry standardPrice5 = util.createPricebookEntry(pricebookId, prod5.Id, 500); 
        insert new List<PricebookEntry>{standardPrice1, standardPrice2, standardPrice3, standardPrice4, standardPrice5};    
        
        OpportunityLineItem oppLine1 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice1.Id, 100, 200, 2);
        OpportunityLineItem oppLine2 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice2.Id, 200, 300, 4);
        OpportunityLineItem oppLine3 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice3.Id, 100, 200, 1);
        OpportunityLineItem oppLine4 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice4.Id, 200, 300, 2);
        OpportunityLineItem oppLine5 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice5.Id, 200, 300, 3);
        insert new List<OpportunityLineItem> {oppLine1, oppLine2, oppLine3, oppLine4, oppLine5}; 
        
        Opportunity opp1 = [Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c from Opportunity where Id = :opp.Id];
        System.assert(opp1 != null);
        System.assertEquals(5, opp1.Total_Quantity_for_Site__c);
        System.assertEquals(3, opp1.Total_Quantity_for_Workshop__c);   
        
        budgetNew.Units__c = 2;
        update budgetNew;
        
        oppLine1.quantity = 5;
        update oppline1;   
        
        Opportunity opp2 = [Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c from Opportunity where Id = :opp.Id];
        System.assert(opp1 != null);
        System.assertEquals(16, opp2.Total_Quantity_for_Site__c);
        System.assertEquals(6, opp2.Total_Quantity_for_Workshop__c);   
    }
    
    static testMethod void testOpportunityDelete()
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
        
        Product2 prod1 = util.createProduct( 'Test product1',  'Lobour',  '1000',  'Site Labour');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        Product2 prod3 = util.createProduct( 'Test product3',  'Lobour',  '1002',  'Workshop Labour'); 
        Product2 prod4 = util.createProduct( 'Test product4',  'Lobour',  '1003',  'Workshop Labour'); 
        Product2 prod5 = util.createProduct( 'Test product5',  'Lobour',  '1004',  'Site Labour');     
        insert new List<Product2>{prod1, prod2, prod3, prod4, prod5};
        
        Id pricebookId = Test.getStandardPricebookId();    
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200); 
        PricebookEntry standardPrice3 = util.createPricebookEntry(pricebookId, prod3.Id, 300); 
        PricebookEntry standardPrice4 = util.createPricebookEntry(pricebookId, prod4.Id, 400); 
        PricebookEntry standardPrice5 = util.createPricebookEntry(pricebookId, prod5.Id, 500); 
        insert new List<PricebookEntry>{standardPrice1, standardPrice2, standardPrice3, standardPrice4, standardPrice5};    
        
        OpportunityLineItem oppLine1 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice1.Id, 100, 200, 2);
        OpportunityLineItem oppLine2 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice2.Id, 200, 300, 4);
        OpportunityLineItem oppLine3 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice3.Id, 100, 200, 1);
        OpportunityLineItem oppLine4 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice4.Id, 200, 300, 2);
        OpportunityLineItem oppLine5 = util.createOpportunityLineItem(opp.Id, budgetNew.Id, standardPrice5.Id, 200, 300, 3);
        insert new List<OpportunityLineItem> {oppLine1, oppLine2, oppLine3, oppLine4, oppLine5}; 
        
        Opportunity opp1 = [Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c from Opportunity where Id = :opp.Id];
        System.assert(opp1 != null);
        System.assertEquals(5, opp1.Total_Quantity_for_Site__c);
        System.assertEquals(3, opp1.Total_Quantity_for_Workshop__c);   
        
        delete new List<OpportunityLineItem> {oppLine1, oppLine4};
        
        Opportunity opp2 = [Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c from Opportunity where Id = :opp.Id];
        System.assert(opp1 != null);
        System.assertEquals(3, opp2.Total_Quantity_for_Site__c);
        System.assertEquals(1, opp2.Total_Quantity_for_Workshop__c);   
        
        delete new List<OpportunityLineItem> {oppLine5, oppLine3};
        
        Opportunity opp3 = [Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c from Opportunity where Id = :opp.Id];
        System.assert(opp1 != null);
        System.assertEquals(0, opp3.Total_Quantity_for_Site__c);
        System.assertEquals(0, opp3.Total_Quantity_for_Workshop__c);
    }
}