#!/bin/bash
control_c(){
        tput clear
        rm -f /tmp/tempfile
	echo "Exiting..."
	exit 1
}
trap control_c SIGINT

exploit(){
	echo ${VULN[@]}
	exit 1
}
if [ "$1" ]; then
	VULN[0]=`curl -s -o "/dev/null" -w "%{http_code}" "$1/jmx-console/HtmlAdaptor?action=inspectMBean&name=jboss.system:type=ServerInfo"`
	VULN[1]=`curl -s -o "/dev/null" -w "%{http_code}" "$1/web-console/ServerInfo.jsp"`
	VULN[2]=`curl -s -o "/dev/null" -w "%{http_code}" "$1/invoker/JMXInvokerServlet"`
	for i in ${VULN[@]}; do
		if [[ $i == 200 || $i == 500 ]]; then
			echo "Vulnerable.."; exploit
		fi
	done
else
	echo "Usage: ./jboss.sh site.com.br"
fi
wait
