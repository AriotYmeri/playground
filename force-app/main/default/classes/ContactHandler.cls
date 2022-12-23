public with sharing class ContactHandler {
    public ContactHandler() {

    }

    public void syncActivenessBetweenAccountAndContact(List<Contact> oldContacts, List<Contact> newContacts){
        Map<Contact, Contact> oldContactToNewContactMap = new Map<Contact, Contact>();
        
        Account parentAccount;
        List<Account> accountsToUpdate = new List<Account>();

        for(Contact oldContact : oldContacts){
            for(Contact newContact : newContacts){
                if(oldContact.id == newContact.id){
                    oldContactToNewContactMap.put(oldContact, newContact);
                }
            }
        }
        System.debug('oldContactToNewContactMap: '+oldContactToNewContactMap);
        System.debug('first new contact: '+oldContactToNewContactMap.values()[0]);


        for(Contact con : oldContactToNewContactMap.keySet()){
            Contact newContact = oldContactToNewContactMap.get(con);
            String oldIsActiveValue = String.valueOf(con.Is_Active__c);
            String newIsActiveValue = String.valueOf(newContact.Is_Active__c);
            
            System.debug(oldIsActiveValue);
            System.debug(newIsActiveValue);
            
            if(isFieldChanged(oldIsActiveValue, newIsActiveValue)){
                System.debug('field is changed!');
                Map<Contact, Account> contactToAccount = createContactToAccountMap(newContacts);
                parentAccount = contactToAccount.get(newContact);
                System.debug('Parent account of the contact: '+parentAccount);
                System.debug('contact: '+newContact);
                if(newContact.is_Active__c != parentAccount.is_Active__c){
                    parentAccount.is_Active__c = newContact.is_Active__c;
                    accountsToUpdate.add(parentAccount);
                }
            }
        }
        if(accountsToUpdate.size() > 0){
            update accountsToUpdate;
        }
    }

    private static Boolean isFieldChanged(String oldValue, String newValue){
        System.debug('is field change? :' +oldValue!=newValue);
        return oldValue != newValue;
    }

    private static Map<Contact, Account> createContactToAccountMap(List<Contact> contactList){
        List<Id> accountIds = new List<Id>();

        for(Contact con : contactList){
            accountIds.add(con.AccountId);
        }
        Map<Contact, Account> contactToAccountMap = new Map<Contact,Account>();
        List<Account> AccountsOfContacts = [SELECT id, is_Active__c FROM Account WHERE Id IN: accountIds];
        System.debug('Account found: '+AccountsOfContacts);
        for(Account acc : AccountsOfContacts){
            for(Contact contact : contactList){
                if(acc.Id == contact.AccountId){
                    contactToAccountMap.put(contact, acc);
                }
            }
        }
        System.debug(contactToAccountMap.values());
        return contactToAccountMap;
    }
}