"""Locators of the CMS job management page: /admin/jobs.

All of these were checked on the dev site. The stat cards, the filters and the table body have ids;
the rest uses visible text and structure (there is no data-testid).
"""

JA_CONTENT = "id:cms-content"
JA_BADGE = "xpath://*[@id='cms-content']//h1/preceding-sibling::div[1]"
JA_H1 = "css:#cms-content h1"
JA_SUBTITLE = "css:#cms-content h1 + p"
JA_PUBLIC_LINK = "xpath://*[@id='cms-content']//a[contains(normalize-space(), 'ดูหน้า Public')]"
JA_NEW_LINK = "xpath://*[@id='cms-content']//a[@href='/admin/jobs/new']"
JA_NAV_JOBS = "xpath://nav[@aria-label='CMS sections']//a[@href='/admin/jobs']"

# Stat cards
JA_STAT_ACTIVE = "id:jobStatActive"
JA_STAT_EXPIRED = "id:jobStatAutoExpired"
JA_STAT_CLOSED = "id:jobStatForceClosed"
JA_STAT_VALUES = ["jobStatActive", "jobStatAutoExpired", "jobStatForceClosed"]

# Filters
JA_FILTER_TITLE = "id:adminJobTitleFilter"
JA_FILTER_DEPT = "id:adminJobDeptFilter"
JA_FILTER_TYPE = "id:adminJobTypeFilter"
JA_FILTER_STATUS = "id:adminJobStatusSearch"
JA_FILTER_START = "id:adminJobDeadlineStart"
JA_FILTER_END = "id:adminJobDeadlineEnd"
JA_CLEAR = "xpath:(//*[@id='cms-content']//button[normalize-space()='ล้างเงื่อนไขการค้นหา'])[1]"
JA_CLEAR_EMPTY = "xpath://*[@id='adminJobsTableBody']//a[normalize-space()='ล้างเงื่อนไขการค้นหา']"
JA_FILTER_SECTION = "xpath://section[.//h2[contains(normalize-space(), 'ค้นหาตำแหน่งงาน')]]"

# Table
JA_TABLE_SECTION = "xpath://section[.//h2[normalize-space()='รายการตำแหน่งงาน']]"
JA_RESULT_COUNT = "id:adminJobResultCount"
JA_TABLE_BODY = "id:adminJobsTableBody"
JA_TABLE_HEADINGS = "css:#cms-content table thead th"
JA_FIRST_EDIT = "xpath:(//*[@id='adminJobsTableBody']//a[normalize-space()='แก้ไข'])[1]"
JA_FIRST_TITLE = "xpath:(//*[@id='adminJobsTableBody']/tr/td[1])[1]"
