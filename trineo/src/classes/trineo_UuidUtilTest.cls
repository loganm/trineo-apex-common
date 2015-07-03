/**
 * @author Logan Moore
 */
@IsTest
private class UuidUtilTest
{
	@IsTest
	static void testGenerate()
	{
		String uuid = UuidUtil.generate();
		System.debug( 'Generated UUID: ' + uuid );
		System.assert( Pattern.matches( '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', uuid ), 'Expected: Valid UUID, Actual: ' + uuid );
	}
}
