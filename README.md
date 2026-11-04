# Jobs_Test_RobotFrameWork

ชุดทดสอบอัตโนมัติของหน้า **Career - Jobs** (Eventpass Group) ด้วย Robot Framework + SeleniumLibrary
อ้างอิง Test Case จาก `data/testcases.csv` (84 เคสในไฟล์ CSV: สร้างเป็น test จริง 73 เคส + manual 3 คือ TC002, TC070 และ TC083; ตัดส่วน Header TC003-009 และ TC050 (Ongoing until filled) ออก ไม่ทดสอบ)

## สถานะปัจจุบัน

URL ตั้งไว้แล้วที่ `https://career-web-dev.eventpass.biz/jobs` (เว็บ dev) locator ส่วนใหญ่เติมจากเว็บ dev แล้ว (เว็บไม่มี `data-testid` จึงใช้ id, aria-label, ข้อความ และโครงสร้างหน้า) ที่ยังเป็น `TODO` คือของที่ไม่มีบนเว็บ dev (ลิงก์ Footer บางอัน, รูปแบบทำงาน) และข้อมูลงานจริงจากฐานข้อมูล
เคสที่เจอ `TODO` จะถูก **SKIP** (ไม่ใช่ Fail) พร้อมบอกเหตุผล

## สิ่งที่ต้องมี

- Python 3.10 ขึ้นไป
- Chrome หรือ Edge (Selenium 4 โหลด driver ให้เอง ไม่ต้องลง ChromeDriver)

```powershell
pip install -r requirements.txt
```

## โครงสร้าง

```
data\testcases.csv        ไฟล์ Test Case ต้นทาง
tests\                    ไฟล์ .robot (สร้างจาก CSV อย่าแก้ด้วยมือ)
resources\                keyword แยกตามหน้า (filters, job_cards ...)
locators\jobs_page.py     locator ทุกตัว (เติมจากเว็บ dev แล้ว ยกเว้นที่เป็น TODO)
testdata\expected.py      ข้อความที่คาดหวัง (จาก Figma) และลิงก์ปลายทาง
testdata\jobs.json        ข้อมูลงานที่คาดหวัง (ตอนนี้เป็นตัวอย่างจาก Figma)
config\env.py             URL, browser, timeout
libraries\                ตัวช่วย Python (Helpers.py, JobData.py)
tools\csv_to_robot.py     สร้าง tests\*.robot จาก CSV
tools\list_todo.py        แสดงรายการที่ยังเป็น TODO
```

| ไฟล์ใน `tests\` | เคส | จำนวน |
|---|---|---|
| 01_smoke | TC001 | 1 |
| 03_hero_search | TC010-017 | 8 |
| 04_sort | TC018-020 | 3 |
| 05_filter | TC021-043 | 23 |
| 06_job_card | TC044-057 | 14 |
| 08_keyboard | TC071 | 1 |
| 09_display_rule | TC072-082, TC084 | 12 |
| 99_manual (ข้ามเสมอ) | TC002, TC070, TC083 | 3 |

## วิธีรัน

ตั้ง URL ของเว็บก่อน (เลือกอย่างใดอย่างหนึ่ง):

```powershell
$env:JOBS_BASE_URL = "https://staging.example.com"
# หรือ
robot --variable BASE_URL:https://staging.example.com tests
```

```powershell
robot tests                                  # รันทั้งหมด
robot tests\01_smoke.robot                   # รันไฟล์เดียว
robot --include TC013 tests                  # รันเคสเดียว
robot --include needs-data tests             # เฉพาะเคสที่ต้องใช้ข้อมูลจริง
robot --exclude needs-data tests             # ไม่เอาเคสที่ต้องใช้ข้อมูลจริง
robot --dryrun tests                         # ตรวจว่า keyword ครบ ไม่เปิดเบราว์เซอร์
```

ผลลัพธ์อยู่ที่ `results\` (เปิด `report.html` และ `log.html`)

ตัวแปรระบบที่ใช้ได้:

| ตัวแปร | ค่าเริ่มต้น | ความหมาย |
|---|---|---|
| `JOBS_BASE_URL` | `TODO` | URL ของเว็บ |
| `JOBS_PATH` | `/jobs` | path ของหน้า Jobs |
| `JOBS_BROWSER` | `chrome` | `chrome` หรือ `edge` |
| `JOBS_HEADLESS` | `false` | `true` = ไม่เปิดหน้าต่าง |
| `JOBS_TIMEOUT` | `10s` | เวลารอ element |
| `JOBS_RESULT_SETTLE` | `1s` | เวลารอหลังค้นหา/กรอง/เรียงลำดับ |

## เมื่อ dev ส่งเว็บมา: เติมค่าที่เป็น TODO

ดูรายการที่ยังขาด:

```powershell
python tools\list_todo.py
```

1. **URL**: ตั้ง `JOBS_BASE_URL` และตรวจ `JOBS_PATH`
2. **Locator**: แก้ที่ `locators\jobs_page.py` ไฟล์เดียว (ไม่ต้องแก้ test)
   - ใช้รูปแบบ SeleniumLibrary เช่น `css:[data-testid='search-input']`
   - `JOB_CARD` และตัวใน `CARD` ต้องเป็น xpath (ตัวใน `CARD` เป็น xpath แบบสัมพัทธ์ `xpath=.//...`)
   - แนะนำให้ขอ `data-testid` จาก dev ทุก element
3. **ข้อความและลิงก์**: แก้ที่ `testdata\expected.py` (ปลายทางของเมนู/Footer, ตัวเลือก Sort, ข้อความภาษาไทย, ข้อความตอนไม่พบงาน)
4. **ข้อมูลงานจริง**: ส่งออกจากฐานข้อมูลมาใส่ `testdata\jobs.json` ตามรูปแบบเดิม แล้วเปลี่ยน `"status"` เป็น `"REAL"` เคสที่ติด tag `needs-data` จึงจะทำงาน

ลำดับที่แนะนำ: เติม locator ของ smoke แล้วรัน `tests\01_smoke.robot` ก่อน จากนั้นเติมทีละกลุ่ม

## สร้าง test ใหม่จาก CSV

เมื่อแก้ `data\testcases.csv` (เพิ่ม/ลบ/แก้เคส):

```powershell
python tools\csv_to_robot.py
```

- CSV เป็นแหล่งจริงของรหัสเคส, คำอธิบาย, ผลที่คาดหวัง และประเภท (automate/manual)
- ขั้นตอนของแต่ละเคสอยู่ในตาราง `STEPS` ในไฟล์ `tools\csv_to_robot.py` เคสใหม่ต้องเพิ่มที่นั่น ไม่เช่นนั้นสคริปต์จะแจ้งข้อผิดพลาด
- รันซ้ำจะเขียนทับ `tests\*.robot`

## Tag ที่ใช้

| tag | ความหมาย |
|---|---|
| `TC001` ... | รหัสเคส |
| `smoke`, `header`, `filter` ... | กลุ่มของเคส |
| `needs-data` | ต้องใช้ข้อมูลงานจริงใน `jobs.json` |
| `assumption` | ขึ้นกับกติกา Filter ที่ยังเป็นข้อสมมติ |
| `needs-job-count` | ต้องมีจำนวนงานในระบบตามที่เคสกำหนด (เช่น 1-5, พอดี 5, พอดี 6, 0) ถ้าไม่ตรงจะ SKIP |
| `manual` | ทดสอบด้วยมือ ข้ามเสมอ |

## กติกาแสดง Search / Filter ตามจำนวนงาน

| จำนวนงานในหน้า | Search | Filter + Filter Tags | การ์ดงาน |
|---|---|---|---|
| 1-5 | ซ่อน | ซ่อน | แสดงเรียงลงมา |
| 6 ขึ้นไป | แสดง | แสดง | แสดง |

- ค่าเกณฑ์อยู่ที่ `MIN_JOBS_FOR_SEARCH_FILTER` ใน `testdata\expected.py` (ตอนนี้ 6)
- เคสกลุ่ม Search, Sort, Filter, Keyboard จะ SKIP เองเมื่อหน้ามีงานน้อยกว่าเกณฑ์
- เคสกลุ่ม `09_display_rule` อ่านจำนวนการ์ดจริงบนหน้า แล้ว SKIP ถ้าจำนวนไม่ตรงเงื่อนไขของเคส
- เคสขอบเขต (TC077 พอดี 5, TC078 พอดี 6, TC082 เป็น 0) ต้องให้ทีมเตรียมข้อมูลในระบบให้ตรงจำนวนก่อน

## ข้อสมมติที่ต้องยืนยัน

- เกณฑ์นับจาก **จำนวนงานทั้งหมด** ไม่ใช่ผลที่กรองแล้ว (TC081) และการ์ด 1 ใบ = 1 ตำแหน่ง ไม่มี pagination
- ปุ่ม Clear filters บนเว็บ dev โผล่หลังเลือก Filter แล้วเท่านั้น (TC022 และ TC071 เลือก Filter ก่อนตรวจ)`n- ตัวเลือก Filter มาจากฐานข้อมูล (ตอนนี้ Departments 2, Job types 2, Location 2) เคสที่ระบุตัวเลือกที่ไม่มีบนเว็บ (Contract, Internship, Bangkok HQ, Chiang Mai) จะ SKIP`n- Footer บนเว็บ dev เป็นภาษาไทย และมีลิงก์แค่ ตำแหน่งที่เปิดรับสมัคร, อีเมล, เบอร์โทร, เว็บไซต์หลักบริษัท (Culture, FAQ, Recruitment Process ไม่มี; คุกกี้ เงื่อนไข ความเป็นส่วนตัว เป็นข้อความ ไม่ใช่ลิงก์)`n- Sort ซ่อนเมื่อมีงาน 1-5 ด้วย (ตามภาพ Figma ที่ไม่มี Sort) ตั้งใน `SORT_HIDDEN_WHEN_FEW` (TC084)
- ข้อความ "N positions found." (TC011) แสดงเฉพาะเมื่อมีงาน 6 ขึ้นไป
- 0 ตำแหน่ง: ซ่อน Search และ Filter แล้วแสดงข้อความไม่มีงาน (TC082)
- ตัวเลขใต้หัวข้อ Hero ("2 open positions ...") นับงานทั้งหมด (TC076)
- Filter ในกลุ่มเดียวกันเป็น "หรือ" และข้ามกลุ่มเป็น "และ" (ตั้งใน `libraries\JobData.py` กระทบ TC026, 033, 038, 039)
- ช่องค้นหา: ผลต้อง "รวม" งานที่ชื่อตรงกับคำค้น (เว็บอาจค้นกว้างกว่าชื่องาน)
- Description อ่านจากข้อมูล ไม่ฝังไว้ใน test (เปลี่ยนข้อความใน DB แล้วไม่ต้องแก้ test)
- Sort บนเว็บ dev เป็น `<select>` ตัวเลือกคือ `Sort: Latest`, `Sort: Oldest`, `Sort: Title (A-Z)` (ค่า `latest`, `oldest`, `title_asc`) ตั้งใน `SORT_OPTION_LABELS` ของ `testdata\expected.py`

## แก้ปัญหา

- ทุกเคสถูก SKIP: ยังไม่ได้ตั้ง `JOBS_BASE_URL` หรือ locator/ข้อมูลยังเป็น `TODO` ดูเหตุผลใน `log.html`
- `robot` ล้มด้วยข้อความ `unknown encoding: utf-8:backslashreplace`: ตั้ง `$env:PYTHONIOENCODING = "utf-8"` ก่อนรัน


## เทสหน้า Login ของ CMS

ไฟล์เทสอยู่ที่ `tests\login\` (56 เคส จาก `data\testcases_login.csv`) สร้างด้วย `python tools\csv_to_robot_login.py`
บัญชีทดสอบเป็นความลับ: คัดลอก `config\secrets.local.env.example` เป็น `config\secrets.local.env` แล้วใส่อีเมลและรหัสผ่าน (ไฟล์นี้ไม่ขึ้น GitHub) ถ้าไม่มีไฟล์ เคสที่ต้องใช้บัญชีจะ SKIP

```powershell
robot tests\login
```

## เทสหน้า Dashboard ของ CMS

อยู่ใน `tests\dashboard\` (77 เคส จาก `data\testcases_dashboard.csv`) สร้างด้วย `python tools\csv_to_robot_dashboard.py`
ต้องใช้บัญชีเดียวกับเทส Login (`config\secrets.local.env`) เทสอ่านตัวเลขและแถวจากหน้าเว็บเอง แล้วเทียบกันเองและเทียบกับไฟล์ Export จึงไม่ผูกกับข้อมูลผู้สมัครในฐานข้อมูล
ไฟล์ที่ดาวน์โหลดจากปุ่ม Export Report เก็บที่ `results\downloads\` (ไม่ขึ้น GitHub)

```powershell
$env:PYTHONIOENCODING="utf-8"
robot --outputdir results\dashboard tests\dashboard
```

## เทสหน้าโปรไฟล์ผู้สมัครของ CMS

ไฟล์เทสอยู่ที่ `tests\profile\` (73 เคส จาก `data\testcases_profile.csv`) สร้างด้วย `python tools\csv_to_robot_profile.py`
ใช้บัญชีทดสอบเดียวกับหน้า Login เทสอ่านข้อมูลอย่างเดียว ไม่บันทึกสถานะและไม่ส่งอีเมล (เคสที่ต้องทำจริงเป็น manual)

```powershell
robot tests\profile
```


## เทสหน้าร่างอีเมลส่งให้ Head ของ CMS

ไฟล์เทสอยู่ที่ `tests\email_head\` (50 เคส จาก `data\testcases_email_head.csv`) สร้างด้วย `python tools\csv_to_robot_email_head.py`
เทสไม่ส่งอีเมลจริง: เคสที่กดปุ่มส่งใช้ TO ที่เป็นอีเมลไม่ได้ ระบบต้องปฏิเสธ และเทสตรวจว่าสถานะผู้สมัครไม่เปลี่ยน เคสที่ต้องส่งจริงเป็น manual

```powershell
robot tests\email_head
```


## เทสหน้าร่างอีเมลถึงผู้สมัครของ CMS

ไฟล์เทสอยู่ที่ `tests\email_candidate\` (51 เคส จาก `data\testcases_email_candidate.csv`) สร้างด้วย `python tools\csv_to_robot_email_candidate.py`
กติกาเดียวกับหน้าส่งให้ Head: เทสไม่ส่งอีเมลจริง เคสที่ต้องส่งจริงเป็น manual

```powershell
robot tests\email_candidate
```


## เทสหน้าจัดการตำแหน่งงานของ CMS

ไฟล์เทสอยู่ที่ `tests\jobs_admin\` (55 เคส จาก `data\testcases_jobs_admin.csv`) สร้างด้วย `python tools\csv_to_robot_jobs_admin.py`
เทสไม่กดสวิตช์ Manual Toggle และไม่บันทึกฟอร์ม เพราะกระทบหน้า Public เคสที่ต้องทำจริงเป็น manual

```powershell
robot tests\jobs_admin
```


## เทสฟอร์มเพิ่มตำแหน่งใหม่ของ CMS

ไฟล์เทสอยู่ที่ `tests\job_new\` (52 เคส จาก `data\testcases_job_new.csv`) สร้างด้วย `python tools\csv_to_robot_job_new.py`
เทสไม่บันทึกตำแหน่ง (ตำแหน่งที่บันทึกขึ้นหน้า Public และลบจาก CMS ไม่ได้) เคสที่ต้องบันทึกจริงเป็น manual

```powershell
robot tests\job_new
```


## เทสหน้าแก้ไขตำแหน่งของ CMS

ไฟล์เทสอยู่ที่ `tests\job_edit\` (66 เคส จาก `data\testcases_job_edit.csv`) สร้างด้วย `python tools\csv_to_robot_job_edit.py`
เทสไม่บันทึกตำแหน่ง (การบันทึกเปลี่ยนหน้า Public ทันที) เคสที่ต้องบันทึกจริงเป็น manual

```powershell
robot tests\job_edit
```


## เทสหลังกดยืนยันสมัครงาน (หน้าต่างสำเร็จ + ใบสมัครใน CMS)

ไฟล์เทสอยู่ที่ `tests\submit\` (28 เคส จาก `data\testcases_submit.csv`) สร้างด้วย `python tools\csv_to_robot_submit.py`
- `01_submit.robot` ส่งใบสมัครจริง 1 ใบไปที่ dev (ลบจาก CMS ไม่ได้ และส่งอีเมลยืนยันจริง) จึง **ข้ามอัตโนมัติ** ถ้าไม่เปิดสวิตช์
- `02_after_submit.robot` อ่านอย่างเดียว ดูใบสมัครล่าสุดของ "ทดสอบ AUTO" ใน CMS รันได้ทุกเมื่อ ถ้ายังไม่มีใบสมัครจะข้าม
- ตำแหน่งที่สมัครตั้งด้วย `JOBS_SUBMIT_JOB` (ค่าเริ่มต้น `QA AI`) ผู้สมัครทดสอบอยู่ใน `testdata\submit_expected.py`

```powershell
robot tests\submit\02_after_submit.robot            # อ่านอย่างเดียว

$env:JOBS_ALLOW_SUBMIT = "yes"                      # เปิดสวิตช์ส่งจริง (ใช้ทุกครั้งที่ต้องการสร้างใบสมัครใหม่)
robot tests\submit\01_submit.robot
Remove-Item Env:JOBS_ALLOW_SUBMIT
```