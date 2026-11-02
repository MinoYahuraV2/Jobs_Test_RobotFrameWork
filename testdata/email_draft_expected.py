"""Expected text for the CMS email draft page (to Head): /admin/applications/<id>/email?type=head.

The draft is only opened and filled in by the tests. Nothing here is ever sent: every test that
presses the send button uses a TO address that cannot be valid, so the server must refuse it.
Items marked "assumption" are behaviour seen on dev (or my own expectation) for the team to confirm.
"""

ED_PATH_SUFFIX = "/email?type=head"
ED_TITLE_PREFIX = "ร่างอีเมลส่งให้ Head พิจารณา: "
ED_TITLE_SUFFIX = " | EventPass Careers CMS"
ED_H1_TEXT = "ร่างอีเมลส่งให้ Head พิจารณา"
ED_SUBTITLE_TEXT = "ใช้สำหรับส่งต่อข้อมูลผู้สมัครให้หัวหน้าทีมพิจารณาภายใน"
ED_BACK_TEXT = "กลับไปหน้าโปรไฟล์ผู้สมัคร"
ED_CANCEL_TEXT = "ยกเลิก"
ED_SEND_TEXT = "ส่งอีเมล"
ED_UNKNOWN_TYPES = ["xyz", "HEAD", ""]      # assumption: any other type still opens the Head draft

# Form
ED_FORM_HEADING = "รายละเอียดร่างอีเมล"
ED_FORM_NOTE = "ระบบเตรียมข้อความตั้งต้นไว้ให้ HR สามารถแก้ไข TO, CC, Subject และเนื้อหาได้ก่อนส่ง"
ED_LABEL_TEXTS = ["TO *", "CC", "Subject *", "เนื้อหาอีเมล *", "อัปเดตสถานะ HR อัตโนมัติหลังส่งอีเมล"]
ED_TO_PLACEHOLDER = "ระบุอีเมลผู้รับ เช่น head.tech@example.com"
ED_CC_PLACEHOLDER = "ระบุอีเมล CC ถ้ามี"
ED_BODY_PLACEHOLDER = "พิมพ์เนื้อหาอีเมล..."
ED_SUBJECT_FORMAT = "ขอพิจารณาผู้สมัครตำแหน่ง {job} - {name}"
ED_BODY_START = "เรียน Head ทีมที่เกี่ยวข้อง"
ED_BODY_END = "ขอบคุณครับ/ค่ะ\nทีม HR EventThai"

# Attachments
ED_ATTACH_HEADING = "ไฟล์แนบจากใบสมัคร"
ED_ATTACH_NOTE = "ตัวอย่าง CV หลักและไฟล์แนบเพิ่มเติมจากหน้าสมัครงาน ที่จะถูกส่งต่อให้ Head พร้อมอีเมลฉบับนี้"
ED_ATTACH_TAG = "Attach to email"

# Info panel
ED_INFO_HEADING = "ข้อมูลประกอบ"
ED_INFO_NOTE = "สรุปข้อมูลผู้สมัครที่เกี่ยวข้องกับอีเมลนี้"
ED_INFO_LABELS = ["ประเภทอีเมล", "ผู้สมัคร", "ตำแหน่ง", "อีเมลผู้สมัคร", "CV หลัก"]
ED_INFO_TYPE_TEXT = "Internal / Head Review"

# Status after sending
ED_STATUS_HEADING = "สถานะหลังส่ง"
ED_STATUS_NOTE = "กำหนดการอัปเดตสถานะ HR หลังส่งอีเมล"
ED_AUTO_UPDATE_TEXT = "อัปเดตสถานะ HR อัตโนมัติหลังส่งอีเมล"
ED_STATUS_AFTER_TEXT = "รอ Head Review"          # same text as the HR status list on the profile
ED_STATUS_AFTER_OFF = "-"
ED_TARGET_STATUS = "pending-head-review"         # assumption: value sent to the server (the profile list uses head_review)

# Validation messages
ED_BANNER_TEXT = "กรุณาระบุข้อมูลร่างอีเมลให้ถูกต้องและครบถ้วน"
ED_TO_EMPTY_ERROR = "กรุณาระบุอีเมลผู้รับ (TO)"
ED_TO_BAD_ERROR = "รูปแบบอีเมลไม่ถูกต้อง"
ED_SUBJECT_EMPTY_ERROR = "กรุณาระบุหัวข้ออีเมล (Subject)"
ED_BODY_EMPTY_ERROR = "กรุณาระบุเนื้อหาอีเมล"
ED_CC_BAD_ERROR = "รูปแบบอีเมลไม่ถูกต้อง"        # assumption: CC should be checked like TO (dev shows no message now)
ED_BAD_TO = "abc"                                  # can never be a valid address, so nothing is sent
ED_BAD_CC = "not-an-email"

# Tab order
ED_TAB_ORDER = ["กลับไปหน้าโปรไฟล์ผู้สมัคร", "ยกเลิก", "ส่งอีเมล", "emailDraftTo", "emailDraftCc",
                "emailDraftSubject", "emailDraftBody", "View PDF", "emailAutoUpdateStatus", "ส่งอีเมล"]
