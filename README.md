# Bash port scanner

Port scanner written in Bash with `tail` being the only external binary. I wrote this around 2015 and forgot about it, found it now when wiping an old laptop and figured I might as well share it. I probably had no real use case for this more than having fun.

```console
$ ./port-scan.sh -h
Usage:
port-scan.sh [OPTIONS...] HOST
  -f  Number of forks. Defaults to 10.
  -h  This help message
  -r  Portrange to scan, e.g. 10-20. Defaults to 1-1024.
  -t  Seconds to wait for a response from a port. Defaults to 1.
  -v  More verbose output.
```

Example output and benchmark:

```console
$ time ./port-scan.sh 192.168.0.123
Scanning ports 1 to 1024 on 192.168.0.123...
22: is open
53: is open
139: is open
443: is open
445: is open

================
CPU	23%
user	1.069
system	3.026
total	17.292
```
