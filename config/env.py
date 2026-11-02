"""Run settings. Nothing here is secret.

BASE_URL defaults to the dev site. Change it in ONE of 3 ways:
  1. environment variable:  $env:JOBS_BASE_URL = "https://staging.example.com"
  2. command line:          robot --variable BASE_URL:https://staging.example.com tests
  3. edit the default below.
While BASE_URL is TODO, every test is SKIPPED (not failed).
"""
import os


def _env(name, default):
    return os.environ.get(name, default)


BASE_URL = _env("JOBS_BASE_URL", "https://career-web-dev.eventpass.biz").rstrip("/")
JOBS_PATH = _env("JOBS_PATH", "/jobs")
BROWSER = _env("JOBS_BROWSER", "chrome")  # chrome | edge
HEADLESS = _env("JOBS_HEADLESS", "false").lower() == "true"
TIMEOUT = _env("JOBS_TIMEOUT", "10s")
RESULT_SETTLE = _env("JOBS_RESULT_SETTLE", "1s")  # wait after search/filter/sort
# Detail page tests check ONLY this job (keeps the run short). Empty string = check every job.
#   $env:JOBS_DETAIL_JOB_ONLY = ""            -> every job
DETAIL_JOB_ONLY = _env("JOBS_DETAIL_JOB_ONLY", "Tester AI")


# ---- CMS (admin) login ----
# The account is a SECRET. Put it in config/secrets.local.env (ignored by git) or in the
# environment variables JOBS_ADMIN_EMAIL / JOBS_ADMIN_PASSWORD. Never write it in this file.
def _load_local_secrets():
    values = {}
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "secrets.local.env")
    if os.path.exists(path):
        with open(path, encoding="utf-8") as handle:
            for line in handle:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    key, _, value = line.partition("=")
                    values[key.strip()] = value.strip()
    return values


_LOCAL = _load_local_secrets()
ADMIN_LOGIN_PATH = _env("JOBS_ADMIN_LOGIN_PATH", "/admin/login")
ADMIN_EMAIL = _env("JOBS_ADMIN_EMAIL", _LOCAL.get("JOBS_ADMIN_EMAIL", ""))
ADMIN_PASSWORD = _env("JOBS_ADMIN_PASSWORD", _LOCAL.get("JOBS_ADMIN_PASSWORD", ""))
