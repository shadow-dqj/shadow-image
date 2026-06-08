package main

import (
	"log"

	"github.com/wailsapp/wails/v3/pkg/application"
)

func main() {
	app := application.New(application.Options{
		Name:        "Shadow Image",
		Description: "Desktop ecommerce AI product image generator",
		Assets:     appAssets,
		Bind: []any{
			NewAppService(),
		},
		Mac: application.MacOptions{
			ApplicationShouldTerminateAfterLastWindowClosed: true,
		},
	})

	window := app.NewWebviewWindowWithOptions(application.WebviewWindowOptions{
		Title:            "Shadow Image",
		Width:            1280,
		Height:           800,
		MinWidth:         1024,
		MinHeight:        720,
		Centered:         true,
		BackgroundColour: application.NewRGB(255, 255, 255),
		URL:              "/",
	})

	window.Show()

	if err := app.Run(); err != nil {
		log.Fatal(err)
	}
}
