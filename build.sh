rm ./bin/x-ui.tar.xz
go build -ldflags "-w" -o x-ui main.go
tar -I 'xz -9 -T0' -cf ./bin/x-ui.tar.xz x-ui
rm x-ui