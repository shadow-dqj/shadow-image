package main

import (
	"fmt"

	"shadow-image/server/internal/config"
)

func main() {
	cfg := config.Load()
	fmt.Printf("shadow-image worker initialized with redis=%s\n", cfg.RedisAddr)
}
