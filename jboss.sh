#!/bin/bash
control_c(){
        tput clear
        rm -f /tmp/tempfile
        echo "Exiting..."
        exit 1
}
trap control_c SIGINT
if [ "$1" ]; then
        URL=$1
        VULN[0]=`curl -s -o "/dev/null" -w "%{http_code}" "$URL/jmx-console/HtmlAdaptor?action=inspectMBean&name=jbo$
        VULN[1]=`curl -s -o "/dev/null" -w "%{http_code}" "$URL/web-console/ServerInfo.jsp"` 
        VULN[2]=`curl -s -o "/dev/null" -w "%{http_code}" "$URL/invoker/JMXInvokerServlet"`
        for i in ${VULN[@]}; do
                if [[ $i == 200 ]]; then
                        echo "Vulnerable.."; break
                fi
        done
else
        echo "Usage: ./jboss.sh site.com.br"
fi
wait
