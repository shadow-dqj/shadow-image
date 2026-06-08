package health

import (
	"encoding/json"
	"net/http"
)

// Response is returned by the health endpoint.
type Response struct {
	Status  string `json:"status"`
	Service string `json:"service"`
}

// Handle writes a minimal health response for CI and local smoke checks.
func Handle(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(Response{
		Status:  "ok",
		Service: "shadow-image-api",
	})
}
