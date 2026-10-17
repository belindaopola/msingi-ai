"""Create (or update) one account that can switch between all Msingi workspaces.

Usage:
    MSINGI_ALL_ACCESS_CODE=... python3 scripts/add_all_access_user.py "Full Name" email [base_url]

The server must be started with the same MSINGI_ALL_ACCESS_CODE in its
environment; without it the server refuses to grant all-workspace access.
The password is asked for interactively (or read from MSINGI_USER_PASSWORD).
Safe to re-run for an existing account if you give its current password.
"""

import getpass
import os
import sys

import seed_accounts as accounts


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    name, email = sys.argv[1], sys.argv[2].strip().lower()
    if len(sys.argv) > 3:
        accounts.BASE = sys.argv[3].rstrip("/")
    code = os.environ.get("MSINGI_ALL_ACCESS_CODE", "")
    if not code:
        sys.exit("Set MSINGI_ALL_ACCESS_CODE to the code the server was started with.")
    password = os.environ.get("MSINGI_USER_PASSWORD") or getpass.getpass(f"Password for {email} (8+ characters): ")
    if len(password) < 8:
        sys.exit("Use a password with at least 8 characters.")
    accounts.PASSWORD = password

    local, _, domain = email.partition("@")
    accounts.DOMAIN = domain
    # Start as a teacher profile; the grant below switches it to ALL.
    _, result = accounts.ensure_account(name, "TEACHER", "PP2", local)
    if result.startswith(("SKIPPED", "FAILED")):
        sys.exit(f"{email}: {result}")

    token = accounts.login(email)
    status, env = accounts.post("/function/grant_all_workspaces", {"access_code": code}, token)
    if status != 200 or not env.get("ok"):
        sys.exit(f"{email}: grant refused ({(env.get('error') or {}).get('message', status)})")
    print(f"{email} ({result}) can now switch between the Teacher, Learner and Parent workspaces.")


if __name__ == "__main__":
    main()
