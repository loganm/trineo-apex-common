/**
 * @author Logan Moore
 */
public class UuidUtil
{
	public static String generate()
	{
		String uuid = EncodingUtil.ConvertTohex( Crypto.GenerateAESKey( 128 ) );
		return uuid.SubString(0,8)+ '-' + uuid.SubString(8,12) + '-' + uuid.SubString(12,16) + '-' + uuid.SubString(16,20) + '-' + uuid.substring(20);
	}
}
