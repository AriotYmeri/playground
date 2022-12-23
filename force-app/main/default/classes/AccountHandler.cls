public with sharing class AccountHandler {
    public AccountHandler() {

    }

    public void syncActivenessBetweenAccountAndContacts(List<Account> oldAccounts, Map<Id, Account> newAccountsMap){
        Map<Account, Account> oldAccountToNewAccountMap = new Map<Account, Account>();
        List<Account> newAccounts = new List<Account>();
        for(Account a : newAccountsMap.values()){
            newAccounts.add(a);
        }
        Account parentAccount;
        List<Contact> contactsToUpdate = new List<Contact>();

        for(Account oldAccount : oldAccounts){
            for(Account newAccount : newAccounts){
                System.debug('newAccount is active?: '+newAccount.Is_Active__c);
                if(oldAccount.id == newAccount.id){
                    oldAccountToNewAccountMap.put(oldAccount, newAccount);
                }
            }
        }
        System.debug('oldAccountToNewAccountMap: '+oldAccountToNewAccountMap);
        System.debug('first new Account: '+oldAccountToNewAccountMap.values()[0]);


        for(Account acc : oldAccountToNewAccountMap.keySet()){
            Account newAccount = oldAccountToNewAccountMap.get(acc);
            String oldIsActiveValue = String.valueOf(acc.Is_Active__c);
            String newIsActiveValue = String.valueOf(newAccount.Is_Active__c);
            
            System.debug(oldIsActiveValue);
            System.debug(newIsActiveValue);
            
            if(isFieldChanged(oldIsActiveValue, newIsActiveValue)){
                System.debug('field is changed!');
                Map<Account, List<Contact>> accountToContacts = createAccountToContactsMap(newAccountsMap);
                
                for(Account account : accountToContacts.keySet()){
                    System.debug('is Account active? : '+account.is_Active__c);
                    for(Contact c : accountToContacts.get(account)){
                        System.debug('is Contact active? : '+c.is_Active__c);
                        if(account.Is_Active__c != c.Is_Active__c){
                            c.Is_Active__c = account.is_Active__c;
                            contactsToUpdate.add(c);
                        }
                    }
                }
            }
        }
        if(contactsToUpdate.size() > 0){
            update contactsToUpdate;
        }
    }

    private static Boolean isFieldChanged(String oldValue, String newValue){
        return oldValue != newValue;
    }

    private static Map<Account, List<Contact>> createAccountToContactsMap(Map<Id, Account> accountMap){
        
        Map<Account, List<Contact>> accToContactsMap = new Map<Account,List<Contact>>();
        List<Contact> allcontacts = [SELECT id, Is_Active__c, AccountId FROM Contact WHERE AccountId IN : accountMap.keySet()];
        List<Contact> contacts = new List<Contact>();
        for(Account acc : accountMap.values()){
            for(Contact con : allcontacts){
                if(con.AccountId == acc.id){
                    contacts.add(con);
                }
            }
            if(contacts.size() > 0){
                accToContactsMap.put(acc, contacts);
            }
        }   
        return accToContactsMap;
    }
}