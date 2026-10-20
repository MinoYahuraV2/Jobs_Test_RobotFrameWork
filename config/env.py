"""Run settings. Nothing here is secret.

BASE_URL is "TODO" until dev puts the site online. Fill it in ONE of 3 ways:
  1. environment variable:  $env:JOBS_BASE_URL = "https://staging.example.com"
  2. command line:          robot --variable BASE_URL:https://staging.example.com tests
  3. edit the default below.
While BASE_URL is TODO, every test is SKIPPED (not failed).
"""
import os


def _env(name, default):
    return os.environ.get(name, default)


BASE_URL = _env("JOBS_BASE_URL", "TODO").rstrip("/")
JOBS_PATH = _env("JOBS_PATH", "/jobs")  # TODO: confirm real path with dev
BROWSER = _env("JOBS_BROWSER", "chrome")  # chrome | edge
HEADLESS = _env("JOBS_HEADLESS", "false").lower() == "true"
TIMEOUT = _env("JOBS_TIMEOUT", "10s")
RESULT_SETTLE = _env("JOBS_RESULT_SETTLE", "1s")  # wait after search/filter/sort
