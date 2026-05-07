import { preferences } from '@kit.ArkData';
import { Logger } from './FileLoggerService';

const TAG = 'AuthService';
const PREFS_NAME = 'auth_session';
const KEY_LOGGED_IN = 'isLoggedIn';
const KEY_TOKEN = 'token';
const KEY_USER_ID = 'userId';
const KEY_NAME = 'name';
const KEY_EMAIL = 'email';
const KEY_AGE = 'age';

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
   * Must be awaited in EntryAbility.onWindowStageCreate BEFORE loadContent().
   */
  async init(context: Context): Promise<void> {
    try {
      this.prefs = await preferences.getPreferences(context, PREFS_NAME);
      const isLoggedIn = await this.prefs.get(KEY_LOGGED_IN, false) as boolean;
      const token = await this.prefs.get(KEY_TOKEN, '') as string;
      const userId = await this.prefs.get(KEY_USER_ID, 0) as number;
      const name = await this.prefs.get(KEY_NAME, '') as string;
      const email = await this.prefs.get(KEY_EMAIL, '') as string;
      const age = await this.prefs.get(KEY_AGE, 0) as number;

      AppStorage.setOrCreate<boolean>('isLoggedIn', isLoggedIn);
      AppStorage.setOrCreate<string>('authToken', token);
      AppStorage.setOrCreate<number>('userId', userId);
      AppStorage.setOrCreate<string>('userName', name);
      AppStorage.setOrCreate<string>('userEmail', email);
      AppStorage.setOrCreate<number>('userAge', age);
      AppStorage.setOrCreate<string>('registeredUser', name);
      Logger.info(TAG, `Session restored — loggedIn=${isLoggedIn}, user=${name}`);
    } catch (error) {
      Logger.error(TAG, `Failed to restore session: ${String(error)}`);
      AppStorage.setOrCreate<boolean>('isLoggedIn', false);
    }
  }

  /**
   * Persist a successful login to disk and AppStorage.
   */
  async saveSession(token: string, userId: number, name: string, email: string, age: number): Promise<void> {
    if (!this.prefs) {
      Logger.warn(TAG, 'Preferences not ready, session not persisted');
      return;
    }
    try {
      await this.prefs.put(KEY_LOGGED_IN, true);
      await this.prefs.put(KEY_TOKEN, token);
      await this.prefs.put(KEY_USER_ID, userId);
      await this.prefs.put(KEY_NAME, name);
      await this.prefs.put(KEY_EMAIL, email);
      await this.prefs.put(KEY_AGE, age);
      await this.prefs.flush();
      AppStorage.setOrCreate<string>('authToken', token);
      AppStorage.setOrCreate<number>('userId', userId);
      AppStorage.setOrCreate<string>('userName', name);
      AppStorage.setOrCreate<string>('userEmail', email);
      AppStorage.setOrCreate<number>('userAge', age);
      AppStorage.setOrCreate<string>('registeredUser', name);
      Logger.info(TAG, `Session saved for user: ${name}`);
    } catch (error) {
      Logger.error(TAG, `Failed to save session: ${String(error)}`);
    }
  }

  /**
   * Erase the persisted session from disk.
   */
  async clearSession(): Promise<void> {
    if (!this.prefs) {
      return;
    }
    try {
      await this.prefs.put(KEY_LOGGED_IN, false);
      await this.prefs.put(KEY_TOKEN, '');
      await this.prefs.put(KEY_USER_ID, 0);
      await this.prefs.put(KEY_NAME, '');
      await this.prefs.put(KEY_EMAIL, '');
      await this.prefs.flush();
      Logger.info(TAG, 'Session cleared');
    } catch (error) {
      Logger.error(TAG, `Failed to clear session: ${String(error)}`);
    }
  }
}
