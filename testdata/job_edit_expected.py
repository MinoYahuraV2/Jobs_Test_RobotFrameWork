"""Expected text for the CMS edit job page: /admin/jobs/<id>.

The page is the same form as /admin/jobs/new (see testdata/job_new_expected.py) filled with the saved job.
The tests never save. Items marked "assumption" are behaviour seen on dev for the team to confirm.
"""

JE_NOT_FOUND_TITLE = "ไม่พบตำแหน่งงาน | EventPass Careers CMS"
JE_SCRIPT_ID = "%3Cscript%3Ealert(1)%3C%2Fscript%3E"
JE_FAKE_ID = "000000000000000000000000"
JE_BAD_ID = "abc"
