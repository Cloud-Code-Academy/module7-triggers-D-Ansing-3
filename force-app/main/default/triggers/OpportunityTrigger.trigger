trigger OpportunityTrigger on Opportunity (before update, before delete) {

    // Note to teacher:
    // This trigger is still small enough that I do not feel the need to use a handler class.
    // This is a concious decision, favored by the architects at my employer. (K.I.S.S.)
    // I kept functions seperated with future refactoring in mind. 

    // ===Before update===
   
    // Notes to teacher:
    // I would normally challenge process management on:
    // - We would need a way to close/abbandon an opp, now only delete is available to get rid of low amount opps. 
    // - User-Story said greater than, but actual desired business process is probably greater or equal.

    // Error at: low amount during update
    if(trigger.isUpdate && trigger.isBefore){
        for(Opportunity o : trigger.new){
            if(o.Amount < 5000){
                o.addError('Opportunity amount must be greater than 5000');
            }
        }
    }
    
    // Set primary contact to Account CEO if available
    if(trigger.isUpdate && trigger.isBefore){
            set<Id> accIds = new set<Id>();
            for(Opportunity o : trigger.new){
                accIds.add(o.AccountId);
            }
            list<Contact> contacts = [select Id, AccountId from Contact where AccountId in :accIds and Title = 'CEO'];
            map<Id, contact> contactsbyAccountId = new map<Id, Contact>();
            for(Contact c : contacts){
                contactsbyAccountId.put(c.AccountId, c);
            }
            for(Opportunity o : trigger.new){
                if(contactsbyAccountId.containsKey(o.AccountId)){
                    o.Primary_Contact__c = contactsbyAccountId.get(o.AccountId).Id;
                }
            }
        }

    // === Before Delete ===

    // Error at: Delete of banking closed won Opp
    if(trigger.isDelete && trigger.isBefore){
        set<Id> accIds = new set<Id>();
        for(Opportunity o : trigger.old){
            accIds.add(o.AccountId);
        }
        map<Id, Account> accs = new map<Id, Account>([select id, industry from Account where Id in :accIds]);
        for(Opportunity o : trigger.old){   
            if(o.StageName == 'Closed Won' && accs.get(o.AccountId).Industry == 'Banking'){
                o.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
       
}
