#!/usr/bin/env bash
# ============================================================
#  Linux User & Permission Auditor v2
#  Author : Mukesh
#  Usage  : ./audit.sh [--fix]
#  Purpose: Parse users, groups, sudo, home perms, SSH keys
#           Flag anomalies, optionally auto-remediate, output CSV
# ============================================================

# ── CONFIG ──────────────────────────────────────────────────
PASSWD_FILE=/etc/passwd
GROUP_FILE=/etc/group
SUDOERS_FILE=/etc/sudoers
HOME_BASE=/home

OUTPUT_CSV="audit_report_$(date +%Y%m%d_%H%M%S).csv"
REPORT_DIR="$(pwd)"

# ── ARG PARSING ─────────────────────────────────────────────
FIX_MODE=false
[[ "$1" == "--fix" ]] && FIX_MODE=true

# ── COLOURS ─────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# ── HELPERS ─────────────────────────────────────────────────
log_info()  { echo -e "${CYAN}[INFO]${RESET}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_flag()  { echo -e "${RED}[FLAG]${RESET}  $*"; }
log_fix()   { echo -e "${GREEN}[FIX]${RESET}   $*"; }

# ── STEP 0: Validate files exist ────────────────────────────
for f in "$PASSWD_FILE" "$GROUP_FILE"; do
    [[ -f "$f" ]] || { echo "ERROR: Cannot read $f"; exit 1; }
done

# ── STEP 1: Write CSV header ─────────────────────────────────
echo "username,uid,gid,shell,home_dir,home_exists,home_perms,home_perm_ok,groups,has_sudo,sudo_nopasswd,has_ssh_keys,ssh_dir_perms,ssh_key_perms,ssh_fingerprints,anomaly_flags,risk_level" \
    > "$OUTPUT_CSV"

echo ""
echo -e "${BOLD}══════════════════════════════════════════════════${RESET}"
if $FIX_MODE; then
echo -e "${BOLD}   Linux User & Permission Audit  [FIX MODE]      ${RESET}"
else
echo -e "${BOLD}   Linux User & Permission Security Audit         ${RESET}"
fi
echo -e "${BOLD}══════════════════════════════════════════════════${RESET}"
echo ""

TOTAL=0; FLAGGED=0; HIGH=0

# ── STEP 2: Loop over every user in /etc/passwd ─────────────
while IFS=: read -r username _ uid gid _ home_dir shell; do

    # Skip non-login system accounts (uid 1–999, not root)
    if [[ "$uid" -gt 0 && "$uid" -lt 1000 ]]; then
        continue
    fi

    TOTAL=$((TOTAL + 1))
    anomalies=""
    risk="OK"

    log_info "Auditing user: ${BOLD}${username}${RESET} (uid=$uid)"

    # ── 2a. Shell check ───────────────────────────────────────
    if [[ "$shell" == *"nologin"* || "$shell" == *"false"* ]]; then
        login_capable="no"
    else
        login_capable="yes"
    fi

    # ── 2b. Home directory existence & permissions ────────────
    home_exists="no"
    home_perms="N/A"
    home_perm_ok="N/A"

    if [[ -d "$home_dir" ]]; then
        home_exists="yes"
        home_perms=$(stat -c "%a" "$home_dir" 2>/dev/null)

        if [[ "$home_perms" == "700" ]]; then
            home_perm_ok="yes"
            log_ok "Home dir $home_dir → perms $home_perms ✓"
        else
            home_perm_ok="no"
            anomalies="${anomalies}HOME_PERMS_${home_perms}|"
            log_flag "Home dir $home_dir → perms $home_perms (expected 700)"

            # Auto-fix if --fix passed
            if $FIX_MODE; then
                chmod 700 "$home_dir"
                log_fix "chmod 700 $home_dir — corrected"
                home_perms="700"
                home_perm_ok="yes"
                anomalies="${anomalies/HOME_PERMS_*/}"
            else
                case "$home_perms" in
                    7[0-9][1-9]|[0-6]*) risk="HIGH" ;;
                    7[1-6]0|750|710) [[ "$risk" != "HIGH" ]] && risk="MEDIUM" ;;
                esac
            fi
        fi
    else
        if [[ "$login_capable" == "yes" ]]; then
            anomalies="${anomalies}NO_HOME_DIR|"
            [[ "$risk" != "HIGH" ]] && risk="MEDIUM"
            log_warn "No home dir found at $home_dir"
        fi
    fi

    # ── 2c. Group membership ──────────────────────────────────
    user_groups=$(awk -F: -v u="$username" '
        $4 ~ "(^|,)"u"(,|$)" { printf "%s,", $1 }
    ' "$GROUP_FILE" | sed 's/,$//')

    [[ -z "$user_groups" ]] && user_groups="none"

    # ── 2d. Sudo access check ─────────────────────────────────
    in_sudo_group=$(echo "$user_groups" | grep -cE "(^|,)(sudo|wheel)(,|$)")

    has_sudoers_entry=0
    sudo_nopasswd="no"

    if [[ -f "$SUDOERS_FILE" ]]; then
        sudoers_line=$(grep -E "^${username}\s" "$SUDOERS_FILE" 2>/dev/null)
        if [[ -n "$sudoers_line" ]]; then
            has_sudoers_entry=1
            echo "$sudoers_line" | grep -qi "NOPASSWD" && sudo_nopasswd="yes"
        fi
    fi

    if [[ "$in_sudo_group" -gt 0 || "$has_sudoers_entry" -eq 1 ]]; then
        has_sudo="yes"
        log_warn "$username has sudo access"

        if [[ "$sudo_nopasswd" == "yes" ]]; then
            anomalies="${anomalies}SUDO_NOPASSWD|"
            risk="HIGH"
            log_flag "$username has NOPASSWD sudo!"
        fi

        if [[ "$login_capable" == "no" ]]; then
            anomalies="${anomalies}NOLOGIN_WITH_SUDO|"
            [[ "$risk" != "HIGH" ]] && risk="MEDIUM"
        fi
    else
        has_sudo="no"
        log_ok "$username — no sudo"
    fi

    # ── 2e. SSH key presence, permissions, and fingerprints ───
    has_ssh_keys="no"
    ssh_dir_perms="N/A"
    ssh_key_perms="N/A"
    ssh_fingerprints="none"

    ssh_dir="${home_dir}/.ssh"
    auth_keys="${ssh_dir}/authorized_keys"

    if [[ -d "$ssh_dir" ]]; then
        ssh_dir_perms=$(stat -c "%a" "$ssh_dir" 2>/dev/null)

        if [[ "$ssh_dir_perms" != "700" ]]; then
            anomalies="${anomalies}SSH_DIR_PERMS_${ssh_dir_perms}|"
            [[ "$risk" != "HIGH" ]] && risk="MEDIUM"
            log_flag "$username .ssh dir perms = $ssh_dir_perms (should be 700)"

            if $FIX_MODE; then
                chmod 700 "$ssh_dir"
                log_fix "chmod 700 $ssh_dir — corrected"
                ssh_dir_perms="700"
                anomalies="${anomalies/SSH_DIR_PERMS_*/}"
            fi
        fi
    fi

    if [[ -f "$auth_keys" ]]; then
        has_ssh_keys="yes"
        ssh_key_perms=$(stat -c "%a" "$auth_keys" 2>/dev/null)
        key_count=$(grep -c . "$auth_keys" 2>/dev/null || echo 0)

        # Collect fingerprints for every key in authorized_keys
        fingerprint_list=""
        while IFS= read -r key_line; do
            # Skip blank lines and comments
            [[ -z "$key_line" || "$key_line" == \#* ]] && continue
            fp=$(echo "$key_line" | ssh-keygen -lf /dev/stdin 2>/dev/null | awk '{print $2, $4}')
            [[ -n "$fp" ]] && {
                log_warn "  Key fingerprint: $fp"
                fingerprint_list="${fingerprint_list}${fp};"
            }
        done < "$auth_keys"
        fingerprint_list="${fingerprint_list%;}"   # strip trailing semicolon
        [[ -n "$fingerprint_list" ]] && ssh_fingerprints="$fingerprint_list"

        log_warn "$username has $key_count SSH key(s)"

        if [[ "$ssh_key_perms" != "600" ]]; then
            anomalies="${anomalies}SSH_KEY_PERMS_${ssh_key_perms}|"
            [[ "$risk" != "HIGH" ]] && risk="MEDIUM"
            log_flag "$username authorized_keys perms = $ssh_key_perms (should be 600)"

            if $FIX_MODE; then
                chmod 600 "$auth_keys"
                log_fix "chmod 600 $auth_keys — corrected"
                ssh_key_perms="600"
                anomalies="${anomalies/SSH_KEY_PERMS_*/}"
            fi
        fi

        if [[ "$key_count" -gt 3 ]]; then
            anomalies="${anomalies}MANY_SSH_KEYS_${key_count}|"
            [[ "$risk" != "HIGH" && "$risk" != "MEDIUM" ]] && risk="MEDIUM"
        fi
    fi

    # ── 2f. UID 0 check ───────────────────────────────────────
    if [[ "$uid" -eq 0 && "$username" != "root" ]]; then
        anomalies="${anomalies}UID_0_NON_ROOT|"
        risk="HIGH"
        log_flag "CRITICAL: $username has UID 0 (root equivalent)!"
    fi

    # ── 2g. Empty username guard ──────────────────────────────
    [[ -z "$username" ]] && anomalies="${anomalies}EMPTY_USERNAME|"

    # ── 2h. Tally flagged accounts ────────────────────────────
    [[ -n "$anomalies" ]] && {
        FLAGGED=$((FLAGGED + 1))
        [[ "$risk" == "HIGH" ]] && HIGH=$((HIGH + 1))
    }

    # Strip trailing pipe
    anomalies="${anomalies%|}"
    [[ -z "$anomalies" ]] && anomalies="none"

    # ── 2i. Write CSV row ─────────────────────────────────────
    # ssh_fingerprints field added after ssh_key_perms (col 15)
    echo "\"$username\",$uid,$gid,\"$shell\",\"$home_dir\",$home_exists,$home_perms,$home_perm_ok,\"$user_groups\",$has_sudo,$sudo_nopasswd,$has_ssh_keys,$ssh_dir_perms,$ssh_key_perms,\"$ssh_fingerprints\",\"$anomalies\",$risk_level" \
        >> "$OUTPUT_CSV"

    echo ""

done < "$PASSWD_FILE"

# ── STEP 3: Summary ──────────────────────────────────────────
echo -e "${BOLD}══════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}   AUDIT SUMMARY                                  ${RESET}"
echo -e "${BOLD}══════════════════════════════════════════════════${RESET}"
echo -e "  Total users audited : ${BOLD}${TOTAL}${RESET}"
echo -e "  Users with issues   : ${YELLOW}${FLAGGED}${RESET}"
echo -e "  HIGH risk users     : ${RED}${HIGH}${RESET}"
echo -e "  Report saved to     : ${CYAN}${REPORT_DIR}/${OUTPUT_CSV}${RESET}"
$FIX_MODE && echo -e "  Fix mode          : ${GREEN}enabled — misconfigurations auto-corrected${RESET}"
echo ""

# ── STEP 4: Risk summaries from CSV ──────────────────────────
echo -e "${RED}${BOLD}HIGH Risk Users:${RESET}"
awk -F',' 'NR>1 && $17=="HIGH" {gsub(/"/, "", $1); gsub(/"/, "", $16); print "  → " $1 " | Flags: " $16}' "$OUTPUT_CSV"

echo ""
echo -e "${YELLOW}${BOLD}MEDIUM Risk Users:${RESET}"
awk -F',' 'NR>1 && $17=="MEDIUM" {gsub(/"/, "", $1); gsub(/"/, "", $16); print "  → " $1 " | Flags: " $16}' "$OUTPUT_CSV"

echo ""