# Day 02 — User & Permission Auditor
> Simulate a security audit on a Linux system

## What I Built
Script that audits all login-capable users on a Linux system — their groups, sudo access, home directory permissions, SSH key presence and fingerprints. Flags anomalies, assigns risk levels (HIGH / MEDIUM / OK), and outputs a timestamped CSV compliance report. Supports a `--fix` mode that auto-remediates safe misconfigurations.

## How to Run
```bash
chmod +x audit.sh

# Audit only — read-only, no changes made
./audit.sh

# Audit + auto-remediate (fixes home dir and SSH perms)
sudo ./audit.sh --fix
```

## Tasks
- [x] Parse /etc/passwd and /etc/group
- [x] Check sudo access per user
- [x] Verify home dir permissions (should be 700)
- [x] Check for authorized_keys files
- [x] Output a CSV audit report

## What I Learned
- `/etc/passwd` stores one account per line in 7 colon-separated fields — `while IFS=: read -r` is the idiomatic way to parse it in bash without external tools
- `awk -F: '$4 ~ "(^|,)username(,|$)"'` extracts group memberships from `/etc/group` without false-matching partial usernames
- `stat -c "%a"` returns octal permission strings (`700`, `755`, `777`) — cleaner than parsing `ls -l` output
- Home dirs should be `700` (owner only); `750` leaks to group members, `755` to everyone on the system, `777` allows anyone to plant files like a malicious `.bashrc`
- SSH security requires two separate checks: `.ssh/` must be `700` and `authorized_keys` must be `600` — OpenSSH silently refuses keys if either is too permissive
- `ssh-keygen -lf /dev/stdin` can fingerprint a public key read from stdin, useful for auditing without touching the filesystem
- The detect → remediate → verify loop (run audit, fix issue, re-run audit) is the same pattern used by tools like Lynis, OpenSCAP, and AWS Security Hub at scale

## Tools Used
`bash` · `awk` · `grep` · `stat` · `ssh-keygen` · `chmod` · `wc`

## Resume Bullet
> Built a Bash security audit tool that parses `/etc/passwd`, `/etc/group`, and sudoers to detect permission misconfigurations; flagged world-writable home directories, NOPASSWD sudo entries, and insecure SSH key permissions; generated structured CSV compliance reports with risk classification (HIGH / MEDIUM / OK) and implemented a `--fix` mode for automated remediation