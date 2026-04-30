/**
 * Local Storage Service
 * Persists session history locally using @ohos.data.preferences.
 * [V2-TODO] When V2 is available, replace local persistence with V2 API calls:
 *   - saveSession() → POST /sessions/:id/results
 *   - getSessions() → GET /sessions?userId=...
 *   - getLatestSession() → GET /sessions?userId=...&limit=1&sort=desc
 */
import { preferences } from '@kit.ArkData';
import { Logger } from './FileLoggerService';
import { SessionData } from './RehabilitationService';

const TAG = 'LocalStorage';
const PREFERENCES_NAME = 'rehab_sessions';
const SESSIONS_KEY = 'session_history';

export class LocalStorageService {
  private static instance: LocalStorageService | null = null;
  private preferencesInstance: preferences.Preferences | null = null;
  private initialized: boolean = false;

  private constructor() {}

  static getInstance(): LocalStorageService {
    if (!LocalStorageService.instance) {
      LocalStorageService.instance = new LocalStorageService();
    }
    return LocalStorageService.instance;
  }

  /**
   * Initialize with application context. Must be called before other methods.
   */
  async init(context: Context): Promise<void> {
    if (this.initialized) {
      return;
    }
    try {
      this.preferencesInstance = await preferences.getPreferences(context, PREFERENCES_NAME);
      this.initialized = true;
      Logger.info(TAG, 'LocalStorageService initialized');
    } catch (error) {
      Logger.error(TAG, `Failed to init preferences: ${String(error)}`);
    }
  }

  /**
   * Save a completed session to local storage.
   */
  async saveSession(session: SessionData): Promise<void> {
    if (!this.preferencesInstance) {
      Logger.warn(TAG, 'Preferences not initialized, cannot save session');
      return;
    }
    try {
      const sessions = await this.getSessionsInternal();
      sessions.unshift(session); // newest first
      const json = JSON.stringify(sessions);
      await this.preferencesInstance.put(SESSIONS_KEY, json);
      await this.preferencesInstance.flush();
      Logger.info(TAG, `Session saved: ${session.sessionId}`);
    } catch (error) {
      Logger.error(TAG, `Failed to save session: ${String(error)}`);
    }
  }

  /**
   * Get all saved sessions (newest first).
   */
  async getSessions(): Promise<SessionData[]> {
    return this.getSessionsInternal();
  }

  /**
   * Get the most recent session, or null if none.
   */
  async getLatestSession(): Promise<SessionData | null> {
    const sessions = await this.getSessionsInternal();
    if (sessions.length > 0) {
      return sessions[0];
    }
    return null;
  }

  private async getSessionsInternal(): Promise<SessionData[]> {
    if (!this.preferencesInstance) {
      return [];
    }
    try {
      const json = await this.preferencesInstance.get(SESSIONS_KEY, '[]') as string;
      return JSON.parse(json) as SessionData[];
    } catch (error) {
      Logger.error(TAG, `Failed to read sessions: ${String(error)}`);
      return [];
    }
  }
}
