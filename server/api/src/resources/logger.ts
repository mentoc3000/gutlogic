type LogSeverity = "DEFAULT" | "DEBUG" | "INFO" | "NOTICE" | "WARNING" | "ERROR" | "CRITICAL" | "ALERT" | "EMERGENCY";
type JsonPayload = {
  severity: LogSeverity;
  message: string;
};

/// A logging class to write logs with the expected Cloud Run format for parsing
class Logger {
  private log(payload: JsonPayload) {
    const entry = Object.assign(payload);
    console.log(JSON.stringify(entry));
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
}

const log = new Logger();
export default log;
