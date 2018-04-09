.PHONY: all clean build run stop

all: build

build: cpu
	sudo docker build -t lyqscmy/app:v1 .

run:
	# sudo docker run --cpuset-cpus 0 --cpus=".5" -p 127.0.0.1:3333:3333 --name lyqscmy.app -it lyqscmy/app:v1
	sudo docker run -d --cpuset-cpus 0 --name lyqscmy.app lyqscmy/app:v1

echo-server: echo-server.go
	go build -o app echo-server.go

cpu: cpu.go
	go build -o app cpu.go
stop: 
	sudo docker stop lyqscmy.app

clean:
	sudo docker stop lyqscmy.app
	sudo docker container prune
	rm -f app
