public with sharing class BudgetTriggerHandler extends TriggerHandler
{
    public BudgetTriggerHandler() {}
    
    public override void beforeUpdate() 
    {
    	updateTotalCosts();
    }
    
    private void updateTotalCosts()
    {
    	List<Id> budgetIds = new List<Id>();
    	Map<Id, Decimal> budgetTotalCostPriceMap = new Map<Id, Decimal>();
    	Map<Id, Decimal> budgetTotalSalesPriceMap = new Map<Id, Decimal>();
    	List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();
    	Map<Id, Decimal> budgetToUnitsMap = new Map<Id, Decimal>();
    	
    	Map<Id, Budget__c> budgetOldMap = (Map<Id, Budget__c>)Trigger.oldMap;
    	
    	for(Budget__c budget : (List<Budget__c>)Trigger.new)
    	{
    		Budget__c oldBudget = budgetOldMap.get(budget.Id);
    		if(budget.Units__c != oldBudget.Units__c)
    			budgetIds.add(budget.Id);
    			budgetToUnitsMap.put(budget.Id, budget.Units__c);
    	}
    	
    	if(budgetIds != null && budgetIds.size() > 0)
    	{
	    	oppLines = [ SELECT Id, Budget__c, Budget__r.Units__c, Quantity, New_Individual_Cost__c, UnitPrice FROM OpportunityLineItem where Budget__c In :budgetIds order by Budget__c];  		
	    	
	    	for(OpportunityLineItem line : oppLines)
	    	{
	    		Decimal totalCostPrice = 0;
	    		Decimal totalSalesPrice = 0;
	    		Decimal bUnits = (budgetToUnitsMap != null && budgetToUnitsMap.size() > 0 && budgetToUnitsMap.containsKey(line.Budget__c)) ? budgetToUnitsMap.get(line.Budget__c) : 0;
	    		
	    		if((line.Budget__c != null && (bUnits != null && bUnits != 0)) 
	    		&& (line.Quantity != null && line.Quantity != 0)
	    		&& (line.New_Individual_Cost__c != null && line.New_Individual_Cost__c != 0))
	    			totalCostPrice = (bUnits * line.Quantity) * line.New_Individual_Cost__c;
	    			
	    	
	    		if((line.Budget__c != null && (bUnits != null && bUnits != 0)) 
	    		&& (line.Quantity != null && line.Quantity != 0)
	    		&& (line.UnitPrice != null && line.UnitPrice != 0))
	    			totalSalesPrice = (bUnits * line.Quantity) * line.UnitPrice;
	    			
	    		if(budgetTotalCostPriceMap != null && budgetTotalCostPriceMap.size() > 0 && budgetTotalCostPriceMap.containsKey(line.Budget__c))
	    		{
	    			Decimal costValue = budgetTotalCostPriceMap.get(line.Budget__c);
	    			budgetTotalCostPriceMap.put(line.Budget__c, totalCostPrice + costValue);
	    		}	    		
		    	else
		    	{
		    		budgetTotalCostPriceMap.put(line.Budget__c, totalCostPrice);
		    	}
		    	
		    	if(budgetTotalSalesPriceMap != null && budgetTotalSalesPriceMap.size() > 0 && budgetTotalSalesPriceMap.containsKey(line.Budget__c))
	    		{
	    			Decimal salesValue = budgetTotalSalesPriceMap.get(line.Budget__c);
	    			budgetTotalSalesPriceMap.put(line.Budget__c, totalSalesPrice + salesValue);
	    		}	    		
		    	else
		    	{
		    		budgetTotalSalesPriceMap.put(line.Budget__c, totalSalesPrice);
		    	}
	    	}
	    	
	    	for(Budget__c bSObj : (List<Budget__c>)Trigger.new)
	    	{
	    		if(budgetTotalCostPriceMap != null && budgetTotalCostPriceMap.size() > 0 && budgetTotalCostPriceMap.containsKey(bSObj.Id))
	    			bSObj.Budget_Product_Total_Costs__c = budgetTotalCostPriceMap.get(bSObj.Id);
	    		
	    		if(budgetTotalSalesPriceMap != null && budgetTotalSalesPriceMap.size() > 0 && budgetTotalSalesPriceMap.containsKey(bSObj.Id))
	    			bSObj.Budget_Product_Total_Sales_Price__c = budgetTotalSalesPriceMap.get(bSObj.Id);
	    	}
	    	
    	}
    }
}