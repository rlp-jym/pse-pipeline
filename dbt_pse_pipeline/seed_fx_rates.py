import yfinance as yf
import pandas as pd

 # simplify, just get 2 year average
rates = {
	'usdphp': yf.Ticker("USDPHP=X").history(period="2y")['Close'].mean(),
	'cadphp': yf.Ticker("CADPHP=X").history(period="2y")['Close'].mean(),
}
pd.DataFrame(rates.items(), columns=['currency', 'rate']).to_csv('seeds/fx_rates.csv', index=False)