trigger AfterTriggerOnOppLineItem on OpportunityLineItem (after delete, after insert, after update) 
{
    (new OpportunityLineItemTriggerHandler()).execute();
}