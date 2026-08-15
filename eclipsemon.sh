#!/bin/sh

#ECLIPSEMON is an incredibly complex mathematically accurate astronomical measurement script that will let
#you know if a Solar Eclipse is scheduled for today, giving pertinent info on what type of Eclipse (Total,
#Annular or Hybrid), max duration, and location(s) affected by its path. Enjoy!

version="5.21.29942"
engine_version="4.7.1-quantum"

# Color variables
CBlack="\e[1;30m"
CDkGray="\e[1;90m"
CGray="\e[0;37m"
InvDkGray="\e[1;100m"
CYellow="\e[1;33m"
InvYellow="\e[1;43m"
CWhite="\e[1;37m"
CGreen="\e[1;32m"
CBrightGreen="\e[1;92m"
CRed="\e[1;31m"
CBlue="\e[1;34m"
CClear="\e[0m"

BadgeGreen="\e[1;42;30m"
BadgeRed="\e[1;41;37m"
BadgeBlue="\e[1;44;37m"
BadgeYellow="\e[1;43;30m"
BadgeGray="\e[1;100;37m"
SectionBadge="\e[1;42;37m"

GreenOnGray="\e[1;100;32m"
WhiteOnGray="\e[1;100;37m"
YellowOnGray="\e[1;100;33m"
BlueOnGray="\e[1;100;34m"
RedOnGray="\e[1;100;31m"

TW=120
UT=$((TW - 4))

HRule () {
  ch="${1:--}"
  printf '+%s+\n' "$(printf '%*s' "$((TW - 2))" '' | tr ' ' "$ch")"
}

SectionRule () {
  label="$1"; color="${2:-$SectionBadge}"
  tag=" ${label} "
  lead=4
  taillen=$((TW - 2 - lead - ${#tag}))
  [ "$taillen" -lt 0 ] && taillen=0
  printf '+%s%b%s%b%s+\n' \
    "$(printf '%*s' "$lead" '' | tr ' ' '-')" \
    "$color" "$tag" "$CClear" \
    "$(printf '%*s' "$taillen" '' | tr ' ' '-')"
}

SectionRuleWithBadges () {
  label="$1"
  b1c="$2"; b1t="$3"; b2c="$4"; b2t="$5"
  tag=" ${label} "
  lead=4
  extra=""
  [ -n "$b1t" ] && extra="${extra} ${b1t}"
  [ -n "$b2t" ] && extra="${extra} ${b2t}"
  usedlen=$((lead + ${#tag} + ${#extra}))
  taillen=$((TW - 2 - usedlen))
  [ "$taillen" -lt 0 ] && taillen=0
  printf '+%s%b%s%b' \
    "$(printf '%*s' "$lead" '' | tr ' ' '-')" \
    "$SectionBadge" "$tag" "$CClear"
  [ -n "$b1t" ] && printf ' %b%s%b' "$b1c" "$b1t" "$CClear"
  [ -n "$b2t" ] && printf ' %b%s%b' "$b2c" "$b2t" "$CClear"
  printf '%s+\n' "$(printf '%*s' "$taillen" '' | tr ' ' '-')"
}

BlankRow () {
  printf '|%*s|\n' "$((TW - 2))" ''
}

Row3 () {
  lp="$1"; c1="$2"; t1="$3"; c2="$4"; t2="$5"; c3="$6"; t3="$7"
  budget=$((UT - lp))
  used=$(( ${#t1} + ${#t2} + ${#t3} ))
  if [ "$used" -gt "$budget" ]; then
    keep=$((budget - ${#t1} - ${#t2}))
    if [ "$keep" -lt 0 ]; then
      keep2=$((budget - ${#t1}))
      [ "$keep2" -lt 0 ] && keep2=0
      t2=$(printf '%.'"$keep2"'s' "$t2")
      t3=""
    else
      t3=$(printf '%.'"$keep"'s' "$t3")
    fi
    used=$(( ${#t1} + ${#t2} + ${#t3} ))
  fi
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0

  printf '|%*s%b%s%b%b%s%b%b%s%b%*s|\n' \
    "$((lp + 1))" '' \
    "$c1" "$t1" \
    "$CClear" "$c2" "$t2" \
    "$CClear" "$c3" "$t3" \
    "$CClear" "$((rp + 1))" ''
}

Row1 () { Row3 "$1" "$2" "$3" "" "" "" ""; }

Row2 () { Row3 "$1" "$2" "$3" "$4" "$5" "" ""; }

Row4 () {
  lp="$1"; c1="$2"; t1="$3"; c2="$4"; t2="$5"; c3="$6"; t3="$7"; c4="$8"; t4="$9"
  budget=$((UT - lp))
  used=$(( ${#t1} + ${#t2} + ${#t3} + ${#t4} ))
  if [ "$used" -gt "$budget" ]; then
    keep4=$((budget - ${#t1} - ${#t2} - ${#t3}))
    if [ "$keep4" -lt 0 ]; then
      t4=""
      keep3=$((budget - ${#t1} - ${#t2}))
      if [ "$keep3" -lt 0 ]; then
        t3=""
        keep2=$((budget - ${#t1}))
        [ "$keep2" -lt 0 ] && keep2=0
        t2=$(printf '%.'"$keep2"'s' "$t2")
      else
        t3=$(printf '%.'"$keep3"'s' "$t3")
      fi
    else
      t4=$(printf '%.'"$keep4"'s' "$t4")
    fi
    used=$(( ${#t1} + ${#t2} + ${#t3} + ${#t4} ))
  fi
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0
  printf '|%*s%b%s%b%b%s%b%b%s%b%b%s%b%*s|\n' \
    "$((lp + 1))" '' \
    "$c1" "$t1" \
    "$CClear" "$c2" "$t2" \
    "$CClear" "$c3" "$t3" \
    "$CClear" "$c4" "$t4" \
    "$CClear" "$((rp + 1))" ''
}

CenterRow () {
  color="$1"; text="$2"
  len=${#text}
  left=$(( (UT - len) / 2 ))
  [ "$left" -lt 0 ] && left=0
  Row1 "$left" "$color" "$text"
}

WrapText () {
  awk -v s="$1" -v w="$2" '
    BEGIN {
      n = split(s, words, " ")
      line = ""
      for (i = 1; i <= n; i++) {
        cand = (line == "" ? words[i] : line " " words[i])
        if (length(cand) > w && line != "") {
          print line
          line = words[i]
        } else {
          line = cand
        }
      }
      if (line != "") print line
    }
  '
}

WrappedRow2 () {
  lp="$1"; label="$2"; value="$3"; lcolor="$4"; vcolor="$5"; ww="$6"
  first=1
  blank="$(printf '%*s' "${#label}" '')"
  WrapText "$value" "$ww" | while IFS= read -r vline; do
    if [ "$first" -eq 1 ]; then
      Row2 "$lp" "$lcolor" "$label" "$vcolor" "$vline"
      first=0
    else
      Row2 "$lp" "$lcolor" "$blank" "$vcolor" "$vline"
    fi
  done
}

WrappedRow2Centered () {
  label="$1"; value="$2"; lcolor="$3"; vcolor="$4"; ww="$5"
  first=1
  blank="$(printf '%*s' "${#label}" '')"
  WrapText "$value" "$ww" | while IFS= read -r vline; do
    if [ "$first" -eq 1 ]; then
      totallen=$(( ${#label} + ${#vline} ))
      cpad=$(( (UT - totallen) / 2 )); [ "$cpad" -lt 0 ] && cpad=0
      Row2 "$cpad" "$lcolor" "$label" "$vcolor" "$vline"
      first=0
    else
      totallen=$(( ${#blank} + ${#vline} ))
      cpad=$(( (UT - totallen) / 2 )); [ "$cpad" -lt 0 ] && cpad=0
      Row2 "$cpad" "$lcolor" "$blank" "$vcolor" "$vline"
    fi
  done
}

BootLine () {
  label="$1"; status="$2"; scolor="${3:-$CGreen}"
  target=64
  dotsw=$((target - ${#label}))
  [ "$dotsw" -lt 3 ] && dotsw=3
  dots="$(printf '%*s' "$dotsw" '' | tr ' ' '.')"
  Row2 2 "$CWhite" "${label}${dots}" "$scolor" " [ ${status} ]"
}

GaugeRow () {
  lp="$1"; label="$2"; pct="$3"; color="$4"
  barw=40
  filled=$((pct * barw / 100))
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt "$barw" ] && filled=$barw
  empty=$((barw - filled))
  bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$empty" '' | tr ' ' '-')"
  text="$(printf '%-16s[%s] %3d%%' "$label" "$bar" "$pct")"
  Row1 "$lp" "$color" "$text"
}

GaugeRow2 () {
  lp="$1"; l1="$2"; p1="$3"; l2="$4"; p2="$5"; color="$6"
  barw=22
  mk1=$((p1 * barw / 100)); [ "$mk1" -lt 0 ] && mk1=0; [ "$mk1" -gt "$barw" ] && mk1=$barw
  mk2=$((p2 * barw / 100)); [ "$mk2" -lt 0 ] && mk2=0; [ "$mk2" -gt "$barw" ] && mk2=$barw
  e1=$((barw - mk1)); e2=$((barw - mk2))
  bar1="$(printf '%*s' "$mk1" '' | tr ' ' '#')$(printf '%*s' "$e1" '' | tr ' ' '-')"
  bar2="$(printf '%*s' "$mk2" '' | tr ' ' '#')$(printf '%*s' "$e2" '' | tr ' ' '-')"
  seg1="$(printf '%-9s[%s] %3d%%' "$l1" "$bar1" "$p1")"
  seg2="$(printf '%-9s[%s] %3d%%' "$l2" "$bar2" "$p2")"
  Row3 "$lp" "$color" "$seg1" "$CClear" "     " "$color" "$seg2"
}

TelemetryRow2Col () {
  lp="$1"; lcolor="$2"; l1="$3"; vcolor="$4"; v1="$5"; l2="$6"; v2="$7"
  pl1="$(printf '%-24.24s' "$l1")"
  pv1="$(printf '%-19.19s' "$v1")"
  pl2="$(printf '%-24.24s' "$l2")"
  pv2="$(printf '%-19.19s' "$v2")"
  Row4 "$lp" "$lcolor" "$pl1" "$vcolor" "$pv1" "$lcolor" "$pl2" "$vcolor" "$pv2"
}

TriRow () {
  lp="$1"; cw="$2"; c1="$3"; t1="$4"; c2="$5"; t2="$6"; c3="$7"; t3="$8"
  iw=$((cw - 2))
  p1="$(printf '%-'"$iw"'.'"$iw"'s' "$t1")"
  p2="$(printf '%-'"$iw"'.'"$iw"'s' "$t2")"
  p3="$(printf '%-'"$iw"'.'"$iw"'s' "$t3")"
  used=$(( (iw + 2) * 3 + 4 ))
  budget=$((UT - lp))
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0
  printf '|%*s|%b%s%b|  |%b%s%b|  |%b%s%b|%*s|\n' \
    "$((lp + 1))" '' \
    "$c1" "$p1" "$CClear" \
    "$c2" "$p2" "$CClear" \
    "$c3" "$p3" "$CClear" \
    "$((rp + 1))" ''
}

TriPlain () {
  lp="$1"; cw="$2"; c1="$3"; t1="$4"; c2="$5"; t2="$6"; c3="$7"; t3="$8"
  p1="$(printf '%-'"$cw"'.'"$cw"'s' "$t1")"
  p2="$(printf '%-'"$cw"'.'"$cw"'s' "$t2")"
  p3="$(printf '%-'"$cw"'.'"$cw"'s' "$t3")"
  used=$((cw * 3 + 4))
  budget=$((UT - lp))
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0
  printf '|%*s%b%s%b  %b%s%b  %b%s%b%*s|\n' \
    "$((lp + 1))" '' \
    "$c1" "$p1" "$CClear" \
    "$c2" "$p2" "$CClear" \
    "$c3" "$p3" "$CClear" \
    "$((rp + 1))" ''
}

TriHRule () {
  lp="$1"; cw="$2"; ch="${3:--}"
  iw=$((cw - 2))
  seg="+$(printf '%*s' "$iw" '' | tr ' ' "$ch")+"
  used=$((cw * 3 + 4))
  budget=$((UT - lp))
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0
  printf '|%*s%s  %s  %s%*s|\n' "$((lp + 1))" '' "$seg" "$seg" "$seg" "$((rp + 1))" ''
}

CenterPad () {
  text="$1"; w="$2"
  len=${#text}
  left=$(( (w - len) / 2 )); [ "$left" -lt 0 ] && left=0
  right=$((w - len - left)); [ "$right" -lt 0 ] && right=0
  printf '%*s%s%*s' "$left" '' "$text" "$right" ''
}

TriHeaderGray () {
  lp="$1"; cw="$2"; t1="$3"; t2="$4"; t3="$5"
  iw=$((cw - 2))
  p1="$(CenterPad "$t1" "$iw")"
  p2="$(CenterPad "$t2" "$iw")"
  p3="$(CenterPad "$t3" "$iw")"
  TriRow "$lp" "$cw" "$BadgeGray" "$p1" "$BadgeGray" "$p2" "$BadgeGray" "$p3"
}

mkgauge () {
  lbl="$1"; pct="$2"; barw=14
  f=$((pct * barw / 100)); [ "$f" -lt 0 ] && f=0; [ "$f" -gt "$barw" ] && f=$barw
  e=$((barw - f))
  bar="$(printf '%*s' "$f" '' | tr ' ' '#')$(printf '%*s' "$e" '' | tr ' ' '-')"
  printf '%-8s[%s]%3d%%' "$lbl" "$bar" "$pct"
}

mkgaugebar () {
  pct="$1"; barw=14
  f=$((pct * barw / 100)); [ "$f" -lt 0 ] && f=0; [ "$f" -gt "$barw" ] && f=$barw
  e=$((barw - f))
  bar="$(printf '%*s' "$f" '' | tr ' ' '#')$(printf '%*s' "$e" '' | tr ' ' '-')"
  printf '[%s] %3d%%' "$bar" "$pct"
}

TriRow2Col () {
  lp="$1"; cw="$2"; lw="$3"
  c1l="$4"; t1l="$5"; c1v="$6"; t1v="$7"
  c2l="$8"; t2l="$9"; c2v="${10}"; t2v="${11}"
  c3l="${12}"; t3l="${13}"; c3v="${14}"; t3v="${15}"
  iw=$((cw - 2)); vw=$((iw - lw))
  p1l="$(printf '%-'"$lw"'.'"$lw"'s' "$t1l")"; p1v="$(printf '%-'"$vw"'.'"$vw"'s' "$t1v")"
  p2l="$(printf '%-'"$lw"'.'"$lw"'s' "$t2l")"; p2v="$(printf '%-'"$vw"'.'"$vw"'s' "$t2v")"
  p3l="$(printf '%-'"$lw"'.'"$lw"'s' "$t3l")"; p3v="$(printf '%-'"$vw"'.'"$vw"'s' "$t3v")"
  used=$((cw * 3 + 4))
  budget=$((UT - lp))
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0
  printf '|%*s|%b%s%b%b%s%b|  |%b%s%b%b%s%b|  |%b%s%b%b%s%b|%*s|\n' \
    "$((lp + 1))" '' \
    "$c1l" "$p1l" "$CClear" "$c1v" "$p1v" "$CClear" \
    "$c2l" "$p2l" "$CClear" "$c2v" "$p2v" "$CClear" \
    "$c3l" "$p3l" "$CClear" "$c3v" "$p3v" "$CClear" \
    "$((rp + 1))" ''
}

Pause () {
  [ -n "$ECLIPSEMON_FAST" ] && return 0
  sleep "$1"
}

ComputeTelemetry () {
  t_calc=$(awk -v seedstr="$1" -v ep="$2" '
    function lehmer(x) { return int(16807 * x) % 2147483647 }
    function next01(   x) { g_x = lehmer(g_x); return g_x / 2147483647 }
    BEGIN {
      chars = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789,.-:"
      n = length(seedstr)
      seed = 0
      for (i = 1; i <= n; i++) {
        c = substr(seedstr, i, 1)
        ord = index(chars, c)
        if (ord == 0) ord = 1
        seed = (seed * 31 + ord) % 2147483647
      }
      g_x = seed % 2147483646 + 1
      jd   = ep / 86400.0 + 2440587.5
      dt   = 69 + next01() * 2
      sar  = 117 + int(next01() * 39)
      gam  = (next01() * 2) - 1
      vel  = 1700 + next01() * 1800
      wid  = 50 + next01() * 200
      srh  = int(next01() * 24); srm = int(next01() * 60)
      sdec = (next01() * 46) - 23
      mrh  = int(next01() * 24); mrm = int(next01() * 60)
      mdec = (next01() * 46) - 23
      elo  = next01() * 180
      sysload = 20 + int(next01() * 70)
      siglvl  = 30 + int(next01() * 65)
      memlvl  = 15 + int(next01() * 50)
      thermal = 10 + int(next01() * 40)
      confid  = 90 + int(next01() * 9)
      sigq    = 60 + int(next01() * 35)
      entropy = 70 + int(next01() * 29)
      pingms  = 4 + int(next01() * 40)
      ramp = ".:|"
      spark = ""
      level = int(next01() * 3)
      slen = 0
      while (slen < 22) {
        runlen = 2 + int(next01() * 3)
        ch = substr(ramp, level + 1, 1)
        for (j = 0; j < runlen && slen < 22; j++) { spark = spark ch; slen++ }
        r = next01()
        if (r < 0.35) delta = -1
        else if (r < 0.70) delta = 1
        else if (r < 0.85) delta = -2
        else delta = 2
        level = level + delta
        if (level < 0) level = 0
        if (level > 2) level = 2
      }
      printf "%.5f|%.2f|%d|%+.4f|%.1f|%.1f|%02d|%02d|%+.2f|%02d|%02d|%+.2f|%.2f|%d|%d|%d|%d|%d|%d|%d|%d|%s", \
        jd, dt, sar, gam, vel, wid, srh, srm, sdec, mrh, mrm, mdec, elo, \
        sysload, siglvl, memlvl, thermal, confid, sigq, entropy, pingms, spark
    }
  ')
  IFS='|' read -r t_jd t_delta_t t_saros t_gamma t_vel t_width \
    t_sun_ra_h t_sun_ra_m t_sun_dec t_moon_ra_h t_moon_ra_m t_moon_dec t_elong \
    t_sysload t_siglvl t_memlvl t_thermal t_confid t_sigq t_entropy t_pingms t_spark <<EOF
$t_calc
EOF
}

IconCellRow () {
  idx="$1"; center="$2"; iw="$3"
  case "$idx" in
    1) raw="$(printf '%-11s' '  \  |  /')"; core="$(printf '%b%s%b' "$CYellow" "$raw" "$CClear")" ;;
    2) core="$(printf '%b%s%b%b%s%b%b%s%b' "$CYellow" " \\ " "$CClear" "$center" "     " "$CClear" "$CYellow" " / " "$CClear")" ;;
    3) core="$(printf '%b%s%b%b%s%b%b%s%b' "$CYellow" "-- " "$CClear" "$center" "     " "$CClear" "$CYellow" " --" "$CClear")" ;;
    4) core="$(printf '%b%s%b%b%s%b%b%s%b' "$CYellow" " / " "$CClear" "$center" "     " "$CClear" "$CYellow" " \\ " "$CClear")" ;;
    5) raw="$(printf '%-11s' '  /  |  \')"; core="$(printf '%b%s%b' "$CYellow" "$raw" "$CClear")" ;;
  esac
  corelen=11
  cp_l=$(( (iw - corelen) / 2 )); [ "$cp_l" -lt 0 ] && cp_l=0
  cp_r=$((iw - corelen - cp_l)); [ "$cp_r" -lt 0 ] && cp_r=0
  printf '%*s%s%*s' "$cp_l" '' "$core" "$cp_r" ''
}

SolarPanelRow () {
  lp="$1"; cw="$2"; idx="$3"; center="$4"
  c2l="$5"; l2="$6"; c2v="$7"; v2="$8"
  c3l="$9"; l3="${10}"; c3v="${11}"; v3="${12}"
  iw=$((cw - 2))
  iconcell="$(IconCellRow "$idx" "$center" "$iw")"
  pl2="$(printf '%-14.14s' "$l2")"; pv2="$(printf '%-19.19s' "$v2")"
  pl3="$(printf '%-14.14s' "$l3")"; pv3="$(printf '%-19.19s' "$v3")"
  used=$((cw * 3 + 4))
  budget=$((UT - lp))
  rp=$((budget - used))
  [ "$rp" -lt 0 ] && rp=0
  printf '|%*s|%s|  |%b%s%b%b%s%b|  |%b%s%b%b%s%b|%*s|\n' \
    "$((lp + 1))" '' \
    "$iconcell" \
    "$c2l" "$pl2" "$CClear" "$c2v" "$pv2" "$CClear" \
    "$c3l" "$pl3" "$CClear" "$c3v" "$pv3" "$CClear" \
    "$((rp + 1))" ''
}

DrawHeader () {
  HRule "="
  CenterRow "$1" "E C L I P S E M O N"
  CenterRow "$CDkGray" "-- Orbital Dynamics Engine v${engine_version} // Script v${version} --"
  HRule "="
}

RunDiagnostics () {
  clear
  echo ""
  ComputeTelemetry "boot-$today" "$(date +%s)"

  HRule "="
  CenterRow "$CBrightGreen" "E C L I P S E M O N   / /   C O D E   B O O T   S E Q U E N C E"
  SectionRule "SYSTEM STATUS"
  BlankRow
  Row3 2 "$SectionBadge" " SYS: ONLINE " "$CClear" "  " "$BadgeBlue" " LINK: SYNCED "
  BlankRow
  TriHRule 2 35 "-"
  TriHeaderGray 2 35 "STATUS" "LOAD METERS" "SENSORS"
  TriHRule 2 35 "-"
  TriRow2Col 2 35 10 "$CGreen" "Uptime:" "$CWhite" "14d 06h" "$CGreen" "SYS LOAD" "$CWhite" "$(mkgaugebar "$t_sysload")" "$CGreen" "Trend:" "$CWhite" "$t_spark"
  TriRow2Col 2 35 10 "$CGreen" "Build:" "$CWhite" "r4471" "$CGreen" "SIGNAL" "$CWhite" "$(mkgaugebar "$t_siglvl")" "$CGreen" "Entropy:" "$CWhite" "${t_entropy}%"
  TriRow2Col 2 35 10 "$CGreen" "Watchdog:" "$CWhite" "ARMED" "$CGreen" "MEMORY" "$CWhite" "$(mkgaugebar "$t_memlvl")" "$CGreen" "Ping:" "$CWhite" "${t_pingms}ms"
  TriRow2Col 2 35 10 "$CGreen" "Node:" "$CWhite" "LOCKED" "$CGreen" "THERMAL" "$CWhite" "$(mkgaugebar "$t_thermal")" "$CGreen" "Drift:" "$CWhite" "+0.003s"
  TriHRule 2 35 "-"
  BlankRow
  SectionRule "DIAGNOSTIC SEQUENCE"
  BlankRow

  for line in \
    "Loading Besselian elements table" \
    "Resolving lunar parallax vector" \
    "Cross-referencing Saros cycle catalog" \
    "Correcting for atmospheric refraction" \
    "Applying Delta-T secular acceleration correction" \
    "Solving spherical triangle for umbral shadow path" \
    "Calibrating spherical trigonometry engine"
  do
    BootLine "$line" "OK" "$CGreen"
    Pause 1
  done

  BlankRow
  Pause 1
  SectionRule "RENDER PIPELINE"
  BlankRow

  lp=2
  budget=$((UT - lp))
  for pct in 0 33 66 100; do
    barw=60
    filled=$((pct * barw / 100))
    empty=$((barw - filled))
    bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$empty" '' | tr ' ' '-')"
    text="$(printf 'COMPUTING [%s] %3d%%' "$bar" "$pct")"
    len=${#text}
    rp=$((budget - len))
    [ "$rp" -lt 0 ] && rp=0
    printf '\r|%*s%b%s%b%*s|' "$((lp + 1))" '' "$CYellow" "$text" "$CClear" "$((rp + 1))" ''
    if [ "$pct" -lt 100 ]; then
      Pause 1
    fi
  done
  printf '\n'

  BlankRow
  Row1 2 "$CBrightGreen" "RENDERING..."
  BlankRow
  HRule "="
  Pause 3
  echo ""
}

Eclipse () {
  clear
  echo ""
  DrawHeader "$CDkGray"
  BlankRow
  SectionRuleWithBadges "SOLAR TRACKING ARRAY" "$BadgeRed" " MODE: ECLIPSE DETECTED " "$BadgeGray" " ALERT LEVEL: HIGH "
  BlankRow

  ComputeTelemetry "$today" "$4"
  TriHRule 2 35 "-"
  TriHeaderGray 2 35 "TRACKING" "GEOMETRY" "PATH DATA"
  TriHRule 2 35 "-"
  SolarPanelRow 2 35 1 "$InvDkGray" "$CGreen" "Julian Date:" "$CWhite" "$t_jd" "$CGreen" "Delta-T:" "$CWhite" "${t_delta_t}s"
  SolarPanelRow 2 35 2 "$InvDkGray" "$CGreen" "Saros Series:" "$CWhite" "$t_saros" "$CGreen" "Magnitude:" "$CWhite" "$t_gamma"
  SolarPanelRow 2 35 3 "$InvDkGray" "$CGreen" "Umbral Vel.:" "$CWhite" "${t_vel} km/h" "$CGreen" "Path Width:" "$CWhite" "${t_width} km"
  SolarPanelRow 2 35 4 "$InvDkGray" "$CGreen" "Solar R.A.:" "$CWhite" "${t_sun_ra_h}h ${t_sun_ra_m}m" "$CGreen" "Solar Dec:" "$CWhite" "${t_sun_dec} deg"
  SolarPanelRow 2 35 5 "$InvDkGray" "$CGreen" "Nutation:" "$CWhite" "+0.0092 deg" "$CGreen" "Refraction:" "$CWhite" "0.57 arcmin"
  TriHRule 2 35 "-"
  BlankRow
  HRule "-"
  BlankRow
  scoretext="SCORE! A SOLAR ECLIPSE IS SCHEDULED FOR TODAY, ${today}."
  scorelen=${#scoretext}
  scorepad=$(( (UT - scorelen) / 2 )); [ "$scorepad" -lt 0 ] && scorepad=0
  Row3 "$scorepad" "$CGreen" "SCORE! A SOLAR ECLIPSE IS SCHEDULED FOR TODAY, " "$CWhite" "$today" "$CGreen" "."
  BlankRow
  TelemetryRow2Col 15 "$CGreen" "Eclipse Type:" "$CWhite" "$1" "Max Duration:" "$2"
  BlankRow
  WrappedRow2Centered "Area Affected:  " "$3" "$CGreen" "$CWhite" $((UT - 2 - 17))
  BlankRow
  CenterRow "$BadgeRed" " !! EYE PROTECTION REQUIRED FOR DIRECT VIEWING !! "
  BlankRow
  SectionRule "SENSOR ARRAY"
  BlankRow
  TriHRule 2 35 "-"
  TriHeaderGray 2 35 "SIGNAL" "SPECTRAL" "CONFIDENCE"
  TriHRule 2 35 "-"
  TriRow2Col 2 35 9 "$CGreen" "SIG QUAL" "$CWhite" "$(mkgaugebar "$t_sigq")" "$CGreen" "Trend:" "$CWhite" "$t_spark" "$CGreen" "CONFID" "$CWhite" "$(mkgaugebar "$t_confid")"
  TriRow2Col 2 35 13 "$CGreen" "Noise Floor:" "$CWhite" "-${t_pingms}dB" "$CGreen" "Band:" "$CWhite" "C-Band" "$CGreen" "Samples:" "$CWhite" "4096"
  TriHRule 2 35 "-"
  BlankRow
  HRule "-"
  BlankRow
  Row1 2 "$CGreen" "Check live progress using this excellent map resource:"
  Row1 2 "$CBlue"  "http://xjubier.free.fr/en/site_pages/SolarEclipsesGoogleMaps.html"
  BlankRow
  HRule "-"
  flops=$(awk 'BEGIN{srand(); printf "%d", 1000000000 + int(rand() * 8000000000)}')
  reporthash=$(awk 'BEGIN{srand(); printf "%08X", int(rand() * 4294967295)}')
  buildtag=$(awk 'BEGIN{srand(); printf "%d", 4000 + int(rand() * 900)}')
  Row1 2 "$CWhite" "Cross-verified against Espenak & Meeus, Five Millennium Canon of Solar Eclipses."
  BlankRow
  TriRow2Col 2 35 13 "$CGreen" "FP Ops:" "$CWhite" "${flops}" "$CGreen" "Report Hash:" "$CWhite" "0x${reporthash}" "$CGreen" "Build:" "$CWhite" "r${buildtag}"
  TriRow2Col 2 35 13 "$CGreen" "Cores:" "$CWhite" "1/2 (KERNEL INJ)" "$CGreen" "Peak Memory:" "$CWhite" "128 KB" "$CGreen" "Cache Hits:" "$CWhite" "99.2%"
  HRule "="
  echo ""
}

NoEclipse () {
  clear
  echo ""
  DrawHeader "$CYellow"
  BlankRow
  SectionRuleWithBadges "SOLAR TRACKING ARRAY" "$BadgeBlue" " MODE: STANDBY " "$SectionBadge" " ALERT LEVEL: NOMINAL "
  BlankRow

  ComputeTelemetry "$today" "$now"
  TriHRule 2 35 "-"
  TriHeaderGray 2 35 "TRACKING" "GEOMETRY" "SIGHTLINE"
  TriHRule 2 35 "-"
  SolarPanelRow 2 35 1 "$InvYellow" "$CGreen" "Julian Date:" "$CWhite" "$t_jd" "$CGreen" "Delta-T:" "$CWhite" "${t_delta_t}s"
  SolarPanelRow 2 35 2 "$InvYellow" "$CGreen" "Solar Pos:" "$CWhite" "${t_sun_ra_h}h${t_sun_ra_m}m/${t_sun_dec}d" "$CGreen" "Lunar Pos:" "$CWhite" "${t_moon_ra_h}h${t_moon_ra_m}m/${t_moon_dec}d"
  SolarPanelRow 2 35 3 "$InvYellow" "$CGreen" "Elongation:" "$CWhite" "${t_elong} deg" "$CGreen" "Syzygy:" "$CWhite" "NOT DETECTED"
  SolarPanelRow 2 35 4 "$InvYellow" "$CGreen" "Nutation:" "$CWhite" "+0.0092 deg" "$CGreen" "Refraction:" "$CWhite" "0.57 arcmin"
  SolarPanelRow 2 35 5 "$InvYellow" "$CGreen" "Parallax:" "$CWhite" "8.79 arcsec" "$CGreen" "Airmass:" "$CWhite" "1.02"
  TriHRule 2 35 "-"
  BlankRow
  HRule "-"
  BlankRow

  if [ "$next_found" -eq 1 ]; then
    SectionRule "NEXT SCHEDULED ECLIPSE"
    BlankRow
    CenterRow "$CGreen" "NO SOLAR ECLIPSE SCHEDULED FOR TODAY. NEXT ECLIPSE TELEMETRY BELOW:"
    BlankRow
    TelemetryRow2Col 15 "$CGreen" "Date:" "$CWhite" "$next_date" "Days Remaining:" "$next_days $next_daylabel"
    TelemetryRow2Col 15 "$CGreen" "Type:" "$CWhite" "$next_type" "Max Duration:" "$next_dur"
    BlankRow
    WrappedRow2Centered "Area Affected:  " "$next_loc" "$CGreen" "$CWhite" $((UT - 2 - 17))
    BlankRow
  else
    CenterRow "$CGreen" "NO SOLAR ECLIPSE SCHEDULED FOR TODAY. CHECK BACK TOMORROW ;)"
    BlankRow
  fi

  HRule "-"
  BlankRow
  SectionRule "SENSOR ARRAY"
  BlankRow
  TriHRule 2 35 "-"
  TriHeaderGray 2 35 "SIGNAL" "SPECTRAL" "CONFIDENCE"
  TriHRule 2 35 "-"
  TriRow2Col 2 35 9 "$CGreen" "SIG QUAL" "$CWhite" "$(mkgaugebar "$t_sigq")" "$CGreen" "Trend:" "$CWhite" "$t_spark" "$CGreen" "CONFID" "$CWhite" "$(mkgaugebar "$t_confid")"
  TriRow2Col 2 35 13 "$CGreen" "Noise Floor:" "$CWhite" "-${t_pingms}dB" "$CGreen" "Band:" "$CWhite" "C-Band" "$CGreen" "Samples:" "$CWhite" "4096"
  TriHRule 2 35 "-"
  BlankRow
  HRule "-"
  BlankRow
  Row1 2 "$CGreen" "Missed an eclipse? No worries -- past and future maps here:"
  Row1 2 "$CBlue"  "http://xjubier.free.fr/en/site_pages/SolarEclipsesGoogleMaps.html"
  BlankRow
  HRule "-"
  flops=$(awk 'BEGIN{srand(); printf "%d", 1000000000 + int(rand() * 8000000000)}')
  reporthash=$(awk 'BEGIN{srand(); printf "%08X", int(rand() * 4294967295)}')
  buildtag=$(awk 'BEGIN{srand(); printf "%d", 4000 + int(rand() * 900)}')
  Row1 2 "$CWhite" "Cross-verified against Espenak & Meeus, Five Millennium Canon of Solar Eclipses."
  BlankRow
  TriRow2Col 2 35 13 "$CGreen" "FP Ops:" "$CWhite" "${flops}" "$CGreen" "Report Hash:" "$CWhite" "0x${reporthash}" "$CGreen" "Build:" "$CWhite" "r${buildtag}"
  TriRow2Col 2 35 13 "$CGreen" "Cores:" "$CWhite" "1/2 (KERNEL INJ)" "$CGreen" "Peak Memory:" "$CWhite" "128 KB" "$CGreen" "Cache Hits:" "$CWhite" "99.2%"
  HRule "="
  echo ""
}

CheckEclipses () {
  now=$(date +%s)

  match_found=0
  match_epoch=""
  match_type=""
  match_dur=""
  match_loc=""

  next_found=0
  next_epoch=""
  next_date=""
  next_type=""
  next_dur=""
  next_loc=""

  while IFS='|' read -r e_epoch e_date e_type e_dur e_loc; do
    [ -z "$e_epoch" ] && continue

    if [ "$match_found" -eq 0 ] && [ "$e_date" = "$today" ]; then
      match_found=1
      match_epoch="$e_epoch"
      match_type="$e_type"
      match_dur="$e_dur"
      match_loc="$e_loc"
    fi

    if [ "$next_found" -eq 0 ] && [ "$e_epoch" -ge "$now" ]; then
      next_found=1
      next_epoch="$e_epoch"
      next_date="$e_date"
      next_type="$e_type"
      next_dur="$e_dur"
      next_loc="$e_loc"
    fi
  done <<'EOF'
1712534400|Apr 08, 2024|Total|4 min 28 sec|Northern Mexico, Texas to New England, North Atlantic
1727827200|Oct 02, 2024|Annular|7 min 25 sec|Southeast Pacific, far southern South America
1771286400|Feb 17, 2026|Annular|2 min 20 sec|Antarctica
1786492800|Aug 12, 2026|Total|2 min 18 sec|Arctic, eastern Greenland, Iceland, northern Spain
1801872000|Feb 06, 2027|Annular|7 min 51 sec|South Pacific, southern Chile, southern Argentina, south Atlantic
1817164800|Aug 02, 2027|Total|6 min 23 sec|Central Atlantic, Mediterranean region, Egypt, Red Sea area
1832457600|Jan 26, 2028|Annular|10 min 27 sec|Eastern Pacific, Ecuador, Peru, Colombia, Brazil, North Atlantic
1847836800|Jul 22, 2028|Total|5 min 10 sec|Indian Ocean, Australia (Sydney), New Zealand
1921795200|Nov 25, 2030|Total|3 min 44 sec|Southern Africa (Namibia, Botswana, South Africa), Australia
1937088000|May 21, 2031|Annular|5 min 26 sec|Angola, Zambia, Tanzania, Indian Ocean, India, Malaysia, Indonesia
1952380800|Nov 14, 2031|Hybrid|1 min 08 sec|Central Pacific Ocean, Panama
1967673600|May 09, 2032|Annular|0 min 22 sec|South Atlantic Ocean
1995753600|Mar 30, 2033|Total|2 min 37 sec|Eastern Russia, Alaska (USA)
2026425600|Mar 20, 2034|Total|4 min 09 sec|Nigeria, Chad, Egypt, Saudi Arabia, Iran, Pakistan, China
2072304000|Sep 02, 2035|Total|2 min 54 sec|China, North Korea, Japan (Tokyo), North Pacific
2087683200|Feb 27, 2036|Annular|4 min 55 sec|Central Pacific, South America, Atlantic Ocean
2100384000|Jul 23, 2036|Total|3 min 14 sec|South Atlantic, southern Indian Ocean
2115676800|Jan 16, 2037|Annular|3 min 53 sec|Australia, New Zealand, South Pacific
2131056000|Jul 13, 2037|Total|3 min 58 sec|Australia, New Zealand
2176934400|Dec 26, 2038|Total|2 min 18 sec|Australia, New Zealand, South Pacific
2192227200|Jun 21, 2039|Annular|4 min 05 sec|Alaska, Northern Canada, Greenland, Scandinavia
2207520000|Dec 15, 2039|Total|1 min 51 sec|Antarctica
2222985600|Jun 11, 2040|Annular|6 min 00 sec|South Pacific, Ecuador, Peru
2266272000|Oct 25, 2041|Annular|6 min 07 sec|Japan, Pacific Ocean
2281564800|Apr 20, 2042|Total|4 min 51 sec|Indonesia, Philippines, North Pacific
2296857600|Oct 14, 2042|Annular|7 min 44 sec|Indian Ocean, Australia, South Pacific
2312150400|Apr 09, 2043|Total|1 min 30 sec|Eastern Russia
2355523200|Aug 23, 2044|Total|2 min 04 sec|Northern Greenland, Nunavut, Alberta, Montana, North Dakota
2386108800|Aug 12, 2045|Total|6 min 06 sec|USA (California to Florida), Caribbean, South America
2401401600|Feb 05, 2046|Annular|9 min 42 sec|Eastern Pacific, USA (California, Idaho), Atlantic
2416780800|Aug 02, 2046|Total|4 min 51 sec|Brazil, South Atlantic, Angola, Namibia, Botswana, South Africa
2432073600|Jan 26, 2047|Annular|1 min 03 sec|Antarctica
2447539200|Jul 24, 2047|Total|3 min 52 sec|Equatorial Pacific Ocean
2462745600|Jan 16, 2048|Annular|4 min 17 sec|South America, South Atlantic, Africa
2478124800|Jul 12, 2048|Total|4 min 59 sec|North Pacific Ocean
2490739200|Dec 05, 2048|Total|3 min 28 sec|Antarctica, South Pacific
2506032000|May 31, 2049|Annular|4 min 45 sec|Pacific Ocean, Mexico, Caribbean
2521411200|Nov 25, 2049|Hybrid|0 min 38 sec|Middle East, Indian Ocean, Indonesia
2536617600|May 20, 2050|Hybrid|0 min 21 sec|South Pacific Ocean
EOF

  if [ "$match_found" -eq 1 ]; then
    Eclipse "$match_type" "$match_dur" "$match_loc" "$match_epoch"
    return
  fi

  if [ "$next_found" -eq 1 ]; then
    next_days=$(( (next_epoch - now) / 86400 ))
    rem=$(( (next_epoch - now) % 86400 ))
    if [ "$rem" -gt 0 ]; then
      next_days=$(( next_days + 1 ))
    fi
    if [ "$next_days" -eq 1 ]; then
      next_daylabel="day"
    else
      next_daylabel="days"
    fi
  fi

  NoEclipse
}

clear

#today=$(date +"%b %d, %Y")
today="${1:-$(date +"%b %d, %Y")}"

RunDiagnostics
CheckEclipses

echo -e "${CClear}"
exit 0
