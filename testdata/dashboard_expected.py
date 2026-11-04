"""Expected values for the CMS dashboard tests (text seen on the dev site).

Nothing here depends on the applicants in the database: the tests read the numbers and rows
from the page itself and check that they agree with each other (and with the Export file).
"""

DASH_PATH = "/admin/dashboard"
DASH_JOBS_PATH = "/admin/jobs"
DASH_NEW_JOB_PATH = "/admin/jobs/new"
DASH_APPLICATION_PATH_PATTERN = r"/admin/applications/[0-9a-f]{24}$"

DASH_TITLE = "Dashboard | EventPass Careers CMS"
DASH_H1_TEXT = "Dashboard"
DASH_SUBTITLE_TEXT = "ภาพรวมและสถานะของผู้สมัครงานทั้งหมด"
DASH_BRAND_TEXT = "HR Admin"
DASH_USER_TEXT = "ผู้ดูแลระบบ"
DASH_USER_AVATAR_TEXT = "HR"
DASH_EXPORT_TEXT = "Export Report"
DASH_NEW_JOB_TEXT = "สร้างตำแหน่งงานใหม่"
DASH_SKIP_LINK_TEXT = "ข้ามไปยังเนื้อหา"
DASH_MOBILE_MENU_LABEL = "เปิดเมนู CMS"

DASH_NAV_TEXTS = ["ภาพรวม (Dashboard)", "จัดการผู้สมัคร", "ตำแหน่งงานเปิดรับ"]

# Summary
DASH_TOTAL_LABEL = "ผู้สมัครทั้งหมด"
DASH_TOTAL_DESC = "ยอดรวมผู้สมัครทั้งหมด แยกออกจากสถานะ Workflow เพื่อให้อ่าน Dashboard ได้ชัดเจน"
DASH_FLOW_STEPS = ["HR Review", "Head Review", "Contacted"]

# (card label, status text in the table / filter list, filter value in the URL, card description)
DASH_STATUS_CARDS = [
    ["รอ HR Review", "รอ HR Review", "hr_review", "ผู้สมัครใหม่ที่รอ HR ตรวจสอบ"],
    ["รอ Head Review", "รอ Head Review", "head_review", "ส่งต่อให้หัวหน้าทีมพิจารณา"],
    ["ติดต่อกลับแล้ว (Contacted)", "ติดต่อกลับแล้ว", "contacted", "ติดต่อผู้สมัครแล้ว / รอสัมภาษณ์"],
    ["ผ่านการพิจารณา (Passed)", "ผ่านการพิจารณา", "passed", "รอเซ็นสัญญา / เริ่มงาน"],
    ["ไม่ผ่านการพิจารณา (Failed)", "ไม่ผ่านการพิจารณา", "failed", "ส่งอีเมลปฏิเสธแล้ว"],
    ["ติด Blacklist", "Blacklist", "blacklist", "ไม่มาสัมภาษณ์ / ประวัติมีปัญหา"],
]
DASH_STATUS_CARD_LABELS = [c[0] for c in DASH_STATUS_CARDS]
DASH_STATUS_TEXTS = [c[1] for c in DASH_STATUS_CARDS]
# Same names as in the summary sheet of the Export file.
DASH_EXPORT_SUMMARY_NAMES = ["รอ HR Review", "รอ Head Review", "ติดต่อกลับแล้ว", "ผ่านการพิจารณา",
                             "ไม่ผ่านการพิจารณา", "Blacklist"]

# Table
DASH_TABLE_SECTION_TITLE = "รายการผู้สมัครล่าสุด"
DASH_TABLE_HEADINGS_TEXT = ["วันที่สมัคร", "ผู้สมัคร", "ตำแหน่งที่สมัคร", "AI Screening", "สถานะ HR", "จัดการ"]
DASH_PAGE_SIZE = 20
DASH_BADGE_PATTERN = r"^(ผู้สมัครใหม่|เคยสมัคร \d+ ครั้ง)$"
DASH_AI_LABELS = ["AI Match", "AI Partial Match", "วิเคราะห์ไม่สำเร็จ", "กำลังวิเคราะห์"]
DASH_AI_SCORE_PATTERN = r"^Score: (\d{1,3}%|-)$"
DASH_PROFILE_LINK_TEXT = "ดูโปรไฟล์"

# Filters
DASH_SEARCH_PLACEHOLDER = "ชื่อ อีเมล หรือเบอร์โทร..."
DASH_SEARCH_MAXLENGTH = "120"
DASH_ALL_JOBS_TEXT = "ทุกตำแหน่ง"
DASH_ALL_STATUS_TEXT = "สถานะ HR ทั้งหมด"
DASH_STATUS_OPTIONS = ["สถานะ HR ทั้งหมด"] + [c[1] for c in DASH_STATUS_CARDS]
DASH_EMPTY_TITLE = "ไม่พบผู้สมัครตามเงื่อนไข"
DASH_EMPTY_HINT = "ลองเปลี่ยนคำค้นหา หรือดูผู้สมัครทั้งหมด"
DASH_CLEAR_FILTERS_TEXT = "ล้างตัวกรอง"
DASH_NO_MATCH_SEARCH = "zzzzqqqq-no-such-applicant"
DASH_LONG_SEARCH_LENGTH = 200

# Export
DASH_EXPORT_FILE_PATTERN = r"^eventpass-career-report-(\d{8})\.xlsx$"
DASH_EXPORT_SHEETS = ["ผู้สมัคร", "ตำแหน่งงาน"]
DASH_EXPORT_APPLICANT_COLUMNS = ["วันที่สมัคร", "ชื่อ", "นามสกุล", "อีเมล", "เบอร์โทร",
                                 "ตำแหน่งที่สมัคร", "เงินเดือนที่คาดหวัง", "สถานะ"]
DASH_DOWNLOAD_FOLDER = "results/downloads"
