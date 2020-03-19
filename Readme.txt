根据：

https://stackoverflow.com/questions/41556813/indy-tcp-hole-punching-10061-connection-refused

的说法，采用 Indy 的 TCP 控件是可以去做 TCP 打洞的。

这里测试一下。

首先测试同一个程序的 TCPServer 和 TCPClient 占用同一个端口。

设置 Indy 的 TCPServer 和 TCPClient 的控件的 ReuseSocket 的属性为 True，TCP Server 可以监听一个端口，TCPClient 同时可以在此端口上打开一个向外部的服务器的连接，也就是设置 TCPClient 的 Binding 的 Port 属性。或者设置其 BoundPort 属性。

这样，客户端的 TCPClient 的本地端口，向外发起连接，使得 NAT 对该客户端的该端口打开了一个洞。然后，当其它客户端针对该端口发起TCP连接时，工作在该端口上的 TCPServer 就可以被连接成功。

TCP Client 和 TCP Server 绑定同一个本地端口，测试成功。

NAT punching 测试结果：目前在我自己的 NAT 上测试不成功。

另：在我的 WIN10 上面，客户端程序的 IdTCPServer1 和 IdTCPClient1 和 IdTCPClient2 同时绑定同一个本地端口，程序有时候能够工作，有时候 IdTCPClient1 无法连接服务器，会出现 access denied 的异常。

因此，看起来 TCP 打洞并不实用。所以暂时停止继续测试。先把代码留存，以后有时间再测试。