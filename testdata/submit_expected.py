"""Expected text and data for the REAL application tests (tests/submit).

01_submit.robot sends one real application when JOBS_ALLOW_SUBMIT=yes (see config/env.py).
02_after_submit.robot only LOOKS at the newest application of this test person in the CMS.
Items marked "assumption" are behaviour seen on dev (or my own expectation) for the team to confirm.
"""

# The test person. The name is unique so the newest row with it is always the last test application.
SUBMIT_APPLICANT = {
    "first_name": "ทดสอบ",
    "last_name": "AUTO",
    "email": "superpeet9@gmail.com",
    "phone": "0812345678",
    "salary": "30000",
}
SUBMIT_FULL_NAME = "ทดสอบ AUTO"
SUBMIT_PHONE_STORED = "+66812345678"          # how the CMS shows the phone typed as 0812345678
SUBMIT_SALARY_STORED = "฿30,000 / เดือน"
SUBMIT_SOURCE = "Facebook"
SUBMIT_FILE_NAME = "cv.pdf"
SUBMIT_FILE_EXT = "PDF"

# ---- success dialog after "Confirm & Submit Application" ----
SUCCESS_TITLE = "Application Submitted Successfully"
SUCCESS_THANKS = "Thank you for applying for the {job} position at EVENTPASS GROUP! We have successfully received your application."
SUCCESS_NEXT = ("Our recruitment team is currently reviewing your profile and will contact you via email or phone "
                "within 7 business days if you are shortlisted.")
SUCCESS_EMAIL = "A confirmation email has been sent to {email}"
SUCCESS_CONTACT = "Have questions? Feel free to contact us at tel: 095-942-2201"
SUCCESS_PHONE_HREF = "tel:+66959422201"
SUCCESS_BACK_TEXT = "Back to Career"
SUCCESS_VIEW_TEXT = "View My Application"

# ---- what the CMS shows for the new application ----
NEW_HR_STATUS_VALUE = "hr_review"
NEW_HR_STATUS_TEXT = "รอ HR Review"
# AI result: the three final labels, and "กำลังวิเคราะห์" while the AI is still reading the CV (seen on dev)
AI_IN_PROGRESS = "กำลังวิเคราะห์"
AUTO_REPLY_TYPE = "ตอบรับใบสมัครอัตโนมัติ"
AUTO_REPLY_SUBJECT = "สมัครร่วมงานกับ EVENTPASS GROUP สำเร็จ!"
AUTO_REPLY_SENDER = "ระบบอัตโนมัติ"
AUTO_REPLY_MINUTES = 10          # assumption: the auto reply is logged within 10 minutes of the application
