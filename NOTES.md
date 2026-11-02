# บันทึกสิ่งที่ค้าง (อัปเดต 2026-10-28)

## หน้า Jobs Detail: เคสที่พัง
- JD071: ข้อมูล JobPosting (ที่ให้ Google อ่าน) ใช้ `http://localhost:3000` แทนเว็บจริง
  - เป็นบั๊กของเว็บ ต้องส่ง dev แก้ (url และ hiringOrganization.sameAs)
  - ดูเอง: เปิดหน้ารายละเอียดงาน กด Ctrl+U แล้วค้น `localhost`

## Figma มี แต่เว็บ dev ไม่มี (รอทีมยืนยันว่า dev ลืม หรือตั้งใจตัด)
- Work Arrangement (Hybrid: Blend of office and remote work ...)
- Posted date (Posted Jun 24, 2026)
- Work Location: Figma เขียน `Bangkok HQ (Pak Kret, Nonthaburi)` เว็บเขียน `Bangkok HQ (Pak Kret)`
- ลิงก์ Footer 6 อัน: Culture, FAQ, Recruitment Process, Cookies, Terms, Privacy
- ปุ่ม Share Job (Figma มีไอคอน ↗) ยังไม่รู้ว่ากดแล้วเกิดอะไร (JD058 เป็น manual)

## เคสที่ยังไม่ได้รัน
- Jobs: TC077 (พอดี 5 งาน), TC078 (พอดี 6 งาน) ต้องปรับจำนวนงานใน CMS
- Detail manual 3 เคส: JD029, JD058, JD074

## ตั้งค่า
- เทสหน้า Detail ตรวจแค่งาน `Tester AI` (ตั้งที่ `DETAIL_JOB_ONLY` ใน `config/env.py`)
- ตรวจทุกงาน: `$env:JOBS_DETAIL_JOB_ONLY = ""`

## Git
- ยังไม่ได้ commit งานหน้า Detail
- ยัง push ไม่ได้ ต้องรันเอง: `git push -u origin main`

## ฟอร์มสมัครงาน (Apply Job) — เทสอยู่ใน branch `feature/apply-form-tests`
- 79 เคส (`data/testcases_apply.csv`): automate 75, manual 4 สร้างไฟล์ด้วย `python tools/csv_to_robot_apply.py`
- ไม่มีเคสไหนกด `Confirm & Submit Application` เพราะจะเกิดใบสมัครจริงบน dev (เป็นเคส manual)
- เคสที่ติด tag `assumption` ใช้ข้อความตามเว็บ dev ไม่ใช่ Figma ถ้าทีมบอกว่า Figma ถูก ต้องแก้ที่ `testdata/apply_expected.py`

Figma ต่างจากเว็บ dev (รอทีมยืนยัน ว่าอันไหนถูก)
| จุด | Figma | เว็บ dev |
|---|---|---|
| หัวฟอร์ม | Job Application Form | แบบฟอร์มสมัครงาน |
| บรรทัดตำแหน่ง | Applying for— Event Operations Manager | สมัครตำแหน่ง Tester AI |
| ชื่อส่วนแรก | Personal Information + All fields marked with * are required. | ข้อมูลผู้สมัคร + Let's start with the basics. |
| ชื่อช่อง | First name, Last name, Email address, Phone number, Expected salary (THB) | ชื่อภาษาไทย, นามสกุลภาษาไทย, อีเมล, เบอร์โทรศัพท์, เงินเดือนที่คาดหวัง (THB) |
| ข้อความตัวอย่างในช่อง | Enter your firstname, 08X-XXX-XXXX, e.g. 30,000 - 35,000 | เช่น อารยา, 081-234-5678, เช่น 30,000 |
| Breadcrumb | Careers > Jobs > Job Details > Apply Job | มีแต่ Back to job details (AP010 ข้ามอยู่) |
| ตัวเลือกช่องทาง | X, Company Website, Other | X (Twitter), เว็บไซต์ของบริษัท, อื่น ๆ |
| Read Privacy Notice | ลิงก์สีน้ำเงิน | ข้อความธรรมดา กดไม่ได้ |

มีบนเว็บ dev แต่ไม่มีใน Figma: หน้า Review Application, ช่องกรอกเพิ่มเมื่อเลือก อื่น ๆ, ข้อความแจ้งเตือนใต้ช่อง


## หน้า Login ของ CMS (/admin/login) — branch `feature/admin-login-tests`
- 56 เคส (`data/testcases_login.csv`): automate 52, manual 4 สร้างไฟล์ด้วย `python tools/csv_to_robot_login.py`
- ข้ามส่วน "ลืมรหัสผ่าน" ตามที่สั่ง (dev ยังไม่ทำ) ไม่มีเคสของส่วนนี้
- บัญชีทดสอบอยู่ใน `config/secrets.local.env` (ไม่ขึ้น GitHub) ถ้าไม่มีไฟล์นี้ เคสที่ติด tag `needs-account` จะ SKIP
- ผลรันก่อนหน้า: ผ่าน 51, พัง 1, ข้าม 4 (manual)
- LG022 เคยพัง (อีเมลไม่มีในระบบขึ้นข้อความต่างจากรหัสผ่านผิด ทำให้เดาได้ว่าอีเมลไหนมีบัญชี) dev แก้แล้ว รันซ้ำเคสเดียวผ่าน ยังไม่ได้รันทั้งชุดซ้ำ

- LG036: ทีมยืนยันแล้วว่าหลัง login ไป Dashboard เสมอ แม้ลิงก์มี ?next= เคสนี้จึงตรวจว่าไป Dashboard (ผ่าน)


## หน้า Dashboard ของ CMS (/admin/dashboard) - branch `feature/admin-dashboard-tests`
- 77 เคส (`data/testcases_dashboard.csv`): automate 73, manual 4 สร้างไฟล์ด้วย `python tools/csv_to_robot_dashboard.py`
- เทสไม่ผูกกับข้อมูลผู้สมัคร: อ่านตัวเลข/แถวจากหน้าเอง แล้วเทียบกัน (ผลรวมการ์ด = ทั้งหมด, การ์ด = ผลกรอง, ตาราง = ไฟล์ Export)
- ผลรัน: ผ่าน 70, พัง 3, ข้าม 4 (manual)

เคสที่พัง (เป็นบั๊กของเว็บ ส่ง dev)
| เคส | ที่เห็น | ควรเป็น |
|---|---|---|
| DB021, DB063 | เวลาสมัครในตารางเกินจริง 7 ชั่วโมง เช่น ตาราง "2 พ.ย. 2569 16:39 น." แต่ไฟล์ Export ขึ้น 02/11/2026 09:39 (ตอนนั้นเวลาจริงยังไม่ถึง 10:30) น่าจะแปลงเขตเวลาซ้ำ | ตารางและไฟล์ Export แสดงเวลาเดียวกัน ตรงกับเวลาไทยจริง |
| DB042 | กรองวันที่เริ่มต้นหลังวันที่สิ้นสุด (เช่น from=2099-01-01 to=2000-01-01) ไม่พบผู้สมัคร แต่ข้อความใต้ตารางขึ้น "หน้า 1 จาก 2 · ทั้งหมด 0 รายการ" | ขึ้น "แสดง 0 รายการ" หรือ "หน้า 1 จาก 1" และควรเตือนว่าช่วงวันที่ไม่ถูกต้อง |

ข้อสังเกตที่ไม่ใช่บั๊กชัดเจน (ให้ทีมยืนยัน, เคสติด tag `assumption`)
- เปิด ?page=9999 ขึ้นรายการว่างพร้อมข้อความ "หน้า 999 จาก 2" ควรพากลับหน้าสุดท้ายหรือไม่ (DB057 ตรวจแค่ไม่ error)
- ตัวเลขการ์ดสรุปเป็นยอดทั้งระบบ ไม่เปลี่ยนตามตัวกรองของตาราง (DB015)
- ค้นหาด้วยช่องว่างล้วน ระบบมองข้าม (DB035)
- เคสหน้าถัดไป (DB052-056) ข้ามเองถ้ามีผู้สมัครไม่เกิน 20 คน
- ปุ่ม Export Report ตอนไม่กรอง ดาวน์โหลดผู้สมัครทั้งหมด (ยังไม่ได้ลองตอนกรองอยู่)
