public class TransactionRow {
	public Date transactionDate {get;set;}
    public Integer amount {get;set;}
    public Decimal price {get;set;}
    public Decimal totalPrice {get;set;}
    
    public TransactionRow(Decimal cash, HistoricalRow hRow) {
        this.transactionDate = hRow.tradeDate;
        this.amount = Integer.valueOf(cash / hRow.adjClose);
        this.price = hRow.adjClose;
        this.totalPrice = this.amount * this.price;
    }
    
    public TransactionRow(Integer amount, HistoricalRow hRow, Boolean sellFlag) {
		this.transactionDate = hRow.tradeDate;
        this.amount = 0 - amount;
        this.price = hRow.adjClose;
        this.totalPrice = this.amount * this.price;
    }
    
}