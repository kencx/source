+++
title = "How to test network connectivity without nc or telnet"
date = "2026-08-11"
updated = 2026-10-20

[taxonomies]
tags = [ "linux", "networking", "bash" ]
+++

Using Bash:

```sh
echo > /dev/tcp/127.0.0.1/80 && echo "PORT OPEN" || echo "PORT CLOSED"
echo > /dev/udp/127.0.0.1/53 && echo "PORT OPEN" || echo "PORT CLOSED"
```

If the port is closed, the above command(s) will hang. Pairing with `timeout`,
we can ensure an output is always returned:

```sh
(timeout 1 bash -c '</dev/tcp/127.0.0.1/80 && echo PORT OPEN || echo PORT CLOSED') 2>/dev/null
```

## Bonus: HTTP requests via /dev/tcp

[HTTP requests are also possible](https://rednafi.com/misc/http-requests-via-dev-tcp/).

{% <details summary="Copied shameless from above for archival purposes"> %}
```sh
#!/bin/bash

# Open TCP connection to example.com:80 and assign file descriptor 3
# exec keeps /dev/fd/3 open; 3<> enables bidirectional read-write
exec 3<>/dev/tcp/example.com/80

# Send the HTTP GET request to the server (>& redirects to /dev/fd/3)
echo -e \
    "GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n" >&3

# Read and print the server's response
# <& redirects the output of /dev/fd/3 to cat
cat <&3

# Close the file descriptor, terminating the TCP connection
exec 3>&-
```
{% </details> %}

## References

- [bash (1)](https://www.mankier.com/1/bash#Redirection-/dev/tcp/host/port)
- [rednafi - HTTP requests via /dev/tcp](https://rednafi.com/misc/http-requests-via-dev-tcp/)
