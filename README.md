# Conn

ssh 접속 편리성을 위한 CLI 툴

- 복잡한 명령 없이 SSH 접속을 간단하게 처리
- 서버 리스트를 효율적으로 관리

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
- server-1 (IP: 192.168.20.150, User: conn)
```

4. ssh 접속

```sh
conn connect server-1
Enter password: ****
Welcome to server-1!
```
