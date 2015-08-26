/**
 * CSVBatchProcess.cls
 *
 * Process a CSV using a batch job
 * -------------------------------
 * This is intended for use with a large CSV.
 * We use the CSVParser.LineReader to break the CSV in to smaller chunks.
 * You should implement ICSVProcessor, writing code to process a CSV of your chosen scope size.
 * The execute method of this batch job will simply call your ICSVProcessor.
 * NOTE: The CSV _must_ be UTF-8 encoded
 *
 * @author: Nathan (Trineo)
 * @date: 20 August 2015 (Thursday)
 */
global with sharing class CSVBatchProcess implements Database.batchable<String>, Database.Stateful {

    global Map<String, Integer> headers = null; // First execute will be null.
    private Blob blobCSV;
    private String csvData;
    private Integer startRow;

    protected List<String> errors = new List<String>();
    private ICSVProcessor processor;

    public Integer csvLength {
        get
        {
            if (csvData != null) {
                return csvData.length();
            } else
            {
                return 0;
            }
        }
    }

    public CSVBatchProcess(Blob blobCSV, ICSVProcessor processor) {
        this.processor = processor;
        this.blobCSV = blobCSV;
    }

    private void convertCSVToStr() {
        String b64;
        String strUrlUTF8;
        String csvStr;

        b64 = EncodingUtil.base64Encode(this.blobCSV);
        this.blobCSV = EncodingUtil.base64Decode(b64);

        this.csvData = this.blobCSV.toString();
    }

    global Iterable<String> start(Database.batchableContext batchableContext) {
        System.debug('Constructing iterator to allow for gradual processing of CSV');
        convertCSVToStr();
        this.blobCSV = null;

        String lineSeparator = CSVParser.getLineSeparator(csvData);
        return new CSVParser.LineReader(lineSeparator, csvData);
    }

    global void execute(Database.BatchableContext batchableContext, List<String> scope) {
        System.debug('Running code to process ' + scope.size() + ' lines of CSV');
        System.debug('First row length: ' + scope[0].length());

        // The scope list contains a list of strings, each string being a row of a CSV.
        // To get the actual values, let's just turn it in to a proper CSV file and let the parser get the values for us.
        String csvFile = '';
        for (String row : scope) {
            csvFile += row + '\n';
        }

        List<List<String>> csvLines = CSVParser.parseCSV(csvFile);
        startProcessing(csvLines);
    }

    private void startProcessing(List<List<String>> csvLines) {
        if (headers == null) {
            // This is the first row. We assume that it is a header row.
            // The headers map is a map from column value to column index
            headers = new Map<String, Integer>();
            List<String> headerRow = csvLines[0];
            for (Integer index = 0; index < headerRow.size(); index += 1) {
                String header = headerRow[index];
                if (String.isNotBlank(header)) {
                    headers.put(header, index);
                }
            }
            // Remove the header row from the CSV to be processed
            csvLines.remove(0);
        }

        try {
            processor.handleProcessing(headers, csvLines);
        } catch (Exception e) {
            errors.add(e.getMessage() + '\n' + e.getStackTraceString());
            throw e;
        }
    }

    global void finish(Database.BatchableContext batchableContext) {

        if (errors.size() > 0) {

            String errorsStr = '';
            for (String s : errors) {
                errorsStr += (s + '\n');
            }

            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('text/plain');
            attach.setFileName('Errors - ' + System.now().format() + '.txt');
            attach.setInline(false);
            attach.Body = Blob.valueOf(errorsStr);

            // Send an email to notify a trineo dev
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new List<String> { 'sfdev@trineo.co.nz' });
            mail.setSenderDisplayName(processor.getDebugTitle() + ' ' + (runningInASandbox() ? 'SANDBOX' : ''));
            mail.setSubject('CSV Processing error');
            mail.setPlainTextBody('See attached for errors');
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        System.debug('Done');
    }

    private static Boolean runningInASandbox() {
        return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}