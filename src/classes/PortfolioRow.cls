global with sharing class PortfolioRow implements comparable {
    
    public Date milestone {get; set;}
    public String dateStr;
    public Decimal totalCash {get; set;}
    
    public PortfolioRow(Decimal availableCash, Integer stocksCount, HistoricalRow hRow) {
    	this.milestone = hRow.tradeDate;
    	this.totalCash = (stocksCount * hRow.adjClose) + availableCash;
    	this.dateStr = this.milestone.format();
    }
    
    global Integer compareTo(Object compareTo) {
        PortfolioRow compareToPr = (PortfolioRow) compareTo;
        if (this.milestone == compareToPr.milestone) return 0;
        if (this.milestone > compareToPr.milestone) return 1;
        return -1;
    }
    
}