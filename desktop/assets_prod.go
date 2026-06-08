//go:build production

package main

import (
	"embed"

	"github.com/wailsapp/wails/v3/pkg/application"
)

//go:embed all:frontend/dist
var frontendAssets embed.FS

var appAssets = application.AssetOptions{
	FS: frontendAssets,
}
