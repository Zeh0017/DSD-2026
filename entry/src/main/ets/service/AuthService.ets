/**
 * AuthService — Persistent session management.
 *
 * WHY THIS EXISTS:
 *   AppStorage is in-memory only and is wiped on every app restart. Without this
 *   service, the user is forced to log in every time the app is opened.
 *
 * HOW IT WORKS:
 *   Login state (isLoggedIn, username) is written to @ohos.data.preferences,
 *   which survives app restarts. On each launch, EntryAbility calls init()
 *   before loading the UI, so AppStorage is already populated with the correct
 *   session state when the first page renders.
 *
 * LIFECYCLE:
 *   1. EntryAbility.onWindowStageCreate  → AuthService.init(context)
 *      Reads persisted state and writes it into AppStorage.
 *   2. ProfilePage.handleLogin           → AuthService.saveSession(username)
 *      Writes the new session to disk after a successful login.
 *   3. ProfilePage.handleLogout          → AuthService.clearSession()
 *      Removes the session from disk so the next launch starts unauthenticated.
 *
 * EXTENSION POINT:
 *   When V2 authentication is implemented, replace the boolean isLoggedIn flag
 *   with a JWT token and expiry timestamp. Add a isTokenExpired() check inside
 *   init() to invalidate sessions that have exceeded the server's TTL.
 */
import { preferences } from '@kit.ArkData';
import { Logger } from './FileLoggerService';

const TAG = 'AuthService';
const PREFS_NAME = 'auth_session';
const KEY_LOGGED_IN = 'isLoggedIn';
const KEY_USERNAME = 'username';

export class AuthService {
  private static instance: AuthService | null = null;
  private prefs: preferences.Preferences | null = null;

  private constructor() {}

  static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * Restore session from disk into AppStorage.
   * Must be awaited in EntryAbility.onWindowStageCreate BEFORE loadContent()
   * so the UI receives the correct login state on first render.
   */
  async init(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, PREFS_NAME);
      const isLoggedIn = await this.prefs.get(KEY_LOGGED_IN, false) as boolean;
      const username = await this.prefs.get(KEY_USERNAME, '') as string;

      AppStorage.setOrCreate<boolean>('isLoggedIn', isLoggedIn);
      if (isLoggedIn && username.length > 0) {
        AppStorage.setOrCreate<string>('registeredUser', username);
      }
      Logger.info(TAG, `Session restored — loggedIn=${isLoggedIn}, user=${username}`);
    } catch (error) {
      Logger.error(TAG, `Failed to restore session: ${String(error)}`);
      AppStorage.setOrCreate<boolean>('isLoggedIn', false);
    }
  }

  /**
   * Persist a successful login to disk.
   * Call immediately after the user authenticates.
   */
  async saveSession(username: string): Promise<void> {
    if (!this.prefs) {
      Logger.warn(TAG, 'Preferences not ready, session not persisted');
      return;
    }
    try {
      await this.prefs.put(KEY_LOGGED_IN, true);
      await this.prefs.put(KEY_USERNAME, username);
      await this.prefs.flush();
      Logger.info(TAG, `Session saved for user: ${username}`);
    } catch (error) {
      Logger.error(TAG, `Failed to save session: ${String(error)}`);
    }
  }

  /**
   * Erase the persisted session from disk.
   * Call on explicit logout so the next app launch starts unauthenticated.
   */
  async clearSession(): Promise<void> {
    if (!this.prefs) {
      return;
    }
    try {
      await this.prefs.put(KEY_LOGGED_IN, false);
      await this.prefs.put(KEY_USERNAME, '');
      await this.prefs.flush();
      Logger.info(TAG, 'Session cleared');
    } catch (error) {
      Logger.error(TAG, `Failed to clear session: ${String(error)}`);
    }
  }
}
