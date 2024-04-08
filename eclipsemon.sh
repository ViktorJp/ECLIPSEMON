#!/bin/sh

#ECLIPSEMON is a astronomical measurement script that will let you know if a Solar Eclipse is scheduled
#for today, giving pertinent info on what type of Eclipse (Total or Annular), max duration, and location(s)
#affected by its path. Enjoy!

version="0.0.1"

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
  echo -e "${CDkGray}    ______________    ________  _____ ________  _______  _   __"
  echo -e "   / ____/ ____/ /   /  _/ __ \/ ___// ____/  |/  / __ \/ | / /"
  echo -e "  / __/ / /   / /    / // /_/ /\__ \/ __/ / /|_/ / / / /  |/ / "
  echo -e " / /___/ /___/ /____/ // ____/___/ / /___/ /  / / /_/ / /|  /  "
  echo -e "/_____/\____/_____/___/_/    /____/_____/_/  /_/\____/_/ |_/  ${CClear}v$version"
  echo ""
  echo -e "${CYellow}"
  echo -e "                             \  |  /  "
  echo -e "                            \ ${InvDkGray}     ${CClear}${CYellow} / "
  echo -e "                           -- ${InvDkGray}     ${CClear}${CYellow} --"
  echo -e "                            / ${InvDkGray}     ${CClear}${CYellow} \ "
  echo -e "                             /  |  \  "
  echo ""
  echo -e "${CGreen}Score! A ${CWhite}$1 Eclipse${CGreen} that will last approx. ${CWhite}$2 ${CGreen}is going"
  echo -e "${CGreen}to take place today, $today! Get your Eclipse viewing glasses ready!"
  echo -e "Area affected: ${CWhite}$3"
  echo ""
}

NoEclipse () {  
  clear
  echo ""
  echo ""
  echo -e "${CYellow}    ______________    ________  _____ ________  _______  _   __"
  echo -e "   / ____/ ____/ /   /  _/ __ \/ ___// ____/  |/  / __ \/ | / /"
  echo -e "  / __/ / /   / /    / // /_/ /\__ \/ __/ / /|_/ / / / /  |/ / "
  echo -e " / /___/ /___/ /____/ // ____/___/ / /___/ /  / / /_/ / /|  /  "
  echo -e "/_____/\____/_____/___/_/    /____/_____/_/  /_/\____/_/ |_/  ${CClear}v$version"
  echo -e "${CYellow}"
  echo -e "                             \  |  /  "
  echo -e "                            \ ${InvYellow}     ${CClear}${CYellow} / "
  echo -e "                           -- ${InvYellow}     ${CClear}${CYellow} --"
  echo -e "                            / ${InvYellow}     ${CClear}${CYellow} \ "
  echo -e "                             /  |  \  "
  echo ""
  echo -e "${CGreen}There are no Solar Eclipses scheduled for today.  Please check back tomorrow! ;)"
  echo ""
}

clear

today=$(date +"%b %d, %Y")

if [ "$today" == "Apr 08, 2024" ]; then
  Eclipse "Total" "4 min 28 sec" "Northern Mexico, Texas to New England, North Atlantic"
elif [ "$today" == "Oct 02, 2024" ]; then
  Eclipse "Annular" "7 min 25 sec" "Southeast Pacific, far southern South America"
elif [ "$today" == "Feb 17, 2026" ]; then
  Eclipse "Annular" "2 min 20 sec" "Antarctica"
elif [ "$today" == "Aug 12, 2026" ]; then
  Eclipse "Total" "2 min 18 sec" "Arctic, eastern Greenland, Iceland, northern Spain"
elif [ "$today" == "Feb 06, 2027" ]; then
  Eclipse "Annular" "7 min 51 sec" "South Pacific, southern Chile, southern Argentina, south Atlantic"
elif [ "$today" == "Aug 02, 2027" ]; then
  Eclipse "Total" "6 min 23 sec" "Central Atlantic, Mediterranean region, Egypt, Red Sea area"
else
  NoEclipse
fi

echo -e "${CClear}"
exit 0
