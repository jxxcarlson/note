color=`tput setaf 48`
reset=`tput setaf 7`

echo "${color}Compiling note.rkt to note ,,, ${reset}"
raco exe note.rkt

echo "${color}Compiling diary.rkt to diary ... ${reset}"
cp note.rkt diary.rkt
raco exe diary.rkt

echo "${color}Done${reset}"