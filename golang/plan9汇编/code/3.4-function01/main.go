package main

import "fmt"

func Swap(a, b int) (int, int)

func main() {
	a, b := 1, 2
	c, d := Swap(a, b)

	fmt.Println(c, d)
}
