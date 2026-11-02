"""Helpers for the CMS email draft tests (/admin/applications/<id>/email?type=head).

* read_drafts() downloads the draft page of many applicants with one JavaScript call (same browser,
  so it is logged in) and turns each page into a dict.
* draft_problems() holds the "is the draft filled in correctly" checks. They compare the draft with
  the applicant's profile (a dict from ProfileData.read_profiles). Empty list = passed.
* applicant_state() reads the HR status and the number of log rows of one profile. The validation
  tests use it to prove that a rejected form changed nothing.
* Only GET requests are made here. Nothing is ever sent.
"""
import re

from robot.libraries.BuiltIn import BuiltIn

SUBJECT_FORMAT = "ขอพิจารณาผู้สมัครตำแหน่ง {job} - {name}"
TITLE_FORMAT = "ร่างอีเมลส่งให้ Head พิจารณา: {name} | EventPass Careers CMS"
BODY_START = "เรียน Head ทีมที่เกี่ยวข้อง"
BODY_END = "ขอบคุณครับ/ค่ะ\nทีม HR EventThai"
STATUS_AFTER = "รอ Head Review"
TARGET_STATUS = "pending-head-review"


def _driver():
    return BuiltIn().get_library_instance("SeleniumLibrary").driver


_DRAFT_JS = r"""
const done = arguments[arguments.length - 1];
const kind = arguments[1];
const text = (el) => el ? el.textContent.replace(/\s+/g, ' ').trim() : '';
const parse = (path, html, status) => {
  const doc = new DOMParser().parseFromString(html, 'text/html');
  const out = {path: path, status: status, title: doc.title};
  const subject = doc.getElementById('emailDraftSubject');
  if (!subject) { out.missing = true; out.text = text(doc.body).slice(0, 200); return out; }
  const h1 = doc.querySelector('h1');
  out.h1 = text(h1);
  out.subject = subject.getAttribute('value');
  out.to = doc.getElementById('emailDraftTo').getAttribute('value');
  out.cc = doc.getElementById('emailDraftCc').getAttribute('value');
  out.body = doc.getElementById('emailDraftBody').textContent;
  const id = (i) => text(doc.getElementById(i));
  out.info = {type: id('emailDraftRecipientType'), name: id('emailDraftApplicantName'),
              job: id('emailDraftApplicantJob'), email: id('emailDraftApplicantEmail'), cv: id('emailDraftCvName')};
  out.status_after = id('emailDraftStatusAfterSend');
  const target = doc.querySelector('input[name=targetStatus]');
  const update = doc.querySelector('input[name=updateStatus]');
  out.target = target ? target.getAttribute('value') : null;
  out.update = update ? update.getAttribute('value') : null;
  out.checked = doc.getElementById('emailAutoUpdateStatus').hasAttribute('checked');
  const src = [...doc.querySelectorAll('div')].find(d => d.children.length === 0 && text(d).startsWith('Source: Application Form'));
  out.attach_name = src && src.previousElementSibling ? text(src.previousElementSibling) : '';
  out.attach_type = src && src.nextElementSibling ? text(src.nextElementSibling) : '';
  return out;
};
Promise.all(arguments[0].map(p => fetch(p + '/email?type=' + kind, {credentials: 'same-origin'})
  .then(r => r.text().then(t => parse(p, t, r.status)))
  .catch(e => ({path: p, status: 0, missing: true, text: String(e)}))))
  .then(done);
"""

_STATE_JS = r"""
const done = arguments[arguments.length - 1];
fetch(arguments[0], {credentials: 'same-origin'}).then(r => r.text()).then(t => {
  const doc = new DOMParser().parseFromString(t, 'text/html');
  const sel = doc.querySelector('#profileHrStatus');
  const h = doc.getElementById('email-history-heading');
  const rows = h ? h.closest('section').querySelectorAll('tbody tr').length : -1;
  done([sel ? sel.value : null, rows]);
});
"""


def read_drafts(paths, kind="head"):
    """Download the draft page (email?type=<kind>) of these profile paths."""
    paths = list(paths)
    if not paths:
        raise AssertionError("There are no applicants, so there is no draft to check")
    return _driver().execute_async_script(_DRAFT_JS, paths, kind)


def applicant_state(path):
    """[HR status value, number of rows in the email log] of one applicant, from the profile page."""
    state = _driver().execute_async_script(_STATE_JS, path)
    if state[0] is None:
        raise AssertionError(f"The profile {path} did not load")
    return state


def _salary_text(profile):
    return profile["salary"].replace("฿", "").replace(" / เดือน", "").strip()


def _ai_line(profile):
    if profile["ai_score"] == "-":
        return "AI Screening: -"
    return f"AI Screening: {profile['ai_label']} ({profile['ai_score']})"


def _who(profile):
    return f"{profile['first']} {profile['last']} ({profile['path'].rsplit('/', 1)[-1][-6:]})"


def draft_problems(check, drafts, profiles):
    """Run one named check over every draft. Returns a list of problems (empty = passed)."""
    profile_of = {p["path"]: p for p in profiles}
    problems = []
    for d in drafts:
        p = profile_of.get(d["path"])
        if p is None or p.get("missing"):
            problems.append(f"{d['path']}: no profile to compare with")
            continue
        who = _who(p)
        name = f"{p['first']} {p['last']}"
        if check == "opens":
            if d.get("status") != 200 or d.get("missing"):
                problems.append(f"{who}: HTTP {d.get('status')} {d.get('text', '')[:80]}")
            continue
        if d.get("missing"):
            problems.append(f"{who}: the draft page did not load")
            continue
        if check == "title":
            if d["title"] != TITLE_FORMAT.format(name=name):
                problems.append(f"{who}: title is '{d['title']}'")
        elif check == "subject":
            wanted = SUBJECT_FORMAT.format(job=p["job"], name=name)
            if d["subject"] != wanted:
                problems.append(f"{who}: subject is '{d['subject']}', expected '{wanted}'")
        elif check == "body_details":
            lines = [line.strip() for line in d["body"].split("\n")]
            extra = ", ".join(p["extra"]) if p["extra"] else "-"
            wanted = [f"ผู้สมัคร: {name}", f"ตำแหน่งที่สมัคร: {p['job']}",
                      f"เงินเดือนที่คาดหวัง: {_salary_text(p)} บาท", _ai_line(p),
                      f"CV หลักสำหรับ AI Screening: {p['cv']}", f"ไฟล์แนบเพิ่มเติม: {extra}",
                      f"- CV หลัก: {p['cv']}", f"- ไฟล์เพิ่มเติม: {extra}"]
            for line in wanted:
                if line not in lines:
                    problems.append(f"{who}: the body has no line '{line}'")
        elif check == "body_frame":
            body = d["body"].strip().replace("\r\n", "\n")
            if not body.startswith(BODY_START):
                problems.append(f"{who}: body does not start with '{BODY_START}'")
            if not body.endswith(BODY_END):
                problems.append(f"{who}: body does not end with the HR signature")
        elif check == "recipients_empty":
            if d["to"] or d["cc"]:
                problems.append(f"{who}: TO is '{d['to']}' and CC is '{d['cc']}' before anyone typed")
        elif check == "info":
            info = d["info"]
            for label, shown, wanted in (("type", info["type"], "Internal / Head Review"), ("name", info["name"], name),
                                         ("position", info["job"], p["job"]), ("email", info["email"], p["email"]),
                                         ("CV", info["cv"], p["cv"])):
                if shown != wanted:
                    problems.append(f"{who}: info panel {label} is '{shown}', expected '{wanted}'")
        elif check == "attachment":
            ext = p["cv"].rsplit(".", 1)[-1].upper() if "." in p["cv"] else ""
            if d["attach_name"] != p["cv"]:
                problems.append(f"{who}: attachment card shows '{d['attach_name']}', the CV is '{p['cv']}'")
            if f"File Type: {ext}" not in d["attach_type"]:
                problems.append(f"{who}: attachment type is '{d['attach_type']}', expected File Type: {ext}")
        elif check == "status_after":
            if d["status_after"] != STATUS_AFTER:
                problems.append(f"{who}: status after sending is '{d['status_after']}'")
            if not d["checked"] or d["update"] != "true":
                problems.append(f"{who}: auto update is not on by default (checked={d['checked']}, hidden={d['update']})")
        elif check == "target_status":
            if d["target"] != TARGET_STATUS:
                problems.append(f"{who}: the form sends status '{d['target']}', expected '{TARGET_STATUS}'")
        else:
            raise AssertionError(f"Unknown draft check: {check}")
    return problems


def should_pass_draft_check(check, drafts, profiles):
    problems = draft_problems(check, drafts, profiles)
    if problems:
        shown = "\n".join(problems[:12])
        more = f"\n... and {len(problems) - 12} more" if len(problems) > 12 else ""
        raise AssertionError(f"{len(problems)} problem(s) in {len(drafts)} drafts:\n{shown}{more}")


def address_could_be_valid(text):
    """True when this looks like an email address. The validation tests refuse to send such a TO."""
    return re.fullmatch(r"[^@\s]+@[^@\s]+\.[^@\s]+", (text or "").strip()) is not None
