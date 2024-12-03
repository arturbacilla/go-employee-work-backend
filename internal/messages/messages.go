package messages

import (
	"fmt"
	"log"

	"github.com/fatih/color"
)

var red = color.New(color.FgRed).SprintFunc()
var yellow = color.New(color.FgYellow).SprintFunc()
var cyan = color.New(color.FgCyan).SprintFunc()
var green = color.New(color.FgHiGreen).SprintFunc()

func MsgError(msg string) string {
	log.Fatalf("%s: %s", red("[ERROR]"), msg)
	return fmt.Sprintf("%s: %s", red("[ERROR]"), msg)
}

func MsgWarn(msg string) string {
	log.Printf("%s: %s", yellow("[WARN]"), msg)
	return fmt.Sprintf("%s: %s", yellow("[WARN]"), msg)

}

func MsgInfo(msg string) string {
	log.Printf("%s: %s", cyan("[INFO]"), msg)
	return fmt.Sprintf("%s: %s", cyan("[INFO]"), msg)
}

func MsgSuccess(msg string) string {
	log.Printf("%s: %s", green("[SUCCESS]"), msg)
	return fmt.Sprintf("%s: %s", green("[SUCCESS]"), msg)
}
