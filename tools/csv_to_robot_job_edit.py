"""Build the CMS CMS edit job .robot files from data/testcases_job_edit.csv.

Run:  python tools/csv_to_robot_job_edit.py [path/to/testcases_job_edit.csv]

* Same idea as tools/csv_to_robot_dashboard.py: the CSV is the source of truth for ID, description,
  expected result and type. STEPS maps each ID to its keywords and file group.
* Writes tests/job_edit/*.robot (the other test folders are not touched).
* Do not hand-edit the generated files; edit STEPS or resources/pages/job_edit.resource instead.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from csv_to_robot import read_cases, render_test  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases_job_edit.csv"
OUT_DIR = ROOT / "tests" / "job_edit"
PREFIX = "JE"

GROUPS = {
    "open": ("01_open", "Open the page, leaving it and wrong ids"),
    "saved": ("02_saved_data", "Every job: the form against the job list"),
    "form": ("03_form", "The form of the first job"),
    "editors": ("04_editors", "The three rich text boxes"),
    "status": ("05_status", "Publishing status and closing date"),
    "meta": ("06_metadata", "Type, urgent badge, vacancies and map"),
    "validation": ("07_validation", "What the browser refuses (nothing is saved)"),
    "layout": ("08_keyboard_layout", "Keyboard and screen sizes"),
}
MANUAL_FILE = "99_manual"

# JE id -> (group, [steps])
STEPS = {
    "JE001": ("open", ["Edit Form Should Open From The List"]),
    "JE002": ("open", ["Edit Heading Should Match"]),
    "JE003": ("open", ["Top Bar Should Show Brand And User", "Menu Texts Should Match", "Jobs Menu Should Be The Current Page"]),
    "JE004": ("open", ["Edit Form Should Ask For Login When Logged Out"]),
    "JE005": ("open", ["Link Should Return To The Job List    ${JN_BACK_LINK}    ${JN_BACK_TEXT}"]),
    "JE006": ("open", ["Link Should Return To The Job List    ${JN_CANCEL}    ${JN_CANCEL_TEXT}"]),
    "JE007": ("open", ["Typed Text Should Be Lost When Leaving Without Saving"]),
    "JE008": ("open", ["Refresh Should Bring Back The Saved Values"]),
    "JE009": ("open", ["Unknown Job Edit Page Should Show Not Found    ${JE_FAKE_ID}"]),
    "JE010": ("open", ["Unknown Job Edit Page Should Show Not Found    ${JE_BAD_ID}"]),
    "JE011": ("open", ["Odd Job Id Should Be Harmless"]),
    "JE012": ("saved", ["Every Job Form Should Pass    opens"]),
    "JE013": ("saved", ["Every Job Form Should Pass    title"]),
    "JE014": ("saved", ["Every Job Form Should Pass    dept"]),
    "JE015": ("saved", ["Every Job Form Should Pass    type"]),
    "JE016": ("saved", ["Every Job Form Should Pass    deadline"]),
    "JE017": ("saved", ["Every Job Form Should Pass    status"]),
    "JE018": ("saved", ["Every Job Form Should Pass    id"]),
    "JE019": ("saved", ["Every Job Form Should Pass    required"]),
    "JE020": ("saved", ["Every Job Form Should Pass    numbers"]),
    "JE021": ("saved", ["Every Job Form Should Pass    tab"]),
    "JE022": ("saved", ["Every Job Form Should Pass    benefits"]),
    "JE023": ("saved", ["Every Job Form Should Pass    editors"]),
    "JE024": ("saved", ["Every Job Form Should Pass    hot"]),
    "JE025": ("form", ["Section Headings And Notes Should Show"]),
    "JE026": ("form", ["Field Labels Should Match"]),
    "JE027": ("form", ["Form Boxes Should Show The First Job"]),
    "JE028": ("form", ["Ticked Benefits Should Match The Saved Job"]),
    "JE029": ("form", ["Lists Should Have The Right Choices"]),
    "JE030": ("form", ["Benefits Should Flip When Clicked"]),
    "JE031": ("form", ["Required Fields Should Be Marked Required"]),
    "JE032": ("form", ["Whole Form Should Be Valid"]),
    "JE033": ("form", ["Hidden Text Fields Should Be Filled When The Page Opens"]),
    "JE034": ("editors", ["Editors Should Sync The Hidden Fields"]),
    "JE035": ("editors", ["Special Characters Should Be Escaped"]),
    "JE036": ("editors", ["Bold Button Should Make Text Bold"]),
    "JE037": ("editors", ["List Buttons Should Make Lists"]),
    "JE038": ("editors", ["Heading Choice Should Make A Heading"]),
    "JE039": ("editors", ["Emptying An Editor Should Empty The Hidden Fields"]),
    "JE040": ("editors", ["Every Editor Should Have Its Toolbar"]),
    "JE041": ("status", ["Status Box Should Match The List"]),
    "JE042": ("status", ["Open Job Status Should Close With The Toggle"]),
    "JE043": ("status", ["Open Job Past Deadline Should Show Auto Expired"]),
    "JE044": ("status", ["Open Job Today Should Still Be Open"]),
    "JE045": ("status", ["Deadline Box Should Need A Date"]),
    "JE046": ("meta", ["Full Time Job Should Move To The Internship Tab"]),
    "JE047": ("meta", ["Urgent Box Should Flip The Hidden Field"]),
    "JE048": ("meta", ["Vacancies Box Should Take Whole Numbers From One"]),
    "JE049": ("meta", ["Coordinates Should Take Decimal Numbers"]),
    "JE050": ("meta", ["Maps Link Should Show The Saved Coordinates"]),
    "JE051": ("meta", ["Maps Link Should Follow The Coordinates"]),
    "JE052": ("validation", ["Emptied Title Should Be Refused On Edit"]),
    "JE053": ("validation", ["Each Required Box Left Empty Should Be Invalid"]),
    "JE054": ("layout", ["Main Fields Should Follow The Tab Order"]),
    "JE055": ("layout", ["Status Panel Should Sit Beside The Form"]),
    "JE056": ("layout", ["Status Panel Should Sit Below The Form    768    1024", "Page Should Not Scroll Sideways    768    1024"]),
    "JE057": ("layout", ["Page Should Not Scroll Sideways    375    812"]),
}

# Behaviour read from the dev site (or an expectation of mine) that the team must confirm.
ASSUMPTION_IDS = {"JE009", "JE010", "JE021", "JE054", "JE055", "JE056"}


def file_header(title, ids, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({ids[0]} to {ids[-1]}). GENERATED by tools/csv_to_robot_job_edit.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../../resources/all_pages.resource",
                "Suite Setup       Open Edit Browser",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Open Edit Form",
                "Test Tags         automate    job-edit    needs-account"]
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
        print(f"  job_edit/{filename}.robot  {len(by_group[group])}")
    print(f"  job_edit/{MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
