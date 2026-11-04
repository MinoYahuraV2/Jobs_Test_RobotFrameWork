"""Expected text and rules for the CMS applicant profile: /admin/applications/<id>.

Everything marked "assumption" is behaviour seen on the dev site (or my own expectation) that the
team should confirm. The cases that use it carry the tag `assumption`.
"""

PF_PATH_PATTERN = r"/admin/applications/[0-9a-f]{24}$"
PF_LIST_PATH = "/admin/dashboard"
PF_LIST_FRAGMENT = "#recent-applicants"
PF_FAKE_ID = "000000000000000000000000"
PF_BAD_ID = "abc"
PF_SCRIPT_ID = "%3Cscript%3Ealert(1)%3C%2Fscript%3E"

PF_TITLE_PREFIX = "โปรไฟล์ผู้สมัคร: "
PF_TITLE_SUFFIX = " | EventPass Careers CMS"
PF_H1_TEXT = "โปรไฟล์ผู้สมัคร"
PF_SUBTITLE_TEXT = "ตรวจสอบข้อมูลใบสมัคร ไฟล์แนบ ช่องทางที่ทราบข่าว Consent และอัปเดตสถานะ HR"
PF_BACK_TEXT = "กลับไปหน้าจัดการผู้สมัคร"
PF_LIST_TEXT = "รายการผู้สมัคร"
PF_SAVE_TEXT = "บันทึกการอัปเดต"

PF_NOT_FOUND_TITLE = "ไม่พบผู้สมัคร | EventPass Careers CMS"
PF_NOT_FOUND_HEADING = "ไม่พบข้อมูลผู้สมัคร"
PF_NOT_FOUND_TEXT = "รหัสผู้สมัครที่ระบุอาจถูกลบ ย้าย หรือไม่มีอยู่ในระบบ กรุณาตรวจสอบและลองใหม่อีกครั้ง"
PF_NOT_FOUND_BACK_TEXT = "กลับไปหน้ารายการผู้สมัคร"

# The five sections, in page order (h2)
PF_SECTION_HEADINGS = ["ข้อมูลจากใบสมัคร", "ประวัติการสมัครกับบริษัท", "ไฟล์จากใบสมัคร",
                       "ประวัติการสื่อสาร", "ผลการคัดกรองและสถานะ"]

# Application info
PF_INFO_NOTE = "ข้อมูลส่วนนี้เป็นข้อมูลที่ผู้สมัครยื่นเข้ามา ไม่สามารถแก้ไขจากหน้านี้ได้"
PF_APPLIED_PREFIX = "วันที่สมัคร:"
PF_INFO_LABEL_TEXTS = ["ชื่อ", "นามสกุล", "E-Mail", "เบอร์ติดต่อกลับ", "ตำแหน่งที่สมัคร", "เงินเดือนที่คาดหวัง",
                  "ช่องทางที่ทราบข่าวสมัครงาน", "Consent Form"]

# History
PF_HISTORY_NOTE = "ระบบยืนยันประวัติเดิมด้วยเงื่อนไข ชื่อ + นามสกุล + เบอร์ติดต่อกลับตรงกัน"
PF_HISTORY_BUTTON = "ค้นหาชื่อเดียวกันเพิ่มเติม"

# Files
PF_FILES_NOTE = "แยก CV หลักที่ใช้สำหรับ AI Screening ออกจากไฟล์ประกอบเพิ่มเติม"
PF_CV_TITLE = "ประวัติการทำงาน / CV หลัก"
PF_CV_TAG = "ใช้ประเมิน AI"
PF_EXTRA_TITLE = "ไฟล์แนบเพิ่มเติม"
PF_EXTRA_TAG = "ประกอบการพิจารณา"
PF_ZIP_NOTE = "หมายเหตุ: ZIP/RAR ใช้เป็นไฟล์ประกอบสำหรับ HR/Head Review ไม่ใช้เป็นไฟล์หลักในการประเมิน AI"
PF_PREVIEW_TITLE_PREFIX = "Preview"

# Email log
PF_LOG_NOTE = "บันทึกการส่งอีเมลภายในและอีเมลถึงผู้สมัคร"
PF_LOG_TAG = "Prototype Log"   # assumption: a label that may be removed before release
PF_LOG_HEADINGS_TEXT = ["วันที่", "ประเภท", "ผู้รับ", "ผู้ส่ง", "สถานะ"]

# Status panel
PF_STATUS_NOTE = "AI Screening เป็นผลประเมินจากระบบ ส่วน HR อัปเดตได้เฉพาะสถานะ HR"
PF_AI_NOTE = "ผลนี้มาจากการประเมินอัตโนมัติของ AI จาก JD และ CV ผู้สมัคร ไม่สามารถแก้ไขได้โดยตรง ใช้ประกอบการพิจารณาเท่านั้น"
PF_AI_FAILED_NOTE = "AI อ่าน CV ใบนี้ไม่สำเร็จ ให้พิจารณาจากไฟล์ CV โดยตรง"
PF_AI_LABELS = ["AI Match", "AI Partial Match", "วิเคราะห์ไม่สำเร็จ", "กำลังวิเคราะห์"]
PF_AI_FAILED = "วิเคราะห์ไม่สำเร็จ"
PF_HR_NOTE = "สถานะนี้ใช้ควบคุมการทำงานของ HR และรายงานผู้สมัคร"
# (value, text) in the order of the list. Same texts as the status filter on the dashboard.
PF_STATUS_OPTIONS = [("hr_review", "รอ HR Review"), ("head_review", "รอ Head Review"),
                     ("contacted", "ติดต่อกลับแล้ว"), ("passed", "ผ่านการพิจารณา"),
                     ("failed", "ไม่ผ่านการพิจารณา"), ("blacklist", "Blacklist")]
PF_NEXT_TITLE = "การดำเนินการต่อ"
PF_NEXT_NOTE = "เปิดร่างอีเมลก่อนส่งจริง เพื่อให้ HR ตรวจสอบ TO / CC และแก้ไขเนื้อหาได้"
PF_HEAD_EMAIL_TEXT = "ส่งให้ Head พิจารณา"
PF_CANDIDATE_EMAIL_TEXT = "ส่งอีเมลถึงผู้สมัคร"

# Email draft pages (opened only)
PF_HEAD_DRAFT_TITLE = "ร่างอีเมลส่งให้ Head พิจารณา"
PF_CANDIDATE_DRAFT_TITLE = "ร่างอีเมลถึงผู้สมัคร"
PF_DRAFT_BACK_TEXT = "กลับไปหน้าโปรไฟล์ผู้สมัคร"
PF_CANDIDATE_TEMPLATES = ["นัดสัมภาษณ์", "ขอข้อมูลเพิ่มเติม", "แจ้งผ่านการพิจารณา", "แจ้งไม่ผ่านการพิจารณา"]

# Tab order (assumption: the order the page is laid out, left to right, top to bottom)
PF_TAB_ORDER = ["กลับไปหน้าจัดการผู้สมัคร", "รายการผู้สมัคร", "บันทึกการอัปเดต", "ค้นหาชื่อเดียวกันเพิ่มเติม",
                "View PDF"]
