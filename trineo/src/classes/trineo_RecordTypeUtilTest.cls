/**
 * @author Logan Moore
 */
@IsTest
private class RecordTypeUtilTest
{
	@IsTest
	static void testsNotImplemented()
	{
		Map<String, Id> fetchedRecordTypes = RecordTypeUtil.getRecordTypeIdsByDeveloperName( Account.SObjectType );
	}
}
