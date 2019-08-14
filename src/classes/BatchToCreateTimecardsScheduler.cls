global class BatchToCreateTimecardsScheduler implements Schedulable
{
	public static String sched = '0 0 0 * * ?';  //Every Day at Midnight 

    global static String runBatch() {
        BatchToCreateTimecardsScheduler scheduler = new BatchToCreateTimecardsScheduler(); 
        return System.schedule('Create time cards', sched, scheduler);
    }
    
    global void execute (SchedulableContext SC){
         BatchToCreateTimecards batch = new  BatchToCreateTimecards();
       	 ID batchprocessid = Database.executeBatch(batch, 200);
    }
}