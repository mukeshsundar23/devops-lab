# Day 11 — Log Parser & Alerter

> Turn noisy logs into actionable alerts

## What I Built

_Parse Nginx/Apache access logs. Count 4xx/5xx errors, find top IPs, flag repeated failures, and send a summary to Slack via webhook._

## How to Run

```bash
# Build/Run instructions here
```

## Tasks

- [ ] Parse access.log for status codes\n- [ ] Count and rank error types\n- [ ] Find top 10 requesting IPs\n- [ ] Flag IPs with >100 requests/min (potential DDoS)\n- [ ] Send summary to Slack webhook with curl

## What I Learned

- [Key learning 1]
- [Key learning 2]

## Tools Used

`bash` · `awk` · `sort` · `uniq` · `curl`

## Resume Bullet

> _Built log analysis & alerting pipeline in Bash; integrated Slack webhook notifications for 5xx error spikes_
