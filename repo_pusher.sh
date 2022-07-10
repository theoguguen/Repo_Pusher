#!/bin/bash
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
PURPLE='\033[0;35m'

function draw_ascii()
{
	clear
	echo -e "\n██████╗ ███████╗██████╗  ██████╗     ██████╗ ██╗   ██╗███████╗██╗  ██╗███████╗██████╗"
	echo -e "██╔══██╗██╔════╝██╔══██╗██╔═══██╗    ██╔══██╗██║   ██║██╔════╝██║  ██║██╔════╝██╔══██╗"
	echo -e "██████╔╝█████╗  ██████╔╝██║   ██║    ██████╔╝██║   ██║███████╗███████║█████╗  ██████╔╝"
	echo -e "██╔══██╗██╔══╝  ██╔═══╝ ██║   ██║    ██╔═══╝ ██║   ██║╚════██║██╔══██║██╔══╝  ██╔══██╗"
	echo -e "██║  ██║███████╗██║     ╚██████╔╝    ██║     ╚██████╔╝███████║██║  ██║███████╗██║  ██║"
	echo -e "╚═╝  ╚═╝╚══════╝╚═╝      ╚═════╝     ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝\n\n\n"
}

function help()
{
	echo -e "Thanks for using Repo Pusher !\n\n"
	echo -e "It is really simple to use. Here is how: \n"
	echo -e "./repo_pusher.sh [all]\n"
	echo -e "\t- With no argument, the script will ask you which files / directories you want to commit. You can press tab for auto completion."
	echo -e "\t  To see which files can be committed, type *'list'. To validate your files, type 'stop'.\n"
	echo -e "\t- If you want to add all files from the repository, type ./repo_pusher.sh all."
	echo -e "\n\n*'list': List shows you files' status: M for modified, D for deleted, ?? for created."
	exit
}

function add_directory()
{
	git add $file
	echo -e "${PURPLE}Directory '$file' correctly added."
	((nb_files++))
}

function add_files()
{
	echo -e "${ORANGE}List files you want to commit :"
        while [ true ]
        do
		read -e -p $'\e[033mEnter a filename: \e[0m' file
		if [ "$file" == "" ]
		then
			echo -e "${RED}Please enter a valid file.${NC}"
			continue;
		fi
                if [ "$file" == "stop" ]
                then
                        break
		fi
		if [ "$file" == "list" ]
		then
			git status -s
			continue
		fi
		if ! test -f $file && [ "$file" != "stop" ]
		then
			if [ -d $file ] && [ "$(git status | grep $file)" != "" ]
			then
				add_directory
				continue
			else
				echo -e "${RED}Please enter a valid file.${NC}"
				continue
			fi
		fi
		if [ "$(git status | grep $file)" == "" ]
		then
			echo -e "${RED}Nothing to do with this file!"
			continue
		fi
                if ! git add $file 2>/dev/null
                then
                        echo -e "${RED}Failed to add file !${NC}"
                        continue
                fi
                ((nb_files++))
	done
}

draw_ascii
if [ $# -eq 1 ] && [ "$1" == "-h" ]
then
	help
fi
echo -e "${GREEN}Let's push that repo!!"
nb_files=0
if [ "$1" == "all" ]
then
	git add .
	((nb_files++))
else
	add_files
fi

if [ $nb_files -eq 0 ]
then
	echo -e "${RED}You did not add any valid file :/"
	echo -e "Exiting.${NC}"
	exit
fi
echo -e "${PURPLE}Adding files ok."
echo -e "${CYAN}What's your commit message ?${NC}"
while [ true ]
do
	read commit_message
	if [ "$commit_message" != "" ]
	then
		break
	fi
	echo -e "${RED}Please enter a commit message.${NC}"
done
git commit -m "$commit_message" &>/dev/null
git push 2>/dev/null
echo -e "${PURPLE}Files correctly pushed with the message: '$commit_message' !${NC}"
