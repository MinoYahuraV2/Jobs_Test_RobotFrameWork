"""Build the CMS applicant profile .robot files from data/testcases_profile.csv.

Run:  python tools/csv_to_robot_profile.py [path/to/testcases_profile.csv]

* Same idea as tools/csv_to_robot_dashboard.py: the CSV is the source of truth for ID, description,
  expected result and type. STEPS maps each ID to its keywords and file group.
* Writes tests/profile/*.robot (the other test folders are not touched).
* Do not hand-edit the generated files; edit STEPS or resources/pages/profile.resource instead.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from csv_to_robot import read_cases, render_test  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases_profile.csv"
OUT_DIR = ROOT / "tests" / "profile"
PREFIX = "PF"

GROUPS = {
    "open": ("01_open", "Open the profile, top of the page and wrong ids"),
    "info": ("02_info", "Application info of every applicant"),
    "history": ("03_history", "Earlier applications"),
    "files": ("04_files", "CV, extra files and the PDF preview"),
    "log": ("05_email_log", "Email log"),
    "status": ("06_status", "AI result and HR status"),
    "next": ("07_next_steps", "Email draft links"),
    "layout": ("08_keyboard_layout", "Keyboard and screen sizes"),
}
MANUAL_FILE = "99_manual"

# PF id -> (group, [steps])
STEPS = {
    "PF001": ("open", ["Profile Should Open From The Table"]),
    "PF002": ("open", ["Heading And Subtitle Should Match"]),
    "PF003": ("open", ["Top Bar Should Show Brand And User", "Menu Texts Should Match"]),
    "PF004": ("open", ["Page Should Have Five Sections In Order"]),
    "PF005": ("open", ["Link Should Return To The Applicant Table    ${PF_BACK_LINK}"]),
    "PF006": ("open", ["Link Should Return To The Applicant Table    ${PF_LIST_BUTTON}"]),
    "PF007": ("open", ["Profile Should Ask For Login When Logged Out"]),
    "PF008": ("open", ["Unknown Applicant Should Show Not Found    ${PF_FAKE_ID}"]),
    "PF009": ("open", ["Unknown Applicant Should Show Not Found    ${PF_BAD_ID}"]),
    "PF010": ("open", ["Odd Applicant Id Should Be Harmless"]),
    "PF011": ("open", ["Not Found Back Link Should Open The Applicant Table"]),
    "PF012": ("open", ["Refresh Should Keep The Same Applicant"]),
    "PF013": ("info", ["Info Section Should Be Titled"]),
    "PF014": ("info", ["Info Labels Should Match"]),
    "PF015": ("info", ["Info Fields Should Be Read Only"]),
    "PF016": ("info", ["Every Profile Should Pass    identity"]),
    "PF017": ("info", ["Every Profile Should Pass    applied"]),
    "PF018": ("info", ["Every Profile Should Pass    phone"]),
    "PF019": ("info", ["Every Profile Should Pass    email"]),
    "PF020": ("info", ["Every Profile Should Pass    salary"]),
    "PF021": ("info", ["Every Profile Should Pass    not_future"]),
    "PF022": ("info", ["Every Profile Should Pass    sources"]),
    "PF023": ("info", ["Consent Should Match The Application Time"]),
    "PF024": ("info", ["Every Profile Should Pass    opens"]),
    "PF025": ("history", ["History Section Should Be Titled"]),
    "PF026": ("history", ["Every Profile Should Pass    history_consistent"]),
    "PF027": ("history", ["Repeat Applicants Should Show Their History    listed"]),
    "PF028": ("history", ["Same Name Link Should Open The Applicant Table"]),
    "PF029": ("history", ["Repeat Applicants Should Show Their History    position"]),
    "PF030": ("history", ["Repeat Applicants Should Show Their History    ai"]),
    "PF031": ("history", ["Repeat Applicants Should Show Their History    status"]),
    "PF074": ("history", ["Every Profile Should Pass    history_rule"]),
    "PF032": ("files", ["Files Section Should Be Titled"]),
    "PF033": ("files", ["Every Profile Should Pass    cv_ext"]),
    "PF034": ("files", ["Every Profile Should Pass    extra_files"]),
    "PF035": ("files", ["Preview Should Show The CV"]),
    "PF036": ("files", ["Preview Download Link Should Match The Frame"]),
    "PF037": ("files", ["Preview File Should Be A Real Pdf"]),
    "PF038": ("files", ["Close Button Should Close The Preview"]),
    "PF039": ("files", ["Escape Key Should Close The Preview"]),
    "PF040": ("files", ["Every Profile Needs    extra_files    extra_files"]),
    "PF041": ("log", ["Log Section Should Be Titled"]),
    "PF042": ("log", ["Every Profile Should Pass    auto_reply"]),
    "PF043": ("log", ["Log Recipient Should Be A Mail Link"]),
    "PF044": ("log", ["Every Profile Should Pass    log_dates"]),
    "PF045": ("log", ["Every Profile Should Pass    log_empty"]),
    "PF046": ("log", ["Every Profile Needs    two_log_rows    log_order"]),
    "PF047": ("status", ["Status Panel Should Be Titled"]),
    "PF048": ("status", ["Every Profile Should Pass    ai_display"]),
    "PF049": ("status", ["Every Profile Should Pass    ai"]),
    "PF050": ("status", ["Failed AI Should Explain Itself"]),
    "PF051": ("status", ["AI Result Should Not Be Editable"]),
    "PF052": ("status", ["Every Status List Should Match"]),
    "PF053": ("status", ["Every Profile Should Pass    status"]),
    "PF054": ("status", ["Every Profile Should Pass    summary"]),
    "PF055": ("status", ["Changing Status Without Saving Should Not Keep It"]),
    "PF056": ("status", ["Save Buttons Should Be Ready"]),
    "PF057": ("status", ["Status List Should Have A Label"]),
    "PF058": ("status", ["Status List Should Work With The Keyboard"]),
    "PF059": ("next", ["Next Steps Should Be Titled"]),
    "PF060": ("next", ["Every Profile Should Pass    email_links"]),
    "PF061": ("next", ["Head Draft Should Open"]),
    "PF062": ("next", ["Candidate Draft Should Open"]),
    "PF063": ("next", ["Draft Back Link Should Return To The Profile"]),
    "PF064": ("layout", ["Tab Order Should Follow The Page"]),
    "PF065": ("layout", ["Panel Should Sit Beside The Sections"]),
    "PF066": ("layout", ["Panel Should Sit Below The Sections    768    1024"]),
    "PF067": ("layout", ["Page Should Not Scroll Sideways    375    812"]),
}

# Behaviour read from the dev site (or an expectation of mine) that the team must confirm.
ASSUMPTION_IDS = {"PF074", "PF018", "PF021", "PF022", "PF023", "PF027", "PF028", "PF029", "PF037", "PF039", "PF041",
                  "PF044", "PF046", "PF062", "PF064", "PF065", "PF066"}


def file_header(title, ids, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({ids[0]} to {ids[-1]}). GENERATED by tools/csv_to_robot_profile.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../../resources/all_pages.resource",
                "Suite Setup       Open Profile Browser",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Open Profile",
                "Test Tags         automate    profile    needs-account"]
    return "\n".join(out) + "\n\n\n*** Test Cases ***\n"


def main():
    csv_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CSV
    cases = read_cases(csv_path, PREFIX)
    auto = [c for c in cases if c["type"] == "automate"]
    manual = [c for c in cases if c["type"] == "manual"]

    missing = [c["id"] for c in auto if c["id"] not in STEPS]
    extra = [i for i in STEPS if i not in {c["id"] for c in auto}]
    if missing or extra:
        sys.exit(f"STEPS mismatch. In CSV as automate but no steps: {missing}. Steps but not automate in CSV: {extra}")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for old in OUT_DIR.glob("*.robot"):
        old.unlink()

    by_group = {g: [] for g in GROUPS}
    for case in auto:
        group, steps = STEPS[case["id"]]
        tags = [case["id"], group]
        if case["id"] in ASSUMPTION_IDS:
            tags.append("assumption")
        by_group[group].append(render_test(case, steps, tags))

    for group, (filename, title) in GROUPS.items():
        tests = by_group[group]
        ids = [t.split()[0] for t in tests]
        body = file_header(title, ids) + "\n\n".join(tests) + "\n"
        (OUT_DIR / f"{filename}.robot").write_text(body, encoding="utf-8", newline="\n")

    manual_tests = [
        render_test(c, ["Skip    Manual case: run by hand and record the result in the CSV"], [c["id"], "manual"])
        for c in manual
    ]
    ids = [c["id"] for c in manual]
    body = file_header("Manual cases (always skipped)", ids, manual=True) + "\n\n".join(manual_tests) + "\n"
    (OUT_DIR / f"{MANUAL_FILE}.robot").write_text(body, encoding="utf-8", newline="\n")

    print(f"automate: {len(auto)}  manual: {len(manual)}  total: {len(cases)}")
    for group, (filename, _) in GROUPS.items():
        print(f"  profile/{filename}.robot  {len(by_group[group])}")
    print(f"  profile/{MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
