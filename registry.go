package vvs

import (
	"github.com/dop251/goja"
	"github.com/dop251/goja_nodejs/require"
)

var registry = func() interface {
	Enable(runtime *goja.Runtime) *require.RequireModule
	RegisterNativeModule(name string, loader require.ModuleLoader)
} {
	r := new(require.Registry)
	return r
}()
