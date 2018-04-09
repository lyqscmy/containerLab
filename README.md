# 网络调试
容器的网络栈一般由Network Namespaces和veth pair决定。容器启动时会创建Network Namespaces和一对虚拟网卡，一端分配给前面创建的Network Namespaces，一端桥接到虚拟路由上。容器内进程的网络通信全部通过虚拟网卡与主机交互。

![](https://yeasy.gitbooks.io/docker_practice/content/advanced_network/_images/network.png)

只需要进入同样的Network Namespaces即可对容器内的网络栈进行调试。执行下面的命令会创建一个纯二进制echo-http-server。
```shell
make 
make run
```
然后通过[netshoot](https://github.com/nicolaka/netshoot)启动另外一个调试容器(包含ping，nslookup等工具)进入前面容器的Network Namespaces。
```shell
docker run -it --net container:<container_name> nicolaka/netshoot
```

这里只展示了docker的操作方法，其他方法原理类似，本质是进入容器的Network Namespaces。

# 资源管理
资源管理是通过[cgroups](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/resource_management_guide/chap-introduction_to_control_groups)实现。

容器启动会在/sys/fs/cgroup下各个controller的层级结构创建一个新的group，并把容器内的进程加入。所以只需要设置这个group下相应controller的值即可控制容器的资源使用。

修改Makefile，切换到CPU实验。执行下面命令会启动一个无限循环空跑的容器，并且固定在第一个核上。

```shell
make
make run
```

首先找到容器的pid
```shell
pgrep app
```
之后以root用户执行cg对cpu资源进行调控，cpus值的语义与[docker资源管理](https://docs.docker.com/config/containers/resource_constraints/#cpu)相似
```shell
./cg pid --cpus 0.5
```
执行之后cpu的使用率降低到50%以下。其他资源，memory，io，network类似。