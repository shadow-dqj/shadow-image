package main

import (
	"os"
	"path/filepath"
	"runtime"
)

const appDirName = "ShadowImage"

// AppService exposes basic desktop bridge methods used by the Vue frontend.
// It intentionally keeps API keys and provider calls out of the frontend layer.
type AppService struct{}

// NewAppService creates the root Wails bridge service.
func NewAppService() *AppService {
	return &AppService{}
}

// GetAppDataDir returns the cross-platform application data directory.
func (s *AppService) GetAppDataDir() (string, error) {
	return getAppDataDir()
}

// EnsureAppDataDir creates the application data directory if needed and returns it.
func (s *AppService) EnsureAppDataDir() (string, error) {
	dir, err := getAppDataDir()
	if err != nil {
		return "", err
	}

	if err := os.MkdirAll(dir, 0o700); err != nil {
		return "", err
	}

	return dir, nil
}

// Health returns a simple readiness marker for bridge smoke checks.
func (s *AppService) Health() string {
	return "ok"
}

func getAppDataDir() (string, error) {
	var baseDir string

	switch runtime.GOOS {
	case "windows":
		baseDir = os.Getenv("APPDATA")
		if baseDir == "" {
			baseDir = os.Getenv("LOCALAPPDATA")
		}
	case "darwin":
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		baseDir = filepath.Join(homeDir, "Library", "Application Support")
	default:
		baseDir = os.Getenv("XDG_DATA_HOME")
		if baseDir == "" {
			homeDir, err := os.UserHomeDir()
			if err != nil {
				return "", err
			}
			baseDir = filepath.Join(homeDir, ".local", "share")
		}
	}

	if baseDir == "" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		baseDir = homeDir
	}

	return filepath.Join(baseDir, appDirName), nil
}
