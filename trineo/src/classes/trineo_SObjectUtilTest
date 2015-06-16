/**
 * Unit tests for SObjectUtilTest
 *
 * @author Logan Moore
 */
@IsTest
private class SObjectUtilTest
{
	@IsTest
	static void testfieldsMatch()
	{
		Account leftAccount = new Account( Name = 'Name', Description = 'Description', Phone = '123123123' );
		Account rightAccount = new Account( Name = 'Name', Description = 'Description', Phone = '321321321' );
		System.assertEquals( true, SObjectUtil.fieldsMatch( leftAccount, rightAccount, new Set<Schema.SObjectField> { Account.Name, Account.Description } ), 'Should have been a match' );
		System.assertEquals( false, SObjectUtil.fieldsMatch( leftAccount, rightAccount, new Set<Schema.SObjectField> { Account.Name, Account.Description, Account.Phone } ), 'Should NOT have been a match' );
	}
	
	@IsTest
	static void testfieldMatches()
	{
		Account leftAccount = new Account( Name = 'Name', Phone = '123123123' );
		Account rightAccount = new Account( Name = 'Name', Phone = '321321321' );
		System.assertEquals( true, SObjectUtil.fieldMatches( leftAccount, rightAccount, Account.Name ), 'Account Name Should have been a match' );
		System.assertEquals( false, SObjectUtil.fieldMatches( leftAccount, rightAccount, Account.Phone ), 'Account Phone Should NOT have been a match' );
	}
}
