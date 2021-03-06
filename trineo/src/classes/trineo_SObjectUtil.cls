/**
 * A utility class to help when dealing with SObjects.
 *
 * @author Logan Moore
 */
public with sharing class SObjectUtil
{
	/**
	 * Given two SObjects and a list of fields to compare, this method tells
	 * you if the list of fields are the same on both SObjects.
	 *
	 * @param leftSObject first of the SObjects to compare (must be same as rightSObject param)
	 * @param rightSObject second of the SObjects to compare (must be same as leftSObject param)
	 * @param fields list of field references that will be compared (must be from the same SObjectType as leftSObject and rightSObject params)
	 * @return true if all fields are the same on both SObjects, false if any fields are different
	 * @throws SObjectTypeException if SObjectTypes of leftSobject and rightSObject do not match
	 */
	public static Boolean fieldsMatch( SObject leftSObject, SObject rightSObject, Set<Schema.SObjectField> fields )
	{
		if ( leftSObject.getSObjectType() != rightSObject.getSObjectType() )
		{
			throw new SObjectTypeException( 'leftSObject and rightSObject must be of the same SObjectType' );
		}
		for ( Schema.SObjectField field : fields )
		{
			if ( !fieldMatches( leftSObject, rightSObject, field ) )
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * Given two SObjects and a field to compare, this method tells
	 * you if the fields is the same on both SObjects.
	 *
	 * @param leftSObject first of the SObjects to compare (must be same as rightSObject param)
	 * @param rightSObject second of the SObjects to compare (must be same as leftSObject param)
	 * @param field a field reference that will be compared (must be from the same SObjectType as leftSObject and rightSObject params)
	 * @return true if the field is the same on both SObjects, false if the field is different
	 * @throws SObjectTypeException if SObjectTypes of leftSobject and rightSObject do not match
	 */
	public static Boolean fieldMatches( SObject leftSObject, SObject rightSObject, Schema.SObjectField field )
	{
		if ( leftSObject.getSObjectType() != rightSObject.getSObjectType() )
		{
			throw new SObjectTypeException( 'leftSObject and rightSObject must be of the same SObjectType' );
		}
		return leftSObject.get( field ) == rightSObject.get( field );
	}

	/**
	 * Default field truncation length
	 */
	private static final Integer TRUNCATION_LENGTH = 3;
	/**
	 * Truncate the value of a given field by referring to the length of the field.
	 * Useful when preparing DML safe data for the clientside code to use
	 * Especially considering we currently cannot use the `AllowFieldTruncation` header over the rest API
	 * @param SObject sObj Modified directly. The value will be truncated if its value exceeds the allowed length
	 */
	public static void truncateFieldValue(SObject sObj, final Schema.SObjectField field)
	{
		Object rawValue = sObj.get(field);
		if ( field.getDescribe().getSoapType() != Schema.SOAPType.STRING )
		{
			throw new FieldTypeException( 'The provided SObject field must be a text field' );
		}

		Integer fieldLength = field.getDescribe().getLength();
		String fieldValue = (String) sObj.get( field );
		if ( String.isNotBlank( fieldValue ) )
		{
			if ( fieldValue.length() > fieldLength )
			{
				fieldValue = fieldValue.left( fieldLength - TRUNCATION_LENGTH );
				for ( Integer i = 0; i < TRUNCATION_LENGTH; i ++ )
				{
					fieldValue += '.';
				}
			}
		}

		sObj.put( field, fieldValue );
	}

	/**
	 * Exception for when there's a problem with SObjectTypes
	 */
	public class SObjectTypeException extends Exception {}

	/**
	 * Exception for when there's a problem with a field type
	 */
	public class FieldTypeException extends Exception {}
}
