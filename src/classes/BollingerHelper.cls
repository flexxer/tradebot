public class BollingerHelper {
    
    public static Decimal countMiddleLine(List<Decimal> prevRows) {
        if (prevRows.size() != 20) {
            return 0;
        }
        Decimal result = 0;
        for (Decimal row : prevRows) {
            result += row;
        }
        result = result / prevRows.size();
        return result;
    }
    
    public static Decimal countTopLine(Decimal ml, Decimal stdDev) {
        return ml + (stdDev * 2);
    }
    
    public static Decimal countBottomLine(Decimal ml, Decimal stdDev) {
        return ml - (stdDev * 2);
    }
    
    public static Decimal countStdDev(Decimal ml, List<Decimal> prevRows) {
        if (prevRows.size() != 20) {
            return 0;
        }
        Double result = 0;
        for (Decimal row : prevRows) {
            result += Math.pow(Double.valueOf(row - ml), 2);
        }
        result = result / prevRows.size();
        result = Math.sqrt(result);
        return Decimal.valueOf(result);
    }
    
}