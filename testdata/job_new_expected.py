"""Expected text for the CMS new job form: /admin/jobs/new.

The tests only open the form, fill it in and look at it. They NEVER save: a saved job appears on the public
Jobs page. Every click on the save button is made with the title empty, which the browser refuses, and a safety
net stops any form that would still go out. Real saving is a manual case.
Items marked "assumption" are behaviour seen on dev (or my own expectation) for the team to confirm.
"""

JN_PATH = "/admin/jobs/new"
JN_LIST_PATH = "/admin/jobs"
JN_TITLE_TEXT = "เพิ่มตำแหน่งงานใหม่ | EventPass Careers CMS"
JN_BACK_TEXT = "กลับไปหน้ารายการตำแหน่งเปิดรับ"
JN_BADGE_TEXT = "Position Editor"
JN_H1_TEXT = "เพิ่มตำแหน่งงานใหม่"
JN_SUBTITLE_TEXT = "กรอกข้อมูลตำแหน่งงานเพื่อนำไปแสดงผลบนหน้าประกาศรับสมัครงาน"
JN_CANCEL_TEXT = "ยกเลิก / กลับหน้ารายการ"
JN_SAVE_TEXT = "บันทึกตำแหน่งงาน"

# Sections
JN_LOCATION_HEADING = "สถานที่ปฏิบัติงานและแผนที่ (Location)"
JN_LOCATION_NOTE = "ข้อมูลที่อยู่และพิกัดแผนที่ (Latitude, Longitude) สำหรับแสดงผลบนหน้าประกาศรับสมัครงาน"
JN_STATUS_HEADING = "Publishing Status"
JN_METADATA_HEADING = "Metadata"
JN_BENEFITS_HEADING = "สวัสดิการ"
JN_BENEFITS_NOTE = "เลือกสวัสดิการที่จะไปแสดงในหน้ารายละเอียดงาน"
JN_MANUAL_TITLE = "Manual Toggle"
JN_MANUAL_NOTE = "เปิดไว้เพื่อให้ระบบคำนวณตามวันที่"
JN_DEADLINE_NOTE = "ระบบจะเปลี่ยนสถานะเป็นปิดรับสมัครอัตโนมัติ ณ เวลา 23:59 น. ของวันที่ระบุ"
JN_INTERN_NOTE = "หากเลือก Internship ระบบจะจัดตำแหน่งนี้ไปอยู่ใน Tab นักศึกษาฝึกงาน"
JN_URGENT_TEXT = "แสดง Badge: Urgent"
JN_REQUIRED_TAG = "Required"

# Labels (the star is part of the label)
JN_LABELS = ["ชื่อตำแหน่งงาน *", "เกี่ยวกับงานนี้ *", "ความรับผิดชอบ (Responsibilities) *", "คุณสมบัติ (Qualifications) *",
             "ที่อยู่สถานที่ปฏิบัติงาน (Location Address) *", "ละติจูด (Lat) *", "ลองจิจูด (Lng) *", "เปิดรับถึงวันที่ *",
             "แผนก *", "ประเภทการจ้างงาน *", "หมวดการแสดงผล *", "สถานที่ทำงานหลัก (Work Location) *",
             "จำนวนอัตราที่เปิดรับ (Vacancies) *"]

# Defaults (the form is pre-filled except the title)
JN_TITLE_PLACEHOLDER = "เช่น Senior Frontend Engineer (React)"
JN_DEFAULT_DEPT = "บริหาร (Management / Executive)"
JN_DEFAULT_TYPE = "Full-Time"
JN_DEFAULT_TAB = "ตำแหน่งที่เปิดรับ"
JN_INTERN_TAB = "นักศึกษาฝึกงาน (Internship)"
JN_DEFAULT_WORK_LOCATION = "Bangkok HQ"
JN_DEFAULT_VACANCIES = "1"
JN_DEFAULT_DEADLINE_DAYS = 30            # assumption: the default closing date is today + 30 days
JN_DEFAULT_LOCATION_TEXT = "ตำบลบ้านใหม่ อำเภอปากเกร็ด จังหวัดนนทบุรี"
JN_DEFAULT_LAT = "13.909839711764425"
JN_DEFAULT_LNG = "100.54939055069198"
JN_DEFAULT_ABOUT_START = "เรากำลังมองหาผู้ร่วมทีม"                  # assumption: sample text is pre-filled
JN_DEFAULT_RESP_START = "รับผิดชอบในส่วนงานที่ได้รับมอบหมาย"
JN_DEFAULT_QUAL_START = "มีประสบการณ์การทำงานในสายงานที่เกี่ยวข้อง"

# Lists (same as the filters on the job list)
JN_DEPARTMENTS = ["บริหาร (Management / Executive)", "Project / Operation", "Marketing / Digital / Content",
                  "Design / Creative", "Tech / IT / Developer", "Sales / Business Development",
                  "Customer Support / Service", "Admin / Support / HR", "QA / Technical Support",
                  "Production / Creative Media"]
JN_TYPES = ["Full-Time", "Part-Time", "Contract", "Internship"]
JN_TABS = ["ตำแหน่งที่เปิดรับ", "นักศึกษาฝึกงาน (Internship)"]
JN_BENEFIT_NAMES = ["วันหยุดพักผ่อนประจำปี (Annual Leave)", "ประกันสุขภาพและประกันอุบัติเหตุ", "กองทุนสำรองเลี้ยงชีพ",
               "งบสำหรับการเรียนรู้และพัฒนาตัวเอง", "โบนัสประจำปีตามผลประกอบการ", "ทำงานแบบ Hybrid",
               "เบี้ยเลี้ยงฝึกงาน (ตามตกลง)", "ใบรับรองการผ่านงาน (Certificate)",
               "โอกาสเรียนรู้และทำงานจริงกับผู้เชี่ยวชาญ", "โอกาสพิจารณาเป็นพนักงานประจำในอนาคต"]

# Status preview: (title, note)
JN_STATUS_OPEN = ("เปิดรับสมัครอยู่", "แสดงในหน้า Public และรับใบสมัครได้ตามปกติ")
JN_STATUS_FORCE = ("ปิดรับสมัครด้วยมือ", "Force Close: HR ปิดการแสดงผลทันที แม้ยังไม่ถึงวันที่กำหนด")
JN_STATUS_EXPIRED = ("หมดเขตรับสมัคร (Auto)", "ระบบซ่อนจากหน้า Public อัตโนมัติ เพราะเลยวันที่เปิดรับถึงแล้ว")

# Rich text toolbar (aria-labels of the buttons and lists)
JN_TOOLBAR_BUTTONS = ["ตัวหนา", "ตัวเอียง", "ขีดเส้นใต้", "ชิดซ้าย", "กึ่งกลาง", "ชิดขวา", "รายการแบบจุด",
                      "รายการแบบตัวเลข", "ลดการเยื้อง", "เพิ่มการเยื้อง", "แทรกลิงก์", "ล้างรูปแบบ"]
JN_TOOLBAR_LISTS = ["รูปแบบข้อความ (Font Format)", "ขนาดตัวอักษร (Font Size)"]
JN_SCRIPT_TEXT = "Hello <script>alert(1)</script> & world"

# Tab order of the main fields (assumption: the order they are laid out)
JN_TAB_ORDER = ["jobTitleInput", "jobAboutEditor", "jobResponsibilitiesEditor", "jobQualificationsEditor",
                "jobLocationTextInput", "jobLocationLatInput", "jobLocationLngInput", "jobManualOpenToggle",
                "jobDeadlineInput", "jobDeptInput", "jobEmploymentTypeInput", "jobTabTypeInput",
                "jobWorkLocationInput", "jobVacanciesInput", "jobHotInput"]
