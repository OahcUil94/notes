package main

import (
	"unsafe"
)

type FooArgs struct {
	a bool
	b int16
	c []byte
}
type FooReturns struct {
	c []byte
}

func main() {
	Foo(&FooArgs{}, &FooReturns{})
}

func Foo(FP *FooArgs, FP_ret *FooReturns) {
	// a = FP + offsetof(&args.a)
	_ = unsafe.Offsetof(FP.a) + uintptr(unsafe.Pointer(FP))
	// b = FP + offsetof(&args.b)

	// argsize = sizeof(args)
	argsize := unsafe.Sizeof(FP)

	// c = FP + argsize + offsetof(&return.c)
	_ = uintptr(unsafe.Pointer(FP)) + argsize + unsafe.Offsetof(FP_ret.c)

	// framesize = sizeof(args) + sizeof(returns)
	_ = unsafe.Sizeof(FP) + unsafe.Sizeof(FP_ret)

	return
}
