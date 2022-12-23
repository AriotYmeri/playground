trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete) {

    ContactHandler handler = new ContactHandler();
    
    if(Trigger.isUpdate){
        try{
            handler.syncActivenessBetweenAccountAndContact(Trigger.old, Trigger.new);
        }catch(Exception e){
            System.debug('Error syncing isActive checkbox between contact and account. Error: '+e.getMessage());
        }
        
    }
}