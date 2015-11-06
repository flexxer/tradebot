public class TradeBotController {
    
    public String stock {get; set;}
    public String dFrom {get; set;}
    public String dTo {get; set;}
    public String cash {get; set;}
    
    private Map<Date, Boolean> positiveSaps;
    
    public PageReference run() {
        String url = '/apex/TradeResults?stock=' + EncodingUtil.urlDecode(stock, 'UTF-8') + '&from=' + EncodingUtil.urlDecode(dFrom, 'UTF-8') + '&to=' + EncodingUtil.urlDecode(dTo, 'UTF-8') + '&cash=' + EncodingUtil.urlDecode(cash, 'UTF-8');
        PageReference p = new PageReference(url);
        return p;
    }
    
}