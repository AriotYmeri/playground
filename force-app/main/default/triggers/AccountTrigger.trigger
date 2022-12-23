trigger AccountTrigger on Account (after insert, after update, after delete, after undelete) {

    AccountHandler handler = new AccountHandler();
    
    if(Trigger.isUpdate){
        try{
            handler.syncActivenessBetweenAccountAndContacts(Trigger.old, Trigger.newMap);
        }catch(Exception e){
            System.debug('Error syncing isActive checkbox between contact and account. Error: '+e.getMessage());
        }
        
    }
}