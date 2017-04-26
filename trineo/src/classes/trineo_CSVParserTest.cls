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

    @isTest static void testCommaInside() {
        String header = 'Email,Account ID,Contact ID,Subscribed Date,Subscribe IP,Unsubscribe Time,Unsubscribe IP,Status,Account Name,Account Owner,Account Owner Email Address,Area,Business Name,Business Sector,Exclusions,First Name,Last Name,Note,Note 2,Region,School Name,Send Group,Target\n';
        String row = 'xxx@bombay.school.nz,0019000000xhAJS,",0039000001wGFrh",2016-06-03 11:56:22 +1200,,,,active,Bombay School,Timmy Tu,timmy.tu@nlg.co.nz,Bombay,,Education,,Cherie,Lemon,20160603 NLC Additions,"Auckland, Waikato and Bay of Plenty","35 Paparata Road,",,,North\n';
        String content = header + row;
        List<List<String>> parse = CSVParser.parseCSV(content);

        for (Integer i = 0; i < parse[0].size(); i++) {
            System.debug('Field ' + i + ': ' + parse[0][i]);
        }

        for (Integer i = 0; i < parse[1].size(); i++) {
            System.debug('Field ' + i + ': ' + parse[1][i]);
        }
        System.debug(parse[1]);
        System.assertEquals(2, parse.size());
        System.assertEquals(23, parse[0].size());
        System.assertEquals(23, parse[1].size());


    }
}