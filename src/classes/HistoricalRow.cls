global class HistoricalRow implements Comparable {
    public Date tradeDate;
    public String dateStr;
    public Decimal volume;
    public Decimal adjClose;
    public Decimal bollTop;
    public Decimal bollBottom;
    public Decimal bollMiddle;
    public Boolean isBuySignal;
    
    public Decimal totalCash {get; set;}
    
    
    public HistoricalRow(String csv, List<Decimal> prevValues, Boolean isSap, HistoricalRow prevRow) {
        List<String> values = csv.split('\\,');
        this.tradeDate = Date.valueOf(values[0]);
        this.dateStr = this.tradeDate.format();
        this.volume = Decimal.valueOf(values[5]);
        this.adjClose = Decimal.valueOf(values[4]);
        this.bollMiddle = BollingerHelper.countMiddleLine(prevValues);
        if (!isSap) {
        	Decimal stdDev = BollingerHelper.countStdDev(this.bollMiddle, prevValues);
            this.bollTop = BollingerHelper.countTopLine(this.bollMiddle, stdDev);
            this.bollBottom = BollingerHelper.countBottomLine(this.bollMiddle, stdDev);
            if (prevRow != null && prevRow.adjClose > prevRow.bollBottom && this.adjClose <= this.bollBottom) {
            	this.isBuySignal = true;
            } else {
            	this.isBuySignal = false;
            }
        }
    }
    
    public void countTotalCash(Decimal availableCash, Integer stocksCount) {
    	this.totalCash = (stocksCount * this.adjClose) + availableCash;
    }
    
    global Integer compareTo(Object compareTo) {
    	HistoricalRow compareToHr = (HistoricalRow) compareTo;
        if (this.tradeDate == compareToHr.tradeDate) return 0;
        if (this.tradeDate > compareToHr.tradeDate) return 1;
        return -1;
    }

}