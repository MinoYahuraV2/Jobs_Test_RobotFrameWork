"""Build the Job Detail .robot files from data/testcases_detail.csv.

Run:  python tools/csv_to_robot_detail.py [path/to/testcases_detail.csv]

* Same idea as tools/csv_to_robot.py: the CSV is the source of truth for ID, description,
  expected result and type. STEPS maps each ID to its keywords and file group.
* Writes tests/detail/*.robot (the Jobs page files in tests/ are not touched).
* Do not hand-edit the generated files; edit STEPS or resources/pages/detail.resource instead.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from csv_to_robot import read_cases, render_test  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases_detail.csv"
OUT_DIR = ROOT / "tests" / "detail"
PREFIX = "JD"

GROUPS = {
    "open": ("01_open", "Open the detail page, direct URL, job not found"),
    "nav": ("02_breadcrumb", "Back link and breadcrumb"),
    "header": ("03_header", "Job header: title, badges, department, type, location, salary, vacancies"),
    "sections": ("04_sections", "Sections that open and close"),
    "content": ("05_content", "Job description, responsibilities, qualifications, benefits"),
    "contact": ("06_contact", "Contact and work location"),
    "side": ("07_apply_share", "Apply Now, Share Job, hiring process"),
    "footer": ("08_footer", "Footer"),
    "seo": ("09_seo", "Page data for search engines"),
    "layout": ("10_layout_keyboard", "Layout and keyboard"),
}
MANUAL_FILE = "99_manual"

E = "Every Job Detail Field Should Match"
# JD id -> (group, [steps])
STEPS = {
    "JD001": ("open", ["First Card Should Open Detail"]),
    "JD002": ("open", ["First Card Should Open Detail    ${True}"]),
    "JD003": ("open", ["Every Card Should Open Its Detail"]),
    "JD004": ("open", [f"{E}    tab_title"]),
    "JD005": ("open", ["Detail Page Should Open By Direct Url"]),
    "JD006": ("open", ["Detail Url With Trailing Slash Should Open"]),
    "JD007": ("open", ["Browser Back Should Return To Jobs"]),
    "JD008": ("open", ["Unknown Job Should Show Not Found    ${MISSING_JOB_ID}"]),
    "JD009": ("open", ["Unknown Job Should Show Not Found    ${BAD_JOB_ID}"]),
    "JD010": ("open", ["Not Found Page Title Should Be Correct"]),
    "JD011": ("open", ["Not Found Page Should Explain"]),
    "JD012": ("open", ["Not Found Button Should Open Jobs List"]),
    "JD013": ("nav", ["Back To Jobs Should Be Displayed"]),
    "JD014": ("nav", ["Back To Jobs Should Open Jobs List"]),
    "JD015": ("nav", ["Breadcrumb Should Show Path"]),
    "JD016": ("nav", ["Breadcrumb Last Item Should Be Current Page"]),
    "JD017": ("nav", ["Breadcrumb Jobs Link Should Open Jobs List"]),
    "JD018": ("nav", ["Breadcrumb Careers Link Should Open Careers Home"]),
    "JD019": ("header", [f"{E}    title"]),
    "JD020": ("header", [f"{E}    type_badge"]),
    "JD021": ("header", [f"{E}    urgent"]),
    "JD022": ("header", [f"{E}    deadline"]),
    "JD023": ("header", [f"{E}    department"]),
    "JD024": ("header", [f"{E}    job_type"]),
    "JD025": ("header", [f"{E}    work_location"]),
    "JD026": ("header", [f"{E}    salary"]),
    "JD027": ("header", [f"{E}    vacancies"]),
    "JD028": ("header", ["Detail Header Should Match Its Card"]),
    "JD030": ("sections", ["Sections Should Be Displayed"]),
    "JD031": ("sections", ["All Sections Should Start Expanded"]),
    "JD032": ("sections", ["Section Should Collapse And Expand    Job Description"]),
    "JD033": ("sections", ["Section Should Collapse And Expand    Company Benefits"]),
    "JD034": ("sections", ["Section Should Collapse And Expand    Contact & Location"]),
    "JD035": ("sections", ["Collapsing One Section Should Not Affect Others"]),
    "JD036": ("sections", ["Collapse All Then Expand All Should Restore Content"]),
    "JD037": ("sections", ["Section Should Toggle With Key    ENTER"]),
    "JD038": ("sections", ["Section Should Toggle With Key    SPACE"]),
    "JD039": ("sections", ["Sections Should Be Expanded Again After Reload"]),
    "JD040": ("content", [f"{E}    about"]),
    "JD041": ("content", ["Description Should Match Its Card"]),
    "JD042": ("content", [f"{E}    responsibilities"]),
    "JD043": ("content", [f"{E}    qualifications"]),
    "JD044": ("content", [f"{E}    benefits"]),
    "JD045": ("contact", ["Contact Names Should Be Correct"]),
    "JD046": ("contact", ["Contact Address Should Be Correct"]),
    "JD047": ("contact", ["Contact Phone Should Be Correct And Clickable"]),
    "JD048": ("contact", [f"{E}    location"]),
    "JD049": ("contact", ["Map Should Be Displayed For The Job"]),
    "JD050": ("contact", ["Map Should Come From Google Maps"]),
    "JD051": ("side", ["Apply Message Should Be Displayed"]),
    "JD052": ("side", ["Apply Now Should Link To Apply Form"]),
    "JD053": ("side", ["Apply Now Should Open Form Of This Job"]),
    "JD054": ("side", ["Apply Now Of Every Job Should Open Its Own Form"]),
    "JD055": ("side", ["Apply Form Back Link Should Return To Detail"]),
    "JD056": ("side", ["Share Job Button Should Be Displayed"]),
    "JD057": ("side", ["Share Job Click Should Keep The Page"]),
    "JD059": ("side", ["Hiring Process Should List All Steps In Order"]),
    "JD060": ("side", ["Hiring Process Numbers Should Be In Order"]),
    "JD061": ("footer", ["Footer Should Show All Sections"]),
    "JD062": ("footer", ["Footer Open Positions Link Should Open Jobs List"]),
    "JD063": ("footer", ["Footer Email Should Be Correct And Clickable"]),
    "JD064": ("footer", ["Footer Phone Should Be Correct And Clickable"]),
    "JD065": ("footer", ["Footer Copyright Should Be Correct"]),
    "JD066": ("seo", [f"{E}    seo_meta"]),
    "JD067": ("seo", [f"{E}    seo_title"]),
    "JD068": ("seo", [f"{E}    seo_type"]),
    "JD069": ("seo", [f"{E}    seo_openings"]),
    "JD070": ("seo", [f"{E}    seo_valid"]),
    "JD071": ("seo", ["Job Posting Should Use The Real Website Address"]),
    "JD072": ("layout", ["Side Panel Should Be On The Right On Desktop"]),
    "JD073": ("layout", ["Tab Key Should Visit The Page In Order"]),
}

DATA_KEYWORDS = ("Every Job Detail Field", "Every Card Should Open", "Detail Header Should Match",
                 "Description Should Match Its Card", "Apply Now Of Every Job")
# Behaviour or text that the team still has to confirm.
ASSUMPTION_IDS = {"JD018", "JD025", "JD026", "JD057", "JD062"}


def file_header(title, ids, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({ids[0]} to {ids[-1]}). GENERATED by tools/csv_to_robot_detail.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../../resources/all_pages.resource",
                "Suite Setup       Open Jobs Page",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Open Default Detail Page",
                "Test Tags         automate    detail"]
    return "\n".join(out) + "\n\n\n*** Test Cases ***\n"


def main():
    import csv_to_robot  # for the shared reader
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
        if any(step.startswith(DATA_KEYWORDS) for step in steps):
            tags.append("needs-data")
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
        print(f"  detail/{filename}.robot  {len(by_group[group])}")
    print(f"  detail/{MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
