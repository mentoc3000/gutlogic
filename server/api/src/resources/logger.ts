type LogSeverity = "DEFAULT" | "DEBUG" | "INFO" | "NOTICE" | "WARNING" | "ERROR" | "CRITICAL" | "ALERT" | "EMERGENCY";
type JsonPayload = {
  severity: LogSeverity;
  message: string;
};

/// A logging class to write logs with the expected Cloud Run format for parsing
class Logger {
  private show: boolean;

  constructor() {
    this.show = true;
  }

  private log(payload: JsonPayload) {
    if (this.show) {
      const entry = Object.assign(payload);
      console.log(JSON.stringify(entry));
    }
  }

  d(message: string) {
    this.log({ severity: "DEBUG", message });
  }

  i(message: string) {
    this.log({ severity: "INFO", message });
  }

  w(message: string) {
    this.log({ severity: "WARNING", message });
  }

  e(message: string) {
    this.log({ severity: "ERROR", message });
  }

  mute() {
    this.show = false;
  }
}

const log = new Logger();
export default log;
