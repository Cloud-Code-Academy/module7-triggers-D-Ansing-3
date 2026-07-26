trigger AccountTrigger on Account (before insert, after insert) {

    // Note to teacher:
    // This trigger is still small enough that I do not feel the need to use a handler class.
    // This is a concious decision, favored by the architects at my employer. (K.I.S.S.)
    // I kept functions seperated with future refactoring in mind. 

    // === Before Inset ===

    if(trigger.isBefore && trigger.isInsert){
        for(Account a : trigger.new){
            // If type is empty set to Prospect
            if(a.Type == null || a.Type == ''){
                a.Type = 'Prospect';
            }
            // Set Billing address
            if(
                string.isBlank(a.ShippingCity) &&
                string.isblank(a.ShippingCountry) &&
                string.isBlank(a.ShippingPostalCode) &&
                string.isBlank(a.ShippingState) &&
                string.isBlank(a.ShippingStreet)
               )
            {} else {
                a.BillingCity = a.ShippingCity;
                a.BillingCountry = a.ShippingCountry;
                a.BillingPostalCode = a.ShippingPostalCode;
                a.BillingState = a.ShippingState;
                a.BillingStreet = a.ShippingStreet;
            }
            // Set rating to 'Hot' when requirements are met
            if(a.Phone != '' && a.Phone != null && a.Website != '' && a.Website != null && a.Fax != '' && a.Fax != null){
                a.Rating = 'Hot';
            }
        }
    }

    // === After Insert ===

    // Create default Contact for inserted Account
    if(trigger.isAfter && trigger.isInsert){
        list<contact> insertContacts = new list<contact>();
        for(Account a : trigger.new){
            insertContacts.add(new contact(lastName = 'DefaultContact', Email = 'default@email.com', AccountId = a.Id));
        }
        insert insertContacts;
    }
}
