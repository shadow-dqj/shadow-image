package main

import (
	"path/filepath"
	"strings"
	"testing"
)

func TestGetAppDataDirUsesShadowImageDirectory(t *testing.T) {
	dir, err := getAppDataDir()
	if err != nil {
		t.Fatalf("getAppDataDir() error = %v", err)
	}

	if !strings.HasSuffix(filepath.Clean(dir), appDirName) {
		t.Fatalf("expected app data dir to end with %q, got %q", appDirName, dir)
	}
}

func TestAppServiceHealth(t *testing.T) {
	service := NewAppService()

	if got := service.Health(); got != "ok" {
		t.Fatalf("Health() = %q, want ok", got)
	}
}
