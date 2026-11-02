"""Locators of the CMS (admin) login page: /admin/login.

All of these were checked on the dev site. The page has ids on the form fields but no
data-testid on the rest, so the other items use stable text-free structure where possible.
"""

LOGIN_LOGO = "xpath://img[@alt='EventPass Group']"
LOGIN_HEADING = "id:login-heading"
LOGIN_SUBTITLE = "xpath://h1[@id='login-heading']/following::p[1]"
LOGIN_FORM = "xpath://form[.//input[@id='login-email']]"

LOGIN_EMAIL = "id:login-email"
LOGIN_PASSWORD = "id:login-password"
LOGIN_REMEMBER = "id:login-remember"
LOGIN_EMAIL_LABEL = "xpath://label[@for='login-email']"
LOGIN_PASSWORD_LABEL = "xpath://label[@for='login-password']"
LOGIN_REMEMBER_LABEL = "xpath://label[@for='login-remember' or .//input[@id='login-remember']]"

LOGIN_SUBMIT = "css:form button[type='submit']"
LOGIN_BACK_HOME = "xpath://a[@href='/']"

# Red box that shows "wrong password" and similar server answers.
LOGIN_ERROR = "css:div[class*='border-danger']"

# After login (CMS shell)
LOGIN_LOGOUT_BUTTON = "xpath://button[normalize-space()='ออกจากระบบ']"
LOGIN_MENU_DASHBOARD = "xpath://a[@href='/admin/dashboard' and contains(normalize-space(), 'Dashboard')]"
LOGIN_MENU_JOBS = "xpath://a[@href='/admin/jobs']"
