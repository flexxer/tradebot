public class HistoricalHelper {

    public static Map<Date, Boolean> getSapIsPositiveMap(Date startDate, Date endDate) {
        String csv = YahooCSVHelper.getHistoricalData('^GSPC', startDate, endDate);
        if (String.isBlank(csv)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Standard & Poor indexes are not found'));
            return new Map<Date, Boolean>();
        }
        List<String> sapRows = csv.split('\n');
        Map<Date, Boolean> result = new Map<Date, Boolean>();
        List<HistoricalRow> sapIndexes = new List<HistoricalRow>();
        for (Integer i = sapRows.size() - 1; i > 0; i--) {
			List<String> sapRow = sapRows[i].split('\\,');
            sapIndexes.add(new HistoricalRow(sapRows[i], getPrevRows(sapIndexes), true, null));
        }
        for (HistoricalRow row : sapIndexes) {
            if (row.adjClose >= row.bollMiddle) {
				result.put(row.tradeDate, true);
            }
        }
        return result;
    }
    
    public static List<HistoricalRow> getHistoricalData(String company, Date startDate, Date endDate) {
        String csv = YahooCSVHelper.getHistoricalData(company, startDate, endDate);
        if (String.isBlank(csv)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Historical Data for "' + company + '" ID is not found'));
            return new List<HistoricalRow>();
        }
        List<String> rows = csv.split('\n');
        List<HistoricalRow> hRows = new List<HistoricalRow>();
        //for (String s : rows) {
        for (Integer i = rows.size() - 1; i > 0; i--) {
        	if (hRows.size()-1 >= 0) {
        		hRows.add(new HistoricalRow(rows[i], getPrevRows(hRows), false, hRows[hRows.size()-1]));
        	} else {
        		hRows.add(new HistoricalRow(rows[i], getPrevRows(hRows), false, null));
        	}
			
        }
        return hRows;
    }
    
    private static List<Decimal> getPrevRows(List<HistoricalRow> allRows) {
        List<Decimal> result = new List<Decimal>();
        Integer lastIndex = allRows.size() - 20;
        if (lastIndex < 0) {
			lastIndex = 0;
        }
        for (Integer i = allRows.size() - 1; i > = lastIndex; i--) {
            result.add(allRows[i].adjClose);
        }
        return result;
    }
    
}