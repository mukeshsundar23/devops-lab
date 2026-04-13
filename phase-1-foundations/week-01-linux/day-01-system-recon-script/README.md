# Day 01 — System Recon Script

> Build a sysadmin's first-responder toolkit

## What I Built

A Bash script that collects system information including CPU, memory, disk usage, top processes, listening ports, logged-in users, and uptime.  
The script generates a structured, timestamped report and writes it to `/var/log/sysreport.txt`.

## How to Run

```bash
# Make script executable
chmod +x system-recon.sh

# Run the script (requires sudo to write to /var/log)
sudo ./system-recon.sh

# View latest report
sudo tail -n 50 /var/log/sysreport.txt
```

## Tasks

- [x] Collect CPU/RAM/Disk stats using `/proc` and `df`/`free`
- [x] List top 10 CPU-consuming processes
- [x] Show listening ports with `ss` or `netstat`
- [x] Write timestamped report to `/var/log/sysreport.txt`
- [x] Schedule it via cron every 6 hours

## What I Learned

- How to read system metrics from `/proc` (CPU, memory)
- Using `df` and `free` to monitor disk and RAM usage
- Process inspection and sorting using `ps`
- Network inspection using `ss`
- Parsing and formatting CLI output using `awk` and `grep`
- Handling Linux permissions when writing to `/var/log`
- Automating scripts using `cron`
- Importance of filtering signal vs noise in system monitoring

## Tools Used

`bash` · `cron` · `ss` · `awk` · `sed` · `df` · `free` · `/proc`

## Resume Bullet

Built a Bash-based system diagnostics and monitoring tool that collects CPU, memory, disk, process, and network metrics from Linux system interfaces; automated reporting via cron for proactive monitoring.