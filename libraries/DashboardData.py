"""Helpers for the CMS dashboard tests (/admin/dashboard).

* Reads the summary cards, the applicant table and its footer with one JavaScript call each, so
  the Robot keywords stay short.
* Turns the Thai date on the page ("2 พ.ย. 2569 16:39 น.") into an ISO string, so dates can be compared.
* Reads the Excel file made by the "Export Report" button (no extra package needed).
"""
import datetime
import glob
import math
import os
import re
import time
import zipfile

from robot.libraries.BuiltIn import BuiltIn

PAGE_SIZE = 20
THAI_MONTHS = {"ม.ค.": 1, "ก.พ.": 2, "มี.ค.": 3, "เม.ย.": 4, "พ.ค.": 5, "มิ.ย.": 6,
               "ก.ค.": 7, "ส.ค.": 8, "ก.ย.": 9, "ต.ค.": 10, "พ.ย.": 11, "ธ.ค.": 12}


def _driver():
    return BuiltIn().get_library_instance("SeleniumLibrary").driver


# ---------------------------------------------------------------- page reading
_ROWS_JS = """
const out = [];
const lines = (el) => el.innerText.split('\\n').map(s => s.trim()).filter(Boolean);
document.querySelectorAll('#recent-applicants tbody tr').forEach(tr => {
  const tds = [...tr.querySelectorAll('td')];
  if (tds.length < 6) { out.push({empty: true, text: tr.innerText.trim()}); return; }
  const link = tds[5].querySelector('a');
  const who = lines(tds[1]);
  const ai = lines(tds[3]);
  out.push({empty: false, date: tds[0].innerText.trim(), name: who[0] || '', email: who[1] || '',
            badge: who[2] || '', job: tds[2].innerText.trim(), ai_label: ai[0] || '',
            ai_score: ai[1] || '', status: tds[4].innerText.trim(),
            href: link ? link.getAttribute('href') : '',
            aria: link ? (link.getAttribute('aria-label') || '') : ''});
});
return out;
"""

_SUMMARY_JS = """
const sec = [...document.querySelectorAll('section')].find(s => s.getAttribute('aria-label') === arguments[0]);
if (!sec) { return null; }
return [...sec.querySelectorAll('[data-slot="card"]')]
  .map(c => c.innerText.split('\\n').map(s => s.trim()).filter(Boolean));
"""


def get_table_rows():
    """The applicant rows on the page (the 'nothing found' row is not counted)."""
    rows = _driver().execute_script(_ROWS_JS)
    return [r for r in rows if not r.get("empty")]


def table_shows_empty_state():
    rows = _driver().execute_script(_ROWS_JS)
    return any(r.get("empty") for r in rows)


def get_table_footer():
    """Footer text as numbers. kind is 'pages' (page X of Y, total N) or 'count' (shows N items)."""
    text = _driver().execute_script("return document.querySelector('#recent-applicants').innerText;")
    match = re.search(r"หน้า\s*(\d+)\s*จาก\s*(\d+)\s*·\s*ทั้งหมด\s*(\d+)\s*รายการ", text)
    if match:
        return {"kind": "pages", "page": int(match.group(1)), "pages": int(match.group(2)),
                "total": int(match.group(3))}
    match = re.search(r"แสดง\s*(\d+)\s*รายการ", text)
    if match:
        return {"kind": "count", "page": 1, "pages": 1, "total": int(match.group(1))}
    raise AssertionError("The table footer ('หน้า X จาก Y' or 'แสดง N รายการ') was not found")


def get_result_total():
    """How many applicants match the current filter, whichever footer is shown."""
    return get_table_footer()["total"]


def get_dashboard_summary(label="สรุปสถานะผู้สมัคร"):
    """Summary cards as numbers: {total, total_label, total_desc, flow[], cards[{label,count,desc}]}."""
    cards = _driver().execute_script(_SUMMARY_JS, label)
    if not cards or len(cards) < 2:
        raise AssertionError("The summary cards were not found")
    first = cards[0]
    if len(first) < 3:
        raise AssertionError(f"The total card has an unexpected shape: {first}")

    def whole(text, where):
        if not re.fullmatch(r"\d+", text):
            raise AssertionError(f"The number on the '{where}' card is not a whole number: {text!r}")
        return int(text)

    result = {"total_label": first[0], "total": whole(first[1], first[0]), "total_desc": first[2],
              "flow": first[4:] if len(first) > 4 else [], "cards": []}
    for card in cards[1:]:
        if len(card) < 3:
            raise AssertionError(f"A status card has an unexpected shape: {card}")
        result["cards"].append({"label": card[0], "count": whole(card[1], card[0]), "desc": card[2]})
    return result


# ---------------------------------------------------------------- dates
def thai_datetime_to_iso(text):
    """'2 พ.ย. 2569 16:39 น.' -> '2026-11-02T16:39'."""
    match = re.fullmatch(r"(\d{1,2}) (\S+) (\d{4}) (\d{1,2}):(\d{2}) น\.", text.strip())
    if not match:
        raise AssertionError(f"The date does not look like '2 พ.ย. 2569 16:39 น.': {text!r}")
    day, month_text, year, hour, minute = match.groups()
    if month_text not in THAI_MONTHS:
        raise AssertionError(f"Unknown Thai month in the date: {text!r}")
    year = int(year)
    if year > 2400:  # Buddhist year
        year -= 543
    value = datetime.datetime(year, THAI_MONTHS[month_text], int(day), int(hour), int(minute))
    return value.strftime("%Y-%m-%dT%H:%M")


def export_datetime_to_iso(text):
    """'02/11/2026 09:39' -> '2026-11-02T09:39'."""
    match = re.fullmatch(r"(\d{2})/(\d{2})/(\d{4}) (\d{2}):(\d{2})", text.strip())
    if not match:
        raise AssertionError(f"The export date does not look like '02/11/2026 09:39': {text!r}")
    day, month, year, hour, minute = match.groups()
    return f"{year}-{month}-{day}T{hour}:{minute}"


def times_in_the_future(rows, tolerance_minutes=5):
    """Application times that are later than 'now' on this computer (set to Bangkok time)."""
    limit = datetime.datetime.now() + datetime.timedelta(minutes=int(tolerance_minutes))
    late = []
    for row in rows:
        when = datetime.datetime.strptime(thai_datetime_to_iso(row["date"]), "%Y-%m-%dT%H:%M")
        if when > limit:
            late.append(row["date"])
    return late


def today_text(fmt="%Y%m%d"):
    return datetime.datetime.now().strftime(fmt)


def pages_for(total):
    return max(1, math.ceil(int(total) / PAGE_SIZE))


# ---------------------------------------------------------------- download + Excel
def set_download_folder(path):
    path = os.path.abspath(path)
    os.makedirs(path, exist_ok=True)
    for name in glob.glob(os.path.join(path, "*")):
        os.remove(name)
    driver = _driver()
    try:
        driver.execute_cdp_cmd("Browser.setDownloadBehavior", {"behavior": "allow", "downloadPath": path})
    except Exception:
        driver.execute_cdp_cmd("Page.setDownloadBehavior", {"behavior": "allow", "downloadPath": path})
    return path


def wait_for_download(folder, timeout=40):
    """Path of the finished .xlsx file in the folder."""
    end = time.time() + float(timeout)
    while time.time() < end:
        done = [p for p in glob.glob(os.path.join(folder, "*.xlsx"))]
        partial = glob.glob(os.path.join(folder, "*.crdownload")) + glob.glob(os.path.join(folder, "*.tmp"))
        if done and not partial:
            return done[0]
        time.sleep(0.5)
    raise AssertionError(f"No finished .xlsx file appeared in {folder} within {timeout}s")


def _sheet_rows(archive, name, strings):
    xml = archive.read(f"xl/worksheets/{name}.xml").decode("utf-8")
    rows = []
    for row in re.findall(r"<row [^>]*>(.*?)</row>", xml, re.S):
        cells = []
        for attrs, value in re.findall(r"<c [^>]*?r=\"[A-Z]+\d+\"([^>]*?)(?:/>|>(?:<v>([^<]*)</v>)?(?:</c>)?)", row):
            if 't="s"' in attrs and value:
                cells.append(strings[int(value)])
            else:
                cells.append(value or "")
        rows.append(cells)
    return rows


def read_export_workbook(path):
    """{summary: {label: number}, applicants: [..], jobs: [..], sheets: [names]}"""
    archive = zipfile.ZipFile(path)
    raw = re.findall(r"<si>(.*?)</si>", archive.read("xl/sharedStrings.xml").decode("utf-8"), re.S)
    strings = ["".join(re.findall(r"<t[^>]*>([^<]*)</t>", item)) for item in raw]
    sheets = re.findall(r'<sheet [^>]*name="([^"]*)"', archive.read("xl/workbook.xml").decode("utf-8"))
    first = _sheet_rows(archive, "sheet1", strings)
    second = _sheet_rows(archive, "sheet2", strings)

    summary, applicants = {}, []
    header_at = next(i for i, r in enumerate(first) if r and r[0] == "วันที่สมัคร")
    for cells in first[:header_at]:
        if len(cells) >= 2 and re.fullmatch(r"\d+", cells[1]):
            summary[cells[0]] = int(cells[1])
    header = first[header_at]
    for cells in first[header_at + 1:]:
        if cells and any(cells):
            applicants.append(dict(zip(header, cells)))

    jobs_header_at = next(i for i, r in enumerate(second) if r and r[0] == "ชื่อตำแหน่ง")
    jobs = [dict(zip(second[jobs_header_at], c)) for c in second[jobs_header_at + 1:] if c and any(c)]
    return {"summary": summary, "applicants": applicants, "jobs": jobs, "sheets": sheets}
