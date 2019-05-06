/**
 * Created by pmcclellan on 12/14/17. Updated 7/3/18 to add Campaign, Contract, and custom objects.
 * Apex Controller for ConversationFeed.cmp
 * Uses UserId and sharing, along with recordId to return Conversations owned by
 * this user, and related to the particular record page in view.
 */

public with sharing class GetConversationList
{
    @AuraEnabled
    public static List<ConversationWrapper> getConversationList(String recordId, String ConversationSharing)
    {
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else 
        {
            List<Conversation__c> Conversations = new List<Conversation__c>();
            if (recordId == null) { //it's a home page
                Conversations = getConversationsNoRecordId(ConversationSharing);
            } 
            // check for situations where the recordId is the recipient (Contact, Lead, Account)
              else if (recordId.left(3) == Schema.SObjectType.Contact.getKeyPrefix()) // it's a contact record
            {
                Conversations = getConversationsContactId(recordId, ConversationSharing);
            } else if (recordId.left(3) == Schema.SObjectType.Lead.getKeyPrefix()) // it's a lead record
            {
                Conversations = getConversationsLeadId(recordId, ConversationSharing);
            } else if (recordId.left(3) == Schema.SObjectType.Account.getKeyPrefix()) // it's an Account record
            {
                Conversations = getConversationsAccountId(recordId, ConversationSharing);
            } else if (recordId.left(3) == Schema.SObjectType.Conversation__c.getKeyPrefix()) // it's a Conversation record
            {
                Conversations = getConversationsConvId(recordId);
            } else
            {   // get the name and type of the sObject represented by the recordId
                Schema.SObjectType sObjType = Id.valueOf(recordId).getSObjectType();
                List<String> standardObjectList = new List<String>{'Asset', 'Campaign', 'Case', 'Contract', 'Opportunity', 'Order', 'Product2'};
                String sObjName = sObjType.getDescribe().getName();
                if (standardObjectList.contains(sObjName)) // standard object
                {
                    String lookupFieldName = sObjName + '__c';
                    Conversations = getRelatedConversations(recordId, lookupFieldName, ConversationSharing);
                }else //custom object
                {
                    Conversations = getRelatedConversations(recordId, ConversationSharing);
                }
            }
            return wrapConversations(Conversations);
        }
    }

    @AuraEnabled
    public static List<ConversationWrapper> searchConversationList(String searchKey, String ConversationSharing)
    {
        System.debug('searchConversationList ' + searchKey + ' ' + ConversationSharing);
        if(!Conversation__c.SObjectType.getDescribe().isAccessible()) {
            return null;
        } else {
            Id OwnerId = UserInfo.getUserId();
            String name = '\'%' + searchKey + '%\'';
            List<Conversation__c> Conversations = new List<Conversation__c>();
            Conversations = getConversationsLikeName(name, ConversationSharing);
            return wrapConversations(Conversations);
        }
    }

//---------------- UTILITY METHODS -------------------------------------------------------------

    //this method constructs the dynamic query using the WhereAnd parameter from specific methods below
    private static List<Conversation__c> makeQuery(String WhereAnd)
    {
        System.debug('🍉 WhereAnd: ' + WhereAnd);
        String qr =
                'SELECT  Id, GroupInits__c, Unread__c, LastMessageReceived__c, Broadcast__c, FirstName__c, ' +
                        'Group_Name__c, OwnerId, PrimaryUser__c, Owner.FirstName, LastFromInits__c, ' +
                        'LastModifiedDate, PrimaryUserInits__c, LastMessageDate__c, ' +
                        'Asset__c, Asset__r.Name, ' +
                        'Campaign__c, Campaign__r.Name, Case__c, Case__r.Subject, ' + 
                        'Contract__c, Contract__r.ContractNumber, Opportunity__c, ' +
                        'Order__c, Order__r.Name, Order__r.OrderNumber, Product2__c, Product2__r.Name, ' + 
                        'Opportunity__r.Name, Link1__c, Link2__c, ' + 
                        'Record1__c, Record2__c, Record1Name__c, Record2Name__c, OurFromNumber__c ' +
                'FROM Conversation__c ' +
                WhereAnd +
                ' ORDER BY LastMessageDate__c DESC'
            ;
        System.debug('❓ ' + qr);
        return Database.query(qr);
    }

    //this method is used to search for conversations related to standard records
    private static List<Conversation__c> getRelatedConversations(String recordId, String lookupFieldName, String ConversationSharing)
    {
        System.debug('getRelatedConversations: ' + recordId + ' ' + lookupFieldName + ' ' + ConversationSharing);
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND '+ lookupFieldName +' = \'' + recordId + '\' '; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND '+ lookupFieldName +' = \'' + recordId + '\' ' ;
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE '+ lookupFieldName +' = \'' + recordId + '\' ';
        }else{
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND '+ lookupFieldName +' = \'' + recordId + '\' '; 
        }
        return makeQuery(WhereAnd);  
    }

    //this method is used to search for conversations related to custom records
    private static List<Conversation__c> getRelatedConversations(String recordId, String ConversationSharing)
    {
        System.debug('getRelatedConversations: ' + recordId + ' ' + ConversationSharing);
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') '; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') ';
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') ';
        } else{
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND (Record1__c = \'' + recordId + '\'' + ' OR Record2__c = \'' + recordId + '\') '; 
        }
        return makeQuery(WhereAnd); 
    }

    //this method is used to search for conversations where there is no recordId (HomePage placement)
    private static List<Conversation__c> getConversationsNoRecordId(String ConversationSharing)
    {
        System.debug('getConversationsNoRecordId: ' + ConversationSharing);
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' ; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' ;
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        { // on a home page, return this User's conversations
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' ; 
        } else{ //redundant contingency default to Private
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' ; 
        }
        return makeQuery(WhereAnd); 
    }

    //this method finds Conversations related to a ContactId
    private static List<Conversation__c> getConversationsContactId(String recordId, String ConversationSharing)
    {
        System.debug('getConversationsContactId: ' + recordId + ' ' + ConversationSharing);
         //find all the member records for this contact
        List<Member__c> Members = new List<Member__c>();
        if(Member__c.SObjectType.getDescribe().isAccessible())
        {
            Members = [SELECT Conversation__c FROM Member__c WHERE Contact__c = :recordId];
        }
        if(Members.size() < 1){
            System.debug('❗️ no conversations with this contact');
            return new List<Conversation__c>(); //nullList
        }

        List<String> IdList = new List<String>();

        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            // need to add quotes because it's a string literal of the list
            IdList.add('\'' + member.Conversation__c + '\'');
        }
        System.debug('IdList: ' + IdList);
        
        //construct the WhereAnd parameters of the query
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        
        if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND Id IN ' + IdList; 
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE Id IN ' + IdList; 
        } else 
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Id IN ' + IdList ; 
        }
        

        return makeQuery(WhereAnd);   
    }

    //this method finds Conversations related to a LeadId
    private static List<Conversation__c> getConversationsLeadId(String recordId, String ConversationSharing)
    {
        System.debug('getConversationsLeadId: ' + recordId + ' ' + ConversationSharing);
         //find all the member records for this contact
        List<Member__c> Members = [SELECT Conversation__c FROM Member__c WHERE Lead__c = :recordId];
        if(Members.size() < 1){
            System.debug('❗️ no conversations with this lead');
            return new List<Conversation__c>(); //nullList
        }
        List<String> IdList = new List<String>();
        System.debug('IdList: ' + IdList);
        //build a list of conversationIds for all those conversations
        for (Member__c member : Members) {
            // need to add quotes because it's a string literal
            IdList.add('\'' + member.Conversation__c + '\'');
        }
        //construct the WhereAnd parameters of the query
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        
        if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND Id IN ' + IdList; 
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE Id IN ' + IdList; 
        } else {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Id IN ' + IdList; 
        }

        return makeQuery(WhereAnd);
    }

    //this method finds Conversations related to an AccountId
    private static List<Conversation__c> getConversationsAccountId(String recordId, String ConversationSharing)
    {
        System.debug('🚙 getConversationAccountId: ' + recordId + ' ' + ConversationSharing);
        //find all the contacts associated with this account
        List<Contact> Contacts = new List<Contact>();
        if(Contact.SObjectType.getDescribe().isAccessible())
        {
            Contacts = [SELECT Id FROM Contact WHERE AccountId = :recordId];
        }
        System.debug('🚙 Contacts found: ' + Contacts.size());
        if(Contacts.size() > 0) // this user can access some contacts for this account
        {
            List<String> contactIds = new List<String>();
            for(Contact contact : Contacts)
            {
                contactIds.add(contact.Id);
            }
            System.debug('🚙 contactIds: ' + contactIds);
            //find all the member records for all contacts in this list
            List<Member__c> Members = new List<Member__c>();
            if(Member__c.SObjectType.getDescribe().isAccessible())
            {
                Members = [SELECT Conversation__c FROM Member__c WHERE Contact__c IN :contactIds];
            }
            System.debug('🚙 Members: ' + Members);
            if(Members.size() < 1){
                System.debug('❗️ no conversations with this contacts on this account');
                return new List<Conversation__c>(); //nullList
            }
            List<String> IdList = new List<String>();

            //build a list of conversationIds for all those conversations
            for (Member__c member : Members) {
                // need to add quotes because it's a string literal
                IdList.add('\'' + member.Conversation__c + '\'');
            }
            System.debug('🚙 IdList: ' + IdList);
            //construct the WhereAnd parameters of the query
            String UserId = String.valueOf(UserInfo.getUserId());
            String WhereAnd = '';
            
            if(ConversationSharing == 'Shared–PhoneNumber')
            {
                String PhoneNumber = getPhoneNumber();
                System.debug('📳 ' + PhoneNumber);
                WhereAnd =
                    'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                    'AND Id IN ' + IdList; 
                    
            }else if(ConversationSharing == 'Shared–RecordAccess')
            {
                WhereAnd = 
                    'WHERE Id IN ' + IdList; 
            } else {
                WhereAnd = 
                    'WHERE OwnerId = \'' + UserId + '\' ' +
                    'AND Id IN ' + IdList; 
            }

            return makeQuery(WhereAnd);
        } 
        return new List<Conversation__c>(); //nullList
    }

    //this method finds Conversations related to a ConversationId
    private static List<Conversation__c> getConversationsConvId(String recordId)
    {
        System.debug('getConversationsConvId: ' + recordId);
        String WhereAnd = 'WHERE Id = \'' + recordId + '\' ';
        return makeQuery(WhereAnd);
    }

    //this method finds Conversations where the GroupName is LIKE the search term name
    private static List<Conversation__c> getConversationsLikeName(String name, String ConversationSharing)
    {
        String UserId = String.valueOf(UserInfo.getUserId());
        String WhereAnd = '';
        if(ConversationSharing == 'Private')
        {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Group_Name__c LIKE '+ name; 

        }else if(ConversationSharing == 'Shared–PhoneNumber')
        {
            String PhoneNumber = getPhoneNumber();
            System.debug('📳 ' + PhoneNumber);
            WhereAnd =
                'WHERE ((OwnerId = \'' + UserId + '\') ' + ' OR (OurFromNumber__c = \'' + PhoneNumber + '\')) ' +
                'AND Group_Name__c LIKE '+ name; 
                
        }else if(ConversationSharing == 'Shared–RecordAccess')
        {
            WhereAnd = 
                'WHERE Group_Name__c LIKE '+ name; 
        } else {
            WhereAnd = 
                'WHERE OwnerId = \'' + UserId + '\' ' +
                'AND Group_Name__c LIKE '+ name; 
        }
        return makeQuery(WhereAnd);  
    }

    private static List<ConversationWrapper> wrapConversations(List<Conversation__c> Conversations)
    {
        ConversationWrapper[] ConversationWrapperList = new List<ConversationWrapper>();
            for (Conversation__c conv : Conversations)
            {
                ConversationWrapper cw = new ConversationWrapper();
                cw.Id = conv.Id;
                cw.Broadcast = conv.Broadcast__c;
                cw.GroupInits = conv.GroupInits__c;
                cw.Unread = conv.Unread__c;
                cw.LastMessageReceived = conv.LastMessageReceived__c;
                cw.FirstName = conv.FirstName__c;
                cw.Group_Name = conv.Group_Name__c;
                cw.OwnerId = conv.OwnerId;
                cw.OwnerFirstName = conv.Owner.FirstName;
                cw.PrimaryUser = conv.PrimaryUser__c;
                cw.LastFromInits = conv.LastFromInits__c;
                cw.LastModifiedDate = conv.LastModifiedDate;
                cw.LastMessageDate = conv.LastMessageDate__c;
                cw.PrimaryUserInits = conv.PrimaryUserInits__c;
                cw.AssetId = conv.Asset__c;
                cw.AssetName = conv.Asset__r.Name;
                cw.CampaignId = conv.Campaign__c;
                cw.CampaignName = conv.Campaign__r.Name;
                cw.CaseId = conv.Case__c;
                cw.CaseSubject = conv.Case__r.Subject;
                cw.ContractId = conv.Contract__c;
                cw.ContractNumber = conv.Contract__r.ContractNumber;
                cw.OpportunityId = conv.Opportunity__c;
                cw.OpportunityName = conv.Opportunity__r.Name;
                cw.OrderId = conv.Order__c;
                cw.OrderName = conv.Order__r.Name;
                cw.OrderNumber = conv.Order__r.OrderNumber;
                cw.Product2Id = conv.Product2__c;
                cw.Product2Name = conv.Product2__r.Name;
                cw.Link1 = conv.Link1__c;
                cw.Record1 = conv.Record1__c;
                cw.Record1Name = conv.Record1Name__c;
                cw.Link2 = conv.Link2__c;
                cw.Record2 = conv.Record2__c;
                cw.Record2Name = conv.Record2Name__c;
                cw.OurFromNumber = conv.OurFromNumber__c;
                ConversationWrapperList.add(cw);
            }
            return ConversationWrapperList;
    }

    private static String getPhoneNumber()
    {   
        String UserId = String.valueOf(UserInfo.getUserId());
        System.debug('🆔 ' + UserId);
        String PhoneNumber;
        if(ProtonTextUser__c.SObjectType.getDescribe().isAccessible())
        {
            PhoneNumber = [
                SELECT PhoneNumber__r.Number__c
                FROM ProtonTextUser__c
                WHERE User__c = :UserId
            ].PhoneNumber__r.Number__c;
        }
        return PhoneNumber;
    }


    //-----------------------------------------------------------------------------
}