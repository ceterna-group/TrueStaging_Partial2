public with sharing class PurchaseGanttChart 
{
	@RemoteAction
	public static List<ProductDetail> getAllProductDetails()
	{		
		Map<Id, Set<String>> productIdToWorkshopDateMap = new Map<Id, Set<String>>();  //associates product id to list of workshop dates
		Map<String, Decimal> prodIdDateToTotalQuantityMap = new Map<String, Decimal>();  //combination of product id and workshop date to total quantitiy
		Map<String, Decimal> prodIdDateToConfirmedQuantityMap = new Map<String, Decimal>();  //combination of product id and workshop date to confirmed quantitiy (materials to order checkbox)
		List<ProductDetail> productDetailList = new List<ProductDetail>();   //return list
		
		Map<Id, ProductDetail> productIdToProductDetailMap = new Map<Id, ProductDetail>();
		
		Date currentDate = System.today();
		Date additional30Days = System.today().addDays(29);
		
		List<String> productFamilies = new List<String>{'Materials', '3rd Party'};
		
		//retrieve all the opplines where opp is closed won and workshopdate is b/w today and today +30 days
		List<OpportunityLineItem> oppLines = [Select Id, Name, Product_Name__c, Product2Id, Total_Quantity__c, ProductCode, OpportunityId, Opportunity.StageName, Product_stock__c, 
																	Opportunity.ProjectWorkShopDate__c, Opportunity.Materials_Ready_to_Order__c, Product_Family__c
																	from OpportunityLineItem
																	where OpportunityId !=null and Opportunity.StageName = 'Closed Won' and Opportunity.ProjectWorkShopDate__c != null
																	and Opportunity.ProjectWorkShopDate__c >= :currentDate and Opportunity.ProjectWorkShopDate__c <= :additional30Days and Product_Family__c In :productFamilies];
																																		
		if(oppLines != null && oppLines.size() > 0)
		{ 
			for(OpportunityLineItem oppLine : oppLines)
			{
				String projDate = oppLine.Opportunity.ProjectWorkShopDate__c.date().format();
				
				//below if and else is to set all the workshop date to its productId's
				if(productIdToWorkshopDateMap.isEmpty() || (!productIdToWorkshopDateMap.isEmpty() && !productIdToWorkshopDateMap.containsKey(oppLine.Product2Id)))
				{
					productIdToWorkshopDateMap.put(oppLine.Product2Id, new Set<String>{projDate});
				}
				else
				{
					productIdToWorkshopDateMap.get(oppLine.Product2Id).add(projDate);
				}
				
				//below if is to create a wrapper class for product details
				if(productIdToProductDetailMap.isEmpty() || (!productIdToProductDetailMap.isEmpty() && !productIdToProductDetailMap.containsKey(oppLine.Product2Id)))
				{
					ProductDetail prodDetial = new ProductDetail();
					prodDetial.productId = oppLine.Product2Id;
					prodDetial.productName = oppLine.Product_Name__c;
					prodDetial.productCode = oppLine.ProductCode;
					prodDetial.freeStock = oppLine.Product_stock__c;
					
					productIdToProductDetailMap.put(oppLine.Product2Id, prodDetial);
				}
				
				//setting map key
				String key = oppLine.Product2Id + projDate;
				
				//calculating total quantity for each opp line per product
				if(prodIdDateToTotalQuantityMap.isEmpty() || (!prodIdDateToTotalQuantityMap.isEmpty() && !prodIdDateToTotalQuantityMap.containsKey(key)))
				{
					prodIdDateToTotalQuantityMap.put(key, oppLine.Total_Quantity__c);
				}
				else
				{
					if(prodIdDateToTotalQuantityMap.get(key) != null)
					{
						Decimal totalQuantity = prodIdDateToTotalQuantityMap.get(key) + oppLine.Total_Quantity__c;
						prodIdDateToTotalQuantityMap.put(key, totalQuantity);
					}
				}
				
				//calculating confirmed quantity for each opp line per product. only those opp line where opp is marked for confirmed order. (material ready for order check box)
				if(oppLine.Opportunity.Materials_Ready_to_Order__c == true)
				{
					if(prodIdDateToConfirmedQuantityMap.isEmpty() || (!prodIdDateToConfirmedQuantityMap.isEmpty() && !prodIdDateToConfirmedQuantityMap.containsKey(key)))
					{
						prodIdDateToConfirmedQuantityMap.put(key, oppLine.Total_Quantity__c);
					}
					else
					{
						if(prodIdDateToConfirmedQuantityMap.get(key) != null)
						{
							Decimal confirmedQuantity = prodIdDateToConfirmedQuantityMap.get(key) + oppLine.Total_Quantity__c;
							prodIdDateToConfirmedQuantityMap.put(key, confirmedQuantity);
						}
					}
				}
			}
		}
		
		
		//Go through the product Ids. Associate each product detail wrapper to list of stock detail 
		if(!productIdToWorkshopDateMap.isEmpty() && !prodIdDateToTotalQuantityMap.isEmpty())
		{
			for(String prodId : productIdToWorkshopDateMap.keySet())
			{
				List<StockDetail> stockDetailList = new List<StockDetail>();
				if(productIdToWorkshopDateMap.get(prodId) != null && productIdToWorkshopDateMap.get(prodId).size() > 0)
				{
					Set<String> workshopdateList = productIdToWorkshopDateMap.get(prodId);
					
					//build stock detail wrapper
					if(workshopdateList != null && workshopdateList.size() > 0)
					{
						for(String workshopDate : workshopdateList)
						{
							String key = prodId + workshopDate;
							
							StockDetail sd = new StockDetail();
							sd.workshopStartDate = workshopDate;
								
							if(prodIdDateToTotalQuantityMap.containsKey(key) && prodIdDateToTotalQuantityMap.get(key) != null)
							{						
								sd.totalQuantity = prodIdDateToTotalQuantityMap.get(key);						
							}
							
							if(!prodIdDateToConfirmedQuantityMap.isEmpty() && prodIdDateToConfirmedQuantityMap.containsKey(key) && prodIdDateToConfirmedQuantityMap.get(key) != null)
							{						
								sd.confirmedQuantity = prodIdDateToConfirmedQuantityMap.get(key);						
							}

							stockDetailList.add(sd);  
						}
					}
				}
				
				//associate list of stock detail wrapper to each product detail
				if((!productIdToProductDetailMap.isEmpty() && productIdToProductDetailMap.size() > 0 && productIdToProductDetailMap.get(prodId) != null) 
					&& (!stockDetailList.isEmpty() && stockDetailList.size() > 0))
				{
					ProductDetail prodDetail = productIdToProductDetailMap.get(prodId);
					prodDetail.stockDetails = stockDetailList;
					
					productDetailList.add(prodDetail);
				}
			}
		}
		
		return productDetailList;
	}
		
	public with sharing class ProductDetail
	{
		public String productId {get; set;}
		public String productName {get; set;}
		public String productCode {get; set;}
		public Decimal freeStock {get; set;}
		public List<StockDetail> stockDetails {get; set;}
	}
	
	public with sharing class StockDetail
	{
		public String workshopStartDate {get; set;}
		public Double totalQuantity {get; set;}
		public Double confirmedQuantity {get; set;}	
	}
}