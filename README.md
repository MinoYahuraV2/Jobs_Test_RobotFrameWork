# Jobs_Test_RobotFrameWork

ชุดทดสอบอัตโนมัติของหน้า **Career - Jobs** (Eventpass Group) ด้วย Robot Framework + SeleniumLibrary
อ้างอิง Test Case จาก `data/testcases.csv` (71 เคส: automate 69, manual 2 คือ TC002 และ TC070)

## สถานะปัจจุบัน

เว็บจริงยังไม่ขึ้นระบบ ดังนั้น URL, locator และข้อมูลงานจริงยังเป็น `TODO`
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
resources\                keyword แยกตามหน้า (header, filters, job_cards, footer ...)
locators\jobs_page.py     locator ทุกตัว (ตอนนี้เป็น TODO)
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
| 02_header | TC003-009 | 7 |
| 03_hero_search | TC010-017 | 8 |
| 04_sort | TC018-020 | 3 |
| 05_filter | TC021-043 | 23 |
| 06_job_card | TC044-057 | 14 |
| 07_footer | TC058-069 | 12 |
| 08_keyboard | TC071 | 1 |
| 99_manual (ข้ามเสมอ) | TC002, TC070 | 2 |

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

ลำดับที่แนะนำ: เติม locator ของ smoke และ header แล้วรัน `tests\01_smoke.robot` ก่อน จากนั้นเติมทีละกลุ่ม

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
| `manual` | ทดสอบด้วยมือ ข้ามเสมอ |

## ข้อสมมติที่ต้องยืนยัน

- Filter ในกลุ่มเดียวกันเป็น "หรือ" และข้ามกลุ่มเป็น "และ" (ตั้งใน `libraries\JobData.py` กระทบ TC026, 033, 038, 039)
- ช่องค้นหา: ผลต้อง "รวม" งานที่ชื่อตรงกับคำค้น (เว็บอาจค้นกว้างกว่าชื่องาน)
- Description อ่านจากข้อมูล ไม่ฝังไว้ใน test (เปลี่ยนข้อความใน DB แล้วไม่ต้องแก้ test)
- ปีลิขสิทธิ์ใน Footer ใช้ 2026 ตาม Figma
- ใน Figma ปุ่ม Sort สะกด "Lastest" ยังไม่ยืนยันว่าเป็นคำสะกดจริงหรือพิมพ์ผิด

## แก้ปัญหา

- ทุกเคสถูก SKIP: ยังไม่ได้ตั้ง `JOBS_BASE_URL` หรือ locator/ข้อมูลยังเป็น `TODO` ดูเหตุผลใน `log.html`
- `robot` ล้มด้วยข้อความ `unknown encoding: utf-8:backslashreplace`: ตั้ง `$env:PYTHONIOENCODING = "utf-8"` ก่อนรัน
