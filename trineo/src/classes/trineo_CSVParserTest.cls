/**
 * CSVParserTest.cls
 * Description: Tests for CSVParser.cls
 * @author: Nathan (Trineo)
 * @date: 21 August 2015 (Friday)
 */
@isTest
private class trineo_CSVParserTest {

    @isTest static void basicTest() {
        String content = 'Header1,"Header, 2"\nvalue1,"value,, 2"\n';

        List<List<String>> values = CSVParser.parseCSV(content);

        System.assertEquals(2, values.size());
        System.assertEquals('Header1', values[0][0]);
        System.assertEquals('Header, 2', values[0][1]);
        System.assertEquals('value1', values[1][0]);
        System.assertEquals('value,, 2', values[1][1]);
    }

    @isTest static void testLargishCSV() {
        String row = 'col1, col2, col3, "col4", "col5"\r\n';
        String content = row.repeat(1000);

        List<List<String>> parse = CSVParser.parseCSV(content);
        System.assertEquals(1000, parse.size(), 'Expected 1000 lines!');
    }

    @isTest static void testLargishCSV_LF_Terminated() {
        String row = 'col1, col2, col3, "col4", "col5"\n';
        String content = row.repeat(1000);

        List<List<String>> parse = CSVParser.parseCSV(content);
        System.assertEquals(1000, parse.size(), 'Expected 1000 lines!');
    }

    @isTest static void testLargishCSV_CR_Terminated() {
        String row = 'col1, col2, col3, "col4", "col5"\r';
        String content = row.repeat(1000);

        List<List<String>> parse = CSVParser.parseCSV(content);
        System.assertEquals(1000, parse.size(), 'Expected 1000 lines!');
    }

    @isTest static void testLargishCSV_lineReader() {
        String row = 'col1, col2, col3, "col4", "col5"\r\n';
        String content = row.repeat(1000);

        Iterator<String> strIter = new CSVParser.LineReader('\n', content);

        Integer numberOfLines = 0;
        while (strIter.hasNext()) {
            strIter.next();
            numberOfLines ++;
        }
        System.assertEquals(1000, numberOfLines, 'Expected 1000 lines!');
    }
}