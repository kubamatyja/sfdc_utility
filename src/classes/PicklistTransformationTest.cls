@IsTest
private class PicklistTransformationTest {
    private static testMethod void updatePicklistValuesTest() {
        //given
        Account testRecords = new Account(Industry='Airports');
        //when
        PicklistTransformation service = new PicklistTransformation(new Map<String, String>{
                'Airports' => 'Banking and Finance'
        }, 'Industry');
        Account result = (Account)service.transform(testRecords);
        //then
        System.assertEquals('Banking and Finance',result.Industry);
    }

    private static testMethod void noMatchingValueFoundForPicklistValuesTest() {
        //given
        Account testRecords = new Account(Industry='Airports');
        //when
        PicklistTransformation service = new PicklistTransformation(null, 'Industry');
        Account result = (Account)service.transform(testRecords);
        //then
        System.assertEquals('Airports',result.Industry);
    }
}