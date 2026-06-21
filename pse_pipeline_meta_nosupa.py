import os
import re
import json
import time
import requests
import pandas as pd
from bs4 import BeautifulSoup
from typing import Dict, List

base_url = "https://edge.pse.com.ph"
meta_dir = "Meta"  
os.makedirs(meta_dir, exist_ok=True)
session = requests.Session()
session.headers.update({"User-Agent": "Mozilla/5.0"}) 
session.cookies.set("access", "approve", domain="edge.pse.com.ph", path="/")
request_delay = 1

def get_company_list() -> List[Dict]:
    companies = []
    page_no = 1
    url = f"{base_url}/companyDirectory/search.ax"

    while True:
        payload = {
            "pageNo": page_no,
            "keyword": "",
            "companyId": "",
            "sortType": "",
            "dateSortType": "DESC",
            "cmpySortType": "",
            "symbolSortType": ""
        }

        try:
            resp = session.post(url, data=payload, timeout=30)
            if resp.status_code != 200:
                break
        except Exception as e:
            print(f"  Request failed: {e}")
            break

        soup = BeautifulSoup(resp.text, "html.parser")
        table = soup.find("table", class_="list")
        if not table:
            break
        tbody = table.find("tbody")
        if not tbody:
            break
        rows = tbody.find_all("tr")
        if not rows:
            break

        page_companies = 0
        for row in rows:
            cols = row.find_all("td")
            if len(cols) < 5:
                continue
            name_link = cols[0].find("a")
            if not name_link:
                continue
            onclick = name_link.get("onclick", "")
            match = re.search(r"cmDetail\('(\d+)','(\d+)'\)", onclick)
            if not match:
                continue
            cmpy_id = match.group(1)
            security_id = match.group(2)
            name = name_link.get_text(strip=True)
            symbol_cell = cols[1]
            symbol_link = symbol_cell.find("a")
            symbol = symbol_link.get_text(strip=True) if symbol_link else symbol_cell.get_text(strip=True)

            companies.append({
                "cmpy_id": cmpy_id,
                "security_id": security_id,
                "name": name,
                "symbol": symbol,
            })
            page_companies += 1

        print(f"Found {page_companies} companies on page {page_no}")
        if page_companies == 0:
            break
        page_no += 1
        time.sleep(request_delay / 2)

    print(f"Found {len(companies)} companies\n")
    return companies

def get_stock_data(cmpy_id: str) -> Dict:
    url = f"{base_url}/companyPage/stockData.do?cmpy_id={cmpy_id}"
    try:
        resp = session.get(url, timeout=30)
        resp.raise_for_status()
    except Exception as e:
        print(f"  Stock data page error: {e}")
        return {}

    soup = BeautifulSoup(resp.text, "html.parser")
    result = {}

    all_tables = soup.find_all("table", class_="view")
    for table in all_tables:
        for row in table.find_all("tr"):
            ths = row.find_all("th")
            tds = row.find_all("td")
            if not ths or not tds:
                continue
            if len(ths) == len(tds):
                for th, td in zip(ths, tds):
                    key = th.get_text(strip=True).lower()
                    value = td.get_text(strip=True)
                    if "issue type" in key:
                        result["issue_type"] = value
                    elif "isin" in key:
                        result["isin"] = value
                    elif "market capitalization" in key:
                        result["market_cap"] = value
                    elif "outstanding shares" in key:
                        result["outstanding_shares"] = value
                    elif "free float level" in key:
                        result["free_float_percent"] = value

    return result

def company_details(cmpy_id: str) -> Dict:
    url = f"{base_url}/companyInformation/form.do?cmpy_id={cmpy_id}"
    try:
        resp = session.get(url, timeout=30)
        resp.raise_for_status()
    except Exception as e:
        print(f"  Company info error: {e}")
        return {}

    soup = BeautifulSoup(resp.text, "html.parser")
    result = {}

    desc_table = None
    for table in soup.find_all("table", class_="view"):
        caption = table.find("caption")
        if caption and re.search(r"Company Description", caption.get_text(strip=True), re.I):
            desc_table = table
            break
    if desc_table:
        td = desc_table.find("td")
        result["company_description"] = td.get_text(strip=True) if td else ""
    else:
        data_list = soup.find("div", id="dataList")
        if data_list:
            for p in data_list.find_all("p"):
                text = p.get_text(strip=True)
                if len(text) > 200:
                    result["company_description"] = text
                    break
        if "company_description" not in result:
            result["company_description"] = ""

    sec_table = None
    for table in soup.find_all("table", class_="view"):
        caption = table.find("caption")
        if caption and re.search(r"Security Information", caption.get_text(strip=True), re.I):
            sec_table = table
            break
    if sec_table:
        for row in sec_table.find_all("tr"):
            th = row.find("th")
            td = row.find("td")
            if th and td:
                key = th.get_text(strip=True).lower().replace(" ", "_")
                value = td.get_text(strip=True)
                result[key] = value

    return result

def parse_financial_table(table) -> Dict:
    data = {}
    headers = []
    thead = table.find("thead")
    if thead:
        ths = thead.find_all("th")
        headers = [th.get_text(strip=True) for th in ths[1:]]
    for row in table.find_all("tr"):
        th = row.find("th")
        tds = row.find_all("td")
        if th and tds:
            item = th.get_text(strip=True)
            values = [td.get_text(strip=True) for td in tds]
            if headers and len(values) == len(headers):
                data[item] = dict(zip(headers, values))
            else:
                data[item] = values
    return data

def get_financial_reports(cmpy_id: str) -> Dict:
    url = f"{base_url}/companyPage/financial_reports_view.do?cmpy_id={cmpy_id}"
    try:
        resp = session.get(url, timeout=30)
        resp.raise_for_status()
    except Exception as e:
        print(f"  Financial reports error: {e}")
        return {}

    soup = BeautifulSoup(resp.text, "html.parser")
    result = {}

    annual_h3 = soup.find("h3", string=re.compile(r"Annual", re.I))
    if annual_h3:
        p = annual_h3.find_next_sibling("p", class_="textCont")
        if p:
            text = p.get_text(strip=True)
            fy_match = re.search(r"fiscal year ended\s*:\s*(\w+\s\d+,\s\d+)", text, re.I)
            if fy_match:
                result["annual_fiscal_year_ended"] = fy_match.group(1)
            curr_match = re.search(r"Currency.*?:\s*(.+)", text, re.I)
            if curr_match:
                result["annual_currency"] = curr_match.group(1).strip()
        tables = annual_h3.find_next_siblings("table", class_="view", limit=2)
        if len(tables) >= 1:
            result["annual_balance_sheet"] = parse_financial_table(tables[0])
        if len(tables) >= 2:
            result["annual_income_statement"] = parse_financial_table(tables[1])

    qtr_h3 = soup.find("h3", string=re.compile(r"Quarterly", re.I))
    if qtr_h3:
        p = qtr_h3.find_next_sibling("p", class_="textCont")
        if p:
            text = p.get_text(strip=True)
            period_match = re.search(r"period ended\s*:\s*(\w+\s\d+,\s\d+)", text, re.I)
            if period_match:
                result["quarterly_period_ended"] = period_match.group(1)
            curr_match = re.search(r"Currency.*?:\s*(.+)", text, re.I)
            if curr_match:
                result["quarterly_currency"] = curr_match.group(1).strip()
        tables = qtr_h3.find_next_siblings("table", class_="view", limit=2)
        if len(tables) >= 1:
            result["quarterly_balance_sheet"] = parse_financial_table(tables[0])
        if len(tables) >= 2:
            result["quarterly_income_statement"] = parse_financial_table(tables[1])

    return result

def flatten_dict(d: Dict, parent_key: str = '', sep: str = '.') -> Dict:
    items = []
    for k, v in d.items():
        new_key = f"{parent_key}{sep}{k}" if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten_dict(v, new_key, sep=sep).items())
        elif isinstance(v, list):
            items.append((new_key, json.dumps(v, default=str)))
        else:
            items.append((new_key, v))
    return dict(items)

def save_parquet(company: Dict, stock_data: Dict, info_data: Dict, fin_data: Dict) -> Dict:
    orig_symbol = company["symbol"]
    symbol_ps = orig_symbol + ".PS"
    meta_path = os.path.join(meta_dir, f"{orig_symbol}.parquet")

    company_with_ps = company.copy()
    company_with_ps["symbol"] = symbol_ps

    full_meta = {
        "company_info": company_with_ps,
        "stock_data": stock_data,
        "company_details": info_data,
        "financial_reports": fin_data
    }

    flat_meta = flatten_dict(full_meta)
    df_meta = pd.DataFrame([flat_meta])
    df_meta.to_parquet(meta_path, index=False)
    print(f"[{idx}/{total}] {orig_symbol}")

    summary = {
        "cmpy_id": company.get("cmpy_id", ""),
        "symbol": symbol_ps,
        "company_name": company.get("name", ""),
        "sector": company.get("sector", ""),
        "subsector": company.get("subsector", ""),
        "issue_type": stock_data.get("issue_type", ""),
        "isin": stock_data.get("isin", ""),
        "market_cap": stock_data.get("market_cap", ""),
        "outstanding_shares": stock_data.get("outstanding_shares", ""),
        "free_float_percent": stock_data.get("free_float_percent", ""),
        "company_description": info_data.get("company_description", ""),
        "annual_fiscal_year_ended": fin_data.get("annual_fiscal_year_ended", ""),
        "annual_currency": fin_data.get("annual_currency", "")
    }

    bs_annual = fin_data.get("annual_balance_sheet", {})
    if "Total Assets" in bs_annual:
        summary["total_assets_annual_curr"] = bs_annual["Total Assets"][0] if isinstance(bs_annual["Total Assets"], list) else bs_annual["Total Assets"]
    if "Total Liabilities" in bs_annual:
        summary["total_liabilities_annual_curr"] = bs_annual["Total Liabilities"][0] if isinstance(bs_annual["Total Liabilities"], list) else bs_annual["Total Liabilities"]
    if "Stockholders' Equity" in bs_annual:
        summary["equity_annual_curr"] = bs_annual["Stockholders' Equity"][0] if isinstance(bs_annual["Stockholders' Equity"], list) else bs_annual["Stockholders' Equity"]

    inc_annual = fin_data.get("annual_income_statement", {})
    if "Net Income/(Loss) Attributable to Parent" in inc_annual:
        summary["net_income_parent_annual_curr"] = inc_annual["Net Income/(Loss) Attributable to Parent"][0] if isinstance(inc_annual["Net Income/(Loss) Attributable to Parent"], list) else inc_annual["Net Income/(Loss) Attributable to Parent"]

    summary["quarterly_period_ended"] = fin_data.get("quarterly_period_ended", "")
    q_inc = fin_data.get("quarterly_income_statement", {})
    if "Net Income/(Loss) Attributable to Parent" in q_inc:
        ytd_val = q_inc["Net Income/(Loss) Attributable to Parent"][2] if isinstance(q_inc["Net Income/(Loss) Attributable to Parent"], list) and len(q_inc["Net Income/(Loss) Attributable to Parent"]) > 2 else None
        summary["net_income_parent_ytd_curr"] = ytd_val

    return summary

# # # # # # # # # # # # # # # # # # # # # # # # # 

print("Starting PSE Meta Downloader...")
companies = get_company_list()
if not companies:
    print("No companies found. Exiting.")

all_summaries = []
total = len(companies)
for idx, comp in enumerate(companies, 1):
    try:
        stock = get_stock_data(comp["cmpy_id"])
        info = company_details(comp["cmpy_id"])
        fin = get_financial_reports(comp["cmpy_id"])
        save_parquet(comp, stock, info, fin)
    except Exception as e:
        print(f"  Error processing {comp['cmpy_id']}: {e}")
    time.sleep(request_delay)