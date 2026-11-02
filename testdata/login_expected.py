"""Expected values for the CMS login tests (text seen on the dev site)."""

LOGIN_TITLE = "เข้าสู่ระบบ | EventPass Careers CMS"
LOGIN_HEADING_TEXT = "ระบบจัดการหลังบ้าน"
LOGIN_SUBTITLE_TEXT = "เข้าสู่ระบบสำหรับ HR และ Admin"
LOGIN_EMAIL_LABEL_TEXT = "อีเมล (E-Mail)"
LOGIN_PASSWORD_LABEL_TEXT = "รหัสผ่าน (Password)"
LOGIN_EMAIL_PLACEHOLDER = "กรอกอีเมล"
LOGIN_PASSWORD_PLACEHOLDER = "กรอกรหัสผ่าน"
LOGIN_REMEMBER_TEXT = "จดจำฉันไว้ในระบบ"
LOGIN_SUBMIT_TEXT = "เข้าสู่ระบบ"
LOGIN_SUBMIT_LOADING_TEXT = "กำลังเข้าสู่ระบบ"
LOGIN_BACK_HOME_TEXT = "กลับสู่หน้าหลัก"

# Server answers
LOGIN_ERR_WRONG_PASSWORD = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
LOGIN_ERR_NO_ACCOUNT = "ไม่พบบัญชีผู้ใช้นี้ในระบบ"
LOGIN_UNKNOWN_EMAIL = "nobody.not.exist@example.com"

# Where things go
LOGIN_DASHBOARD_PATH = "/admin/dashboard"
LOGIN_DASHBOARD_TITLE = "Dashboard | EventPass Careers CMS"
LOGIN_HOME_PATH = "/jobs"
LOGIN_FAKE_APPLICATION_PATH = "/admin/applications/000000000000000000000000"

# Session cookies set by the server after a good login
LOGIN_SESSION_COOKIES = ["evp_access_token", "evp_refresh_token"]
LOGIN_DAYS_REMEMBER_OFF = 1    # about 1 day when "remember me" is NOT ticked
LOGIN_DAYS_REMEMBER_ON = 30    # about 30 days when it is ticked
