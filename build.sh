rm x-ui
rm ./bin/x-ui.tar.gz
go build -ldflags "-w" -o x-ui main.go
tar -czvf ./bin/x-ui.tar.gz x-ui
rm x-ui