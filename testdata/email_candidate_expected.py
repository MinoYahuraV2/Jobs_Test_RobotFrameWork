"""Expected text for the CMS email draft to the applicant: /admin/applications/<id>/email?type=candidate.

The draft is only opened and filled in by the tests. Nothing is ever sent (see resources/pages/email_head.resource).
Items marked "assumption" are behaviour seen on dev (or my own expectation) for the team to confirm.
"""

EC_PATH_SUFFIX = "/email?type=candidate"
EC_TITLE_PREFIX = "ร่างอีเมลถึงผู้สมัคร: "
EC_H1_TEXT = "ร่างอีเมลถึงผู้สมัคร"
EC_SUBTITLE_TEXT = "ใช้สำหรับติดต่อผู้สมัคร เช่น นัดสัมภาษณ์ ขอข้อมูลเพิ่มเติม หรือแจ้งผล"
EC_LABEL_TEXTS = ["Template สำหรับผู้สมัคร", "TO *", "CC", "Subject *", "เนื้อหาอีเมล *",
                  "อัปเดตสถานะ HR อัตโนมัติหลังส่งอีเมล"]
EC_INFO_TYPE_TEXT = "Candidate Email"
EC_GREETING = "เรียน คุณ{name}"

# value, text in the list, Subject, status shown after sending, value the form sends, a sentence of the body
EC_TEMPLATES = [
    ("candidate-interview", "นัดสัมภาษณ์", "นัดหมายสัมภาษณ์ตำแหน่ง {job}",
     "ติดต่อกลับแล้ว", "contacted", "นัดหมายสัมภาษณ์เพิ่มเติม"),
    ("candidate-request-info", "ขอข้อมูลเพิ่มเติม", "ขอข้อมูลเพิ่มเติมสำหรับการสมัครงานตำแหน่ง {job}",
     "ติดต่อกลับแล้ว", "contacted", "ขอเอกสารหรือข้อมูลเพิ่มเติม"),
    ("candidate-passed", "แจ้งผ่านการพิจารณา", "แจ้งผลการพิจารณาการสมัครงานตำแหน่ง {job}",
     "ผ่านการพิจารณา", "passed", "ผ่านการพิจารณาคัดเลือก"),
    ("candidate-rejected", "แจ้งไม่ผ่านการพิจารณา", "แจ้งผลการพิจารณาการสมัครงานตำแหน่ง {job}",
     "ไม่ผ่านการพิจารณา", "rejected", "ยังไม่สามารถตอบรับท่านเข้าทำงาน"),
]
EC_DEFAULT_STATUS_AFTER = "ติดต่อกลับแล้ว"
# The form sends `rejected` for the "not passed" template; the system turns it into `failed` (confirmed by hand on dev, 2026-11-02).
EC_STATUS_ALIASES = {"rejected": "failed"}

# Tab order (assumption: the order the page is laid out)
EC_TAB_ORDER = ["กลับไปหน้าโปรไฟล์ผู้สมัคร", "ยกเลิก", "ส่งอีเมล", "emailDraftTemplate", "emailDraftTo", "emailDraftCc",
                "emailDraftSubject", "emailDraftBody", "emailAutoUpdateStatus", "ส่งอีเมล"]
