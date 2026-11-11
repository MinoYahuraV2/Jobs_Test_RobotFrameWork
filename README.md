# Jobs_Test_RobotFrameWork

ชุดทดสอบอัตโนมัติของเว็บ Career (Eventpass Group) ด้วย Robot Framework + SeleniumLibrary
ครอบคลุมทั้งหน้า **Public** (Jobs, Jobs Detail, Apply) และหน้า **CMS** (Login, Dashboard, โปรไฟล์ผู้สมัคร, ร่างอีเมล, จัดการตำแหน่งงาน)

ค่าเริ่มต้นชี้ไปที่เว็บ dev `https://career-web-dev.eventpass.biz` เปลี่ยนไปเว็บอื่น (เช่น UAT) ได้ด้วย `JOBS_BASE_URL` ดูหัวข้อ [วิธีรัน](#วิธีรัน)

## สิ่งที่ต้องมี

- Python 3.10 ขึ้นไป
- Chrome หรือ Edge (Selenium 4 โหลด driver ให้เอง ไม่ต้องลง ChromeDriver)

```powershell
pip install -r requirements.txt
```

### บัญชี CMS (ความลับ)

เทสฝั่ง CMS ต้อง login คัดลอก `config\secrets.local.env.example` เป็น `config\secrets.local.env` แล้วใส่อีเมลและรหัสผ่าน
ไฟล์นี้อยู่ใน `.gitignore` ไม่ขึ้น GitHub ห้ามเขียนรหัสผ่านลงไฟล์อื่น ถ้าไม่มีไฟล์ เคสที่ต้องใช้บัญชีจะ SKIP
อีกทางคือตั้ง `JOBS_ADMIN_EMAIL` และ `JOBS_ADMIN_PASSWORD` เป็นตัวแปรระบบ

## ชุดเทสทั้งหมด

| หน้า | โฟลเดอร์เทส | ไฟล์ Test Case (CSV) | ตัวสร้างเทส |
|---|---|---|---|
| Jobs (รายการงาน) | `tests\*.robot` | `data\testcases.csv` | `tools\csv_to_robot.py` |
| Jobs Detail | `tests\detail\` | `data\testcases_detail.csv` | `tools\csv_to_robot_detail.py` |
| Apply (ฟอร์มสมัครงาน + หน้าสรุป) | `tests\apply\` | `data\testcases_apply.csv` | `tools\csv_to_robot_apply.py` |
| หลังกดยืนยันสมัคร (หน้าต่างสำเร็จ + ใบสมัครใน CMS) | `tests\submit\` | `data\testcases_submit.csv` | `tools\csv_to_robot_submit.py` |
| CMS Login | `tests\login\` | `data\testcases_login.csv` | `tools\csv_to_robot_login.py` |
| CMS Dashboard | `tests\dashboard\` | `data\testcases_dashboard.csv` | `tools\csv_to_robot_dashboard.py` |
| CMS โปรไฟล์ผู้สมัคร | `tests\profile\` | `data\testcases_profile.csv` | `tools\csv_to_robot_profile.py` |
| CMS ร่างอีเมลถึง Head | `tests\email_head\` | `data\testcases_email_head.csv` | `tools\csv_to_robot_email_head.py` |
| CMS ร่างอีเมลถึงผู้สมัคร | `tests\email_candidate\` | `data\testcases_email_candidate.csv` | `tools\csv_to_robot_email_candidate.py` |
| CMS จัดการตำแหน่งงาน | `tests\jobs_admin\` | `data\testcases_jobs_admin.csv` | `tools\csv_to_robot_jobs_admin.py` |
| CMS เพิ่มตำแหน่งใหม่ | `tests\job_new\` | `data\testcases_job_new.csv` | `tools\csv_to_robot_job_new.py` |
| CMS แก้ไขตำแหน่ง | `tests\job_edit\` | `data\testcases_job_edit.csv` | `tools\csv_to_robot_job_edit.py` |

ดูจำนวนเคสทั้งหมดได้จาก `robot --dryrun tests` ผลรันจริงดูที่ `report.html`

## โครงสร้างโฟลเดอร์

```
config\            ค่าตั้ง (env.py) และไฟล์บัญชี CMS (secrets.local.env, ไม่ขึ้น GitHub)
data\              ไฟล์ Test Case ต้นทาง (CSV) เป็นแหล่งจริงของรหัสเคส คำอธิบาย ผลที่คาดหวัง และประเภท
tests\             ไฟล์ .robot สร้างจาก CSV ห้ามแก้ด้วยมือ
resources\         keyword แยกตามหน้า (resources\pages\*.resource)
locators\          locator ของแต่ละหน้า
testdata\          ข้อความและค่าที่คาดหวัง (*_expected.py), jobs.json
libraries\         ตัวช่วย Python อ่านข้อมูลจากหน้าเว็บ
tools\             ตัวสร้างเทสจาก CSV
results\           ผลรัน (report.html, log.html) ไม่ขึ้น GitHub
NOTES.md           บั๊กที่เจอ คำถามถึงทีม และสิ่งที่ยังไม่ได้ทดสอบ
```

## วิธีรัน

เปิด PowerShell ที่โฟลเดอร์โปรเจกต์

```powershell
$env:PYTHONIOENCODING = "utf-8"              # กันภาษาไทยเพี้ยน
robot tests                                  # ทุกเคส
robot tests\apply                            # ทั้งโฟลเดอร์
robot tests\detail\03_header.robot           # ไฟล์เดียว
robot --include PF035 tests\profile          # เคสเดียว (ใส่รหัสเคส)
robot --include automate tests               # เฉพาะเคส automate
robot --dryrun tests                         # ตรวจโค้ด ไม่เปิดเบราว์เซอร์
robot --outputdir results\profile tests\profile   # แยกโฟลเดอร์ผลรัน
```

ผลรันอยู่ที่ `results\` เปิด `report.html` (สรุป) และ `log.html` (รายละเอียด)

### รันบนเว็บอื่น (เช่น UAT)

```powershell
$env:JOBS_BASE_URL = "https://career-web-uat.eventpass.biz"
robot tests\profile
Remove-Item Env:JOBS_BASE_URL
```

ข้อมูลบนแต่ละเว็บต่างกัน (รายการงาน ผู้สมัคร) เคสที่ต้องใช้ข้อมูลที่ไม่มีจะ SKIP พร้อมบอกเหตุผล

### ตัวแปรระบบ

| ตัวแปร | ค่าเริ่มต้น | ความหมาย |
|---|---|---|
| `JOBS_BASE_URL` | `https://career-web-dev.eventpass.biz` | URL ของเว็บ |
| `JOBS_PATH` | `/jobs` | path ของหน้า Jobs |
| `JOBS_BROWSER` | `chrome` | `chrome` หรือ `edge` |
| `JOBS_HEADLESS` | `false` | `true` = ไม่เปิดหน้าต่างเบราว์เซอร์ |
| `JOBS_TIMEOUT` | `10s` | เวลารอ element |
| `JOBS_RESULT_SETTLE` | `1s` | เวลารอหลังค้นหา กรอง เรียงลำดับ |
| `JOBS_DETAIL_JOB_ONLY` | `QA AI` | ตำแหน่งหลักที่เทสหน้า Jobs Detail ใช้ |
| `JOBS_ADMIN_LOGIN_PATH` | `/admin/login` | path หน้า Login CMS |
| `JOBS_ADMIN_EMAIL`, `JOBS_ADMIN_PASSWORD` | อ่านจาก `config\secrets.local.env` | บัญชี CMS |
| `JOBS_ALLOW_SUBMIT` | `no` | `yes` = อนุญาตให้ส่งใบสมัครจริง |
| `JOBS_SUBMIT_JOB` | `QA AI` | ตำแหน่งที่ใช้ตอนส่งใบสมัครจริง |

## กติกาความปลอดภัยของเทส

เทสรันกับเว็บที่ใช้ร่วมกับทีม จึงตั้งกติกาไว้ดังนี้

- **ไม่บันทึกข้อมูลใน CMS** เทสหน้าเพิ่ม/แก้ไขตำแหน่งไม่กดบันทึก และไม่กดสวิตช์ Manual Toggle เพราะกระทบหน้า Public ทันที เคสที่ต้องทำจริงเป็น manual
- **ไม่ส่งอีเมลจริง** เคสที่กดปุ่มส่งใช้ช่อง TO ที่เป็นอีเมลไม่ได้ ระบบต้องปฏิเสธ และเทสตรวจว่าสถานะผู้สมัครไม่เปลี่ยน
- **ไม่เปลี่ยนสถานะผู้สมัคร** เคสที่ต้องเปลี่ยนสถานะเป็น manual
- **การส่งใบสมัครจริงต้องเปิดสวิตช์เอง** `tests\submit\01_submit.robot` ข้ามอัตโนมัติถ้า `JOBS_ALLOW_SUBMIT` ไม่ใช่ `yes` เพราะใบสมัครลบจาก CMS ไม่ได้และระบบส่งอีเมลตอบรับจริง ใช้ผู้สมัครทดสอบ "ทดสอบ AUTO" (ตั้งใน `testdata\submit_expected.py`)
- **ไม่ใส่รหัสผ่านในโค้ดหรือผลรัน** ใช้ `config\secrets.local.env` เท่านั้น

```powershell
robot tests\submit\02_after_submit.robot     # อ่านอย่างเดียว ดูใบสมัครล่าสุดของ "ทดสอบ AUTO" ใน CMS

$env:JOBS_ALLOW_SUBMIT = "yes"               # สร้างใบสมัครจริง 1 ใบบนเว็บที่ชี้อยู่
robot tests\submit\01_submit.robot
Remove-Item Env:JOBS_ALLOW_SUBMIT
```

## สร้างเทสใหม่จาก CSV

เมื่อแก้ไฟล์ CSV ใน `data\` (เพิ่ม ลบ แก้เคส) ให้รันตัวสร้างของหน้านั้น เช่น

```powershell
python tools\csv_to_robot_profile.py
```

- ขั้นตอนของแต่ละเคสอยู่ในตาราง `STEPS` ในไฟล์ตัวสร้าง เคสใหม่ต้องเพิ่มที่นั่น ไม่เช่นนั้นสคริปต์แจ้งข้อผิดพลาด
- รันซ้ำจะเขียนทับไฟล์ใน `tests\` ของหน้านั้น
- หลังสร้างให้รัน `robot --dryrun tests` ก่อน เพื่อตรวจว่า keyword ครบ

## Tag ที่ใช้

| tag | ความหมาย |
|---|---|
| `TC001`, `JD001`, `AP001`, `PF001` ... | รหัสเคส (Jobs, Jobs Detail, Apply, Profile ...) |
| `automate` | เคสที่รันอัตโนมัติ |
| `manual` | ทดสอบด้วยมือ ข้ามเสมอ |
| `assumption` | ใช้ค่าที่เห็นบนเว็บจริงหรือที่เดาไว้ ต้องให้ทีมยืนยัน |
| `needs-job-count` | ต้องมีจำนวนงานตามที่เคสกำหนด ถ้าไม่ตรงจะ SKIP |
| `needs-data` | ต้องใช้ข้อมูลงานจริงใน `testdata\jobs.json` |

## กติกาแสดง Search / Filter ตามจำนวนงาน (หน้า Jobs)

| จำนวนงานในหน้า | Search | Filter | Sort | การ์ดงาน |
|---|---|---|---|---|
| 1-5 | ซ่อน | ซ่อน | ซ่อน | แสดง |
| 6 ขึ้นไป | แสดง | แสดง | แสดง | แสดง |

- เกณฑ์ตั้งที่ `MIN_JOBS_FOR_SEARCH_FILTER` ใน `testdata\expected.py` (ตอนนี้ 6)
- เคสกลุ่ม Search, Sort, Filter, Keyboard จะ SKIP เองเมื่อมีงานน้อยกว่าเกณฑ์
- Filter ในกลุ่มเดียวกันเป็น "หรือ" ข้ามกลุ่มเป็น "และ" (ตั้งใน `libraries\JobData.py`)
- ตัวเลือก Filter มาจากฐานข้อมูล เคสที่ระบุตัวเลือกที่เว็บไม่มีจะ SKIP

## บั๊กและคำถามที่ค้าง

ดู `NOTES.md` เก็บบั๊กที่เจอ คำตอบจากทีม ความต่างระหว่าง Figma กับเว็บ และสิ่งที่ยังไม่ได้ทดสอบของแต่ละหน้า

## แก้ปัญหา

- **ทุกเคสถูก SKIP**: เคสที่ใช้บัญชี CMS จะข้ามถ้าไม่มี `config\secrets.local.env` ดูเหตุผลใน `log.html`
- **`unknown encoding: utf-8:backslashreplace`**: ตั้ง `$env:PYTHONIOENCODING = "utf-8"` ก่อนรัน
- **เว็บ dev ขึ้น "This page couldn't load" หรือ 502 เป็นช่วง ๆ**: เว็บ dev ล้มเวลาโดนเรียกถี่ ผลรันจะไม่นิ่งและพังคนละเคสในแต่ละรอบ ให้รอแล้วรันซ้ำเฉพาะเคสที่พัง
- **บัญชี CMS ถูกปฏิเสธ**: อย่ารันชุด Login ซ้ำหลายรอบ เพราะมีเคสใส่รหัสผ่านผิดหลายครั้ง เช็กรหัสผ่านใน `config\secrets.local.env` ก่อน
