#!/bin/sh

#ECLIPSEMON is an incredibly complex mathematically accurate astronomical measurement script that will let
#you know if a Solar Eclipse is scheduled for today, giving pertinent info on what type of Eclipse (Total,
#Annular or Hybrid), max duration, and location(s) affected by its path. Enjoy!

version="0.0.2"

# Color variables
CBlack="\e[1;30m"
CDkGray="\e[1;90m"
InvDkGray="\e[1;100m"
CYellow="\e[1;33m"
InvYellow="\e[1;43m"
CWhite="\e[1;37m"
CGreen="\e[1;32m"
CClear="\e[0m"

Eclipse () {
  clear
  echo ""
  echo ""
  echo -e "${CDkGray}        ______________    ________  _____ ________  _______  _   __"
  echo -e "       / ____/ ____/ /   /  _/ __ \/ ___// ____/  |/  / __ \/ | / /"
  echo -e "      / __/ / /   / /    / // /_/ /\__ \/ __/ / /|_/ / / / /  |/ / "
  echo -e "     / /___/ /___/ /____/ // ____/___/ / /___/ /  / / /_/ / /|  /  "
  echo -e "    /_____/\____/_____/___/_/    /____/_____/_/  /_/\____/_/ |_/  ${CClear}v$version"
  echo ""
  echo -e "${CYellow}"
  echo -e "                                 \  |  /  "
  echo -e "                                \ ${InvDkGray}     ${CClear}${CYellow} / "
  echo -e "                               -- ${InvDkGray}     ${CClear}${CYellow} --"
  echo -e "                                / ${InvDkGray}     ${CClear}${CYellow} \ "
  echo -e "                                 /  |  \  "
  echo ""
  echo -e "${CGreen}Score! A ${CWhite}$1 Eclipse${CGreen} that will last approx. ${CWhite}$2 ${CGreen}is going"
  echo -e "${CGreen}to take place today, $today! Get your Eclipse viewing glasses ready!"
  echo -e "Area affected: ${CWhite}$3"
  echo ""
  echo -e "${CGreen}Check live progress of the Eclipse using this excellent map resource:"
  echo -e "${CYellow}http://xjubier.free.fr/en/site_pages/SolarEclipsesGoogleMaps.html"
  echo ""
}

NoEclipse () {  
  clear
  echo ""
  echo ""
  echo -e "${CYellow}        ______________    ________  _____ ________  _______  _   __"
  echo -e "       / ____/ ____/ /   /  _/ __ \/ ___// ____/  |/  / __ \/ | / /"
  echo -e "      / __/ / /   / /    / // /_/ /\__ \/ __/ / /|_/ / / / /  |/ / "
  echo -e "     / /___/ /___/ /____/ // ____/___/ / /___/ /  / / /_/ / /|  /  "
  echo -e "    /_____/\____/_____/___/_/    /____/_____/_/  /_/\____/_/ |_/  ${CClear}v$version"
  echo -e "${CYellow}"
  echo -e "                                 \  |  /  "
  echo -e "                                \ ${InvYellow}     ${CClear}${CYellow} / "
  echo -e "                               -- ${InvYellow}     ${CClear}${CYellow} --"
  echo -e "                                / ${InvYellow}     ${CClear}${CYellow} \ "
  echo -e "                                 /  |  \  "
  echo ""
  echo -e "${CGreen}There are no Solar Eclipses scheduled for today.  Please check back tomorrow! ;)"
  echo ""

  if [ "$next_found" -eq 1 ]; then
    echo -e "${CGreen}Next up: a ${CWhite}$next_type Eclipse${CGreen} on ${CWhite}$next_date${CGreen}, which is just ${CWhite}$next_days $next_daylabel${CGreen} away!"
    echo -e "${CGreen}Max duration approx. ${CWhite}$next_dur"
    echo -e "${CGreen}Area affected: ${CWhite}$next_loc"
    echo ""
  fi

  echo -e "${CGreen}Missed an Eclipse? No worries. Check out past and future Eclipse maps here:"
  echo -e "${CYellow}http://xjubier.free.fr/en/site_pages/SolarEclipsesGoogleMaps.html"
  echo ""
  echo ""
}

CheckEclipses () {
  now=$(date +%s)

  match_found=0
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
    Eclipse "$match_type" "$match_dur" "$match_loc"
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

today=$(date +"%b %d, %Y")

CheckEclipses

echo -e "${CClear}"
exit 0
