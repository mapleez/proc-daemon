# proc-daemon

***proc-daemon*** is a daemon process written by perl. And is used to monitor server-side daemon programms. We use as simple as possible configurable interface for user. At this version **0.0.8** we juse check whether the configured programs is running normally, with process name and pid. Maybe some new usable features shell be added.

### Configuration
***proc-daemon*** has two config file named **daemon.conf** and **proc.conf**. The first one configures proc-daemon itself, and another one configures your daemon programs running on server, to be monitored. 

##### 1) daemon.conf
Configure for ***proc-daemon*** with all the items below in this version.
* ```stdout_file``` : The file that ***proc-daemon*** will redirect __STDOUT__ here. We just use `logs/out.log` as default.
* ```stderr_file``` : The file that ***proc-daemon*** will redirect __STDERR__ here. We just use `logs/err.log` as default.
* ```pid_file``` : The pid file for ***proc-daemon***, `data/daemon.pid` as default.
* ```proc_conf``` : The configuration file name for monitored daemon programs, `conf/proc.conf` as default.
* ```interval``` : The interval for checking loop. In fact, ***proc-daemon*** runs the main ``while (true)`` loop and check all the configured daemon programs in order. In each loop we simply invoke ``sleep ($INTERVAL)`` function ;)

##### 2) proc.conf
A plain-text file which lists daemon programs on which your ***proc-daemon*** should monitor, one program per line. Each line contains 2 fields :
```markdown
process_name   handle_script
```
Note: the __process_name__ shell be `grep`ed with JPS (A JVM process) or `ps -e`; And __handle_script__ shell be a non-block script (e.g. A daemon, or one which shell return at a short time.). The format is alike below :
```markdown
Alarmer     /opt/deploy/ez/Alarmer1.0.2/restart.sh
RedisConsumer    /home/redisusr/RedisConsumer2.3.4/start.sh

# TestDaemon     /opt/test/daemon.sh
```

### Usage
When you finished configuring, it's time to run ***proc-daemon***.
```markdown
perl daemon.pl
```
And when you wanna kill it. You shell use `ps -e` and find the perl process, kill it ;) . We'll improve it in the future.


### Dependency and Environment
Now this version only depends on perl module `Config::Tiny`. And we've added into dep/. 
We've tested it on **Ubuntu desktop 16.04** and **CentOS 7**.

### Author info
* ez's CSDN blog [http://blog.csdn.net/u012842205](http://blog.csdn.net/u012842205)
* ez's Tencent Email [1786428321@qq.com](mailto://1786428321@qq.com)
* ez's 126 Email [kukunanhai_5207@126.com](mailto://kukunanhai_5207@126.com)

***Enjoy it :)***

