public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler
{
    public OpportunityLineItemTriggerHandler() {}
    
    public override void afterInsert() 
    {
    	updateOpportunity('insert');
    }
    
    public override void afterUpdate() 
    {
    	updateOpportunity('update');
    }
    
    public override void afterDelete() 
    {
    	updateOpportunity('delete');
    }
    
    private void updateOpportunity(String ops)
    {
    	List<Id> oppIds = new List<Id>();
    	Map<Id, Decimal> totalQuantitySiteMap = new Map<Id, Decimal>();
    	Map<Id, Decimal> totalQuantityWorkshopMap = new Map<Id, Decimal>();
    	Set<String> productTypeSet = new Set<String>();
    	List<Id> pricebookEntryIds = new List<Id>();
    	List<PricebookEntry> pbentryList = new List<PricebookEntry>();
    	List<OpportunityLineItem> oppLineList;
    	Set<String> productTypeAggrSet = new Set<String>();
    	
    	if(ops == 'delete')
    		oppLineList = (List<OpportunityLineItem>)Trigger.old;
    	else
    		oppLineList = (List<OpportunityLineItem>)Trigger.new;
    	     	
    	for(OpportunityLineItem oppLine : oppLineList)
    	{
    		oppIds.add(oppLine.OpportunityId);
    	}
    	
    	
	  	AggregateResult[] groupedResults = [ SELECT SUM(Total_Quantity__c) quantity, PricebookEntry.Product2.Product_Type__c pType,  PricebookEntry.Product2.Family pFamily, OpportunityId 
	  											 FROM OpportunityLineItem 
	  											 group by PricebookEntry.Product2.Product_Type__c, PricebookEntry.Product2.Family, OpportunityId 
	  											 Having OpportunityId In :oppIds
	  											 order by OpportunityId];  				
	  			  											 	
  		for(AggregateResult result : groupedResults)
  		{
  			String productType = (String)result.get('pType');
  			
  			if(productType == 'Site Labour')
  			{
  				totalQuantitySiteMap.put((Id)result.get('OpportunityId'), (Decimal)result.get('quantity'));
  			}
  			
  			if(productType == 'Workshop Labour')
  			{
  				totalQuantityWorkshopMap.put((Id)result.get('OpportunityId'), (Decimal)result.get('quantity'));
  			}
  		}	  		
	  		
  		Map<Id, Opportunity> opportunutyMap = new Map<Id, Opportunity>([Select Id, Total_Quantity_for_Site__c, Total_Quantity_for_Workshop__c
  																		from Opportunity where Id In :oppIds]);
  		List<Opportunity> updateOppList = new List<Opportunity>();
  		for(Opportunity opportunity : opportunutyMap.values())
  		{
  			if(totalQuantitySiteMap != null && totalQuantitySiteMap.size() > 0 && totalQuantitySiteMap.containsKey(opportunity.Id))
  			{
  				opportunity.Total_Quantity_for_Site__c = totalQuantitySiteMap.get(opportunity.Id);
  			}
  			else
  			{
  				opportunity.Total_Quantity_for_Site__c = 0;
  			}
  				
  			if(totalQuantityWorkshopMap != null && totalQuantityWorkshopMap.size() > 0 && totalQuantityWorkshopMap.containsKey(opportunity.Id))
  			{
  				opportunity.Total_Quantity_for_Workshop__c = totalQuantityWorkshopMap.get(opportunity.Id);	
  			}
  			else
  			{
  				opportunity.Total_Quantity_for_Workshop__c = 0;	
  			}
  				
  			updateOppList.add(opportunity);
  		}	
  		  		
  		if(updateOppList != null && updateOppList.size() > 0) update updateOppList;	
    }    
}