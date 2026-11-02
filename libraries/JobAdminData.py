"""Helpers for the CMS job management tests (/admin/jobs).

* get_job_rows() reads the table as the user sees it, with one JavaScript call.
* job_problems() holds the "do the rows make sense" checks. Each returns readable problems
  (empty list = passed).
* expected_admin_titles() works out which jobs a filter SHOULD show, from the full list of rows, so a test can
  compare it with what the page shows after the filter is used.
* Nothing here changes data. The Manual Toggle switch is never pressed by the tests.
"""
import datetime
import re

from robot.libraries.BuiltIn import BuiltIn

STATUS_OPEN = "เปิดรับสมัครอยู่"
STATUS_CLOSED = "หมดเขตรับสมัคร (Auto)"
STATUS_DRAFT = "ปิดรับสมัครด้วยมือ"
STATUS_VALUE = {STATUS_OPEN: "open", STATUS_CLOSED: "closed", STATUS_DRAFT: "draft"}
STATUS_NOTE = {
    STATUS_OPEN: "แสดงในหน้า Public และรับใบสมัครได้ตามปกติ",
    STATUS_CLOSED: "ระบบซ่อนจากหน้า Public อัตโนมัติ เพราะเลยวันที่เปิดรับถึงแล้ว",
}
EDIT_PATTERN = re.compile(r"^/admin/jobs/([0-9a-f]{24})$")
LABEL_ID_PATTERN = re.compile(r"([0-9a-f]{24})\s*$")


def _driver():
    return BuiltIn().get_library_instance("SeleniumLibrary").driver


_ROWS_JS = r"""
const lines = (el) => el.innerText.split('\n').map(s => s.trim()).filter(Boolean);
return [...document.querySelectorAll('#adminJobsTableBody tr')]
  .filter(tr => tr.querySelectorAll('td').length >= 6)
  .map(tr => {
    const td = [...tr.querySelectorAll('td')];
    const sw = td[4].querySelector('[role=switch]');
    const edit = td[5].querySelector('a');
    const status = lines(td[3]);
    const kind = lines(td[1]);
    return {title: (lines(td[0])[0] || ''), dept: kind[0] || '', type: kind[1] || '',
            deadline: td[2].innerText.trim(), status: status[0] || '', note: status[1] || '',
            switch_on: sw ? sw.getAttribute('aria-checked') : null, switch_text: sw ? sw.innerText.trim() : '',
            switch_label: sw ? (sw.getAttribute('aria-label') || '') : '', edit: edit ? edit.getAttribute('href') : ''};
  });
"""


def get_job_rows():
    """The job rows on the page now (the 'nothing found' row is not counted)."""
    return _driver().execute_script(_ROWS_JS)


def get_public_job_titles():
    """Titles of the job cards on the public Jobs page that is open now."""
    return _driver().execute_script("return [...document.querySelectorAll('main article h3')].map(h => h.innerText.trim());")


def parse_date(text):
    """'28/11/2026' -> date. None when it is not a real date."""
    match = re.fullmatch(r"(\d{2})/(\d{2})/(\d{4})", (text or "").strip())
    if not match:
        return None
    try:
        return datetime.date(int(match.group(3)), int(match.group(2)), int(match.group(1)))
    except ValueError:
        return None


def _who(row):
    return f"{row['title']} ({row['deadline']})"


def job_problems(check, rows, departments=(), types=()):
    """Run one named check over the rows. Returns a list of problems (empty = passed)."""
    today = datetime.date.today()
    problems = []
    seen_ids = set()
    if check == "newest_first":
        ids = [(EDIT_PATTERN.match(r["edit"] or "") or [None, ""])[1] for r in rows]
        if ids != sorted(ids, reverse=True):
            problems.append(f"rows are not newest first (ids {[i[-6:] for i in ids]})")
        return problems
    for row in rows:
        who = _who(row)
        deadline = parse_date(row["deadline"])
        if check == "complete":
            if not row["title"]:
                problems.append(f"{who}: no title")
            if row["dept"] not in departments:
                problems.append(f"{who}: department '{row['dept']}' is not in the department list")
            if row["type"] not in types:
                problems.append(f"{who}: type '{row['type']}' is not in the type list")
            if deadline is None:
                problems.append(f"{who}: deadline '{row['deadline']}' is not dd/mm/yyyy")
            if row["status"] not in STATUS_VALUE:
                problems.append(f"{who}: unknown status '{row['status']}'")
            if row["switch_on"] is None:
                problems.append(f"{who}: no Manual Toggle switch")
            if not EDIT_PATTERN.match(row["edit"] or ""):
                problems.append(f"{who}: edit link '{row['edit']}'")
        elif check == "status_vs_date":
            if deadline is None:
                continue
            if row["status"] == STATUS_OPEN and deadline < today:
                problems.append(f"{who}: says open but the deadline is before today ({today:%d/%m/%Y})")
            if row["status"] == STATUS_CLOSED and deadline >= today:
                problems.append(f"{who}: says auto-expired but the deadline is not before today ({today:%d/%m/%Y})")
        elif check == "status_note":
            wanted = STATUS_NOTE.get(row["status"])
            if wanted is not None and row["note"] != wanted:
                problems.append(f"{who}: note under '{row['status']}' is '{row['note']}'")
        elif check == "switch":
            on = row["switch_on"]
            if row["status"] == STATUS_DRAFT:
                if on != "false":
                    problems.append(f"{who}: closed by hand but the switch is {on}")
            elif on != "true" or row["switch_text"] != "เปิด":
                problems.append(f"{who}: switch is {on} / '{row['switch_text']}', expected on / 'เปิด'")
        elif check == "ids":
            edit_id = (EDIT_PATTERN.match(row["edit"] or "") or [None, None])[1]
            label_id = (LABEL_ID_PATTERN.search(row["switch_label"]) or [None, None])[1]
            if edit_id is None or edit_id != label_id:
                problems.append(f"{who}: edit link id {edit_id} and switch id {label_id} differ")
            if edit_id in seen_ids:
                problems.append(f"{who}: the same job id appears twice")
            seen_ids.add(edit_id)
        else:
            raise AssertionError(f"Unknown job check: {check}")
    return problems


def should_pass_job_check(check, rows, departments=(), types=()):
    problems = job_problems(check, rows, departments, types)
    if problems:
        shown = "\n".join(problems[:12])
        more = f"\n... and {len(problems) - 12} more" if len(problems) > 12 else ""
        raise AssertionError(f"{len(problems)} problem(s) in {len(rows)} jobs:\n{shown}{more}")


def status_counts(rows):
    """[open, auto-expired, closed by hand] from the rows."""
    return [sum(1 for r in rows if r["status"] == s) for s in (STATUS_OPEN, STATUS_CLOSED, STATUS_DRAFT)]


def expected_admin_titles(rows, title="", department="", job_type="", status="", start="", end=""):
    """Titles (in table order) a filter should show. `status` is open / closed / draft / '' (all)."""
    wanted = title.strip().casefold()
    first, last = parse_date(start), parse_date(end)
    found = []
    for row in rows:
        deadline = parse_date(row["deadline"])
        if wanted and wanted not in row["title"].casefold():
            continue
        if department and row["dept"] != department:
            continue
        if job_type and row["type"] != job_type:
            continue
        if status and STATUS_VALUE.get(row["status"]) != status:
            continue
        if first and (deadline is None or deadline < first):
            continue
        if last and (deadline is None or deadline > last):
            continue
        found.append(row["title"])
    return found
