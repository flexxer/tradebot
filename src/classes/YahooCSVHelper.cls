public class YahooCSVHelper {
    
    public static String getHistoricalData(String source, Date dateFrom, Date dateTo) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(getEndpoint(source, dateFrom.addMonths(-1), dateTo));
        request.setMethod('GET');
        Http h = new Http();
        HttpResponse response = h.send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        }
        return null;
    }
    
    private static String getEndpoint(String source, Date dateFrom, Date dateTo) {
        String result = 'http://ichart.yahoo.com/table.csv?s=' + source;
        result += '&a=' + (dateFrom.month() - 1);
        result += '&b=' + dateFrom.day();
        result += '&c=' + dateFrom.year();
        result += '&d=' + (dateTo.month() - 1);
        result += '&e=' + dateTo.day();
        result += '&f=' + dateTo.year();
        result += '&g=d&ignore=.csv';
        return result;
    }
    //http://ichart.yahoo.com/table.csv?s=GOOG&a=0&b=1&c=2000&d=0&e=31&f=2010&g=w&ignore=.csv
}