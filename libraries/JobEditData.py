"""Helpers for the CMS edit job tests (/admin/jobs/<id>).

* read_job_forms() downloads the edit page of every job with one JavaScript call (same browser, so it is
  logged in) and turns the filled-in form into a dict.
* job_form_problems() compares each form with its row in the job list (from JobAdminData.get_job_rows) and
  checks that the saved values make sense. Empty list = passed.
* Only GET requests are made here. Nothing is ever saved.
"""
import datetime
import re

from robot.libraries.BuiltIn import BuiltIn

STATUS_OPEN = "เปิดรับสมัครอยู่"
STATUS_CLOSED = "หมดเขตรับสมัคร (Auto)"
STATUS_DRAFT = "ปิดรับสมัครด้วยมือ"
BENEFITS = ["วันหยุดพักผ่อนประจำปี (Annual Leave)", "ประกันสุขภาพและประกันอุบัติเหตุ", "กองทุนสำรองเลี้ยงชีพ",
            "งบสำหรับการเรียนรู้และพัฒนาตัวเอง", "โบนัสประจำปีตามผลประกอบการ", "ทำงานแบบ Hybrid",
            "เบี้ยเลี้ยงฝึกงาน (ตามตกลง)", "ใบรับรองการผ่านงาน (Certificate)",
            "โอกาสเรียนรู้และทำงานจริงกับผู้เชี่ยวชาญ", "โอกาสพิจารณาเป็นพนักงานประจำในอนาคต"]
INTERN_TYPE = "Internship"
INTERN_TAB = "นักศึกษาฝึกงาน (Internship)"


def _driver():
    return BuiltIn().get_library_instance("SeleniumLibrary").driver


_FORM_JS = r"""
const done = arguments[arguments.length - 1];
const text = (el) => el ? el.textContent.replace(/\s+/g, ' ').trim() : '';
const parse = (path, html, status) => {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const out = {path: path, status: status, title: doc.title};
  const title = doc.getElementById('jobTitleInput');
  if (!title) { out.missing = true; out.text = text(doc.body).slice(0, 160); return out; }
  const val = (id) => { const e = doc.getElementById(id); return e ? (e.getAttribute('value') || '') : ''; };
  const sel = (id) => { const s = doc.getElementById(id); if (!s) { return ''; } const o = s.querySelector('option[selected]') || s.options[0]; return text(o); };
  const hidden = (name) => { const e = doc.querySelector('#jobManagementForm input[name="' + name + '"]'); return e ? e.getAttribute('value') || '' : null; };
  out.h1 = text(doc.querySelector('h1'));
  out.job_title = val('jobTitleInput');
  out.deadline = val('jobDeadlineInput');
  out.dept = sel('jobDeptInput');
  out.type = sel('jobEmploymentTypeInput');
  out.tab = sel('jobTabTypeInput');
  out.work_location = val('jobWorkLocationInput');
  out.vacancies = val('jobVacanciesInput');
  out.lat = val('jobLocationLatInput');
  out.lng = val('jobLocationLngInput');
  const loc = doc.getElementById('jobLocationTextInput');
  out.location_text = loc ? loc.textContent.trim() : '';
  out.manual = doc.getElementById('jobManualOpenToggle').hasAttribute('checked');
  out.hot = doc.getElementById('jobHotInput').hasAttribute('checked');
  out.hidden_id = hidden('id');
  out.hidden_manual = hidden('manualOpen');
  out.hidden_hot = hidden('isHot');
  const editor = (id) => text(doc.getElementById(id));
  out.about = editor('jobAboutEditor'); out.about_html = hidden('aboutHtml');
  out.resp = editor('jobResponsibilitiesEditor'); out.resp_html = hidden('responsibilitiesHtml');
  out.qual = editor('jobQualificationsEditor'); out.qual_html = hidden('qualificationsHtml');
  out.benefits = [...doc.querySelectorAll('#jobManagementForm input[name="benefits"]')]
    .filter(i => i.hasAttribute('checked')).map(i => text(i.parentElement));
  out.preview = text(doc.getElementById('jobStatusPreview'));
  return out;
};
Promise.all(arguments[0].map(p => fetch(p, {credentials: 'same-origin'})
  .then(r => r.text().then(t => parse(p, t, r.status)))
  .catch(e => ({path: p, status: 0, missing: true, text: String(e)}))))
  .then(done);
"""


def read_job_forms(paths):
    """Download these edit pages (/admin/jobs/<id>) and return a list of dicts."""
    paths = list(paths)
    if not paths:
        raise AssertionError("There are no jobs, so there is no edit page to check")
    return _driver().execute_async_script(_FORM_JS, paths)


def _day(text):
    match = re.fullmatch(r"(\d{2})/(\d{2})/(\d{4})", (text or "").strip())
    return datetime.date(int(match.group(3)), int(match.group(2)), int(match.group(1))) if match else None


def _iso(text):
    try:
        return datetime.date.fromisoformat(text)
    except ValueError:
        return None


def _plain(html):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", html or "")).replace("&amp;", "&").replace("&lt;", "<").replace("&gt;", ">").strip()


def job_form_problems(check, forms, rows):
    """Run one named check over every job. rows are the job list rows (matched by edit link)."""
    today = datetime.date.today()
    row_of = {r["edit"]: r for r in rows}
    problems = []
    for f in forms:
        who = f.get("job_title") or f["path"]
        if check == "opens":
            if f.get("status") != 200 or f.get("missing"):
                problems.append(f"{f['path']}: HTTP {f.get('status')} {f.get('text', '')[:80]}")
            continue
        if f.get("missing"):
            problems.append(f"{f['path']}: the edit page did not load")
            continue
        row = row_of.get(f["path"])
        if check in ("title", "dept", "type", "deadline", "status") and row is None:
            problems.append(f"{who}: not found in the job list")
            continue
        if check == "title":
            if f["job_title"] != row["title"]:
                problems.append(f"list says '{row['title']}', form has '{f['job_title']}'")
            if f["h1"] != f"แก้ไขตำแหน่งงาน: {row['title']}" or f["title"] != f"แก้ไขตำแหน่งงาน: {row['title']} | EventPass Careers CMS":
                problems.append(f"{who}: heading '{f['h1']}' / tab title '{f['title']}'")
        elif check == "dept":
            if f["dept"] != row["dept"]:
                problems.append(f"{who}: list '{row['dept']}', form '{f['dept']}'")
        elif check == "type":
            if f["type"] != row["type"]:
                problems.append(f"{who}: list '{row['type']}', form '{f['type']}'")
        elif check == "deadline":
            if _iso(f["deadline"]) != _day(row["deadline"]):
                problems.append(f"{who}: list '{row['deadline']}', form '{f['deadline']}'")
        elif check == "status":
            day = _iso(f["deadline"])
            if not f["manual"] and day and day < today:
                continue   # closed by hand AND past its date: which one wins is not settled (see NOTES)
            if not f["manual"]:
                shown = STATUS_DRAFT
            else:
                shown = STATUS_CLOSED if (day and day < today) else STATUS_OPEN
            if row["status"] != shown:
                problems.append(f"{who}: list says '{row['status']}', the form (toggle {'on' if f['manual'] else 'off'}, deadline {f['deadline']}) says '{shown}'")
            if not f["preview"].startswith(shown):
                problems.append(f"{who}: status box says '{f['preview'][:40]}', expected '{shown}'")
            if (row["switch_on"] == "true") != f["manual"]:
                problems.append(f"{who}: list switch {row['switch_on']}, form toggle {f['manual']}")
        elif check == "id":
            if f["hidden_id"] != f["path"].rsplit("/", 1)[-1]:
                problems.append(f"{who}: the form sends id '{f['hidden_id']}' but the page is {f['path']}")
        elif check == "required":
            for label, value in (("title", f["job_title"]), ("about", _plain(f["about_html"])), ("responsibilities", _plain(f["resp_html"])),
                                 ("qualifications", _plain(f["qual_html"])), ("address", f["location_text"]), ("latitude", f["lat"]),
                                 ("longitude", f["lng"]), ("deadline", f["deadline"]), ("work location", f["work_location"]),
                                 ("vacancies", f["vacancies"])):
                if not (value or "").strip():
                    problems.append(f"{who}: {label} is empty")
        elif check == "numbers":
            try:
                lat, lng = float(f["lat"]), float(f["lng"])
                if not (-90 <= lat <= 90 and -180 <= lng <= 180):
                    problems.append(f"{who}: coordinates {lat}, {lng} are outside the earth")
            except ValueError:
                problems.append(f"{who}: coordinates '{f['lat']}', '{f['lng']}' are not numbers")
            if not re.fullmatch(r"[1-9]\d*", f["vacancies"] or ""):
                problems.append(f"{who}: vacancies '{f['vacancies']}' is not a whole number from 1")
        elif check == "tab":
            if (f["type"] == INTERN_TYPE) != (f["tab"] == INTERN_TAB):
                problems.append(f"{who}: type '{f['type']}' but tab '{f['tab']}'")
        elif check == "benefits":
            unknown = [b for b in f["benefits"] if b not in BENEFITS]
            if unknown:
                problems.append(f"{who}: unknown benefits {unknown}")
            if len(set(f["benefits"])) != len(f["benefits"]):
                problems.append(f"{who}: a benefit is ticked twice")
        elif check == "editors":
            for label, html in (("about", f["about_html"]), ("responsibilities", f["resp_html"]),
                                ("qualifications", f["qual_html"])):
                if re.search(r"<\s*(script|iframe|object)|\son\w+\s*=", html or "", re.I):
                    problems.append(f"{who}: the saved {label} HTML holds script-like markup")
        elif check == "hot":
            if f["hot"] != (f["hidden_hot"] == "true"):
                problems.append(f"{who}: urgent box {f['hot']} but hidden value '{f['hidden_hot']}'")
            if f["manual"] != (f["hidden_manual"] == "true"):
                problems.append(f"{who}: manual toggle {f['manual']} but hidden value '{f['hidden_manual']}'")
        else:
            raise AssertionError(f"Unknown job form check: {check}")
    return problems


def should_pass_job_form_check(check, forms, rows):
    problems = job_form_problems(check, forms, rows)
    if problems:
        shown = "\n".join(problems[:12])
        more = f"\n... and {len(problems) - 12} more" if len(problems) > 12 else ""
        raise AssertionError(f"{len(problems)} problem(s) in {len(forms)} jobs:\n{shown}{more}")
