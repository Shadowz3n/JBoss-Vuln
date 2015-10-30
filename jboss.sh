#!/bin/bash

control_c(){
        tput clear
        rm -f /tmp/tempfile
	echo "Exiting..."
	exit 1
}
trap control_c SIGINT # Ctrl+C

exploit(){
	tput clear
	echo "Loading exploit.. ${VULNLINK[$1]}"
	exit 1
}

if [ "$1" ]; then
	VULNLINK=("/jmx-console/HtmlAdaptor?action=inspectMBean&name=jboss.system:type=ServerInfo" "/web-console/ServerInfo.jsp" "/invoker/JMXInvokerServlet")
	VULNCHECK[0]=`curl -s -o "/dev/null" -w "%{http_code}" "$1${VULNLINK[0]}"`
	VULNCHECK[1]=`curl -s -o "/dev/null" -w "%{http_code}" "$1${VULNLINK[1]}"`
	VULNCHECK[2]=`curl -s -o "/dev/null" -w "%{http_code}" "$1${VULNLINK[2]}"`
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
