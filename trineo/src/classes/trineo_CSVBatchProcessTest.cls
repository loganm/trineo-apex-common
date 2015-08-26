/**
 * CSVBatchProcessTest.cls
 * Description: Test class for batch CSV processing
 */
@isTest
private class trineo_CSVBatchProcessTest {
    private static final String TEST_CSV =
        'First Name,Last Name,Email\n' +
        '"Foo","Bar","foo@bar.com"\n' +
        '"Foo2","Bar2","foo@bar2.com"\n' +
        '"Foo3","Bar3","foo@bar3.com"\n';

    private class MockCSVProcessor implements ICSVProcessor {
        public String getDebugTitle() {
            return 'Mock CSV Processor';
        }
        public void handleProcessing(Map<String, Integer> headers, List<List<String>> csvLines) {
            List<Contact> contacts = new List<Contact>();
            for (List<String> row : csvLines) {
                Contact c = new Contact();
                c.FirstName = row[0];
                c.LastName = row[1];
                c.Email = row[2];
                contacts.add(c);
            }
            insert contacts;
        }
    }

    @isTest static void testCSVProcessor() {
        ICSVProcessor mockProcessor = new MockCSVProcessor();

        Test.startTest();
        CSVBatchProcess processCSV = new CSVBatchProcess(Blob.valueOf(TEST_CSV), mockProcessor);
        Database.executeBatch(processCSV);
        Test.stopTest();

        List<Contact> createdContacts = [SELECT Id, FirstName, LastName, Email FROM Contact];
        System.assertEquals(3, createdContacts.size(), 'Expected exactly 3 new contacts');
    }
}