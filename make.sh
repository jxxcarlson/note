color=`tput setaf 48`
reset=`tput setaf 7`

echo "${color}Compiling note.rkt to note ,,, ${reset}"
raco exe note.rkt

echo "${color}Coping note to diary ... ${reset}"
cp note diary

echo "${color}Copying note to list ... ${reset}"
cp note list

echo "${color}Done${reset}"