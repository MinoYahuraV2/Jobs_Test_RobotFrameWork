"""Helpers for the CMS applicant profile tests (/admin/applications/<id>).

* read_profiles() downloads many profile pages with one JavaScript call (same browser session, so it
  is logged in) and turns each page into a plain dict. That makes it cheap to check every applicant
  instead of only the first one.
* profile_problems() holds the "does this profile make sense" checks. Each returns a list of
  readable problems; an empty list means the check passed.
* Nothing here changes data on the site. Only GET requests are made.
"""
import datetime
import re
import time
import urllib.request

from robot.api import SkipExecution
from robot.libraries.BuiltIn import BuiltIn

THAI_MONTHS = {"ม.ค.": 1, "ก.พ.": 2, "มี.ค.": 3, "เม.ย.": 4, "พ.ค.": 5, "มิ.ย.": 6,
               "ก.ค.": 7, "ส.ค.": 8, "ก.ย.": 9, "ต.ค.": 10, "พ.ย.": 11, "ธ.ค.": 12}
NO_HISTORY_TEXT = "ไม่พบประวัติเดิม"
EMPTY_LOG_TEXT = "ยังไม่มีประวัติการส่งอีเมล"
NO_EXTRA_FILES_TEXT = "ไม่มีไฟล์แนบเพิ่มเติม"
AUTO_REPLY_TYPE = "ตอบรับใบสมัครอัตโนมัติ"
AUTO_SENDER = "ระบบอัตโนมัติ"
AI_IN_PROGRESS = "กำลังวิเคราะห์"   # seen on dev while the AI still reads a new CV
AI_HISTORY_PLACEHOLDER = "AINeedReviewScore:-"


def _driver():
    return BuiltIn().get_library_instance("SeleniumLibrary").driver


# ---------------------------------------------------------------- reading profile pages
_PARSE_JS = r"""
const done = arguments[arguments.length - 1];
const paths = arguments[0];
const text = (el) => el ? el.textContent.replace(/\s+/g, ' ').trim() : '';
const parse = (path, html, status) => {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  // The server streams parts of the page (React Suspense): the HTML holds <template id="P:x"> holes and the
  // content arrives later in a hidden element id="S:x". The browser swaps them with a script; do the same here.
  for (let pass = 0; pass < 6; pass++) {
    let moved = 0;
    doc.querySelectorAll('template[id^="P:"]').forEach(hole => {
      const part = doc.getElementById('S:' + hole.id.slice(2));
      if (!part) return;
      const holder = part.closest('table[hidden], div[hidden]');
      hole.replaceWith(...part.childNodes);
      if (holder) holder.remove(); else part.remove();
      moved++;
    });
    if (!moved) break;
  }
  const out = {path: path, status: status, title: doc.title};
  const sel = doc.querySelector('#profileHrStatus');
  if (!sel) { out.missing = true; out.text = text(doc.body).slice(0, 300); return out; }
  const field = (name) => {
    const l = [...doc.querySelectorAll('label')].find(x => text(x).toLowerCase() === name.toLowerCase());
    return l ? l.nextElementSibling : null;
  };
  const form = doc.querySelector('#applicant-status-form');
  const after = (root, label) => {
    const s = [...root.querySelectorAll('span')].find(x => text(x) === label);
    return s ? text(s.nextElementSibling) : null;
  };
  const section = (id) => { const h = doc.getElementById(id); return h ? h.closest('section') : null; };
  out.first = text(field('ชื่อ'));
  out.last = text(field('นามสกุล'));
  out.email = text(field('E-Mail'));
  out.phone = text(field('เบอร์ติดต่อกลับ'));
  out.job = text(field('ตำแหน่งที่สมัคร'));
  out.salary = text(field('เงินเดือนที่คาดหวัง'));
  const src = field('ช่องทางที่ทราบข่าวสมัครงาน');
  out.sources = src ? [...src.querySelectorAll('span')].map(text) : [];
  out.consent = text(field('Consent Form'));
  const applied = [...doc.querySelectorAll('span')].find(s => text(s).startsWith('วันที่สมัคร:'));
  out.applied = applied ? text(applied).replace('วันที่สมัคร:', '').trim() : '';
  out.ai_label = after(form, 'ผลประเมิน AI');
  out.ai_score = after(form, 'คะแนน AI');
  const bar = form.querySelector('[role=progressbar]');
  out.bar = bar ? bar.getAttribute('aria-valuenow') : null;
  out.status_value = sel.value;
  const chosen = sel.querySelector('option[selected]') || sel.options[0];
  out.status_label = text(chosen);
  out.options = [...sel.options].map(o => [o.value, text(o)]);
  out.sum_ai = after(form, 'AI Screening');
  out.sum_score = after(form, 'Score');
  out.sum_status = after(form, 'สถานะ HR');
  const hist = section('applicant-history-heading');
  out.history = text(hist);
  const same = out.history.match(/Possible same-name records: (\d+)/);
  out.same_name = same ? parseInt(same[1], 10) : null;
  const found = out.history.match(/พบประวัติที่ยืนยันได้\s*(\d+)\s*รายการ/);
  out.history_count = found ? parseInt(found[1], 10) : null;
  out.history_none = out.history.includes('ไม่พบประวัติเดิม');
  out.history_rows = hist ? [...hist.querySelectorAll('tbody tr')].map(tr => [...tr.children].map(td => text(td))) : [];
  const files = section('applicant-files-heading');
  out.files = text(files);
  const names = files ? [...files.querySelectorAll('.truncate')].map(text) : [];
  out.cv = names[0] || '';
  out.extra = names.slice(1);
  const ext = out.files.match(/นามสกุลไฟล์: (\S+)/);
  out.cv_ext = ext ? ext[1] : '';
  const log = section('email-history-heading');
  out.log_text = text(log);
  out.log_rows = log ? [...log.querySelectorAll('tbody tr')].map(tr => [...tr.children].map(td => text(td))) : [];
  out.log_mailto = log ? [...log.querySelectorAll('a[href^="mailto:"]')].map(a => a.getAttribute('href')) : [];
  const head = form.querySelector('a[href*="type=head"]');
  const cand = form.querySelector('a[href*="type=candidate"]');
  out.head_link = head ? head.getAttribute('href') : null;
  out.candidate_link = cand ? cand.getAttribute('href') : null;
  return out;
};
Promise.all(paths.map(p => fetch(p, {credentials: 'same-origin'})
  .then(r => r.text().then(t => parse(p, t, r.status)))
  .catch(e => ({path: p, status: 0, missing: true, text: String(e)}))))
  .then(done);
"""


def read_profiles(paths):
    """Download these profile paths (e.g. /admin/applications/<id>) and return a list of dicts."""
    paths = list(paths)
    if not paths:
        raise AssertionError("There are no applicants on the dashboard, so there is no profile to check")
    return _driver().execute_async_script(_PARSE_JS, paths)


# ---------------------------------------------------------------- small helpers
def thai_datetime(text):
    """'2 พ.ย. 2569 16:39 น.' -> datetime (year changed from Buddhist to normal). None if it does not parse."""
    match = re.search(r"(\d{1,2})\s+(\S+)\s+(\d{4})\s+(\d{1,2}):(\d{2})", text or "")
    if not match or match.group(2) not in THAI_MONTHS:
        return None
    day, month, year, hour, minute = (int(match.group(1)), THAI_MONTHS[match.group(2)],
                                      int(match.group(3)) - 543, int(match.group(4)), int(match.group(5)))
    return datetime.datetime(year, month, day, hour, minute)


def _name(profile):
    return f"{profile['first']} {profile['last']}"


def _who(profile):
    return f"{_name(profile)} ({profile['path'].rsplit('/', 1)[-1][-6:]})"


def _by_path(rows):
    return {row["href"]: row for row in rows}


def _is_auto_reply(row):
    return row and row[1].startswith(AUTO_REPLY_TYPE)


# ---------------------------------------------------------------- the checks
def profile_problems(check, profiles, rows=None, status_options=None):
    """Run one named check over every profile. Returns a list of problems (empty = passed).

    rows is the dashboard table rows (needed by the checks that compare profile and table).
    """
    now = datetime.datetime.now()
    row_of = _by_path(rows or [])
    problems = []

    if check == "opens":
        for p in profiles:
            if p.get("status") != 200 or p.get("missing"):
                problems.append(f"{p['path']}: HTTP {p.get('status')} {p.get('text', '')[:80]}")
        return problems

    for p in profiles:
        if p.get("missing"):
            problems.append(f"{p['path']}: profile page did not load")
            continue
        who = _who(p)
        row = row_of.get(p["path"])
        if check in ("identity", "applied", "ai", "status") and row is None:
            problems.append(f"{who}: not found in the dashboard table")
            continue

        if check == "identity":
            for label, mine, theirs in (("name", _name(p), row["name"]), ("email", p["email"], row["email"]),
                                        ("position", p["job"], row["job"])):
                if mine != theirs:
                    problems.append(f"{who}: {label} is '{mine}' on the profile but '{theirs}' in the table")
        elif check == "applied":
            if p["applied"] != row["date"]:
                problems.append(f"{who}: applied '{p['applied']}' on the profile, '{row['date']}' in the table")
        elif check == "ai":
            score = row["ai_score"].replace("Score:", "").strip()
            if p["ai_label"] != row["ai_label"]:
                problems.append(f"{who}: AI result '{p['ai_label']}' on the profile, '{row['ai_label']}' in the table")
            if p["ai_score"] != score:
                problems.append(f"{who}: AI score '{p['ai_score']}' on the profile, '{score}' in the table")
        elif check == "status":
            if p["status_label"] != row["status"]:
                problems.append(f"{who}: HR status '{p['status_label']}' on the profile, '{row['status']}' in the table")
        elif check == "phone":
            if not re.fullmatch(r"\+?\d{9,15}", p["phone"]):
                problems.append(f"{who}: phone '{p['phone']}' is not digits")
        elif check == "email":
            if not re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", p["email"]):
                problems.append(f"{who}: email '{p['email']}' is not an email address")
        elif check == "salary":
            if not re.fullmatch(r"฿[\d,]+( - [\d,]+)? / เดือน", p["salary"]):
                problems.append(f"{who}: salary '{p['salary']}' does not look like '฿25,000 / เดือน'")
        elif check == "not_future":
            moment = thai_datetime(p["applied"])
            if moment is None:
                problems.append(f"{who}: application time '{p['applied']}' cannot be read")
            elif moment > now + datetime.timedelta(minutes=5):
                problems.append(f"{who}: application time {moment:%d/%m/%Y %H:%M} is later than now ({now:%d/%m/%Y %H:%M})")
        elif check == "consent":
            when = thai_datetime(p["consent"])
            if "ยินยอมแล้ว" not in p["consent"]:
                problems.append(f"{who}: consent says '{p['consent']}'")
            elif when != thai_datetime(p["applied"]):
                problems.append(f"{who}: consent time '{p['consent']}' differs from application time '{p['applied']}'")
        elif check == "sources":
            if not p["sources"]:
                problems.append(f"{who}: no source channel shown")
            elif len(set(p["sources"])) != len(p["sources"]):
                problems.append(f"{who}: a source channel is listed twice: {p['sources']}")
        elif check == "history_rule":
            # the page says: earlier applications are found by first name + last name + phone
            key = (p["first"], p["last"], p["phone"])
            others = [q for q in profiles if q["path"] != p["path"] and (q["first"], q["last"], q["phone"]) == key]
            shown = p["history_count"] or 0
            if shown != len(others):
                problems.append(f"{who}: history lists {shown} earlier application(s), {len(others)} other application(s) "
                                f"have the same name and phone")
        elif check == "history_consistent":
            rows_n, count = len(p["history_rows"]), p["history_count"]
            if p["history_none"]:
                if rows_n or count:
                    problems.append(f"{who}: says '{NO_HISTORY_TEXT}' but has {rows_n} history rows (count {count})")
            elif count is None:
                problems.append(f"{who}: history shows neither '{NO_HISTORY_TEXT}' nor a count")
            elif count != rows_n or count < 1:
                problems.append(f"{who}: history says {count} record(s) but the table lists {rows_n}")
        elif check == "cv_ext":
            ext = p["cv"].rsplit(".", 1)[-1].upper() if "." in p["cv"] else ""
            if not p["cv"] or ext != p["cv_ext"].upper():
                problems.append(f"{who}: CV file '{p['cv']}' but extension label '{p['cv_ext']}'")
        elif check == "extra_files":
            if p["extra"] and NO_EXTRA_FILES_TEXT in p["files"]:
                problems.append(f"{who}: says there are no extra files but lists {p['extra']}")
            if not p["extra"] and NO_EXTRA_FILES_TEXT not in p["files"]:
                problems.append(f"{who}: no extra files listed and no empty message")
        elif check == "auto_reply":
            for r in p["log_rows"]:
                if not _is_auto_reply(r):
                    continue
                if p["email"] not in r[2]:
                    problems.append(f"{who}: auto reply went to '{r[2]}', applicant email is '{p['email']}'")
                if AUTO_SENDER not in r[3] or r[4] not in ("Sent", "Failed"):
                    problems.append(f"{who}: auto reply sender/status is '{r[3]}' / '{r[4]}'")
        elif check == "log_dates":
            applied = thai_datetime(p["applied"])
            for r in p["log_rows"]:
                moment = thai_datetime(r[0])
                if moment is None:
                    problems.append(f"{who}: log time '{r[0]}' cannot be read")
                elif applied and moment < applied:
                    problems.append(f"{who}: log time {r[0]} is before the application time {p['applied']}")
                elif moment > now + datetime.timedelta(minutes=5):
                    problems.append(f"{who}: log time {r[0]} is in the future")
        elif check == "log_empty":
            empty_shown = EMPTY_LOG_TEXT in p["log_text"]
            if bool(p["log_rows"]) == empty_shown:
                problems.append(f"{who}: {len(p['log_rows'])} log rows but empty message shown = {empty_shown}")
        elif check == "log_order":
            times = [thai_datetime(r[0]) for r in p["log_rows"]]
            if None not in times and times != sorted(times, reverse=True):
                problems.append(f"{who}: log is not newest first: {[r[0] for r in p['log_rows']]}")
        elif check == "ai_display":
            label, score, bar = p["ai_label"], p["ai_score"], p["bar"]
            if label not in ("AI Match", "AI Partial Match", "วิเคราะห์ไม่สำเร็จ", AI_IN_PROGRESS):
                problems.append(f"{who}: unknown AI result '{label}'")
            if score == "-":
                if label not in ("วิเคราะห์ไม่สำเร็จ", AI_IN_PROGRESS):
                    problems.append(f"{who}: score '-' but result is '{label}'")
                if bar is not None:
                    problems.append(f"{who}: has a score bar ({bar}) but no score")
            elif re.fullmatch(r"\d{1,3}%", score) and 0 <= int(score[:-1]) <= 100:
                if bar != score[:-1]:
                    problems.append(f"{who}: score {score} but bar value {bar}")
                if label == "วิเคราะห์ไม่สำเร็จ":
                    problems.append(f"{who}: result says analysis failed but score is {score}")
            else:
                problems.append(f"{who}: score '{score}' is not 0-100%")
        elif check == "summary":
            if (p["sum_ai"], p["sum_score"].replace("%", ""), p["sum_status"]) != \
                    (p["ai_label"], p["ai_score"].replace("%", ""), p["status_label"]):
                problems.append(f"{who}: summary box ({p['sum_ai']} / {p['sum_score']} / {p['sum_status']}) differs from "
                                f"the panel ({p['ai_label']} / {p['ai_score']} / {p['status_label']})")
        elif check == "status_options":
            if [tuple(o) for o in p["options"]] != [tuple(o) for o in (status_options or [])]:
                problems.append(f"{who}: HR status list is {p['options']}")
        elif check == "email_links":
            base = p["path"]
            if p["head_link"] != f"{base}/email?type=head" or p["candidate_link"] != f"{base}/email?type=candidate":
                problems.append(f"{who}: email links are {p['head_link']} / {p['candidate_link']}")
        else:
            raise AssertionError(f"Unknown profile check: {check}")
    return problems


def should_pass_profile_check(check, profiles, rows=None, status_options=None):
    problems = profile_problems(check, profiles, rows, status_options)
    if problems:
        shown = "\n".join(problems[:12])
        more = f"\n... and {len(problems) - 12} more" if len(problems) > 12 else ""
        raise AssertionError(f"{len(problems)} problem(s) in {len(profiles)} profiles:\n{shown}{more}")


def should_have_profiles_with(profiles, what):
    """SKIP the test when the dev data has no profile of the kind we need."""
    pick = {
        "failed_ai": lambda p: p.get("ai_label") == "วิเคราะห์ไม่สำเร็จ",
        "extra_files": lambda p: bool(p.get("extra")),
        "log_rows": lambda p: bool(p.get("log_rows")),
        "two_log_rows": lambda p: len(p.get("log_rows", [])) >= 2,
        "no_log_rows": lambda p: not p.get("log_rows"),
    }[what]
    found = [p for p in profiles if not p.get("missing") and pick(p)]
    if not found:
        raise SkipExecution(f"No applicant on dev has: {what}")
    return found


_HISTORY_JS = r"""
const h = document.getElementById('applicant-history-heading');
const sec = h ? h.closest('section') : null;
if (!sec) { return null; }
const text = (el) => el.textContent.replace(/\s+/g, ' ').trim();
return [...sec.querySelectorAll('tbody tr')].map(tr => [...tr.children].map(text));
"""


def _history_in_browser(path):
    """The history table as the user sees it (the downloaded page can differ from the finished page)."""
    driver = _driver()
    base = BuiltIn().get_variable_value("${BASE_URL}")
    driver.get(base + path)
    for _ in range(40):
        rows = driver.execute_script(_HISTORY_JS)
        if rows is not None and driver.execute_script("return document.readyState") == "complete":
            return rows
        time.sleep(0.25)
    raise AssertionError(f"The history section of {path} did not appear")


def repeat_applicants_should_show_history(profiles, what):
    """Applicants who share first name + last name + phone are the same person applying twice.

    Each of their profiles must list the other application(s) in the history table (read from the
    open browser). `what` is the column to check against the other application's own profile:
      listed    the other application is in the table at all
      position  'ตำแหน่งเดิม' equals that application's position
      ai        'ผล AI เดิม' equals that application's AI result and score
      status    'สถานะ HR เดิม' shows the status code (hr_review, contacted ...) of that application;
                the team confirmed the code is what the page should show
    The ai column is SKIPPED while every row still shows the placeholder (dev has not built the AI part of the history).
    Skips the test when the dev data has no such pair.
    """
    groups = {}
    for p in profiles:
        if p.get("missing"):
            continue
        # Exact match, like the site: "Test TEst" and "Test Test" are NOT the same person
        key = (p["first"].strip(), p["last"].strip(), re.sub(r"\D", "", p["phone"]))
        groups.setdefault(key, []).append(p)
    pairs = [members for members in groups.values() if len(members) > 1]
    if not pairs:
        raise SkipExecution("No two applicants on dev share the same name and phone")
    problems = []
    ai_cells = []
    for members in pairs:
        for me in members:
            shown_rows = _history_in_browser(me["path"])
            by_date = {row[0]: row for row in shown_rows}
            for other in members:
                if other is me:
                    continue
                row = by_date.get(other["applied"])
                if row is None:
                    problems.append(f"{_who(me)}: the application of {other['applied']} ({_who(other)}) is not in its history "
                                    f"(rows: {[r[0] for r in shown_rows]})")
                    continue
                if what == "position" and row[1] != other["job"]:
                    problems.append(f"{_who(me)}: history position is '{row[1]}', that application was for '{other['job']}'")
                elif what == "ai":
                    shown = re.sub(r"\s+", "", row[2])
                    ai_cells.append(shown)
                    wanted = re.sub(r"\s+", "", f"{other['ai_label']}Score:{other['ai_score']}")
                    if shown != wanted:
                        problems.append(f"{_who(me)}: history AI is '{row[2]}', that application has '{other['ai_label']} / {other['ai_score']}'")
                elif what == "status" and row[3] != other["status_value"]:
                    problems.append(f"{_who(me)}: history HR status is '{row[3]}', that application has '{other['status_value']}'")
    if what == "ai" and ai_cells and all(cell == AI_HISTORY_PLACEHOLDER for cell in ai_cells):
        raise SkipExecution("The AI column of the history still shows the placeholder (dev has not built it yet)")
    if problems:
        shown = "\n".join(problems[:10])
        more = f"\n... and {len(problems) - 10} more" if len(problems) > 10 else ""
        seen = f"\nAI cells seen in the history: {sorted(set(ai_cells))}" if what == "ai" else ""
        raise AssertionError(f"{len(problems)} problem(s) with repeat applicants ({len(pairs)} people applied twice):\n{shown}{more}{seen}")

def pdf_should_be_real(url):
    """Download the first bytes of the file behind the preview; a PDF starts with %PDF."""
    request = urllib.request.Request(url, headers={"Range": "bytes=0-9"})
    with urllib.request.urlopen(request, timeout=30) as response:
        head = response.read(8)
        status = response.status
    if status not in (200, 206) or not head.startswith(b"%PDF"):
        raise AssertionError(f"{url} returned HTTP {status} and starts with {head!r}, not a PDF")
