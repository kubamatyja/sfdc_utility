@IsTest
private class TransformationExecutorBatchTest {
    public static testMethod void executeTransformationBatchTest() {
        //Given
        insert new List<Lead>{
                new Lead(LastName = 'Test1', Company = 'TestComp1', Salutation = 'Mr'),
                new Lead(LastName = 'Test2', Company = 'TestComp2', Salutation = 'Mrs')
        };
        List<RecordsTransformationUtility> transformations = new List<RecordsTransformationUtility>{
                new PicklistTransformation(new Map<String, String>{
                        'Mr' => 'Mrs',
                        'Mrs' => 'Mr'
                }, 'Salutation')
        };
        //When
        Test.startTest();
        String jobId = Database.executeBatch(new TransformationExecutorBatch('SELECT Salutation From Lead', transformations, false));
        Test.stopTest();

        //Then
        AsyncApexJob result = [SELECT Status, NumberOfErrors FROM AsyncApexJob WHERE Id = :jobId];
        System.assertEquals(0, result.NumberOfErrors);
        System.assertEquals('Completed', result.Status);
    }
}