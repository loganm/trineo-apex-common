/**
 * ICSVProcessor.cls
 * Description: Interface for CSV Processing
 * @author: Nathan (Trineo)
 * @date: 24 August 2015 (Monday)
 */
public interface ICSVProcessor {
    String getDebugTitle();
    void handleProcessing(Map<String, Integer> headers, List<List<String>> csvLines);
}