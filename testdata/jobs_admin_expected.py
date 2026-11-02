"""Expected text for the CMS job management page: /admin/jobs.

The tests read the rows from the page and check them against each other, the filters and the public
Jobs page, so they do not depend on which jobs exist. Items marked "assumption" are behaviour seen on
dev (or my own expectation) for the team to confirm.
"""

JA_PATH = "/admin/jobs"
JA_NEW_PATH = "/admin/jobs/new"
JA_TITLE = "จัดการตำแหน่งงานเปิดรับ | EventPass Careers CMS"
JA_NEW_TITLE = "เพิ่มตำแหน่งงานใหม่ | EventPass Careers CMS"
JA_EDIT_TITLE_PREFIX = "แก้ไขตำแหน่งงาน: "
JA_TITLE_SUFFIX = " | EventPass Careers CMS"
JA_BADGE_TEXT = "Job Position Management"
JA_H1_TEXT = "จัดการตำแหน่งงานเปิดรับ"
JA_SUBTITLE_TEXT = "หน้ารวมตำแหน่งงานทั้งหมด พร้อมสถานะ Manual Toggle + Auto-Expiration"
JA_PUBLIC_LINK_TEXT = "ดูหน้า Public"
JA_NEW_LINK_TEXT = "เพิ่มตำแหน่งใหม่"
JA_NAV_TEXTS = ["ภาพรวม (Dashboard)", "จัดการผู้สมัคร", "ตำแหน่งงานเปิดรับ"]

# Stat cards (label, id of the number)
JA_STAT_LABELS = ["เปิดรับอยู่", "หมดเขตอัตโนมัติ", "ปิดด้วยมือ"]

# Filters
JA_FILTER_HEADING = "ค้นหาตำแหน่งงาน"
JA_FILTER_NOTE = "ค้นหาและกรองข้อมูลตำแหน่งงานเปิดรับในระบบหลังบ้าน"
JA_FILTER_LABELS = ["ค้นหาจากตำแหน่งที่เปิดรับ", "ค้นหาแผนก", "ค้นหาประเภท", "ค้นหาสถานะ", "ค้นหาช่วงวันที่เปิดรับ"]
JA_TITLE_PLACEHOLDER = "เช่น Frontend, Marketing, UX/UI"
JA_DATE_PLACEHOLDER = "dd/mm/yyyy"
JA_DATE_NOTE = "ระบบจะค้นหาจากวันที่ “เปิดรับถึง” ของแต่ละตำแหน่ง"
JA_ALL_DEPARTMENTS = "แผนกทั้งหมด"
JA_ALL_TYPES = "ประเภททั้งหมด"
JA_ALL_STATUSES = "สถานะทั้งหมด"
JA_DEPARTMENTS = ["บริหาร (Management / Executive)", "Project / Operation", "Marketing / Digital / Content",
                  "Design / Creative", "Tech / IT / Developer", "Sales / Business Development",
                  "Customer Support / Service", "Admin / Support / HR", "QA / Technical Support",
                  "Production / Creative Media"]
JA_TYPES = ["Full-Time", "Part-Time", "Contract", "Internship"]
# (text in the list, value used by the page)
JA_STATUSES = [("เปิดรับสมัครอยู่", "open"), ("หมดเขตรับสมัคร (Auto)", "closed"), ("ปิดรับสมัครด้วยมือ", "draft")]
JA_CLEAR_TEXT = "ล้างเงื่อนไขการค้นหา"
JA_EMPTY_TEXT = "ไม่พบตำแหน่งงานที่ตรงกับเงื่อนไขการค้นหา"
JA_NO_MATCH_SEARCH = "zzzzqqqq-no-such-job"

# Table
JA_TABLE_HEADING = "รายการตำแหน่งงาน"
JA_TABLE_NOTE = "กด “เพิ่มตำแหน่งใหม่” หรือ “แก้ไข” เพื่อเปิดหน้าฟอร์มใหม่ในแท็บเดิม"
JA_PUBLIC_NOTE = "เผยแพร่หน้า Public เฉพาะตำแหน่งที่"
JA_TABLE_HEADINGS_TEXT = ["ตำแหน่งงาน", "แผนก / ประเภท", "เปิดรับถึง", "สถานะ", "MANUAL TOGGLE", "จัดการ"]
JA_RESULT_PATTERN = r"^แสดง (\d+) จากทั้งหมด (\d+) รายการ$"

# Tab order (assumption: the order the page is laid out, left to right, top to bottom)
JA_TAB_ORDER = ["ดูหน้า Public", "เพิ่มตำแหน่งใหม่", "ล้างเงื่อนไขการค้นหา", "adminJobTitleFilter", "adminJobDeptFilter",
                "adminJobTypeFilter", "adminJobStatusSearch", "adminJobDeadlineStart", "adminJobDeadlineEnd"]
