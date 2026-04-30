/**
 * Logger Service
 * Centralized logging via HiLog. All logs go to system HiLog only.
 *
 * To capture logs to a file on your PC, run:
 *   hdc hilog -T APP | tee E:\project\logs\session.log
 * Or filter by tag:
 *   hdc hilog -T APP -t S2DataAcquisition
 *
 * Log levels (lowest to highest):
 *   DETAIL - every function call, branch, variable value (hilog debug)
 *   DEBUG  - internal state, buffer sizes, periodic stats (hilog debug)
 *   INFO   - key events: session start/end, upload success (hilog info)
 *   WARN   - recoverable issues: V2 fallback, retry (hilog warn)
 *   ERROR  - failures: network error, validation failure (hilog error)
 *   FATAL  - unrecoverable: app crash (hilog fatal)
 *
 * Usage:
 *   import { Logger } from '../service/FileLoggerService';
 *   Logger.debug('MyModule', 'entering functionX');
 *   Logger.info('MyModule', 'session started');
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

export enum LogLevel {
  DETAIL = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  FATAL = 5,
}

// HiLog domain — use 0xFF00 so it's easy to filter: hdc hilog | grep "APP/"
const HILOG_DOMAIN = 0xFF00;
// Prefix all tags for easy filtering
const TAG_PREFIX = 'APP/';

class LoggerService {
  private minLevel: LogLevel = LogLevel.DETAIL;

  /**
   * Initialize the logger. No-op now (no file), but kept for API compatibility.
   */
  init(context: Context): void {
    hilog.info(HILOG_DOMAIN, TAG_PREFIX + 'Logger', 'Logger initialized (HiLog only). Use: hdc hilog | grep APP/');
  }

  setMinLevel(level: LogLevel): void {
    this.minLevel = level;
  }

  detail(tag: string, message: string): void {
    this.log(LogLevel.DETAIL, tag, message);
  }

  debug(tag: string, message: string): void {
    this.log(LogLevel.DEBUG, tag, message);
  }

  info(tag: string, message: string): void {
    this.log(LogLevel.INFO, tag, message);
  }

  warn(tag: string, message: string): void {
    this.log(LogLevel.WARN, tag, message);
  }

  error(tag: string, message: string): void {
    this.log(LogLevel.ERROR, tag, message);
  }

  fatal(tag: string, message: string): void {
    this.log(LogLevel.FATAL, tag, message);
  }

  /**
   * No-op now, kept for API compatibility.
   */
  close(): void {
    hilog.info(HILOG_DOMAIN, TAG_PREFIX + 'Logger', 'Logger closed');
  }

  /**
   * No-op now, kept for API compatibility.
   */
  getLogFilePath(): string {
    return '(HiLog only — use hdc hilog to capture)';
  }

  private log(level: LogLevel, tag: string, message: string): void {
    if (level < this.minLevel) {
      return;
    }

    const fullTag = TAG_PREFIX + tag;

    switch (level) {
      case LogLevel.DETAIL:
      case LogLevel.DEBUG:
        hilog.debug(HILOG_DOMAIN, fullTag, '%{public}s', message);
        break;
      case LogLevel.INFO:
        hilog.info(HILOG_DOMAIN, fullTag, '%{public}s', message);
        break;
      case LogLevel.WARN:
        hilog.warn(HILOG_DOMAIN, fullTag, '%{public}s', message);
        break;
      case LogLevel.ERROR:
        hilog.error(HILOG_DOMAIN, fullTag, '%{public}s', message);
        break;
      case LogLevel.FATAL:
        hilog.fatal(HILOG_DOMAIN, fullTag, '%{public}s', message);
        break;
    }
  }
}

export const Logger = new LoggerService();
