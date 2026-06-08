package config

import "os"

const (
	defaultAPIAddr   = ":8080"
	defaultRedisAddr = "localhost:6379"
)

// Config contains runtime configuration shared by API and worker entrypoints.
type Config struct {
	APIAddr   string
	RedisAddr string
}

// Load reads non-secret runtime configuration from environment variables.
// Secret-bearing configuration is intentionally not required by this scaffold.
func Load() Config {
	return Config{
		APIAddr:   getenv("API_ADDR", defaultAPIAddr),
		RedisAddr: getenv("REDIS_ADDR", defaultRedisAddr),
	}
}

func getenv(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}
