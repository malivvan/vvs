package vvs

import (
	"github.com/dop251/goja_nodejs/buffer"
	"sync"
)

type WebAssembly struct {
	mutex sync.Mutex
}

func (w *WebAssembly) Instantiate(buf *buffer.Buffer, importObject map[string]interface{}) (interface{}, error) {
	return nil, nil
}

func (w *WebAssembly) Compile(buf *buffer.Buffer) (interface{}, error) {
	return nil, nil
}
