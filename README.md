# Conn

ssh 접속 편리성을 위한 CLI 툴

## 사용법

```sh
cp config/config.sample.yaml config/config.yaml
```

```yaml
server-1:
  - ip: 192.168.20.150
  - user: conn
```

```sh
conn list
Available servers:
- dev-controller-1 (IP: 192.168.0.1, User: admin)
- jenkins-build-1 (IP: 192.168.0.100, User: jenkins)
- server-1 (IP: 192.168.20.150, User: conn)
```

```sh
conn connect rel-controller-1
Enter password:
```
