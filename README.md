# Conn

ssh 접속 편리성을 위한 CLI 툴

## 사용법

1. 설정 파일 복사

```sh
cp config/config.sample.yaml ~/.config/conn/config.yaml
```

2. 설정 파일 작성

```yaml
# vi ~/.config/conn/config.yaml
server-1:
  - ip: 192.168.20.150
  - user: conn
```

3. 리스트 조회

```sh
conn list
Available servers:
- dev-controller-1 (IP: 192.168.0.1, User: admin)
- jenkins-build-1 (IP: 192.168.0.100, User: jenkins)
- server-1 (IP: 192.168.20.150, User: conn)
```

4. ssh 접속

```sh
conn connect rel-controller-1
Enter password:
```
