"""Build the CMS dashboard .robot files from data/testcases_dashboard.csv.

Run:  python tools/csv_to_robot_dashboard.py [path/to/testcases_dashboard.csv]

* Same idea as tools/csv_to_robot_login.py: the CSV is the source of truth for ID, description,
  expected result and type. STEPS maps each ID to its keywords and file group.
* Writes tests/dashboard/*.robot (the other test folders are not touched).
* Do not hand-edit the generated files; edit STEPS or resources/pages/dashboard.resource instead.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from csv_to_robot import read_cases, render_test  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases_dashboard.csv"
OUT_DIR = ROOT / "tests" / "dashboard"
PREFIX = "DB"

GROUPS = {
    "open": ("01_open", "Open the dashboard and the top bar"),
    "summary": ("02_summary", "Summary cards"),
    "table": ("03_table", "Applicant table"),
    "filter": ("04_filter", "Search and filters"),
    "paging": ("05_paging", "Pages"),
    "actions": ("06_export_links", "Export Report, buttons and menu links"),
    "layout": ("07_keyboard_layout", "Keyboard and screen sizes"),
}
MANUAL_FILE = "99_manual"

# DB id -> (group, [steps])
STEPS = {
    "DB001": ("open", ["Dashboard Should Be Open"]),
    "DB002": ("open", ["Element Text Should Be    ${DASH_H1}    ${DASH_H1_TEXT}",
                       "Element Text Should Be    ${DASH_SUBTITLE}    ${DASH_SUBTITLE_TEXT}"]),
    "DB003": ("open", ["Top Bar Should Show Brand And User"]),
    "DB004": ("open", ["Menu Texts Should Match"]),
    "DB005": ("open", ["Only Dashboard Menu Should Be Marked Current"]),
    "DB006": ("open", ["Header Buttons Should Match"]),
    "DB007": ("open", ["Skip Link Should Jump To The Content"]),
    "DB008": ("summary", ["Total Card Should Match"]),
    "DB009": ("summary", ["Workflow Summary Should Match"]),
    "DB010": ("summary", ["Status Cards Should Match"]),
    "DB011": ("summary", ["Every Count Should Be A Whole Number"]),
    "DB012": ("summary", ["Status Counts Should Add Up To The Total"]),
    "DB013": ("summary", ["Total Card Should Match The Table Total"]),
    "DB014": ("summary", ["Each Card Should Match Its Filtered List"]),
    "DB015": ("summary", ["Summary Should Not Change When Filtering"]),
    "DB016": ("table", ["Table Headings Should Match"]),
    "DB017": ("table", ["First Page Should Have The Right Number Of Rows"]),
    "DB018": ("table", ["Every Row Should Be Complete"]),
    "DB019": ("table", ["Every Date Should Have The Right Format"]),
    "DB020": ("table", ["Rows Should Be Newest First"]),
    "DB021": ("table", ["No Application Time Should Be In The Future"]),
    "DB022": ("table", ["Every Status Should Be A Known Status"]),
    "DB023": ("table", ["Every AI Screening Cell Should Be Valid"]),
    "DB024": ("table", ["Every Applicant Badge Should Match"]),
    "DB025": ("table", ["Profile Links Should Name The Applicant"]),
    "DB026": ("table", ["Open The First Profile"]),
    "DB027": ("table", ["Profile Links Should Be Different"]),
    "DB028": ("filter", ["Filter Fields Should Match"]),
    "DB029": ("filter", ["Job List Should Start With All Jobs"]),
    "DB030": ("filter", ["Status List Should Match"]),
    "DB031": ("filter", ["Filters Should Be Empty By Default"]),
    "DB032": ("filter", ["Search By Part Of A Name Should Find That Applicant"]),
    "DB033": ("filter", ["Search By Email Should Find Only That Email"]),
    "DB034": ("filter", ["Dashboard Search Should Ignore Letter Case"]),
    "DB035": ("filter", ["Spaces Only Should Not Filter"]),
    "DB036": ("filter", ["Search With No Match Should Show The Empty State"]),
    "DB037": ("filter", ["Each Position Filter Should Only Show That Position"]),
    "DB038": ("filter", ["Each Status Filter Should Only Show That Status"]),
    "DB039": ("filter", ["Position And Status Filters Should Work Together"]),
    "DB040": ("filter", ["One Day Filter Should Only Show That Day"]),
    "DB041": ("filter", ["Future Dates Should Show The Empty State"]),
    "DB042": ("filter", ["Start Date After End Date Should Show The Empty State"]),
    "DB043": ("filter", ["Dashboard Clear Filters Should Reset Everything"]),
    "DB044": ("filter", ["Clear Button In The Empty State Should Reset Everything"]),
    "DB045": ("filter", ["Filters Should Survive A Refresh"]),
    "DB046": ("filter", ["Enter In The Search Box Should Search"]),
    "DB047": ("filter", ["Search With A Script Tag Should Be Harmless"]),
    "DB048": ("filter", ["Search With SQL Text Should Find Nobody"]),
    "DB049": ("filter", ["Search Box Should Stop At The Maximum Length"]),
    "DB050": ("filter", ["Unknown Filter Values Should Be Ignored"]),
    "DB051": ("paging", ["Footer Should Agree With The Table"]),
    "DB052": ("paging", ["Previous Should Be Off On The First Page"]),
    "DB053": ("paging", ["Next Should Open The Second Page"]),
    "DB054": ("paging", ["Next Should Be Off On The Last Page"]),
    "DB055": ("paging", ["Previous Should Return To The First Page"]),
    "DB056": ("paging", ["Pages Should Continue In Date Order"]),
    "DB057": ("paging", ["Page Past The End Should Not Break"]),
    "DB058": ("paging", ["Bad Page Numbers Should Open The First Page"]),
    "DB059": ("actions", ["Export Should Download A Dated Excel File"]),
    "DB060": ("actions", ["Export Should Have The Expected Sheets And Columns"]),
    "DB061": ("actions", ["Export Summary Should Match The Cards"]),
    "DB062": ("actions", ["Export Should List Every Applicant"]),
    "DB063": ("actions", ["Export Time Should Match The Table"]),
    "DB064": ("actions", ["Position List Should Match The Export"]),
    "DB065": ("actions", ["New Job Button Should Open The New Job Page"]),
    "DB066": ("actions", ["Jobs Menu Should Open The Jobs Page"]),
    "DB067": ("actions", ["Applicants Menu Should Jump To The Table"]),
    "DB068": ("actions", ["Brand Link Should Return To The Dashboard"]),
    "DB069": ("layout", ["Filter Form Tab Order Should Follow The Form"]),
    "DB070": ("layout", ["Card Grid Should Be Laid Out    3    2"]),
    "DB071": ("layout", ["Page Should Not Scroll Sideways    375    812", "Phone Menu Should Open"]),
    "DB072": ("layout", ["Set Window Size    375    812",
                         "Sleep    ${RESULT_SETTLE}",
                         "Card Grid Should Be Laid Out    1    6"]),
    "DB073": ("layout", ["Page Should Not Scroll Sideways    768    1024"]),
}

# Behaviour read from the dev site (or an expectation of mine) that the team must confirm.
ASSUMPTION_IDS = {"DB015", "DB021", "DB034", "DB035", "DB042", "DB050", "DB057", "DB063", "DB064",
                  "DB070", "DB072"}


def file_header(title, ids, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({ids[0]} to {ids[-1]}). GENERATED by tools/csv_to_robot_dashboard.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../../resources/all_pages.resource",
                "Suite Setup       Open Dashboard Browser",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Open Dashboard",
                "Test Tags         automate    dashboard    needs-account"]
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
        print(f"  dashboard/{filename}.robot  {len(by_group[group])}")
    print(f"  dashboard/{MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
