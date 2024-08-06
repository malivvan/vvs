package main

import (
	"github.com/malivvan/vvs"
	"os"
)

func main() {
	vm := vvs.Runtime()
	for _, arg := range os.Args[1:] {
		src, err := os.ReadFile(arg)
		check(err)
		_, err = vm.RunScript(arg, string(src))
		check(err)
	}
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
