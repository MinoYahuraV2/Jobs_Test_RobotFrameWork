"""Build the Apply Job form .robot files from data/testcases_apply.csv.

Run:  python tools/csv_to_robot_apply.py [path/to/testcases_apply.csv]

* Same idea as tools/csv_to_robot_detail.py: the CSV is the source of truth for ID, description,
  expected result and type. STEPS maps each ID to its keywords and file group.
* Writes tests/apply/*.robot (the other test folders are not touched).
* Do not hand-edit the generated files; edit STEPS or resources/pages/apply.resource instead.
* No case presses "Confirm & Submit Application": that would create a real application.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from csv_to_robot import read_cases, render_test  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases_apply.csv"
OUT_DIR = ROOT / "tests" / "apply"
PREFIX = "AP"

GROUPS = {
    "open": ("01_open", "Open the apply form, direct URL, unknown job"),
    "nav": ("02_navigation", "Back link, Cancel, breadcrumb, browser Back"),
    "head": ("03_headings", "Form heading and section titles"),
    "personal": ("04_personal", "Personal information fields and their messages"),
    "resume": ("05_resume", "Resume and additional document upload"),
    "portfolio": ("06_portfolio", "Portfolio URL"),
    "source": ("07_source", "How the applicant found the job"),
    "privacy": ("08_privacy", "Privacy consent"),
    "sidebar": ("09_sidebar", "Complete Your Profile and What to expect"),
    "review": ("10_review", "Review Application dialog"),
    "layout": ("11_layout_keyboard", "Layout and keyboard"),
    "footer": ("12_footer", "Footer"),
}
MANUAL_FILE = "99_manual"

# AP id -> (group, [steps])
STEPS = {'AP001': ('open',
           ['Open Job Detail By Title    ${DEFAULT_DETAIL_JOB}',
            'Click Element Safe    ${APPLY_NOW}',
            'Apply Form Should Be Open']),
 'AP002': ('open', ['Go To    about:blank', 'Open Apply Form', 'Apply Form Should Be Open']),
 'AP003': ('open', ['Apply Form Title Should Name The Job']),
 'AP004': ('open', ['Apply Form Should Name The Job']),
 'AP005': ('open', ['Unknown Job Apply Form Should Show Not Found']),
 'AP006': ('nav',
           ['Element Should Be Shown    ${APPLY_PAGE_BACK}',
            'Element Text Should Include    ${APPLY_PAGE_BACK}    ${BACK_TEXT}']),
 'AP007': ('nav', ['Click Element Safe    ${APPLY_PAGE_BACK}', 'Should Be On Detail Of Default Job']),
 'AP008': ('nav', ['Element Should Be Shown    ${CANCEL_LINK}']),
 'AP009': ('nav', ['Click Element Safe    ${CANCEL_LINK}', 'Should Be On Detail Of Default Job']),
 'AP010': ('nav', ['Breadcrumb Should Show The Apply Path']),
 'AP011': ('nav', ['Browser Back From Form Should Return To Detail']),
 'AP012': ('head', ['Element Text Should Match    ${APPLY_H1}    ${FORM_H1_TEXT}    ignore_case=${False}']),
 'AP013': ('head', ['Form Sections Should Be Shown']),
 'AP014': ('head', ['Personal Labels Should Match']),
 'AP015': ('personal', ['Personal Labels Should Match']),
 'AP016': ('personal', ['Placeholders Should Match']),
 'AP017': ('personal',
           ['Fill Field    first_name    ${APPLICANT}[first_name]',
            'Fill Field    last_name    ${APPLICANT}[last_name]',
            'Field Value Should Be    first_name    ${APPLICANT}[first_name]',
            'Field Value Should Be    last_name    ${APPLICANT}[last_name]']),
 'AP018': ('personal',
           ['Fill Field    email    ${APPLICANT}[email]',
            'Field Value Should Be    email    ${APPLICANT}[email]']),
 'AP019': ('personal', ['Element Should Be Shown    ${PHONE_PREFIX}']),
 'AP020': ('personal',
           ['Fill Field    phone    ${APPLICANT}[phone]',
            'Field Value Should Be    phone    ${APPLICANT}[phone]']),
 'AP021': ('personal',
           ['Fill Field    salary    ${APPLICANT}[salary]',
            'Field Value Should Be    salary    ${SALARY_SHOWN}']),
 'AP022': ('personal', ['Fill Field    salary    abc', 'Field Value Should Be    salary    ${EMPTY}']),
 'AP023': ('personal',
           ['Click Review',
            'Messages Should Be Shown    @{PERSONAL_ERRORS}',
            'Review Dialog Should Be Closed']),
 'AP024': ('personal',
           ['Fill Valid Personal Info',
            'Fill Field    email    abc',
            'Click Review',
            'Text Should Be Shown    ${ERR_EMAIL}']),
 'AP025': ('personal',
           ['Fill Valid Personal Info',
            'Fill Field    phone    081',
            'Click Review',
            'Text Should Be Shown    ${ERR_PHONE}']),
 'AP026': ('personal',
           ['Click Review',
            'Field Should Be Marked Invalid    first_name',
            'Field Should Be Marked Invalid    last_name',
            'Field Should Be Marked Invalid    email',
            'Field Should Be Marked Invalid    phone',
            'Field Should Be Marked Invalid    salary']),
 'AP027': ('personal',
           ['Click Review',
            'Text Should Be Shown    ${ERR_FIRST_NAME}',
            'Fill Field    first_name    ${APPLICANT}[first_name]',
            'Click Review',
            'Text Should Not Be Shown    ${ERR_FIRST_NAME}',
            'Field Should Not Be Marked Invalid    first_name']),
 'AP028': ('resume', ['Dropzone Should Show    ${RESUME_DROPZONE}    ${RESUME_HINT}']),
 'AP029': ('resume', ['Dropzone Should Show    ${ADDITIONAL_DROPZONE}    ${ADDITIONAL_HINT}']),
 'AP030': ('resume',
           ['Accept Types Should Be    ${RESUME_INPUT}    ${RESUME_ACCEPT}',
            'Accept Types Should Be    ${ADDITIONAL_INPUT}    ${ADDITIONAL_ACCEPT}']),
 'AP031': ('resume',
           ['Upload Resume    pdf', 'File Should Be Listed    cv.pdf', 'File Should Be Listed    2 KB']),
 'AP032': ('resume',
           ['Upload Resume    pdf',
            'File Should Be Listed    cv.pdf',
            'Remove File    cv.pdf',
            'File Should Not Be Listed    cv.pdf',
            'Upload Resume    pdf',
            'File Should Be Listed    cv.pdf']),
 'AP033': ('resume', ['Upload Resume    txt', 'Text Should Be Shown    ${ERR_FILE_TYPE}']),
 'AP034': ('resume', ['Upload Resume    big_pdf', 'Text Should Be Shown    ${ERR_FILE_BIG}']),
 'AP035': ('resume',
           ['Fill Valid Personal Info',
            'Select Source    Facebook',
            'Agree To Privacy',
            'Click Review',
            'Text Should Be Shown    ${ERR_RESUME_MISSING}',
            'Review Dialog Should Be Closed']),
 'AP036': ('resume',
           ['Upload Resume    pdf',
            'File Should Be Listed    cv.pdf',
            'Upload Resume    pdf2',
            'File Should Be Listed    cv2.pdf',
            'File Should Not Be Listed    cv.pdf']),
 'AP037': ('resume',
           ['Upload Additional    zip',
            'Upload Additional    png',
            'File Should Be Listed    portfolio.zip',
            'File Should Be Listed    photo.png']),
 'AP038': ('resume', ['Only One Upload Message Should Be Shown After Empty Submit']),
 'AP039': ('portfolio',
           ['Element Text Should Match    ${PORTFOLIO_LABEL}    ${PORTFOLIO_LABEL_TEXT}    '
            'ignore_case=${False}',
            'Element Attribute Value Should Be    ${PORTFOLIO_INPUT}    placeholder    '
            '${PORTFOLIO_PLACEHOLDER}']),
 'AP040': ('portfolio',
           ['Fill Whole Form Valid',
            'Fill Field Portfolio    notaurl',
            'Click Review',
            'Text Should Be Shown    ${ERR_PORTFOLIO}',
            'Review Dialog Should Be Closed']),
 'AP041': ('portfolio',
           ['Fill Whole Form Valid',
            'Fill Field Portfolio    ${PORTFOLIO_URL_OK}',
            'Click Review',
            'Review Dialog Should Be Open',
            'Text Should Not Be Shown    ${ERR_PORTFOLIO}']),
 'AP042': ('portfolio', ['Portfolio Clear Link Should Clear The Field']),
 'AP043': ('portfolio',
           ['Click Review',
            'Text Should Be Shown    ${ERR_RESUME_MISSING}',
            'Text Should Not Be Shown    ${ERR_PORTFOLIO}']),
 'AP044': ('source', ['All Source Options Should Be Shown']),
 'AP045': ('source',
           ['Select Source    Facebook',
            'Source Should Be Checked    Facebook',
            'Source Should Not Be Checked    TikTok']),
 'AP046': ('source',
           ['Select Source    Facebook',
            'Select Source    LinkedIn',
            'Select Source    JobThai',
            'Source Should Be Checked    Facebook',
            'Source Should Be Checked    LinkedIn',
            'Source Should Be Checked    JobThai']),
 'AP047': ('source',
           ['Select Source    Facebook',
            'Source Should Be Checked    Facebook',
            'Select Source    Facebook',
            'Source Should Not Be Checked    Facebook']),
 'AP048': ('source',
           ['Click Review', 'Text Should Be Shown    ${ERR_SOURCE}', 'Review Dialog Should Be Closed']),
 'AP049': ('source',
           ['Select Source    ${SOURCE_OTHER}',
            'Source Should Be Checked    ${SOURCE_OTHER}',
            'Element Should Be Shown    ${OTHER_INPUT}',
            'Element Attribute Value Should Be    ${OTHER_INPUT}    placeholder    ${OTHER_PLACEHOLDER}']),
 'AP050': ('source',
           ['Fill Whole Form Valid',
            'Select Source    ${SOURCE_OTHER}',
            'Click Review',
            'Text Should Be Shown    ${ERR_OTHER}',
            'Review Dialog Should Be Closed']),
 'AP051': ('source',
           ['Select Source    ${SOURCE_OTHER}',
            'Element Should Be Shown    ${OTHER_INPUT}',
            'Select Source    ${SOURCE_OTHER}',
            'Wait Until Element Is Not Visible    ${OTHER_INPUT}    5s']),
 'AP052': ('privacy',
           ['Element Should Be Shown    ${PRIVACY_LABEL}',
            'Element Should Contain    ${PRIVACY_LABEL}    ${PRIVACY_TEXT}',
            'Checkbox Should Not Be Selected    ${PRIVACY_CHECKBOX}']),
 'AP053': ('privacy',
           ['Click Review', 'Text Should Be Shown    ${ERR_PRIVACY}', 'Review Dialog Should Be Closed']),
 'AP054': ('privacy',
           ['Click Review',
            'Text Should Be Shown    ${ERR_PRIVACY}',
            'Agree To Privacy',
            'Checkbox Should Be Selected    ${PRIVACY_CHECKBOX}',
            'Click Review',
            'Text Should Not Be Shown    ${ERR_PRIVACY}']),
 'AP055': ('sidebar', ['Side Panel Should Start Empty']),
 'AP056': ('sidebar', ['Progress Should Grow With Each Personal Field']),
 'AP057': ('sidebar',
           ['Fill Valid Personal Info',
            'Side Item Should Be Done    Personal information',
            'Side Item Should Not Be Done    Resume & Portfolio']),
 'AP058': ('sidebar',
           ['Upload Resume    pdf',
            'Progress Should Be    25',
            'Side Item Should Be Done    Resume & Portfolio']),
 'AP059': ('sidebar',
           ['Select Source    Facebook',
            'Progress Should Be    25',
            'Side Item Should Be Done    Recruitment Source']),
 'AP060': ('sidebar',
           ['Agree To Privacy', 'Progress Should Be    25', 'Side Item Should Be Done    Privacy Consent']),
 'AP061': ('sidebar',
           ['Select Source    ${SOURCE_OTHER}',
            'Progress Should Be    0',
            'Side Item Should Not Be Done    Recruitment Source',
            'Input Text    ${OTHER_INPUT}    เพื่อนแนะนำ',
            'Progress Should Be    25',
            'Side Item Should Be Done    Recruitment Source']),
 'AP062': ('sidebar',
           ['Fill Whole Form Valid',
            'Progress Should Be    100',
            'Side Item Should Be Done    Personal information',
            'Side Item Should Be Done    Resume & Portfolio',
            'Side Item Should Be Done    Recruitment Source',
            'Side Item Should Be Done    Privacy Consent']),
 'AP063': ('sidebar', ['What To Expect Should Be Shown']),
 'AP064': ('review',
           ['Fill Valid Personal Info',
            'Click Review',
            'Review Dialog Should Be Closed',
            'Apply Form Should Be Open']),
 'AP065': ('review', ['Open Review Dialog With Valid Form', 'Review Dialog Should Show The Job']),
 'AP066': ('review', ['Open Review Dialog With Valid Form', 'Review Dialog Should Show The Personal Info']),
 'AP067': ('review',
           ['Fill Whole Form Valid',
            'Fill Field Portfolio    ${PORTFOLIO_URL_OK}',
            'Click Review',
            'Review Dialog Should Be Open',
            'Review Dialog Should Show The Documents']),
 'AP068': ('review',
           ['Open Review Dialog With Valid Form    Facebook    LinkedIn',
            'Review Dialog Should Include    Channel: Facebook, LinkedIn']),
 'AP069': ('review',
           ['Open Review Dialog With Valid Form',
            'Click Element Safe    ${MODAL_BACK}',
            'Review Dialog Should Be Closed',
            'Field Value Should Be    first_name    ${APPLICANT}[first_name]',
            'File Should Be Listed    cv.pdf',
            'Source Should Be Checked    Facebook']),
 'AP070': ('review',
           ['Open Review Dialog With Valid Form',
            'Click Element Safe    ${MODAL_CLOSE}',
            'Review Dialog Should Be Closed',
            'Field Value Should Be    first_name    ${APPLICANT}[first_name]']),
 'AP071': ('review',
           ['Open Review Dialog With Valid Form',
            'Press Keys    None    ESCAPE',
            'Review Dialog Should Be Closed']),
 'AP072': ('review', ['Open Review Dialog With Valid Form', 'Element Should Be Shown    ${MODAL_CONFIRM}']),
 'AP073': ('layout', ['Profile Panel Should Be On The Right On Desktop']),
 'AP074': ('layout', ['Tab Key Should Move Through The Personal Fields']),
 'AP075': ('footer', ['Apply Form Footer Should Be Shown'])}

# Text or behaviour that the dev site shows differently from Figma, or that the team must confirm.
ASSUMPTION_IDS = {'AP010', 'AP061', 'AP071', 'AP005', 'AP012', 'AP016', 'AP044', 'AP004', 'AP014', 'AP036', 'AP013', 'AP015'}


def file_header(title, ids, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({ids[0]} to {ids[-1]}). GENERATED by tools/csv_to_robot_apply.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../../resources/all_pages.resource",
                "Suite Setup       Open Jobs Page",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Open Apply Form",
                "Test Tags         automate    apply"]
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
        print(f"  apply/{filename}.robot  {len(by_group[group])}")
    print(f"  apply/{MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
