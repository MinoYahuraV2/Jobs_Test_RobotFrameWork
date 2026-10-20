"""Build the .robot test files from the test-case CSV.

Run:  python tools/csv_to_robot.py [path/to/testcases.csv]

* The CSV stays the source of truth for ID, description, expected result and type.
* STEPS below maps each Test Case ID to its keyword steps and its file group.
* Re-running overwrites tests/*.robot. Do not hand-edit the generated files; edit
  STEPS or the keywords in resources/ instead.
"""
import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases.csv"
TESTS_DIR = ROOT / "tests"

GROUPS = {
    "smoke": ("01_smoke", "Smoke: whole page"),
    "header": ("02_header", "Header: menu, Eventthai.com, language"),
    "search": ("03_hero_search", "Hero, result count, search"),
    "sort": ("04_sort", "Sort"),
    "filter": ("05_filter", "Filters, selected tags, result count, empty state"),
    "card": ("06_job_card", "Job cards and View & Apply"),
    "footer": ("07_footer", "Footer"),
    "keyboard": ("08_keyboard", "Keyboard use"),
}
MANUAL_FILE = "99_manual"

# TC id -> (group, [steps]). A step is "Keyword    arg    arg".
STEPS = {
    "TC001": ("smoke", ["Jobs Page Should Display All Main Sections"]),
    "TC003": ("header", ["Header Menu Should Be Complete"]),
    "TC004": ("header", ["Click Header Menu And Verify Destination    careers"]),
    "TC005": ("header", ["Click Header Menu And Verify Destination    culture"]),
    "TC006": ("header", ["Click Header Menu And Verify Destination    why_join_us"]),
    "TC007": ("header", ["Click Header Menu And Verify Destination    jobs"]),
    "TC008": ("header", ["Eventthai Button Should Link To Website"]),
    "TC009": ("header", ["Switch Language And Verify    TH", "Switch Language And Verify    EN"]),
    "TC010": ("search", ["Hero Title Should Be Correct"]),
    "TC011": ("search", ["Result Count Should Match Displayed Cards"]),
    "TC012": ("search", ["Search Bar Should Be Displayed With Placeholder"]),
    "TC013": ("search", ["Search By Existing Title Should Show Match"]),
    "TC014": ("search", ["Search By Keyword Should Show Matches"]),
    "TC015": ("search", ["Search With No Match Should Show Empty State"]),
    "TC016": ("search", ["Clearing Search Should Show All Jobs Again"]),
    "TC017": ("search", ["Search Should Ignore Letter Case"]),
    "TC018": ("sort", ["Sort Options Should Be Displayed"]),
    "TC019": ("sort", ["Latest Sort Should Order By Newest Posted Date"]),
    "TC020": ("sort", ["Changing Sort Option Should Update Selection"]),
    "TC021": ("filter", ["Filter Panel Should Be Displayed On The Left"]),
    "TC022": ("filter", ["Clear Filters Button Should Be Displayed"]),
    "TC023": ("filter", ["Clear Filters Should Reset Everything"]),
    "TC024": ("filter", ["Filter Group Should Collapse And Expand    departments"]),
    "TC025": ("filter", ["Filters From Data Should Match    departments    1"]),
    "TC026": ("filter", ["Filters From Data Should Match    departments    2"]),
    "TC027": ("filter", ["Removing Filter Should Restore Results    departments"]),
    "TC028": ("filter", ["Filter Group Should Collapse And Expand    job_types"]),
    "TC029": ("filter", ["Filter By Label Should Match Data    job_types    Full-Time"]),
    "TC030": ("filter", ["Filter By Label Should Match Data    job_types    Part-Time"]),
    "TC031": ("filter", ["Filter By Label Should Match Data    job_types    Contract"]),
    "TC032": ("filter", ["Filter By Label Should Match Data    job_types    Internship"]),
    "TC033": ("filter", ["Filters From Data Should Match    job_types    2"]),
    "TC034": ("filter", ["Removing Filter Should Restore Results    job_types"]),
    "TC035": ("filter", ["Filter Group Should Collapse And Expand    location"]),
    "TC036": ("filter", ["Filter By Label Should Match Data    location    Bangkok HQ"]),
    "TC037": ("filter", ["Filter By Label Should Match Data    location    Chiang Mai"]),
    "TC038": ("filter", ["Filters From Data Should Match    location    2"]),
    "TC039": ("filter", ["Filters Across Groups Should Match Data"]),
    "TC040": ("filter", ["Selected Filters Should Be Shown As Tags"]),
    "TC041": ("filter", ["Removing Tag Should Update Results"]),
    "TC042": ("filter", ["Result Count Should Match Filtered Data"]),
    "TC043": ("filter", ["Impossible Filter Combination Should Show Empty State"]),
    "TC044": ("card", ["Job Cards Should Be Displayed"]),
    "TC045": ("card", ["Displayed Titles Should Match Data"]),
    "TC046": ("card", ["Card Field Should Match Data    description"]),
    "TC047": ("card", ["Card Field Should Match Data    type_badge"]),
    "TC048": ("card", ["Card Field Should Match Data    urgent_badge"]),
    "TC049": ("card", ["Card Field Should Match Data    deadline"]),
    "TC050": ("card", ["Card Field Should Match Data    ongoing"]),
    "TC051": ("card", ["Card Field Should Match Data    department"]),
    "TC052": ("card", ["Card Field Should Match Data    location"]),
    "TC053": ("card", ["Card Field Should Match Data    work_mode"]),
    "TC054": ("card", ["Card Field Should Match Data    posted"]),
    "TC055": ("card", ["View And Apply Should Open Job Detail"]),
    "TC056": ("card", ["Opened Detail Should Match Selected Card    1", "Go To Jobs Page",
                       "Opened Detail Should Match Selected Card    last"]),
    "TC057": ("card", ["Job Cards Should Not Be Duplicated"]),
    "TC058": ("footer", ["Footer Should Show All Sections"]),
    "TC059": ("footer", ["Footer Link Should Navigate    open_positions"]),
    "TC060": ("footer", ["Footer Link Should Navigate    culture"]),
    "TC061": ("footer", ["Footer Link Should Navigate    recruitment_process"]),
    "TC062": ("footer", ["Footer Link Should Navigate    faq"]),
    "TC063": ("footer", ["Footer Email Should Be Correct And Clickable"]),
    "TC064": ("footer", ["Footer Phone Should Be Correct And Clickable"]),
    "TC065": ("footer", ["Footer Link Should Navigate    go_to_website"]),
    "TC066": ("footer", ["Footer Link Should Navigate    cookies"]),
    "TC067": ("footer", ["Footer Link Should Navigate    terms"]),
    "TC068": ("footer", ["Footer Link Should Navigate    privacy"]),
    "TC069": ("footer", ["Footer Copyright Should Be Correct"]),
    "TC071": ("keyboard", ["Keyboard Navigation Should Work On Jobs Page"]),
}

# Tags added automatically when a step uses one of these keywords.
DATA_KEYWORDS = (
    "Search By Existing Title", "Search By Keyword", "Search Should Ignore Letter Case",
    "Filters From Data", "Filter By Label", "Filters Across Groups", "Result Count Should Match Filtered",
    "Impossible Filter", "Displayed Titles Should Match Data", "Card Field Should Match Data",
    "Job Cards Should Not Be Duplicated",
)
ASSUMPTION_TCS = {"TC026", "TC033", "TC038", "TC039"}  # depend on the AND/OR filter rule


def read_cases(csv_path):
    with open(csv_path, encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.reader(handle))
    header = [h.strip() for h in rows[0]]
    id_col = header.index("Check list ID")
    desc_col = 1
    exp_col = header.index("Expected Result")
    type_col = header.index("Type Test")
    cases = []
    for row in rows[1:]:
        if not row or not row[id_col].strip().startswith("TC"):
            continue
        cases.append({
            "id": row[id_col].strip(),
            "desc": " ".join(row[desc_col].split()),
            "expected": " ".join(row[exp_col].split()),
            "type": row[type_col].strip().lower(),
        })
    return cases


def render_test(case, steps, tags):
    lines = [f"{case['id']} {case['desc']}",
             f"    [Documentation]    {case['expected']}",
             f"    [Tags]    {'    '.join(tags)}"]
    lines += [f"    {step}" for step in steps]
    return "\n".join(lines)


def file_header(title, tcs, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({tcs[0]} to {tcs[-1]}). GENERATED by tools/csv_to_robot.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../resources/all_pages.resource",
                "Suite Setup       Open Jobs Page",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Go To Jobs Page",
                "Test Tags         automate"]
    return "\n".join(out) + "\n\n\n*** Test Cases ***\n"


def main():
    csv_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_CSV
    cases = read_cases(csv_path)
    auto = [c for c in cases if c["type"] == "automate"]
    manual = [c for c in cases if c["type"] == "manual"]

    missing = [c["id"] for c in auto if c["id"] not in STEPS]
    extra = [i for i in STEPS if i not in {c["id"] for c in auto}]
    if missing or extra:
        sys.exit(f"STEPS mismatch. In CSV as automate but no steps: {missing}. Steps but not automate in CSV: {extra}")

    TESTS_DIR.mkdir(exist_ok=True)
    for old in TESTS_DIR.glob("*.robot"):
        old.unlink()

    by_group = {g: [] for g in GROUPS}
    for case in auto:
        group, steps = STEPS[case["id"]]
        tags = [case["id"], group]
        if any(step.startswith(DATA_KEYWORDS) for step in steps):
            tags.append("needs-data")
        if case["id"] in ASSUMPTION_TCS:
            tags.append("assumption")
        by_group[group].append(render_test(case, steps, tags))

    for group, (filename, title) in GROUPS.items():
        tests = by_group[group]
        ids = [t.split()[0] for t in tests]
        body = file_header(title, ids) + "\n\n".join(tests) + "\n"
        (TESTS_DIR / f"{filename}.robot").write_text(body, encoding="utf-8", newline="\n")

    manual_tests = [
        render_test(c, ["Skip    Manual case: run by hand and record the result in the CSV"], [c["id"], "manual"])
        for c in manual
    ]
    ids = [c["id"] for c in manual]
    body = file_header("Manual cases (always skipped)", ids, manual=True) + "\n\n".join(manual_tests) + "\n"
    (TESTS_DIR / f"{MANUAL_FILE}.robot").write_text(body, encoding="utf-8", newline="\n")

    print(f"automate: {len(auto)}  manual: {len(manual)}  total: {len(cases)}")
    for group, (filename, _) in GROUPS.items():
        print(f"  {filename}.robot  {len(by_group[group])}")
    print(f"  {MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
