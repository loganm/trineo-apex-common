/*
 * Parse a CSV String into a 2D Array.
 * Adapted from code sample at http://wiki.developerforce.com/page/Code_Samples#Parse_a_CSV_with_APEX.
 *
 * Modified 2015 Ed to use a Line Iterator so that we don't hit regex limits. Now hit
 * cpu limits at about 2500-3000 lines. The only way to avoid this is to use a batch
 * job - see trineo_CSVBatchProcess.cls
 *
 * @author: Luke/Morgan/Ed/Nathan
 * @date: Feb 2012
 * @modified: 21 August 2015 (Friday)
 */
public with sharing class trineo_CSVParser {
    public class CSVException extends Exception { }

    public static final String CR = '\r';
    public static final String LF = '\n';
    public static final String CRLF = CR + LF;

    // Return a 2D String array with headers on first row
    public static List<List<String>> parseCSV(String contents) {
        // default to 2,500 lines to process.
        return parseCSV(contents, 2500);
    }

    public static String toCSV(List<List<String>> csvContents) {
        String csv = '';

        Boolean firstRow = true;
        for (List<String> row : csvContents) {

            if (!firstRow) {
                // Add a separating line break between this row and the previous row
                csv += CRLF;
            } else {
                firstRow = false;
            }

            Boolean firstValue = true;
            for (String val : row) {
                if (!firstValue) {
                    // Add a separating comma between this value and the previous value
                    csv += ',';
                } else {
                    firstValue = false;
                }

                csv += val;
            }
        }

        return csv;
    }

    public static String getLineSeparator(String contents) {
        String splitBy = '\n'; // We almost always split by \n

        // Determine if it is split by newLine(\n) or return carriage(\r) or a \r\nn
        Boolean hasNewLine = false;
        Boolean hasCarrReturn = false;

        //First check for a \r\n char
        if (contents.contains('\r\n')) {
            System.debug('## Contains at least one \'\\r\\n\' character');
            hasNewLine = true;
            hasCarrReturn = false;
        } else {
            //If not then check for either a /r or /n
            if (contents.contains('\n')) {
                System.debug('## Contains at least one newline character');
                hasNewLine = true;
            }
            if (contents.contains('\r')) {
                System.debug('## Contains at least one carriage return character');
                hasCarrReturn = true;
            }
        }

        if (!hasNewLine && !hasCarrReturn) {
            System.debug('## Is just one line long');
        }

        List<List<String>> allFields = new List<List<String>>();
        if (hasNewLine && hasCarrReturn) {
            addError('The file contains both newline and carriage returns');
        } else if (hasCarrReturn) {
            splitBy = '\r';
        }

        return splitBy;
    }

    public static List<List<String>> parseCSV(String contents, Integer lineLimit) {
        String lineSeparator = getLineSeparator(contents);
        return parseCSV(contents, lineSeparator, lineLimit);
    }

    public static List<List<String>> parseCSV(String contents, String lineSeparator, Integer lineLimit) {
        List<List<String>> allFields = new List<List<String>>();

        Integer num = 0;

        LineReader lineReader = new LineReader(lineSeparator, contents);

        while (lineReader.hasNext()) {
            if (num++ > lineLimit) {
                // soft limit reached, don't breach it, return short handed.
                break;
            }
            String line = lineReader.next();

            // replace instances where a double quote begins a field containing a comma
            // in this case you get a double quote followed by a doubled double quote
            // do this for beginning and end of a field
            line = line.replaceAll(',"""', ',"DBLQT').replaceall('""",', 'DBLQT",');
            // now replace all remaining double quotes - we do this so that we can reconstruct
            // fields with commas inside assuming they begin and end with a double quote
            line = line.replaceAll('""', 'DBLQT');

            //System.debug('## Parsing line: ' + line);
            // Deal with lines where
            //if (line.replaceAll(',','').trim().length() == 0) continue;


            // TODO: Deal with lines where all fields empty. Currently splits into an empty array.

            List<String> fields = line.split(',', -1);
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            //System.debug('## About to read ' + fields.size() + ' fields...');
            for (String field : fields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    cleanFields.add(field.replaceAll('DBLQT', '"'));
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT', '"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT', '"'));
                }
            }

            // Remove double quotes (if present) from start and end of each field
            List<String> noQuoteFields = new List<String>();
            for (String field : cleanFields) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    if ((field.length() - 1) > 0) {
                        field = field.substring(1, field.length() - 1);
                    } else {
                        field = '';
                    }
                }
                field.trim();
                noQuoteFields.add(field);
            }
            allFields.add(noQuoteFields);
        }

        // Remove any rows before header row so that header row is first row:
        Integer headerRow = -1;
        for (Integer i = 0; (i < allFields.size() && headerRow == -1) ; i++) {
            // Determine if all fields in this row are non-blank:
            List<String> row = allFields.get(i);
            Boolean isHeaderRow = true;

            for (String field : row) {
                if (field == '') { // field is blank
                    isHeaderRow = false;
                }
            }

            if (isHeaderRow) {
                headerRow = i;
            }
        }
        System.debug('## headerRow ' + headerRow);

        for (Integer i = 0; i < headerRow; i++) {
            allFields.remove(0);
        }

        System.debug('## About to return ' + allFields.size() + ' lines...');
        return allFields;
    }

    public static void addError(String error) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
    }

    public class LineReader implements Iterator<string>, Iterable<string> {
        private String lineSeparator { get; set; }
        private String textData;
        private Integer index = 0;

        public LineReader(String lineSeparator, String textData) {
            this.lineSeparator = lineSeparator;
            this.textData = textData;
        }

        public Boolean hasNext() {
            return (textData.length() > 0) && (index < textData.length()) ? true : false;
        }

        public String next() {
            String row = null;
            Integer endPos = -1;

            if (index <= textData.length()) {
                endPos = textData.indexOf(this.lineSeparator, index);
            }

            if (endPos == -1) {
                // If we are on the last line, the row is the textData substring from the current index to the end
                row = textData.substring(index);
                textData = '';
            } else {
                row = textData.subString(index, endPos);
                index = endPos + 1;
            }
            return row;
        }

        public Iterator<String> Iterator() {
            return this;
        }
    }
}