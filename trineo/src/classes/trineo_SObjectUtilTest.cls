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

	@IsTest
	static void truncateFieldValue_ShouldTruncateTextFieldsThatExceedFieldLength()
	{
		// Given an uninserted account with a long value in a text field
		String veryLongString = '';
		veryLongString = veryLongString.leftPad( 20000, 'veryLong' );
		Account testAccount = TestObjectFactory.getAccount(veryLongString, false);

		// When truncating its field value
		TruncationUtil.truncateFieldValue( testAccount, Account.Name );

		// The resulting field value should not exceed the field schema's length
		System.assertEquals(
			Account.Name.getDescribe().getLength(), testAccount.Name.length(),
			'After truncating the field value, the length was not equal to the schema max length'
		);
	}

	@IsTest
	static void truncateFieldValue_ShouldNotAlterFieldValuesThatAreWithinFieldLength()
	{
		// Given an uninserted account with a sane value in a text field
		String saneString = 'TestAccount';
		Account testAccount = TestObjectFactory.getAccount( saneString, false );

		// When truncating its field value
		TruncationUtil.truncateFieldValue( testAccount, Account.Name );

		// The resulting field value should be the same as the original value
		System.assertEquals(
			saneString, testAccount.Name,
			'After truncating the field value, the value changed, even though it was within field length limits'
		);
	}

	@IsTest
	static void truncateFieldValue_ShouldNotAlterFieldValuesThatAreBlank()
	{
		// Given an uninserted sObject with a null value in a text field
		String saneString = null;
		Account testAccount = TestObjectFactory.getAccount( saneString, false );

		// When truncating its field value
		TruncationUtil.truncateFieldValue( testAccount, Account.Name );

		// The resulting field value should be the same as the original value
		System.assertEquals(
			saneString, testAccount.Name,
			'After truncating the field value, the value changed. Null values should simply be ignored'
		);
	}
}
