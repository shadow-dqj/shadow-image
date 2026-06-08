package config

import "testing"

func TestLoadUsesDefaults(t *testing.T) {
	t.Setenv("API_ADDR", "")
	t.Setenv("REDIS_ADDR", "")

	cfg := Load()
	if cfg.APIAddr != defaultAPIAddr {
		t.Fatalf("expected default API addr %q, got %q", defaultAPIAddr, cfg.APIAddr)
	}
	if cfg.RedisAddr != defaultRedisAddr {
		t.Fatalf("expected default Redis addr %q, got %q", defaultRedisAddr, cfg.RedisAddr)
	}
}

func TestLoadUsesEnvironment(t *testing.T) {
	t.Setenv("API_ADDR", ":9090")
	t.Setenv("REDIS_ADDR", "redis.example:6379")

	cfg := Load()
	if cfg.APIAddr != ":9090" {
		t.Fatalf("expected env API addr, got %q", cfg.APIAddr)
	}
	if cfg.RedisAddr != "redis.example:6379" {
		t.Fatalf("expected env Redis addr, got %q", cfg.RedisAddr)
	}
}
