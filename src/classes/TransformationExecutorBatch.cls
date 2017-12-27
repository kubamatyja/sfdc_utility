public with sharing class TransformationExecutorBatch implements Database.Batchable<SObject>, Database.Stateful {
    private final String query;
    private final List<RecordsTransformationUtility> recordTransformations;
    private List<String> errorMessages;
    private Boolean sendEmailNotification;
    private Integer updatedRecords;
    private Integer failedRecords;

    public TransformationExecutorBatch(String query, List<RecordsTransformationUtility> recordTransformations, Boolean notifyAfterFinish) {
        this.query = query;
        this.sendEmailNotification = notifyAfterFinish;
        this.recordTransformations = recordTransformations == null ? new List<RecordsTransformationUtility>() : recordTransformations;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        this.errorMessages = new List<String>();
        this.updatedRecords = 0;
        this.failedRecords = 0;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<sObject> scope) {
        for (SObject item : scope) {
            for (RecordsTransformationUtility transformation : recordTransformations) {
                transformation.transform(item);
            }
        }
        List<Database.SaveResult> result = Database.update(scope, false);
        for (Integer i = 0; i < result.size(); i++) {
            if (result[i].isSuccess()) {
                updatedRecords++;
            } else {
                failedRecords++;
                for (Database.Error error : result[i].getErrors()) {
                    errorMessages.add(scope[i].Id + ',\"' + error.message + '\"\n');
                }
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        if (this.sendEmailNotification) {
            AsyncApexJob result = [SELECT Status FROM AsyncApexJob WHERE Id = :context.getJobId()];
            Messaging.SingleEmailMessage outEmailMessage = new Messaging.SingleEmailMessage();
            outEmailMessage.setToAddresses(new List<String>{
                    UserInfo.getUserEmail()
            });
            outEmailMessage.setSubject('Processing of Transformation Executor Batch Finished with ' + result.Status + ' status.');
            outEmailMessage.setPlainTextBody('Updated records: ' + this.updatedRecords +
                    '\n Failed records: ' + this.failedRecords);

            if (!errorMessages.isEmpty()) {
                Messaging.EmailFileAttachment errorLog = new Messaging.EmailFileAttachment();
                errorLog.setFileName('errors.csv');
                errorLog.setBody(Blob.valueOf('Id,Error\n' + String.join(errorMessages, '')));
                outEmailMessage.setFileAttachments(new List<Messaging.EmailFileAttachment>{
                        errorLog
                });
            }
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                    outEmailMessage
            });
        }
    }
}