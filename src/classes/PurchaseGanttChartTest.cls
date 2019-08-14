@isTest
private class PurchaseGanttChartTest 
{	
	static testMethod void testGetAllProductDetailsNotConfirmed()
	{
		Opportunity opp = createOpportunity('Test Festival');
		insert opp;		
		
		opp.StageName = 'Closed Won';
		opp.Materials_Ready_to_Order__c = false;
		update opp;
		
		Project__c proj;
		List<Project__c> projList = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp.Id];
		
		if(projList == null || projList.isEmpty())
		{
			proj = new Project__c(Event_Name__c = 'Test project 1',
	    	Opportunity__c = opp.Id);
			insert proj;
		}
		else
		{
			proj = projList[0];
		}		
		
		Budget__c budget;
		List<Budget__c> budgetList = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp.Id];
		
		if(budgetList == null || budgetList.isEmpty())
		{
			budget = new Budget__c(Opportunity__c = opp.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget;
		}
		else
		{
			budget = budgetList[0];
		}
		
		PricebookEntry pricebookEntry1 =  createProduct('Crew Chief', '1001', 100);
		PricebookEntry pricebookEntry2 =  createProduct('Carpenter', '1002', 200);
		PricebookEntry pricebookEntry3 =  createProduct('Metal Worker', '1003', 300);
		
		OpportunityLineItem oppline1 = createOppLine(opp.Id, pricebookEntry1.Id, 5.0, 200, budget.Id);
		OpportunityLineItem oppline2 = createOppLine(opp.Id, pricebookEntry2.Id, 4.0, 300, budget.Id);
		OpportunityLineItem oppline3 = createOppLine(opp.Id, pricebookEntry3.Id, 3.0, 400, budget.Id);
		
		proj.Workshop_Start_Date_Time__c = System.now();
		proj.Workshop_Finish_Date_Time__c = System.now();
		update proj;		
		
		Test.startTest();
		
		List<PurchaseGanttChart.ProductDetail> prodList = PurchaseGanttChart.getAllProductDetails();
		
		Test.stopTest();
		
		System.assertEquals(3, prodList.size());
		
		for(PurchaseGanttChart.ProductDetail pd : prodList)
		{
			if(pd.productId == pricebookEntry1.Product2Id)
			{
					System.assertEquals(pd.productName, pricebookEntry1.Product2.Name);	
					System.assertEquals(pd.productCode, pricebookEntry1.ProductCode);			
					System.assertEquals(pd.freeStock, pricebookEntry1.Product2.Total_stock__c);	
					System.assertEquals(1, pd.stockDetails.size());			
					System.assertEquals(pd.stockDetails[0].workshopStartDate, proj.Workshop_Start_Date_Time__c.date().format());	
					System.assertEquals(pd.stockDetails[0].totalQuantity, 5);	
					System.assertEquals(pd.stockDetails[0].confirmedQuantity, null);	
			}
			if(pd.productId == pricebookEntry2.Product2Id)
			{
					System.assertEquals(pd.productName, pricebookEntry2.Product2.Name);	
					System.assertEquals(pd.productCode, pricebookEntry2.ProductCode);			
					System.assertEquals(pd.freeStock, pricebookEntry2.Product2.Total_stock__c);	
					System.assertEquals(1, pd.stockDetails.size());			
					System.assertEquals(pd.stockDetails[0].workshopStartDate, proj.Workshop_Start_Date_Time__c.date().format());	
					System.assertEquals(pd.stockDetails[0].totalQuantity, 4);	
					System.assertEquals(pd.stockDetails[0].confirmedQuantity, null);	
			}
			if(pd.productId == pricebookEntry3.Product2Id)
			{
					System.assertEquals(pd.productName, pricebookEntry3.Product2.Name);	
					System.assertEquals(pd.productCode, pricebookEntry3.ProductCode);			
					System.assertEquals(pd.freeStock, pricebookEntry3.Product2.Total_stock__c);	
					System.assertEquals(1, pd.stockDetails.size());			
					System.assertEquals(pd.stockDetails[0].workshopStartDate, proj.Workshop_Start_Date_Time__c.date().format());	
					System.assertEquals(pd.stockDetails[0].totalQuantity, 3);	
					System.assertEquals(pd.stockDetails[0].confirmedQuantity, null);	
			}
		}	
	}
	
	static testMethod void testGetAllProductDetailsConfirmedQantity()
	{
		Opportunity opp = createOpportunity('Test Festival');
		insert opp;		
		
		opp.StageName = 'Closed Won';
		opp.Materials_Ready_to_Order__c = true;
		update opp;
		
		Project__c proj;
		List<Project__c> projList = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp.Id];
		if(projList == null || projList.isEmpty())
		{
			proj = new Project__c(Event_Name__c = 'Test project 1',
	    	Opportunity__c = opp.Id);
			insert proj;
		}
		else
		{
			proj = projList[0];
		}
		
		Budget__c budget;
		List<Budget__c> budgetList = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp.Id];
		if(budgetList == null || budgetList.isEmpty())
		{
			budget = new Budget__c(Opportunity__c = opp.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget;
		}
		else
		{
			budget = budgetList[0];
		}
		
		PricebookEntry pricebookEntry1 =  createProduct('Crew Chief', '1001', 100);
		PricebookEntry pricebookEntry2 =  createProduct('Carpenter', '1002', 200);
		PricebookEntry pricebookEntry3 =  createProduct('Metal Worker', '1003', 300);
		
		OpportunityLineItem oppline1 = createOppLine(opp.Id, pricebookEntry1.Id, 5.0, 200, budget.Id);
		OpportunityLineItem oppline2 = createOppLine(opp.Id, pricebookEntry2.Id, 4.0, 300, budget.Id);
		OpportunityLineItem oppline3 = createOppLine(opp.Id, pricebookEntry3.Id, 3.0, 400, budget.Id);
		
		proj.Workshop_Start_Date_Time__c = System.now();
		proj.Workshop_Finish_Date_Time__c = System.now();
		update proj;		
		
		Test.startTest();
		
		List<PurchaseGanttChart.ProductDetail> prodList = PurchaseGanttChart.getAllProductDetails();
		
		Test.stopTest();
		
		System.assertEquals(3, prodList.size());
		
		for(PurchaseGanttChart.ProductDetail pd : prodList)
		{
			if(pd.productId == pricebookEntry1.Product2Id)
			{
					System.assertEquals(pd.productName, pricebookEntry1.Product2.Name);	
					System.assertEquals(pd.productCode, pricebookEntry1.ProductCode);			
					System.assertEquals(pd.freeStock, pricebookEntry1.Product2.Total_stock__c);	
					System.assertEquals(1, pd.stockDetails.size());			
					System.assertEquals(pd.stockDetails[0].workshopStartDate, proj.Workshop_Start_Date_Time__c.date().format());	
					System.assertEquals(pd.stockDetails[0].totalQuantity, 5);	
					System.assertEquals(pd.stockDetails[0].confirmedQuantity, 5);	
			}
			if(pd.productId == pricebookEntry2.Product2Id)
			{
					System.assertEquals(pd.productName, pricebookEntry2.Product2.Name);	
					System.assertEquals(pd.productCode, pricebookEntry2.ProductCode);			
					System.assertEquals(pd.freeStock, pricebookEntry2.Product2.Total_stock__c);	
					System.assertEquals(1, pd.stockDetails.size());			
					System.assertEquals(pd.stockDetails[0].workshopStartDate, proj.Workshop_Start_Date_Time__c.date().format());	
					System.assertEquals(pd.stockDetails[0].totalQuantity, 4);	
					System.assertEquals(pd.stockDetails[0].confirmedQuantity, 4);	
			}
			if(pd.productId == pricebookEntry3.Product2Id)
			{
					System.assertEquals(pd.productName, pricebookEntry3.Product2.Name);	
					System.assertEquals(pd.productCode, pricebookEntry3.ProductCode);			
					System.assertEquals(pd.freeStock, pricebookEntry3.Product2.Total_stock__c);	
					System.assertEquals(1, pd.stockDetails.size());			
					System.assertEquals(pd.stockDetails[0].workshopStartDate, proj.Workshop_Start_Date_Time__c.date().format());	
					System.assertEquals(pd.stockDetails[0].totalQuantity, 3);	
					System.assertEquals(pd.stockDetails[0].confirmedQuantity, 3);	
			}
		}	
	}
	
	static testMethod void testGetAllProductDetailsMultiple()
	{
		Opportunity opp1 = createOpportunity('Test Festival1');
		Opportunity opp2 = createOpportunity('Test Festival2');
		Opportunity opp3 = createOpportunity('Test Festival3');
		
		insert new List<Opportunity>{opp1, opp2, opp3};		
		
		opp1.StageName = 'Closed Won';
		opp1.Materials_Ready_to_Order__c = false;
		
		opp2.StageName = 'Closed Won';
		opp2.Materials_Ready_to_Order__c = false;
		
		opp3.StageName = 'Closed Won';
		opp3.Materials_Ready_to_Order__c = true;
		update new List<Opportunity>{opp1, opp2, opp3};
		
		Project__c proj1;
		Project__c proj2;
		Project__c proj3;
		
		List<Project__c> proj1List = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp1.Id];
		List<Project__c> proj2List = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp2.Id];
		List<Project__c> proj3List = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp3.Id];
		if(proj1List == null || proj1List.isEmpty())
		{
			proj1 = new Project__c(Event_Name__c = 'Test project 1',
	    	Opportunity__c = opp1.Id);
			insert proj1;
		}
		else
		{
			proj1 = proj1List[0];
		}
		
		if(proj2List == null || proj2List.isEmpty())
		{
			proj2 = new Project__c(Event_Name__c = 'Test project 2',
	    	Opportunity__c = opp2.Id);
			insert proj2;
		}
		else
		{
			proj2 = proj2List[0];
		}
		
		if(proj3List == null || proj3List.isEmpty())
		{
			proj3 = new Project__c(Event_Name__c = 'Test project 3',
	    	Opportunity__c = opp3.Id);
			insert proj3;
		}
		else
		{
			proj3 = proj3List[0];
		}
		
		Budget__c budget1;
		Budget__c budget2;
		Budget__c budget3;
		
		List<Budget__c> budget1List = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp1.Id];
		List<Budget__c> budget2List = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp2.Id];
		List<Budget__c> budget3List = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp3.Id];
		
		if(budget1List == null || budget1List.isEmpty())
		{
			budget1 = new Budget__c(Opportunity__c = opp1.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget1;
		}
		else
		{
			budget1 = budget1List[0];
		}
		
		if(budget2List == null || budget2List.isEmpty())
		{
			budget2 = new Budget__c(Opportunity__c = opp2.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget2;
		}
		else
		{
			budget2 = budget2List[0];
		}
		
		if(budget3List == null || budget3List.isEmpty())
		{
			budget3 = new Budget__c(Opportunity__c = opp3.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget3;
		}
		else
		{
			budget3 = budget3List[0];
		}
		
		PricebookEntry pricebookEntry1 =  createProduct('Crew Chief', '1001', 100);
		
		OpportunityLineItem oppline1 = createOppLine(opp1.Id, pricebookEntry1.Id, 5.0, 200, budget1.Id);
		OpportunityLineItem oppline2 = createOppLine(opp2.Id, pricebookEntry1.Id, 4.0, 300, budget2.Id);
		OpportunityLineItem oppline3 = createOppLine(opp3.Id, pricebookEntry1.Id, 3.0, 400, budget3.Id);
		
		proj1.Workshop_Start_Date_Time__c = System.now();
		proj1.Workshop_Finish_Date_Time__c = System.now();
		
		proj2.Workshop_Start_Date_Time__c = System.now();
		proj2.Workshop_Finish_Date_Time__c = System.now();
		
		proj3.Workshop_Start_Date_Time__c = System.now();
		proj3.Workshop_Finish_Date_Time__c = System.now();
		
		update new List<Project__c>{proj1, proj2, proj3};		
		
		Test.startTest();
		
		List<PurchaseGanttChart.ProductDetail> prodList = PurchaseGanttChart.getAllProductDetails();
		
		Test.stopTest();
		
		System.assertEquals(1, prodList.size());
		System.assertEquals(prodList[0].productId, pricebookEntry1.Product2Id);	
		System.assertEquals(prodList[0].productName, pricebookEntry1.Product2.Name);	
		System.assertEquals(prodList[0].productCode, pricebookEntry1.ProductCode);			
		System.assertEquals(prodList[0].freeStock, pricebookEntry1.Product2.Total_stock__c);	
		System.assertEquals(1, prodList[0].stockDetails.size());			
		System.assertEquals(prodList[0].stockDetails[0].workshopStartDate, proj1.Workshop_Start_Date_Time__c.date().format());	
		System.assertEquals(prodList[0].stockDetails[0].totalQuantity, 12);	
		System.assertEquals(prodList[0].stockDetails[0].confirmedQuantity, 3);			
	}
	
	static testMethod void testGetAllProductDetailsMultipleConfirmed()
	{
		Opportunity opp1 = createOpportunity('Test Festival1');
		Opportunity opp2 = createOpportunity('Test Festival2');
		Opportunity opp3 = createOpportunity('Test Festival3');
		
		insert new List<Opportunity>{opp1, opp2, opp3};		
		
		opp1.StageName = 'Closed Won';
		opp1.Materials_Ready_to_Order__c = true;
		
		opp2.StageName = 'Closed Won';
		opp2.Materials_Ready_to_Order__c = true;
		
		opp3.StageName = 'Closed Won';
		opp3.Materials_Ready_to_Order__c = true;
		update new List<Opportunity>{opp1, opp2, opp3};
		
		Project__c proj1;
		Project__c proj2;
		Project__c proj3;
		
		List<Project__c> proj1List = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp1.Id];
		List<Project__c> proj2List = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp2.Id];
		List<Project__c> proj3List = [Select Id, Name, Opportunity__c from Project__c where Opportunity__c = :opp3.Id];
		if(proj1List == null || proj1List.isEmpty())
		{
			proj1 = new Project__c(Event_Name__c = 'Test project 1',
	    	Opportunity__c = opp1.Id);
			insert proj1;
		}
		else
		{
			proj1 = proj1List[0];
		}
		
		if(proj2List == null || proj2List.isEmpty())
		{
			proj2 = new Project__c(Event_Name__c = 'Test project 2',
	    	Opportunity__c = opp2.Id);
			insert proj2;
		}
		else
		{
			proj2 = proj2List[0];
		}
		
		if(proj3List == null || proj3List.isEmpty())
		{
			proj3 = new Project__c(Event_Name__c = 'Test project 3',
	    	Opportunity__c = opp3.Id);
			insert proj3;
		}
		else
		{
			proj3 = proj3List[0];
		}
		
		Budget__c budget1;
		Budget__c budget2;
		Budget__c budget3;
		
		List<Budget__c> budget1List = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp1.Id];
		List<Budget__c> budget2List = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp2.Id];
		List<Budget__c> budget3List = [Select Id, Name, Opportunity__c from Budget__c where Opportunity__c = :opp3.Id];
		
		if(budget1List == null || budget1List.isEmpty())
		{
			budget1 = new Budget__c(Opportunity__c = opp1.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget1;
		}
		else
		{
			budget1 = budget1List[0];
		}
		
		if(budget2List == null || budget2List.isEmpty())
		{
			budget2 = new Budget__c(Opportunity__c = opp2.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget2;
		}
		else
		{
			budget2 = budget2List[0];
		}
		
		if(budget3List == null || budget3List.isEmpty())
		{
			budget3 = new Budget__c(Opportunity__c = opp3.Id, Headline_Information__c = 'Centre Stage', 
									Budget_Type__c = 'Construction', Description__c = 'Main stage');
        	insert budget3;
		}
		else
		{
			budget3 = budget3List[0];
		}
		
		PricebookEntry pricebookEntry1 =  createProduct('Crew Chief', '1001', 100);
		
		OpportunityLineItem oppline1 = createOppLine(opp1.Id, pricebookEntry1.Id, 5.0, 200, budget1.Id);
		OpportunityLineItem oppline2 = createOppLine(opp2.Id, pricebookEntry1.Id, 4.0, 300, budget2.Id);
		OpportunityLineItem oppline3 = createOppLine(opp3.Id, pricebookEntry1.Id, 3.0, 400, budget3.Id);
		
		proj1.Workshop_Start_Date_Time__c = System.now();
		proj1.Workshop_Finish_Date_Time__c = System.now();
		
		proj2.Workshop_Start_Date_Time__c = System.now();
		proj2.Workshop_Finish_Date_Time__c = System.now();
		
		proj3.Workshop_Start_Date_Time__c = System.now();
		proj3.Workshop_Finish_Date_Time__c = System.now();
		
		update new List<Project__c>{proj1, proj2, proj3};		
		
		Test.startTest();
		
		List<PurchaseGanttChart.ProductDetail> prodList = PurchaseGanttChart.getAllProductDetails();
		
		Test.stopTest();
		
		System.assertEquals(1, prodList.size());
		System.assertEquals(prodList[0].productId, pricebookEntry1.Product2Id);	
		System.assertEquals(prodList[0].productName, pricebookEntry1.Product2.Name);	
		System.assertEquals(prodList[0].productCode, pricebookEntry1.ProductCode);			
		System.assertEquals(prodList[0].freeStock, pricebookEntry1.Product2.Total_stock__c);	
		System.assertEquals(1, prodList[0].stockDetails.size());			
		System.assertEquals(prodList[0].stockDetails[0].workshopStartDate, proj1.Workshop_Start_Date_Time__c.date().format());	
		System.assertEquals(prodList[0].stockDetails[0].totalQuantity, 12);	
		System.assertEquals(prodList[0].stockDetails[0].confirmedQuantity, 12);			
	}
	
	static Opportunity createOpportunity(String oppName)
	{
		Account acc = new Account(Name = 'Test Account');
		insert acc;
		
		Opportunity opp = new Opportunity(AccountId = acc.Id, Amount=1000, CloseDate = System.today(), Name = oppName, StageName = 'Qualification', 
																Expected_Install_Month__c = 'January',  Year__c = String.valueOf(system.today().year()));
				
		return opp;
	}
	
	static PricebookEntry createProduct(String prodName, String prodCode, Integer unitPrice)
	{
		Product2 prod = new Product2(Name = prodName, Family = 'Materials', ProductCode = prodCode, Product_Type__c = 'Standard Timber & Panels', IsActive = true);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();        
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = unitPrice, IsActive = true, UseStandardPrice = false);
        insert standardPrice;    
        
        PricebookEntry pricebook = [Select Id, Name, Pricebook2Id, Product2Id, UnitPrice, Product2.Name, ProductCode, Product2.Total_stock__c from PricebookEntry where Id = :standardPrice.Id];
                
        return pricebook;   
	}
	
	static OpportunityLineItem createOppLine(Id oppId, Id pricebookEntryId, Decimal qantity, Double unitPrice, Id BudgetId)
	{
		OpportunityLineItem oppLine = new OpportunityLineItem (OpportunityId = oppId, PricebookEntryId = pricebookEntryId, Quantity = qantity, UnitPrice = unitPrice, Budget__c = BudgetId);
		insert oppLine;
		
		return oppLine;
	}  

}