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
