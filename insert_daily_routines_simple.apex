// Insert 10 Daily_Routine__c records with past dates only
List<Daily_Routine__c> routines = new List<Daily_Routine__c>();

routines.add(new Daily_Routine__c(Date__c=Date.today()-10));
routines.add(new Daily_Routine__c(Date__c=Date.today()-9));
routines.add(new Daily_Routine__c(Date__c=Date.today()-8));
routines.add(new Daily_Routine__c(Date__c=Date.today()-7));
routines.add(new Daily_Routine__c(Date__c=Date.today()-6));
routines.add(new Daily_Routine__c(Date__c=Date.today()-5));
routines.add(new Daily_Routine__c(Date__c=Date.today()-4));
routines.add(new Daily_Routine__c(Date__c=Date.today()-3));
routines.add(new Daily_Routine__c(Date__c=Date.today()-2));
routines.add(new Daily_Routine__c(Date__c=Date.today()-1));

insert routines;
System.debug('✅ SUCCESS! Inserted ' + routines.size() + ' Daily Routine records');
