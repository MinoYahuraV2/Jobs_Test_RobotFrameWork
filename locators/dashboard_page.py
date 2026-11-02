"""Locators of the CMS dashboard: /admin/dashboard.

All of these were checked on the dev site. The page has ids on the filter form and the table
section, but no data-testid on the rest, so the other items use ids, aria-labels and structure.
"""

DASH_H1 = "css:#cms-content h1"
DASH_SUBTITLE = "css:#cms-content h1 + p"
DASH_EXPORT = "xpath://button[normalize-space()='Export Report']"
DASH_NEW_JOB = "xpath://a[@href='/admin/jobs/new']"
DASH_SKIP_LINK = "xpath://a[@href='#cms-content']"
DASH_CONTENT = "id:cms-content"

# Top bar
DASH_BRAND_LINK = "xpath://header//a[@href='/admin/dashboard' and contains(normalize-space(), 'HR Admin')]"
DASH_HEADER_LOGO = "xpath://header//img[1]"
DASH_USER_AREA = "xpath://header//*[normalize-space()='ผู้ดูแลระบบ']"
DASH_USER_AVATAR = "xpath://header//*[normalize-space()='HR' and not(self::a)]"
DASH_NAV = "css:nav[aria-label='CMS sections']"
DASH_NAV_LINKS = "css:nav[aria-label='CMS sections'] a"
DASH_NAV_DASHBOARD = "xpath://nav[@aria-label='CMS sections']//a[@href='/admin/dashboard']"
DASH_NAV_APPLICANTS = "xpath://nav[@aria-label='CMS sections']//a[@href='#recent-applicants']"
DASH_NAV_JOBS = "xpath://nav[@aria-label='CMS sections']//a[@href='/admin/jobs']"
DASH_MOBILE_MENU_BUTTON = "xpath://button[@aria-label='เปิดเมนู CMS']"
DASH_MOBILE_NAV = "id:cms-mobile-navigation"

# Applicant table section
DASH_TABLE_SECTION = "id:recent-applicants"
DASH_TABLE_HEADINGS = "css:#recent-applicants thead th"
DASH_TABLE_FIRST_PROFILE = "xpath:(//*[@id='recent-applicants']//tbody//a[normalize-space()='ดูโปรไฟล์'])[1]"

# Filters (GET form: name, job, status, from, to)
DASH_FILTER_NAME = "id:filter-name"
DASH_FILTER_JOB = "id:filter-job"
DASH_FILTER_STATUS = "id:filter-status"
DASH_FILTER_FROM = "id:filter-from"
DASH_FILTER_TO = "id:filter-to"
DASH_SEARCH_BUTTON = "xpath://*[@id='recent-applicants']//button[@type='submit' and normalize-space()='ค้นหา']"
DASH_CLEAR_FILTERS_TOP = "xpath:(//*[@id='recent-applicants']//a[normalize-space()='ล้างตัวกรอง'])[1]"
DASH_CLEAR_FILTERS_EMPTY = "xpath:(//*[@id='recent-applicants']//a[normalize-space()='ล้างตัวกรอง'])[last()]"

# Pager
DASH_PAGER_PREV = "xpath://*[@id='recent-applicants']//a[normalize-space()='ก่อนหน้า']"
DASH_PAGER_NEXT = "xpath://*[@id='recent-applicants']//a[normalize-space()='ถัดไป']"
