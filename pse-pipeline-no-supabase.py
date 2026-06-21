import os
import re                   
import time
import requests             
import pandas as pd
from datetime import date, datetime, timedelta
from bs4 import BeautifulSoup   

HISTORY_DIR = "Price"  
BASE_URL = "https://edge.pse.com.ph"
RATE_LIMIT_SEC = 0.75

os.makedirs(HISTORY_DIR, exist_ok=True)

session = requests.Session()
session.headers.update({"User-Agent": "Mozilla/5.0"}) 

# Step 1: Get company list

def get_company_list():
    companies = []
    seen_ids = set()
    page = 1

    while True:     
        url = BASE_URL + f"/companyDirectory/search.ax?pageNo={page}"
        resp = session.get(url, headers={"Referer": BASE_URL + "/companyDirectory/form.do"})
        soup = BeautifulSoup(resp.text, "html.parser")
        rows = soup.select("table.list tbody tr")

        new_on_page = 0
        for row in rows:
            tds = row.find_all("td")
            if len(tds) < 2:
                continue    

            name_anchor = tds[0].find("a")
            symbol_anchor = tds[1].find("a")
            if not name_anchor or not symbol_anchor:
                continue

            match = re.search(r"cmDetail\('(\d+)',\s*'(\d+)'\)", name_anchor.get("onclick", ""))
            if not match:
                continue

            company_id, security_id = match.groups()

            if company_id in seen_ids:
                continue    
            seen_ids.add(company_id)
            new_on_page += 1

            companies.append({
                "symbol":      symbol_anchor.text.strip(),
                "company_id":  company_id,
                "security_id": security_id,
            })

        if new_on_page == 0:
            break       
        page += 1
        time.sleep(RATE_LIMIT_SEC)

    print(f"Found {len(companies)} companies")
    return companies

# Step 2: Smart start date

def get_start_date(symbol):
    path = os.path.join(HISTORY_DIR, f"{symbol}.parquet")

    if not os.path.exists(path):
        return "01-01-1800"

    df = pd.read_parquet(path)
    if df.empty:
        return "01-01-1800"

    last_date = pd.to_datetime(df["Date"]).max() 
    return (last_date - timedelta(days=15)).strftime("%m-%d-%Y")

# Step 3: Download prices for one company

def download_prices(company):
    symbol = company["symbol"]

    payload = {
        "cmpy_id":     company["company_id"],
        "security_id": company["security_id"],
        "startDate":   get_start_date(symbol),
        "endDate":     date.today().strftime("%m-%d-%Y"),
    }

    resp = session.post(
        BASE_URL + "/common/DisclosureCht.ax",
        json=payload,
        headers={
            "Referer": BASE_URL + "/companyPage/stockData.do",
            "X-Requested-With": "XMLHttpRequest"
        }
    )

    records = []
    for item in resp.json().get("chartData", []):
        try:
            records.append({
                "Date": datetime.strptime(item["CHART_DATE"], "%b %d, %Y %H:%M:%S").date(),
                "Symbol": f"{symbol}.PS",
                "Open": item.get("OPEN"),
                "High": item.get("HIGH"),
                "Low": item.get("LOW"),
                "Close": item.get("CLOSE"),
                "Value": item.get("VALUE"),
            })
        except (KeyError, ValueError):
            continue

    return pd.DataFrame(records) if records else None

# Step 4. Save as parquet

def save_parquet(symbol, new_df):
    path = os.path.join(HISTORY_DIR, f"{symbol}.parquet")

    if os.path.exists(path):
        existing = pd.read_parquet(path)
        new_df = pd.concat([existing, new_df], ignore_index=True)

    new_df["Date"] = pd.to_datetime(new_df["Date"])
    new_df = (new_df
        .drop_duplicates("Date", keep="last")
        .sort_values("Date")
        .reset_index(drop=True)
    )
    new_df.to_parquet(path, index=False)

# # # # # # # # # # # # # # # # # # # # # # # # # 

companies = get_company_list()

for i, company in enumerate(companies):
    symbol = company["symbol"]
    try:
        df = download_prices(company)
        if df is not None and not df.empty:
            save_parquet(symbol, df)
            print(f"[{i+1}/{len(companies)}] {symbol} saved {len(df)} rows")
        else:
            print(f"[{i+1}/{len(companies)}] {symbol} no data")
    except Exception as e:
        print(f"[{i+1}/{len(companies)}] {symbol} ERROR: {e}")

    time.sleep(RATE_LIMIT_SEC)

