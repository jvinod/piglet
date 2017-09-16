package tasK

import (
	"time"
)

const (
	// UptimeDefault number of seconds after which a process is assumed to
	// be up.
	UptimeDefault = 30 * time.Second
)

// RestartPolicy defines behavior if a process exits.
const (
	// RestartImmediate restart the process immediately after it exits.
	RestartImmediate = "immediate"
	// RestartBackoff exponential backoff.
	RestartBackoff = "backoff"
	// Restart after specific number of seconds.
	RestartPeriodic = "periodic"
	// RestartNever don't restart if the process exits.
	RestartNever = "never"
)

// Process is the representation of a process to be run.
type Process struct {
	// Name friendly name, referencable across processes.
	Name string `json:"name" yaml:"name"`

	// Cmd absolute path to command.
	Cmd string `json:"cmd" yaml:"cmd"`

	// Requires specifies the process that must be running before this
	// process is running. This is optional.
	Requires string `json:"requires,omitempty" yaml:"requires"`

	// After specifies the order in which this process is started with
	// respect to another process. Note that this does not ensure that
	// the dependent process is up and running. Use requires for that.
	After string `json:"after,omitempty" yaml:"after"`

	// The status URL specifies a URL to ping to see if this service is
	// up. This must conform to the piglet REST api expectation.
	StatusURL string `json:"status_url,omitempty" yaml:"status_url"`

	// Uptime specifies the number of seconds after which it is safe
	// to conclude that the process is up. Default is UptimeDefault.
	Uptime int `json:"uptime,omitempty" yaml:"uptime"`

	// Retries specifies how many times to retry if the process keeps
	// exiting within uptime.
	Retires int `json:"retries,omitempty" yaml:"retries"`

	// Rescue process to run if this process refuses to startup.
	Rescue string `json:"rescue,omitempty" yaml:"rescue"`

	// RestartPolicy is one of defined RestartPolicy constants. Default is
	// RestartBackoff.
	RestartPolicy string `json:"restart_policy,omitempty" yaml:"restart_policy"`

	// RestartInterval number of seconds after which the process should be
	// restarted. This only applies if RestartPolicy is RestartInterval
	RestartInterval string `json:"restart_interval,omitempty" yaml:"restart_interval"`
}
