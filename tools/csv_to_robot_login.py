"""Build the CMS login .robot files from data/testcases_login.csv.

Run:  python tools/csv_to_robot_login.py [path/to/testcases_login.csv]

* Same idea as tools/csv_to_robot_apply.py: the CSV is the source of truth for ID, description,
  expected result and type. STEPS maps each ID to its keywords and file group.
* Writes tests/login/*.robot (the other test folders are not touched).
* Do not hand-edit the generated files; edit STEPS or resources/pages/login.resource instead.
* "Forgot password" is not built yet by dev, so it has no case on purpose.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from csv_to_robot import read_cases, render_test  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_CSV = ROOT / "data" / "testcases_login.csv"
OUT_DIR = ROOT / "tests" / "login"
PREFIX = "LG"

GROUPS = {
    "open": ("01_open", "Open the login page and what it shows"),
    "nav": ("02_navigation", "Links on the login page"),
    "validation": ("03_validation", "Empty and badly formed input (blocked by the browser)"),
    "wrong": ("04_wrong_login", "Wrong email or password"),
    "good": ("05_good_login", "Successful login"),
    "session": ("06_session", "Cookies, logout and pages that need a login"),
    "keyboard": ("07_keyboard_layout", "Keyboard, remember-me checkbox and layout"),
}
MANUAL_FILE = "99_manual"

# LG id -> (group, [steps])
STEPS = {
    "LG001": ("open", ["Login Page Should Be Open"]),
    "LG002": ("open", ["Title Should Be    ${LOGIN_TITLE}"]),
    "LG003": ("open", ["Login Logo Should Be Loaded"]),
    "LG004": ("open", ["Element Text Should Be    ${LOGIN_HEADING}    ${LOGIN_HEADING_TEXT}"]),
    "LG005": ("open", ["Element Text Should Be    ${LOGIN_SUBTITLE}    ${LOGIN_SUBTITLE_TEXT}"]),
    "LG006": ("open", ["Login Labels Should Match"]),
    "LG007": ("open", ["Login Placeholders Should Match"]),
    "LG008": ("open", ["Login Form Should Be Empty By Default"]),
    "LG009": ("open", ["Element Text Should Be    ${LOGIN_SUBMIT}    ${LOGIN_SUBMIT_TEXT}",
                       "Element Should Be Enabled    ${LOGIN_SUBMIT}"]),
    "LG010": ("open", ["Element Text Should Be    ${LOGIN_BACK_HOME}    ${LOGIN_BACK_HOME_TEXT}"]),
    "LG011": ("open", ["Fill Login Form    password=secret-text",
                       "Element Attribute Value Should Be    ${LOGIN_PASSWORD}    type    password"]),
    "LG012": ("open", ["Label Click Should Focus Field    ${LOGIN_EMAIL_LABEL}    login-email",
                       "Label Click Should Focus Field    ${LOGIN_PASSWORD_LABEL}    login-password"]),
    "LG013": ("open", ["Login Autocomplete Should Be Set"]),
    "LG014": ("nav", ["Click Element    ${LOGIN_BACK_HOME}", "Home Page Should Be Open"]),
    "LG015": ("nav", ["Logout Button Should Not Be Shown"]),
    "LG016": ("validation", ["Submit Login",
                             "Form Should Not Have Been Sent",
                             "Login Field Validity Should Be    ${LOGIN_EMAIL}    valueMissing"]),
    "LG017": ("validation", ["Fill Login Form    email=somebody@example.com",
                             "Submit Login",
                             "Form Should Not Have Been Sent",
                             "Login Field Validity Should Be    ${LOGIN_PASSWORD}    valueMissing"]),
    "LG018": ("validation", ["Fill Login Form    password=secret-text",
                             "Submit Login",
                             "Form Should Not Have Been Sent",
                             "Login Field Validity Should Be    ${LOGIN_EMAIL}    valueMissing"]),
    "LG019": ("validation", ["Fill Login Form    email=abc    password=secret-text",
                             "Submit Login",
                             "Form Should Not Have Been Sent",
                             "Login Field Validity Should Be    ${LOGIN_EMAIL}    typeMismatch"]),
    "LG020": ("wrong", ["Failed Login With Changed Admin Password    append",
                        "Login Error Should Be    ${LOGIN_ERR_WRONG_PASSWORD}"]),
    "LG021": ("wrong", ["Login Wrong Attempt    ${LOGIN_UNKNOWN_EMAIL}    secret-text-1",
                        "Login Error Should Be    ${LOGIN_ERR_WRONG_PASSWORD}",
                        "Login Should Not Have Entered The Cms"]),
    "LG022": ("wrong", ["Login Wrong Attempt    ${LOGIN_UNKNOWN_EMAIL}    secret-text-1",
                        "Login Error Should Be    ${LOGIN_ERR_WRONG_PASSWORD}"]),
    "LG023": ("wrong", ["Failed Login With Changed Admin Password    swapcase",
                        "Login Error Should Be    ${LOGIN_ERR_WRONG_PASSWORD}"]),
    "LG024": ("wrong", ["Failed Login With Password    ' OR '1'='1' --",
                        "Login Error Should Be    ${LOGIN_ERR_WRONG_PASSWORD}"]),
    "LG025": ("wrong", ["Failed Login With Password    <script>alert(1)</script>",
                        "Alert Should Not Be Present"]),
    "LG026": ("wrong", ["${long}=    Evaluate    'a' * 1000",
                        "Failed Login With Password    ${long}"]),
    "LG027": ("wrong", ["Email Should Be Kept After Error"]),
    "LG028": ("wrong", ["Submit Button Should Show Loading While Sending"]),
    "LG029": ("wrong", ["Failed Login With Changed Admin Password    append",
                        "Fill Login Form    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}",
                        "Submit Login",
                        "Dashboard Should Be Open"]),
    "LG030": ("good", ["Login As Admin And Reach Dashboard"]),
    "LG031": ("good", ["Require Admin Account",
                       "Fill Login Form    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}",
                       "Press Keys    ${LOGIN_PASSWORD}    ENTER",
                       "Dashboard Should Be Open"]),
    "LG032": ("good", ["Login As Admin And Reach Dashboard", "Cms Menu Should Be Shown"]),
    "LG033": ("good", ["Require Admin Account",
                       "${upper}=    Evaluate    $ADMIN_EMAIL.upper()",
                       "Fill Login Form    ${upper}    ${ADMIN_PASSWORD}",
                       "Submit Login",
                       "Dashboard Should Be Open"]),
    "LG034": ("good", ["Login As Admin And Reach Dashboard    remember=${True}"]),
    "LG035": ("good", ["Login As Admin And Reach Dashboard",
                       "Go To    ${BASE_URL}${ADMIN_LOGIN_PATH}",
                       "Dashboard Should Be Open"]),
    "LG036": ("good", ["Login After Redirect Should Open Dashboard    /admin/jobs"]),
    "LG037": ("session", ["Login As Admin And Reach Dashboard", "Session Cookies Should Be HttpOnly"]),
    "LG038": ("session", ["Login As Admin And Reach Dashboard",
                          "Session Should Last About    ${LOGIN_DAYS_REMEMBER_OFF}"]),
    "LG039": ("session", ["Login As Admin And Reach Dashboard    remember=${True}",
                          "Session Should Last About    ${LOGIN_DAYS_REMEMBER_ON}"]),
    "LG040": ("session", ["Login As Admin And Reach Dashboard",
                          "Logout From Cms",
                          "Login Page Should Be Open",
                          "Session Cookies Should Be Gone"]),
    "LG041": ("session", ["Login As Admin And Reach Dashboard",
                          "Logout From Cms",
                          "Logged Out Page Should Ask For Login    ${LOGIN_DASHBOARD_PATH}"]),
    "LG042": ("session", ["Login As Admin And Reach Dashboard",
                          "Browser Back After Logout Should Not Show The Cms"]),
    "LG043": ("session", ["Login Should Remember Where You Wanted To Go    /admin"]),
    "LG044": ("session", ["Login Should Remember Where You Wanted To Go    /admin/jobs"]),
    "LG045": ("session", ["Login Should Remember Where You Wanted To Go    ${LOGIN_DASHBOARD_PATH}"]),
    "LG046": ("session", ["Logged Out Page Should Ask For Login    ${LOGIN_FAKE_APPLICATION_PATH}"]),
    "LG047": ("session", ["Logged Out Page Should Ask For Login    /admin/jobs/new"]),
    "LG048": ("keyboard", ["Tab Order Should Follow The Form"]),
    "LG049": ("keyboard", ["Remember Me Should Toggle With Click"]),
    "LG050": ("keyboard", ["Remember Me Should Toggle With Space"]),
    "LG051": ("keyboard", ["Login Card Should Be Centered"]),
    "LG052": ("keyboard", ["Login Page Should Fit A Phone Screen"]),
}

# Behaviour read from the dev site that the team must confirm (no design file for this page).
ASSUMPTION_IDS = {"LG022", "LG027", "LG028", "LG033", "LG038", "LG039"}
# Needs the admin account from config/secrets.local.env.
NEEDS_ACCOUNT = {"LG020", "LG023", "LG024", "LG025", "LG026", "LG027", "LG028", "LG029", "LG030",
                 "LG031", "LG032", "LG033", "LG034", "LG035", "LG036", "LG037", "LG038", "LG039",
                 "LG040", "LG041", "LG042"}


def file_header(title, ids, manual=False):
    out = ["*** Settings ***",
           f"Documentation     {title} ({ids[0]} to {ids[-1]}). GENERATED by tools/csv_to_robot_login.py - do not edit."]
    if manual:
        out += ["Test Tags         manual"]
    else:
        out += ["Resource          ../../resources/all_pages.resource",
                "Suite Setup       Open Admin Browser",
                "Suite Teardown    Close All Browsers",
                "Test Setup        Open Login Page",
                "Test Tags         automate    login"]
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
        if case["id"] in NEEDS_ACCOUNT:
            tags.append("needs-account")
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
        print(f"  login/{filename}.robot  {len(by_group[group])}")
    print(f"  login/{MANUAL_FILE}.robot  {len(manual)}")


if __name__ == "__main__":
    main()
