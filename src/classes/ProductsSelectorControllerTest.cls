@isTest
private class ProductsSelectorControllerTest 
{
    static testMethod void testGetProductsWithoutProducts()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
        
        
    	Account acc = util.createAccount('Test Account');
        insert acc;
        
        Opportunity opp =  util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Project__c pro = util.createProject(opp.Id, 'Event');
        insert pro;
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
        
        Id pricebookId = Test.getStandardPricebookId();   
        
        OpportunityLineItem oli = util.createOpportunityLineItem(opp.Id, budget.Id, pricebookId, 1, 1, 1);
        
        
                
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);
        
        Test.startTest();
            List<ProductsSelectorController.Products> prodList = ProductsSelectorController.getProducts();
        Test.stopTest();
        
        System.assertEquals(0, prodList.size());
    }
    static testMethod void testGetProductsWithStandardPrice()
    {
        insert new StandardMarkUp__c(Name='markup', MarkUp__c=2.0);
        
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
        
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
                
        Product2 prod = util.createProduct( 'Test product',  'Materials',  '1000',  'Standard Timber & Panels');
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();        
        
        PricebookEntry standardPrice = util.createPricebookEntry(pricebookId, prod.Id, 1000);
        insert standardPrice;       
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);
        
        Test.startTest();
            List<ProductsSelectorController.Products> prodList = ProductsSelectorController.getProducts();
        Test.stopTest();
        
        System.assertEquals(1, prodList.size());
        
        System.assertEquals(prod.Id, prodList[0].prodId);
        System.assertEquals(standardPrice.Id, prodList[0].pricebookEntryId);
        System.assertEquals(prod.Name, prodList[0].prodName);
        System.assertEquals(prod.Family, prodList[0].prodFamily);
        System.assertEquals(prod.Product_Type__c, prodList[0].prodType);
        System.assertEquals(1000, prodList[0].standardPrice);        
    }
    
    static testMethod void testGetProductsWithOutStandardPrice()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
        
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
                
        Product2 prod = util.createProduct( 'Test product',  'Materials',  '1000',  'Standard Timber & Panels');
        insert prod;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);
        
        Test.startTest();
            List<ProductsSelectorController.Products> prodList = ProductsSelectorController.getProducts();
        Test.stopTest();
        
        System.assertEquals(0, prodList.size());
    }
    
    static testMethod void testCreateOppLineItem()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
        
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
                
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();        
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);  
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};        
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.unitPrice = 1000;  
            oppProd1.isDeleted = false;  
            oppProd1.lineDescription = 'Miscellanous products';      
        
        ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 5;
            oppProd2.unitPrice = 2000;        
            oppProd2.isDeleted = false;        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
        System.assertEquals('completed', resString);
        
        List<OpportunityLineItem>savedOppProds = [Select o.Description, o.UnitPrice, o.TotalPrice, o.Quantity, o.Product2Id, o.PricebookEntryId, o.OpportunityId, o.ListPrice, o.Budget__c From OpportunityLineItem o];
        System.assertEquals(2, savedOppProds.size());
        for(OpportunityLineItem oli : savedOppProds)
        {
            if(oli.Product2Id == prod1.Id)
            {
                System.assertEquals(budgetNew.Id, oli.Budget__c);
                System.assertEquals(standardPrice1.Id, oli.PricebookEntryId);
                System.assertEquals(opp.Id, oli.OpportunityId);
                System.assertEquals(prod1.Id, oli.Product2Id);
                System.assertEquals(10, oli.Quantity);
                System.assertEquals(1000, oli.UnitPrice);
                System.assertEquals(100, oli.ListPrice);
                System.assertEquals(10000, oli.TotalPrice);
                System.assertEquals('Miscellanous products', oli.Description);
            }
            
            if(oli.Product2Id == prod2.Id)
            {
                System.assertEquals(budgetNew.Id, oli.Budget__c);
                System.assertEquals(standardPrice2.Id, oli.PricebookEntryId);
                System.assertEquals(opp.Id, oli.OpportunityId);
                System.assertEquals(prod2.Id, oli.Product2Id);
                System.assertEquals(5, oli.Quantity);
                System.assertEquals(2000, oli.UnitPrice);
                System.assertEquals(200, oli.ListPrice);
                System.assertEquals(10000, oli.TotalPrice);
            }
        }
    }
    
    static testMethod void testCreateOppLineItemWithExistingOppProducts()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
        
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
                
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();        
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100);  
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200); 
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};    
        
        OpportunityLineItem oppLine = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Budget__c = budgetNew.Id,
            PricebookEntryId = standardPrice1.Id,
            Quantity = 5,
            UnitPrice = 50,
            Description  = 'misc product'
        );  
        insert oppLine;
                
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.unitPrice = 1000;
            oppProd1.isDeleted = false;
            oppProd1.lineDescription = 'misc product';
        
        
        ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 5;
            oppProd2.unitPrice = 2000;
            oppProd2.isDeleted = false;
        
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
        System.assertEquals('completed', resString);
        
        List<OpportunityLineItem>savedOppProds = [Select o.Description, o.UnitPrice, o.TotalPrice, o.Quantity, o.Product2Id, o.PricebookEntryId, o.OpportunityId, o.ListPrice, o.Budget__c From OpportunityLineItem o];
        System.assertEquals(2, savedOppProds.size());
        for(OpportunityLineItem oli : savedOppProds)
        {
            if(oli.Product2Id == prod1.Id)
            {
                System.assertEquals(budgetNew.Id, oli.Budget__c);
                System.assertEquals(standardPrice1.Id, oli.PricebookEntryId);
                System.assertEquals(opp.Id, oli.OpportunityId);
                System.assertEquals(prod1.Id, oli.Product2Id);
                System.assertEquals(10, oli.Quantity);
                System.assertEquals(1000, oli.UnitPrice);
                System.assertEquals(100, oli.ListPrice);
                System.assertEquals(10000, oli.TotalPrice);
                System.assertEquals('misc product', oli.Description);
            }
            
            if(oli.Product2Id == prod2.Id)
            {
                System.assertEquals(budgetNew.Id, oli.Budget__c);
                System.assertEquals(standardPrice2.Id, oli.PricebookEntryId);
                System.assertEquals(opp.Id, oli.OpportunityId);
                System.assertEquals(prod2.Id, oli.Product2Id);
                System.assertEquals(5, oli.Quantity);
                System.assertEquals(2000, oli.UnitPrice);
                System.assertEquals(200, oli.ListPrice);
                System.assertEquals(10000, oli.TotalPrice);
            }
        }
    }
    
    static testMethod void testGetExistingOppProductsForBudget()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
        
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
                
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Test product2',  'Materials',  '1001',  'Standard Timber & Panels');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();    
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200); 
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};    
        
        OpportunityLineItem oppLine = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Budget__c = budgetNew.Id,
            PricebookEntryId = standardPrice1.Id,
            Quantity = 5,
            UnitPrice = 110,
            New_Individual_Cost__c = 110,
            Description = 'Misc prod1'
        );  
        
        OpportunityLineItem oppLine1 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Budget__c = budgetNew.Id,
            PricebookEntryId = standardPrice2.Id,
            Quantity = 10,
            UnitPrice = 200,
            New_Individual_Cost__c = 200,
            Description = 'Misc prod2'
        );  
        insert new List<OpportunityLineItem> {oppLine, oppLine1}; 
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            List<ProductsSelectorController.OppProducts> oppProds = ProductsSelectorController.getExistingOppProductsForBudget(budgetNew.Id);
        Test.stopTest();
        
        System.assertEquals(2, oppProds.size());
        for(ProductsSelectorController.OppProducts oli : oppProds)
        {
            if(oli.productId == prod1.Id)
            {
                System.assertEquals(standardPrice1.Id, oli.pricebookEntryId);
                System.assertEquals(opp.Id, oli.opportunityId);
                System.assertEquals(prod1.Id, oli.productId);
                System.assertEquals(5, oli.quantity);
                System.assertEquals(110, oli.unitPrice); 
                System.assertEquals(1.0, oli.markup);
                System.assertEquals(550, oli.totalPrice);
                System.assertEquals(prod1.Name, oli.productName);
                System.assertEquals('Misc prod1', oli.lineDescription);
            }
            
            if(oli.productId == prod2.Id)
            {
                System.assertEquals(standardPrice2.Id, oli.pricebookEntryId);
                System.assertEquals(opp.Id, oli.opportunityId);
                System.assertEquals(prod2.Id, oli.productId);
                System.assertEquals(10, oli.quantity);
                System.assertEquals(200, oli.unitPrice);
                System.assertEquals(1.0, oli.markup);
                System.assertEquals(2000, oli.totalPrice);
                System.assertEquals(prod2.Name, oli.productName);
                System.assertEquals('Misc prod2', oli.lineDescription);
            }
        }       
    }
    
    static testMethod void testNewSiteCrew()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
                
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Project__c proj = [Select Id from Project__c where Opportunity__c = :opp.Id limit 1]; 
        
        if(proj == null)
        {        
        	 proj = util.createProject(opp.Id, 'Test Opp');
        	insert proj;
        }
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];                        
        
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Crew Chief',  'Labour',  '1001',  'Site Labour');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();      
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);         
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};      
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.productName = 'Test product1';
            oppProd1.productType = 'Standard Timber & Panels';
            oppProd1.productFamily = 'Materials';
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.markup = 1.0; 
            oppProd1.unitPrice = 110;  
            oppProd1.totalPrice = 110; 
            oppProd1.isDeleted = false;        
                        
        ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.productName = 'Crew Chief';
            oppProd2.productType = 'Site Labour';
            oppProd2.productFamily = 'Labour';
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 5;
            oppProd2.markup = 1.0; 
            oppProd2.unitPrice = 200;    
            oppProd2.totalPrice = 200; 
            oppProd2.isDeleted = false;       
                    
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
     /*    List<OpportunityLineItem> savedOppProds = [Select Id From OpportunityLineItem o];
        System.assertEquals(2, savedOppProds.size());
        
        List<Workshop_Site_Crew__c> siteCrewList = [Select Id, Crew_Role__c, Days__c, Labour_Type__c, ProductId__c, Project__c, Rate__c from Workshop_Site_Crew__c];
        System.assertEquals(1, siteCrewList.size());
        System.assertEquals('Crew Chief', siteCrewList[0].Crew_Role__c);
        System.assertEquals(5, siteCrewList[0].Days__c);
        System.assertEquals(200, siteCrewList[0].Rate__c);
        System.assertEquals(prod2.Id, siteCrewList[0].ProductId__c);*/
    }
    
    static testMethod void testForExistingSiteCrew()
    {
    	ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
                
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;       
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
        
        Project__c proj = [Select Id from Project__c where Opportunity__c = :opp.Id limit 1]; 
        
        if(proj == null)
        {        
        	 proj = util.createProject(opp.Id, 'Test Opp');
        	insert proj;
        }
                        
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Crew Chief',  'Labour',  '1001',  'Site Labour');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();      
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);         
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};      
        
        Workshop_Site_Crew__c existingSC = new Workshop_Site_Crew__c(Days__c=2, Labour_Type__c = 'Site Labour', Project__c = proj.Id, Rate__c=200, ProductId__c=prod2.Id, Crew_Role__c='Crew Chief');
        insert existingSC;
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.productName = 'Test product1';
            oppProd1.productType = 'Standard Timber & Panels';
            oppProd1.productFamily = 'Materials';
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.markup = 1.0; 
            oppProd1.unitPrice = 110;  
            oppProd1.totalPrice = 110; 
            oppProd1.isDeleted = false;        
                        
        ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.productName = 'Crew Chief';
            oppProd2.productType = 'Site Labour';
            oppProd2.productFamily = 'Labour';
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 5;
            oppProd2.markup = 1.0; 
            oppProd2.unitPrice = 200;    
            oppProd2.totalPrice = 200; 
            oppProd2.isDeleted = false;         
                    
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
       /*  List<OpportunityLineItem> savedOppProds = [Select Id From OpportunityLineItem o];
        System.assertEquals(2, savedOppProds.size());
        
        List<Workshop_Site_Crew__c> siteCrewList = [Select Id, Crew_Role__c, Days__c, Labour_Type__c, ProductId__c, Project__c, Rate__c from Workshop_Site_Crew__c];
        System.assertEquals(1, siteCrewList.size());
        System.assertEquals('Crew Chief', siteCrewList[0].Crew_Role__c);
        System.assertEquals(5, siteCrewList[0].Days__c);
        System.assertEquals(200, siteCrewList[0].Rate__c);
        System.assertEquals(prod2.Id, siteCrewList[0].ProductId__c);*/
    }
    
    static testMethod void testDeletionOfExistingSiteCrew()
    {
    	ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
                
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;       
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
        
        Project__c proj = [Select Id from Project__c where Opportunity__c = :opp.Id limit 1]; 
        
        if(proj == null)
        {        
        	 proj = util.createProject(opp.Id, 'Test Opp');
        	insert proj;
        } 
                       
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'Crew Chief',  'Labour',  '1001',  'Site Labour');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();      
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);        
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};      
        
        Workshop_Site_Crew__c existingSC = new Workshop_Site_Crew__c(Days__c=10, Labour_Type__c = 'Site Labour', Project__c = proj.Id, Rate__c=200, ProductId__c=prod2.Id, Crew_Role__c='Crew Chief');
        insert existingSC;
        
        OpportunityLineItem oppLine1 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Budget__c = budgetNew.Id,
            PricebookEntryId = standardPrice2.Id,
            Quantity = 10,
            UnitPrice = 110
        );  
        insert oppLine1; 
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.productName = 'Test product1';
            oppProd1.productType = 'Standard Timber & Panels';
            oppProd1.productFamily = 'Materials';
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.markup = 1.0; 
            oppProd1.unitPrice = 110;  
            oppProd1.totalPrice = 110; 
            oppProd1.isDeleted = false; 
            
            ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.productName = 'Crew Chief';
            oppProd2.productType = 'Site Labour';
            oppProd2.productFamily = 'Labour';
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 10;
            oppProd2.markup = 1.0; 
            oppProd2.unitPrice = 200;  
            oppProd2.totalPrice = 200; 
            oppProd2.isDeleted = true;        
        
                    
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
        List<Workshop_Site_Crew__c> siteCrewList = [Select Id, Crew_Role__c, Days__c, Labour_Type__c, ProductId__c, Project__c, Rate__c from Workshop_Site_Crew__c];
        //System.assertEquals(0, siteCrewList.size());
    }
    
    static testMethod void testNewRentalAllocation()
    {
        ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
                
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;
        
        Project__c proj = [Select Id from Project__c where Opportunity__c = :opp.Id limit 1]; 
        
        if(proj == null)
        {        
        	 proj = util.createProject(opp.Id, 'Test Opp');
        	insert proj;
        }
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];                        
        
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'True Deck 2000mm x 500mm',  'Rental',  '1001',  'Rental Stock');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();      
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);         
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};      
        
        Rental_Kit__c rentalKit = new Rental_Kit__c(Name = 'True Deck 2000mm x 500mm', Stock_Level__c=10, Rental_Category__c='ACCESSORIES',
        																		Rental_Sub_Category__c='ACCESSORIES');
        insert rentalKit;
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.productName = 'Test product1';
            oppProd1.productType = 'Standard Timber & Panels';
            oppProd1.productFamily = 'Materials';
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.markup = 1.0; 
            oppProd1.unitPrice = 110;  
            oppProd1.totalPrice = 110; 
            oppProd1.isDeleted = false;        
                        
        ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.productName = 'True Deck 2000mm x 500mm';
            oppProd2.productType = 'Rental Stock';
            oppProd2.productFamily = 'Rental';
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 5;
            oppProd2.markup = 1.0; 
            oppProd2.unitPrice = 200;    
            oppProd2.totalPrice = 200; 
            oppProd2.isDeleted = false;       
                    
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
         List<OpportunityLineItem> savedOppProds = [Select Id From OpportunityLineItem o];
        System.assertEquals(2, savedOppProds.size());
        
        List<Rental_Kit_Allocation__c> rentalAllocationList = [Select Id, ProductId__c, Project__c, Quantity__c, Rental_Kit__c from Rental_Kit_Allocation__c];
        System.assertEquals(1, rentalAllocationList.size());
        System.assertEquals(rentalKit.Id, rentalAllocationList[0].Rental_Kit__c);
        System.assertEquals(5, rentalAllocationList[0].Quantity__c);
        System.assertEquals(proj.Id, rentalAllocationList[0].Project__c);
        System.assertEquals(prod2.Id, rentalAllocationList[0].ProductId__c);
    }
    
    static testMethod void testForExistingRentalKitAllocation()
    {
    	ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
                
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;       
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
        
        Project__c proj = [Select Id from Project__c where Opportunity__c = :opp.Id limit 1]; 
        
        if(proj == null)
        {        
        	 proj = util.createProject(opp.Id, 'Test Opp');
        	insert proj;
        }
                        
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'True Deck 2000mm x 500mm',  'Rental',  '1001',  'Rental Stock');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();           
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);         
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};      
        
        Rental_Kit__c rentalKit = new Rental_Kit__c(Name = 'True Deck 2000mm x 500mm', Stock_Level__c=10, Rental_Category__c='ACCESSORIES',
        																		Rental_Sub_Category__c='ACCESSORIES');
        insert rentalKit;
        
        Rental_Kit_Allocation__c rentalKitAllocation = new Rental_Kit_Allocation__c(ProductId__c = prod2.Id, Rental_Kit__c = rentalKit.Id, Project__c = proj.Id, Quantity__c = 3);
        insert rentalKitAllocation;
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.productName = 'Test product1';
            oppProd1.productType = 'Standard Timber & Panels';
            oppProd1.productFamily = 'Materials';
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.markup = 1.0; 
            oppProd1.unitPrice = 110;  
            oppProd1.totalPrice = 110; 
            oppProd1.isDeleted = false;        
                        
        ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.productName = 'True Deck 2000mm x 500mm';
            oppProd2.productType = 'Rental Stock';
            oppProd2.productFamily = 'Rental';
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 5;
            oppProd2.markup = 1.0; 
            oppProd2.unitPrice = 200;    
            oppProd2.totalPrice = 200; 
            oppProd2.isDeleted = false;         
                    
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
         List<OpportunityLineItem> savedOppProds = [Select Id From OpportunityLineItem o];
        System.assertEquals(2, savedOppProds.size());
        
        List<Rental_Kit_Allocation__c> rentalAllocationList = [Select Id, ProductId__c, Project__c, Quantity__c, Rental_Kit__c from Rental_Kit_Allocation__c];
        System.assertEquals(1, rentalAllocationList.size());
        System.assertEquals(rentalKit.Id, rentalAllocationList[0].Rental_Kit__c);
        System.assertEquals(5, rentalAllocationList[0].Quantity__c);
        System.assertEquals(proj.Id, rentalAllocationList[0].Project__c);
        System.assertEquals(prod2.Id, rentalAllocationList[0].ProductId__c);
    }
    
    static testMethod void testDeletionForExistingRentalKitAllocation()
    {
    	ProductSelectorUtils util = new ProductSelectorUtils();
    	Account acc = util.createAccount('Test Account');
        insert acc;
                
        Opportunity opp = util.createOpportunity('Test Opp', acc.Id);
        insert opp;       
        
        Budget__c budget = util.createBudget(opp.Id, 'Centre Stage', 'Construction');
        insert budget;
        Budget__c budgetNew = [Select Id from  Budget__c limit 1];
        
        Project__c proj = [Select Id from Project__c where Opportunity__c = :opp.Id limit 1]; 
        
        if(proj == null)
        {        
        	 proj = util.createProject(opp.Id, 'Test Opp');
        	insert proj;
        }
                        
        Product2 prod1 = util.createProduct( 'Test product1',  'Materials',  '1000',  'Standard Timber & Panels');       
        Product2 prod2 = util.createProduct( 'True Deck 2000mm x 500mm',  'Rental',  '1001',  'Rental Stock');
        insert new List<Product2>{prod1, prod2};
        
        Id pricebookId = Test.getStandardPricebookId();           
        
        PricebookEntry standardPrice1 = util.createPricebookEntry(pricebookId, prod1.Id, 100); 
        PricebookEntry standardPrice2 = util.createPricebookEntry(pricebookId, prod2.Id, 200);         
        insert new List<PricebookEntry>{standardPrice1, standardPrice2};      
        
        Rental_Kit__c rentalKit = new Rental_Kit__c(Name = 'True Deck 2000mm x 500mm', Stock_Level__c=10, Rental_Category__c='ACCESSORIES',
        																		Rental_Sub_Category__c='ACCESSORIES');
        insert rentalKit;
        
        Rental_Kit_Allocation__c rentalKitAllocation = new Rental_Kit_Allocation__c(ProductId__c = prod2.Id, Rental_Kit__c = rentalKit.Id, Project__c = proj.Id, Quantity__c = 10);
        insert rentalKitAllocation;
        
        OpportunityLineItem oppLine1 = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Budget__c = budgetNew.Id,
            PricebookEntryId = standardPrice2.Id,
            Quantity = 10,
            UnitPrice = 110
        );  
        insert oppLine1; 
        
        ProductsSelectorController.OppProducts oppProd1 = new ProductsSelectorController.OppProducts();
            oppProd1.budgetId = budgetNew.Id;
            oppProd1.productId = prod1.Id;
            oppProd1.productName = 'Test product1';
            oppProd1.productType = 'Standard Timber & Panels';
            oppProd1.productFamily = 'Materials';
            oppProd1.pricebookEntryId = standardPrice1.Id;
            oppProd1.opportunityId = opp.Id;
            oppProd1.quantity = 10;
            oppProd1.markup = 1.0; 
            oppProd1.unitPrice = 110;  
            oppProd1.totalPrice = 110; 
            oppProd1.isDeleted = true;  
            
          ProductsSelectorController.OppProducts oppProd2 = new ProductsSelectorController.OppProducts();
            oppProd2.budgetId = budgetNew.Id;
            oppProd2.productId = prod2.Id;
            oppProd2.productName = 'True Deck 2000mm x 500mm';
            oppProd2.productType = 'Rental Stock';
            oppProd2.productFamily = 'Rental';
            oppProd2.pricebookEntryId = standardPrice2.Id;
            oppProd2.opportunityId = opp.Id;
            oppProd2.quantity = 10;
            oppProd2.markup = 1.0; 
            oppProd2.unitPrice = 110;    
            oppProd2.totalPrice = 110; 
            oppProd2.isDeleted = true;              
                        
        ApexPages.StandardController stdController = new ApexPages.StandardController(budgetNew);
        ProductsSelectorController controller = new ProductsSelectorController(stdController);      
        
        Test.startTest();
            String resString = ProductsSelectorController.createOppLineItem(new List< ProductsSelectorController.OppProducts>{oppProd1, oppProd2});
        Test.stopTest();
        
        List<Rental_Kit_Allocation__c> rentalAllocationList = [Select Id, ProductId__c, Project__c, Quantity__c, Rental_Kit__c from Rental_Kit_Allocation__c];
        System.assertEquals(0, rentalAllocationList.size());
    }
}