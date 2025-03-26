trigger OpportunityTrigger on Opportunity (before update, before delete) {

    if (Trigger.isBefore && Trigger.isUpdate) {
        for (Opportunity opp : Trigger.new) {
            if (opp.Amount <= 5000) {
                opp.addError('Opportunity amount must be greater than 5000'); 
        }
    }
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
        }
    }
        Map<Id, Contact> ceoMap = new Map<Id, Contact>();
        for (Contact con : [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Title = 'CEO' AND AccountId IN :accountIds]) {

            if (!ceoMap.containsKey(con.AccountId)) {
                ceoMap.put(con.AccountId, con);
        }
    }
        for (Opportunity opp : Trigger.new) {
            if (ceoMap.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = ceoMap.get(opp.AccountId).Id;
            }
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<Id> accountIds = new Set<Id>(); 
        for (Opportunity opp : Trigger.old) {
            accountIds.add(opp.AccountId); 
    }
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);

        for (Opportunity oppCloseWon : Trigger.old) {
            if (oppCloseWon.StageName == 'Closed Won' &&
                accountMap.get(oppCloseWon.AccountId).Industry == 'Banking') {

                oppCloseWon.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
}
