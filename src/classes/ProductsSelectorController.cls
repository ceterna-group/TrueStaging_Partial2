public with sharing class ProductsSelectorController 
{
    ApexPages.StandardController controller;
    public static String opportunityName {get; set;}
    public static String oppId {get; set;}
    public static String recordId {get; set;}
    public static String headLineInformation {get; set;}
    public static Budget__c budgetRecord;
        
    public ProductsSelectorController(ApexPages.StandardController controller)
    {
        this.controller = controller;
        
        recordId = controller.getId();
        
        budgetRecord = [Select Id, Name, Budget_Type__c , Description__c , Headline_Information__c, Opportunity__c,
                                Opportunity__r.Name, Units__c  from Budget__c where Id=:recordId];
        if(budgetRecord != null)
        {                        
            opportunityName = budgetRecord.Opportunity__r.Name;
            oppId = budgetRecord.Opportunity__c;
            headLineInformation = budgetRecord.Headline_Information__c;
        }
    }
    
    @RemoteAction
    public static List<Products> getProducts()
    {   
        List<Products> productWrapperList = new List<Products>();
        List<Product2> productList = new List<Product2>();
        try
        {            
            productList = [Select p.Product_Type__c, p.ProductCode, p.Name, p.Id, p.Family, p.Product_Markup__c,
                        (Select Id, Pricebook2Id, UnitPrice, UseStandardPrice 
                         From PricebookEntries where IsActive=true limit 1) From Product2 p where IsActive=true limit 49999];
                         
            productWrapperList = buildWrapperList(productList);
        }catch(Exception e)
        {
            System.debug('Error while fetching products :  '+e);
            return productWrapperList;
        }       
        
        return productWrapperList;
    }
    
    public static List<Products> buildWrapperList(List<Product2> productList)
    {        
    	Decimal stdMarkup = 1.6;
    	List<StandardMarkUp__c> temp = StandardMarkUp__c.getAll().values();
    	if(temp != null && temp.size() > 0)
    	{
    		stdMarkup = temp[0].MarkUp__c;
    	}
    	 
        Pricebook2 standardPriceBook;
        if(!Test.isRunningTest())
        {
            standardPriceBook = [Select Name, IsStandard, IsActive, Id From Pricebook2  where IsStandard = true];
        }   
                
        List<Products> productWrapperList = new List<Products>();
         if(productList != null && productList.size() > 0)
         {
            for(Product2 prod : productList)
            {
                Products pSObj = new Products();
                pSObj.prodId = prod.Id;
                pSObj.prodName = prod.Name;
                pSObj.prodFamily = prod.Family;
                pSObj.prodType = prod.Product_Type__c;
                pSObj.prodCode = prod.ProductCode;
                pSObj.prodMarkup = prod.Product_Markup__c != null ? prod.Product_Markup__c : stdMarkup;               
                
                if(prod.PricebookEntries != null && prod.PricebookEntries.size() > 0)
                {
                    if(Test.isRunningTest())  //enters only if its a test class
                    {
                            pSObj.standardPrice = prod.PricebookEntries[0].UnitPrice;
                            pSObj.pricebookEntryId = prod.PricebookEntries[0].Id;
                    }
                    else
                    {
                        if((prod.PricebookEntries[0].Pricebook2Id == standardPriceBook.Id) && (standardPriceBook.IsActive == true))
                        {
                            pSObj.standardPrice = prod.PricebookEntries[0].UnitPrice;
                            pSObj.pricebookEntryId = prod.PricebookEntries[0].Id;
                        }
                        else
                        {
                            pSObj.standardPrice = 0;
                            pSObj.pricebookEntryId = null;
                        }
                    }
                }               
                else
                {
                    pSObj.standardPrice = 0;
                    pSObj.pricebookEntryId = null;
                }                     
               
                if(pSObj.pricebookEntryId != null) //&& pSObj.standardPrice != 0)  //allowing standard price book with 0 cost
                {
                    productWrapperList.add(pSObj);         
                }               
            }
        }
        return productWrapperList;
    }
    
    @RemoteAction
    public static List<OppProducts> getExistingOppProductsForBudget(Id budgetId)
    {
    	Decimal stdMarkup = 1.6;
    	List<StandardMarkUp__c> temp = StandardMarkUp__c.getAll().values();
    	if(temp != null && temp.size() > 0)
    	{
    		stdMarkup = temp[0].MarkUp__c;
    	}
    	
        List<OppProducts> oppLineList = new List<OppProducts>();
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
        
        if(budgetId != null)
        {
            oppLines = [Select Product2.Family, Product2.Product_Type__c, UnitPrice, Quantity, Product2Id, PricebookEntryId, OpportunityId,TotalPrice, Product_Name__c,Actual_Mark_up__c,
                                                                    Id, Budget__c, New_Individual_Cost__c, Description  From OpportunityLineItem where Budget__c = :budgetId];
                                                                    
            if(!oppLines.isEmpty() && oppLines.size() >0 )
            {
                for(OpportunityLineItem existingOppProd : oppLines)
                {
                    OppProducts oppProd = new OppProducts();
                    oppProd.productId = existingOppProd.Product2Id;
                    oppProd.pricebookEntryId = existingOppProd.PricebookEntryId;
                    oppProd.opportunityId = existingOppProd.OpportunityId;
                    oppProd.quantity = existingOppProd.Quantity;
                    oppProd.unitPrice = existingOppProd.UnitPrice;
                    oppProd.newCost = existingOppProd.New_Individual_Cost__c;
                    oppProd.markup = (existingOppProd.Actual_Mark_up__c != null) ? existingOppProd.Actual_Mark_up__c : stdMarkup;
                    oppProd.totalPrice = existingOppProd.TotalPrice;
                    oppProd.productName = existingOppProd.Product_Name__c;
                    oppProd.productType = existingOppProd.Product2.Product_Type__c;
                    oppProd.productFamily = existingOppProd.Product2.Family;
                    oppProd.lineDescription = existingOppProd.Description;
                    oppLineList.add(oppProd);
                }               
            }       
        }
        return oppLineList;
    }
    
    @RemoteAction
    public static  String createOppLineItem(List<OppProducts> oppLines)
    {
        set<String> budgetIds = new set<String>();
        List<OppProducts> existingOppLines  = new List<OppProducts>();
        if(!oppLines.isEmpty() && oppLines != null)
        {
            List<OpportunityLineItem> newOppLineList = new List<OpportunityLineItem>();
            List<OppProducts> siteCrewLines = new List<OppProducts>();
            List<OppProducts> rentalLines = new List<OppProducts>();
            Map<String, Integer> existingProductTypeToNoOfProdMap = new Map<String, Integer>();
            Set<Id> deletedProdIds = new Set<Id>();
    		Set<Id> productIds = new Set<Id>();
    	
            String opportunityId = '';
            for(OppProducts op : oppLines)
            {
            	budgetIds.add(op.budgetId);
            	if(opportunityId == '') opportunityId = op.opportunityId;
            	
            	if(op.isDeleted)
            	{
            		if((op.productFamily == 'Labour' && op.productType == 'Site Labour') || (op.productFamily == 'Rental' && op.productType == 'Rental Stock'))
            			deletedProdIds.add(op.productId);            		
            	}
            	else
            	{
	            	productIds.add(op.productId);
	                if((op.budgetId != null) && (op.OpportunityId != null) && (op.PricebookEntryId != null) && (op.Quantity != null) && (op.Quantity != 0))
	                {
	                    OpportunityLineItem oppLine = new OpportunityLineItem();
	                        oppLine.Budget__c = op.budgetId;
	                        oppLine.OpportunityId = op.opportunityId;
	                        oppLine.Quantity = op.quantity;
	                        oppLine.PricebookEntryId = op.pricebookEntryId;
	                        if(op.UnitPrice != null ) oppLine.UnitPrice = op.unitPrice;
                            if(op.newCost != null ) oppLine.New_Individual_Cost__c = op.newCost;
                            if(op.lineDescription != null) oppLine.Description = op.lineDescription;
	                    
	                    newOppLineList.add(oppLine);
	                }
	                
	                if((op.Quantity != null) && (op.Quantity != 0))
	                {
	                	
	                	if(op.productFamily == 'Labour' && op.productType == 'Site Labour')
	                	{
	                		siteCrewLines.add(op);
	                	}	                	
	                	
	                	if(op.productFamily == 'Rental' && op.productType == 'Rental Stock')
	                	{
	                		rentalLines.add(op);
	                	}
	                }
            	}                
            }     
            
               
                                                            
        	if(!budgetIds.isEmpty()) 
        		deleteOpportunityProducts(new List<String>(budgetIds));           
            
            try
            {            
                if(!newOppLineList.isEmpty()) upsert newOppLineList;
            }
            catch(Exception e)
            {
                System.debug('Error creating opp products:  '+e);
                return 'Error';
            }
            
            //rental kit and site crew calculations  
    		Map<String, Decimal> prodNameIdToQuantityMap = new Map<String, Decimal>();
    		
    		Project__c proj ; 
                          		
    		if((siteCrewLines != null && siteCrewLines.size() >0) || (rentalLines != null && rentalLines.size() >0) || (deletedProdIds != null && deletedProdIds.size() > 0))
    		{       			  
    			proj = [Select Id from Project__c where Opportunity__c = :opportunityId limit 1];    
	        	prodNameIdToQuantityMap = getAggregareResults(opportunityId);
    		}
            
            if(proj != null)
            {
            	createUpdateSiteCrew(siteCrewLines, deletedProdIds, productIds, prodNameIdToQuantityMap, proj.Id);   
            	createRentalKitAllocation(rentalLines, deletedProdIds, productIds, prodNameIdToQuantityMap, proj.Id);
            }
        }
        return 'completed';
    }
   
    //Based on assumptions that there will be  only one product with crew chief of type site labour. 
    //Also site crew record can only be created/deleted from product selector. Not Manual.
    public static void createUpdateSiteCrew(List<OppProducts> oppLines, Set<Id> deletedProdIds, Set<Id> productIds, 
    																Map<String, Decimal> prodNameIdToQuantityMap, Id projectId)
    {    	    	
    	List<Workshop_Site_Crew__c> upsertSiteCrewList = new List<Workshop_Site_Crew__c>();
    	List<Workshop_Site_Crew__c> deleteSiteCrewList = new List<Workshop_Site_Crew__c>();
    	Map<Id, Workshop_Site_Crew__c> siteCrewMap = new Map<Id, Workshop_Site_Crew__c>();
    	    	    	    		
    	if((oppLines != null && oppLines.size() >0) || (deletedProdIds != null && deletedProdIds.size() > 0))
    	{       
	        siteCrewMap = getExistingSiteCrews(projectId);
    	}
    	    	
    	if(oppLines != null && oppLines.size() > 0)
    	{    	
	    	for(OppProducts line : oppLines)
	    	{	    		
	    		if(siteCrewMap.isEmpty() || (!siteCrewMap.isEmpty() && !siteCrewMap.containsKey(line.productId)))
	    		{	    			
	    			if(prodNameIdToQuantityMap != null && prodNameIdToQuantityMap.size() > 0 && prodNameIdToQuantityMap.containsKey(line.productId))
		    		{		    			
		    			if(projectId != null)
		    			{		    				
				    		Workshop_Site_Crew__c scObj = new Workshop_Site_Crew__c(
				    				Crew_Role__c = line.productName,
				    				Days__c = prodNameIdToQuantityMap.get(line.productId),
				    				Labour_Type__c = 'Site Labour',
				    				ProductId__c = line.productId,
				    				Project__c = projectId,
				    				Rate__c = line.unitPrice
				    		);
			    			upsertSiteCrewList.add(scObj);
		    			}
		    		}
	    		}
	    		else
	    		{
	    			if(prodNameIdToQuantityMap != null && prodNameIdToQuantityMap.size() > 0)
	    			{
    					if(prodNameIdToQuantityMap.containsKey(line.productId) && prodNameIdToQuantityMap.get(line.productId) > 0)
		    			{
		    				Workshop_Site_Crew__c updateSCObj = siteCrewMap.get(line.productId);
		    				updateSCObj.Days__c = prodNameIdToQuantityMap.get(line.productId);
		    				upsertSiteCrewList.add(updateSCObj); 
		    			}
	    			}
	    		}
	    	}
    	}
    	
    	if(siteCrewMap != null && siteCrewMap.size() > 0)
    	{    	
	    	for(String productId : siteCrewMap.keySet())
	        {
	        	if(productIds.isEmpty() || !productIds.contains(productId))
	        	{
	        		Workshop_Site_Crew__c siteObj = siteCrewMap.get(productId);
	        		if(!prodNameIdToQuantityMap.isEmpty() && prodNameIdToQuantityMap.containsKey(productId) && prodNameIdToQuantityMap.get(productId) > 0)
	        		{
	    				siteObj.Days__c = prodNameIdToQuantityMap.get(productId);
	        			upsertSiteCrewList.add(siteObj);
	        		}
	        		else
	        		{
	        			deleteSiteCrewList.add(siteObj);    
	        		}
	        	}           	
	        }
    	}
	    
	    try
	    {	
    		if(!upsertSiteCrewList.isEmpty() && upsertSiteCrewList.size() >0) upsert upsertSiteCrewList; 
	    }
	    catch(Exception e)
	    {
	    	System.debug('Error upserting site crew records: '+e);
	    }
	    
	    try
	    {
    		if(!deleteSiteCrewList.isEmpty() && deleteSiteCrewList.size() >0) delete deleteSiteCrewList;  
	    }
	    catch(Exception e)
	    {
	    	System.debug('Error deleting site crew records: '+e);
	    }      	       	
    }
    
    public static Map<String, Decimal> getAggregareResults(String opportunityId)
    {
    	Map<String, Decimal> prodNameIdToQuantityMap = new Map<String, Decimal>();
    	if(opportunityId != null && opportunityId != '')
    	{
	    	AggregateResult[] aggrResults = [Select sum(Total_Quantity__c) sumTotal, Product2.Name pName, Product2Id, Product2.Family, Product2.Product_Type__c , OpportunityId 
	    														from OpportunityLineItem 
	    														GROUP BY Product2Id, Product2.Name, Product2.Family, Product2.Product_Type__c , OpportunityId 
	    														Having Product2.Family In ('Labour', 'Rental') and Product2.Product_Type__c In ('Site Labour', 'Rental Stock') and OpportunityId = :opportunityId];
	    														
	    	if(aggrResults != null && aggrResults.size() > 0)
	    	{													
		    	for(AggregateResult ar : aggrResults)
		    	{
		    		String key = (String)ar.get('Product2Id');
		    		prodNameIdToQuantityMap.put(key, (Decimal)ar.get('sumTotal'));
		    	}
	    	}	    	
    	}
    	return prodNameIdToQuantityMap;
    }
    
    public static Map<Id, Workshop_Site_Crew__c> getExistingSiteCrews(Id projectId)
    {
    	List<Workshop_Site_Crew__c> siteCrewRecords = new List<Workshop_Site_Crew__c>();
    	Map<Id, Workshop_Site_Crew__c> siteCrewMap = new Map<Id, Workshop_Site_Crew__c>();
    	if(projectId != null)
    		siteCrewRecords = [Select Id, Days__c, Rate__c, Project__c, ProductId__c 
    										from Workshop_Site_Crew__c 
    										where Project__c=:projectId
    										and Labour_Type__c = 'Site Labour'
    										];    	
    										
    	if(siteCrewRecords != null && siteCrewRecords.size() > 0)
    	{
    		for(Workshop_Site_Crew__c record : siteCrewRecords)
    		{
    				siteCrewMap.put(record.ProductId__c, record);    			   			
    		}
    	}
    	
    	return siteCrewMap;
    }
    
    public static void deleteOpportunityProducts(List<String> budgetIds)
    {
        if(budgetIds !=null && !budgetIds.isEmpty())
        {
            List<OpportunityLineItem> oppProductList = [Select Budget__c from OpportunityLineItem where Budget__c In :budgetIds];
                        
            try
            {
                if(oppProductList != null && !oppProductList.isEmpty())  delete oppProductList;
            }
            catch(Exception e)
            {
                System.debug('Error deleting existing opp products:  '+e);
            }
        }
    }
    
    public static void createRentalKitAllocation(List<OppProducts> oppLines, Set<Id> deletedProdIds, Set<Id> productIds, 
    																Map<String, Decimal> prodNameIdToQuantityMap, Id projectId)
    {
    	List<String> productNames = new List<String>();
    	Map<String, Rental_Kit__c> existingRentalKitMap = new Map<String, Rental_Kit__c>();
    	List<Rental_Kit_Allocation__c> upsertRentalAllocationList = new List<Rental_Kit_Allocation__c>();
    	List<Rental_Kit_Allocation__c> deleteRentalAllocationList = new List<Rental_Kit_Allocation__c>();
    	
    	for(OppProducts line : oppLines)
    	{
    		productNames.add(line.productName);
    	}
    	    	
    	if((oppLines != null && oppLines.size() >0) || (deletedProdIds != null && deletedProdIds.size() > 0))
    	{
    	 	existingRentalKitMap = getExistingRentalKits(projectId, productNames);
    	}
    	     	 
    	 for(OppProducts record : oppLines)
    	 {
    	 	if(existingRentalKitMap != null && existingRentalKitMap.size() > 0 && existingRentalKitMap.containsKey(record.productName.toLowerCase()))
    	 	{
    	 		Rental_Kit__c parentRentalRecord = existingRentalKitMap.get(record.productName.toLowerCase());
    	 		List<Rental_Kit_Allocation__c> childRentalRecords = parentRentalRecord.Rental_Kit_Allocation__r ;
    	 		
    	 		if(prodNameIdToQuantityMap != null 
	    	 				&& prodNameIdToQuantityMap.size() > 0 
	    	 				&& prodNameIdToQuantityMap.containsKey(record.productId)
	    	 				&& prodNameIdToQuantityMap.get(record.productId) > 0)
	 			{
	 				if(childRentalRecords != null && childRentalRecords.size() > 0 && (record.productId == childRentalRecords[0].ProductId__c))
    	 			{
    	 				Rental_Kit_Allocation__c childRecord = childRentalRecords[0]; // Assuming there is going to be only one child combination of rental kit name and project.
    	 				childRecord.Quantity__c = prodNameIdToQuantityMap.get(record.productId);
	    	 			upsertRentalAllocationList.add(childRecord);
    	 			}
    	 			else
    	 			{
    	 				Rental_Kit_Allocation__c childRecord = new Rental_Kit_Allocation__c(
    	 																					ProductId__c = record.productId,
    	 																					Project__c = projectId,
    	 																					Quantity__c = prodNameIdToQuantityMap.get(record.productId),
    	 																					Rental_Kit__c = parentRentalRecord.Id);
    	 				upsertRentalAllocationList.add(childRecord);																	
    	 			}	 			
	 			}
    	 	}
    	 }
    	 
    	 List<Rental_Kit_Allocation__c> existingRentalAllocations = new List<Rental_Kit_Allocation__c>();
    	 for(Rental_Kit__c parent : existingRentalKitMap.values())
    	 {
    	 	List<Rental_Kit_Allocation__c> childRentalRecords = parent.Rental_Kit_Allocation__r;
    	 	if(childRentalRecords != null && childRentalRecords.size() > 0)
    	 	{
    	 		existingRentalAllocations.addAll(childRentalRecords);
    	 	}
    	 }
    	 
    	 if(existingRentalAllocations != null && existingRentalAllocations.size() > 0)
    	 {
    	 	for(Rental_Kit_Allocation__c childRecord : existingRentalAllocations)
    	 	{
    	 		if(productIds.isEmpty() || !productIds.contains(childRecord.ProductId__c))
	        	{
	        		if(!prodNameIdToQuantityMap.isEmpty() && prodNameIdToQuantityMap.containsKey(childRecord.ProductId__c) && prodNameIdToQuantityMap.get(childRecord.ProductId__c) > 0)
	        		{
	    				childRecord.Quantity__c = prodNameIdToQuantityMap.get(childRecord.ProductId__c);
	        			upsertRentalAllocationList.add(childRecord);
	        		}
	        		else
	        		{
	        			deleteRentalAllocationList.add(childRecord);    
	        		}
	        	}
    	 	}
    	 }
    	 
    	 try
    	 {
    	 	if(!upsertRentalAllocationList.isEmpty() && upsertRentalAllocationList.size() > 0)
    	 		upsert upsertRentalAllocationList;
    	 }
    	 catch(Exception e)
    	 {
    	 	System.debug('Error occured while upserting rental allocation'+e.getMessage());
    	 }
    	 
    	 try
    	 {
    	 	if(!deleteRentalAllocationList.isEmpty() && deleteRentalAllocationList.size() > 0)
    	 		delete deleteRentalAllocationList;
    	 }
    	 catch(Exception e)
    	 {
    	 	System.debug('Error occured while deleting rental allocation'+e.getMessage());
    	 }
    	 
    }
    
    public static Map<String, Rental_Kit__c> getExistingRentalKits(Id projectId, List<String> productNames)
    {
    	//Assuming the rental  kit name are unique and they associate to product name. Rental kit name are not editable.
    	Map<String, Rental_Kit__c> existingRentalKitMap = new Map<String, Rental_Kit__c>();
    	List<Rental_Kit__c> existingRentalKits = [Select r.Name, 
    																			r.Id, 
    																			(Select Id, 
    																						Project__c, 
    																						ProductId__c, 
    																						Rental_Kit__c, 
    																						Quantity__c 
    																						From Rental_Kit_Allocation__r 
    																						where Project__c = :projectId) 
    																	From Rental_Kit__c r];
    																			 
    	if(existingRentalKits != null && existingRentalKits.size() > 0)
    	{
    		for(Rental_Kit__c rentalRecord : existingRentalKits)
    		{
    			existingRentalKitMap.put(rentalRecord.Name.toLowerCase(), rentalRecord);
    		}
    	}
    	
    	return existingRentalKitMap;																 
    }
    
    public class Products
    {
        public String prodId {get; set;}
        public String pricebookEntryId {get; set;}
        public String prodName {get; set;}
        public String prodFamily {get; set;}
        public String prodType {get; set;}
        public String prodCode {get; set;}
        public Double standardPrice {get; set;}
        public Decimal prodMarkup {get; set;}
    }
    
    public class OppProducts
    {
        public String budgetId {get; set;}
        public String productId {get; set;}
        public String productName {get; set;}
        public String productType {get; set;}
        public String productFamily {get; set;}
        public String pricebookEntryId {get; set;}
        public String opportunityId {get; set;}
        public Decimal quantity {get; set;}
        public Double unitPrice {get; set;}
        public Double newCost {get; set;}
        public Double markup {get; set;} 
        public Double totalPrice {get; set;}     
        public Boolean isDeleted {get; set;}
        public String lineDescription {get; set;}
    }
}