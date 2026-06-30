package ai

import (
	"regexp"
)

var (
	emailRegex = regexp.MustCompile(`[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}`)
	phoneRegex = regexp.MustCompile(`(\+?\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}`)
)

type Scrubber struct{}

func (s *Scrubber) Scrub(text string) string {
	scrubbed := emailRegex.ReplaceAllString(text, "[EMAIL]")
	scrubbed = phoneRegex.ReplaceAllString(scrubbed, "[PHONE]")
	return scrubbed
}
