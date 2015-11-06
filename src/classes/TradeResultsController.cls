public with sharing class TradeResultsController {
    
    public transient List<HistoricalRow> hRowsForGraph {get; set;}
    public List<TransactionRow> transactions {get {return transactionsMap.values();} set;}
    public HistoricalRow lastState {get; set;}
    public Integer stocksCount {get; set;}
    public Boolean showResults {get; set;}
    
    private transient Decimal availableCash;
    private transient Map<Date, Boolean> positiveSaps;
    private transient Map<Date, TransactionRow> transactionsMap;
    private transient List<HistoricalRow> hRows;
    private final String stock;
    private final String dateFrom;
    private final String dateTo;
    private final String cash;
    
    public TradeResultsController() {
    	showResults = false;
        stock = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('stock'), 'UTF-8');
        dateFrom = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('from'), 'UTF-8');
        dateTo = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('to'), 'UTF-8');
        cash = EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('cash'), 'UTF-8');
        List<String> dt = dateFrom.split('/');
        Integer yr = Integer.valueOf(dt[2]);
        if (yr < 20) {
        	yr += 2000;
        } else if (yr < 100) {
        	yr +=1900;
        }
        Date dFrom = Date.newInstance(yr, Integer.valueOf(dt[1]), Integer.valueOf(dt[0]));
        dt = dateTo.split('/');
        yr = Integer.valueOf(dt[2]);
        if (yr < 20) {
            yr += 2000;
        } else if (yr < 100) {
            yr +=1900;
        }
        Date dTo = Date.newInstance(yr, Integer.valueOf(dt[1]), Integer.valueOf(dt[0]));
        
        this.hRows = HistoricalHelper.getHistoricalData(stock, dFrom, dTo);
        if (hRows.size() == 0) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No rows returned'));
        	return;
        }
        //this.hRows.sort();
        this.hRows[hRows.size()-1].isBuySignal = true;
        this.positiveSaps = HistoricalHelper.getSapIsPositiveMap(dFrom, dTo);
        removeHrowsWithoutBollingerLines();
        buildTransactions();
        buildGraphRows();
        lastState = hRows[hRows.size()-1];
        showResults = true;
        
    }
    
    private void buildTransactions() {
        stocksCount = 0;
        availableCash = Decimal.valueOf(cash);
        transactionsMap = new Map<Date, TransactionRow>();
        Integer i = 0;
        while (i < hRows.size()) {
        	if (hRows[i].isBuySignal && (positiveSaps.get(hRows[i].tradeDate) != null || i == hRows.size()-1)) {//found a signal. then we must find a next signal
        		Boolean seekingNextSignal = true;
        		Integer startIdx = i + 1;
        		Integer stopIdx = i + 2;
        		Integer j = i;
        		while (seekingNextSignal && j <= hRows.size()-2) {
        			j++;
        			if (hRows[j].isBuySignal && (positiveSaps.get(hRows[j].tradeDate) != null || j == hRows.size()-1)) {
        				seekingNextSignal = false; //next signal found
        				stopIdx = j;
        			}
        		}
        		
        		HistoricalRow possibleSellRow = getSellRow(startIdx, stopIdx); //seek max profit between two signals
        		if (possibleSellRow == null) { // we reach eof
        			break;
        		}
        		if (hRows[i].adjClose < possibleSellRow.adjClose){ //if max profit greater than buy total price - create buy & sell transactions
        			TransactionRow tRow = new TransactionRow(availableCash, hRows[i]);
                    transactionsMap.put(tRow.transactionDate, tRow);
                    availableCash = availableCash - tRow.totalPrice;
                    stocksCount = tRow.amount;
                    tRow = new TransactionRow(stocksCount, possibleSellRow, true);
	                transactionsMap.put(tRow.transactionDate, tRow);
	                availableCash = availableCash - tRow.totalPrice;
	                stocksCount = 0;
	                i = j - 1;// go to next signal
        		}
        		
        	}
        	i++;
        }
        stocksCount = 0;
        availableCash = Decimal.valueOf(cash);
        for (Integer a = 0; a < hRows.size(); a++) {
        	TransactionRow t = transactionsMap.get(hRows[a].tradeDate);
        	if (t == null) {
        		hRows[a].countTotalCash(availableCash, stocksCount);
        	} else {
        		stocksCount = stocksCount + t.amount;
        		availableCash = availableCash - t.totalPrice;
        		hRows[a].countTotalCash(availableCash, stocksCount);
        	}
        }
    }
    
    private void buildGraphRows() {
    	//if (hrows.size() <= 300) {
    	if (true) {
    		hRowsForGraph = hRows;
    		return;
    	}
    	hRowsForGraph = new List<HistoricalRow>();
    	hRowsForGraph.add(hRows[0]);
    	Integer div = hRows.size() / 300;
    	for (Integer i = 1; i < hRows.size()-2; i++) {
    		if (Math.mod(i, div) == 0) {
    			hRowsForGraph.add(hRows[i]);
    		}
    	}
    	hRowsForGraph.add(hRows[hRows.size()-1]);
    }
    
    private HistoricalRow getSellRow(Integer startIndex, Integer stopIndex) {
    	if (startIndex >= hRows.size()) {
            return null;
        }
    	HistoricalRow max = hRows[startIndex];
    	for (Integer i = startIndex; i <= stopIndex; i++) {
    		if (max.adjClose < hRows[i].adjClose) {
    			max = hRows[i];
    		}
    	}
    	return max;
    }
    
    private void removeHrowsWithoutBollingerLines() {
        List<HistoricalRow> onlyFullHrows = new List<HistoricalRow>();
        for (HistoricalRow row : hRows) {
            if (row.bollMiddle != 0) {
                onlyFullHrows.add(row);
            }
        }
        hRows = onlyFullHrows;
    }
    
}