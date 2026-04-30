/**
 * S2 V2 HTTP Client
 * Handles HTTP communication with V2 backend (IF-S2-V2).
 * Endpoints per negotiated spec (Section 4 conflicts resolved).
 *
 * All methods carry the user Token in the Authorization header per SRS IUC-S2-02-01 step 3.
 * V2 currently has no authentication (Conflict 9), so the token is ignored by V2,
 * but S2 must send it to comply with the SRS.
 */
import { http } from '@kit.NetworkKit';
import { Logger } from '../service/FileLoggerService';
import { FormatData, SensorSample, TargetAngle, ErrorEvent } from './S2DataModels';

const TAG = 'S2V2HttpClient';

// V2 backend base URL
const V2_BASE_URL = 'https://dsd2026-teamv2-production.up.railway.app';

// HTTP timeout in milliseconds (SRS IUC-S2-02-01 Alternative 9: V2 long unresponsive)
const HTTP_CONNECT_TIMEOUT_MS = 10000;
const HTTP_READ_TIMEOUT_MS = 10000;

/**
 * Convert Unix millisecond timestamp to ISO 8601 string.
 * V2 uses ISO 8601 (Conflict 6 resolution).
 */
function toISO8601(timestampMs: number): string {
  const date = new Date(timestampMs);
  return date.toISOString();
}

// ArkTS requires explicit class/interface for object literals

class TargetAnglePayload {
  timestamp: string = '';
  angleID: string = '';
  angle: number = 0;
}

class ErrorPayload {
  timestamp: string = '';
  sensorId: string | null = null;
  errorType: string = '';
  message: string = '';
}

class SensorDataPayload {
  timestamp: string = '';
  sensorId: string = '';
  accX: number = 0;
  accY: number = 0;
  accZ: number = 0;
  gyroX: number = 0;
  gyroY: number = 0;
  gyroZ: number = 0;
  roll: number = 0;
  pitch: number = 0;
  yaw: number = 0;
}

class MeasurementPayload {
  sessionID: number = 0;
  targetAngles: TargetAnglePayload[] = [];
  errors: ErrorPayload[] = [];
  sensorData: SensorDataPayload[] = [];
}

class CreateSessionPayload {
  userId: number = 0;
}

function buildTargetAnglePayload(ta: TargetAngle): TargetAnglePayload {
  const p = new TargetAnglePayload();
  p.timestamp = toISO8601(ta.timestamp);
  p.angleID = ta.angleID;
  p.angle = ta.angle;
  return p;
}

function buildErrorPayload(e: ErrorEvent): ErrorPayload {
  const p = new ErrorPayload();
  p.timestamp = toISO8601(e.timestamp);
  p.sensorId = e.sensorId;
  p.errorType = e.errorType;
  p.message = e.message;
  return p;
}

function buildSensorDataPayload(s: SensorSample): SensorDataPayload {
  const p = new SensorDataPayload();
  p.timestamp = toISO8601(s.timestamp);
  p.sensorId = s.deviceId;
  p.accX = s.accX;
  p.accY = s.accY;
  p.accZ = s.accZ;
  p.gyroX = s.gyroX;
  p.gyroY = s.gyroY;
  p.gyroZ = s.gyroZ;
  p.roll = s.roll;
  p.pitch = s.pitch;
  p.yaw = s.yaw;
  return p;
}

export class S2V2HttpClient {
  private static instance: S2V2HttpClient | null = null;
  private baseUrl: string = V2_BASE_URL;

  private constructor() {}

  static getInstance(): S2V2HttpClient {
    if (!S2V2HttpClient.instance) {
      S2V2HttpClient.instance = new S2V2HttpClient();
    }
    return S2V2HttpClient.instance;
  }

  /**
   * Create a new session on V2.
   * POST /sessions with {userId} (Conflict 3: use V2's design)
   * Returns server-generated integer session ID (Conflict 8: server auto-increment)
   * Expects 201 Created (Conflict 9: use V2's status codes)
   *
   * @param userId User ID referencing V2 users table
   * @param token User auth token for Authorization header (SRS IUC-S2-02-01 step 3)
   */
  async createSession(userId: number, token: string): Promise<number> {
    const url = `${this.baseUrl}/sessions`;
    const payload = new CreateSessionPayload();
    payload.userId = userId;
    const body = JSON.stringify(payload);

    Logger.info(TAG, `Creating session for userId=${userId}`);

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        extraData: body,
        connectTimeout: HTTP_CONNECT_TIMEOUT_MS,
        readTimeout: HTTP_READ_TIMEOUT_MS,
      });

      if (response.responseCode === 201) {
        const responseBody = JSON.parse(response.result as string) as Record<string, Object>;
        // V2 response uses snake_case (Conflict 7)
        const sessionId = responseBody['id'] as number || responseBody['session_id'] as number;
        Logger.info(TAG, `Session created: id=${sessionId}`);
        return sessionId;
      } else {
        Logger.error(TAG, `Create session failed: ${response.responseCode} ${response.result as string}`);
        throw new Error(`Create session failed: HTTP ${response.responseCode}`);
      }
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * Upload a batch of measurements to V2.
   * POST /measurements/batch (Conflict 1: use V2's endpoint path)
   * Uses negotiated format from Conflict 4 resolution.
   * Carries Token and session meta data for authentication (SRS IUC-S2-02-01 step 3).
   *
   * Throws on network failure (SRS IUC-S2-02-01 Alternative 3).
   * Throws on V2 verification failure / non-success status (SRS IUC-S2-02-01 Alternative 7).
   *
   * @param sessionId Server-generated session ID
   * @param data FormatData to upload
   * @param token User auth token
   */
  async uploadMeasurements(sessionId: number, data: FormatData, token: string): Promise<void> {
    const url = `${this.baseUrl}/measurements/batch`;

    // Build payload with typed classes (ArkTS requires explicit types)
    const payload = new MeasurementPayload();
    payload.sessionID = sessionId;

    const taList: TargetAnglePayload[] = [];
    for (const ta of data.targetAngles) {
      taList.push(buildTargetAnglePayload(ta));
    }
    payload.targetAngles = taList;

    if (data.errors.length > 0) {
      const errList: ErrorPayload[] = [];
      for (const e of data.errors) {
        errList.push(buildErrorPayload(e));
      }
      payload.errors = errList;
    }

    if (data.sensorData.length > 0) {
      const sdList: SensorDataPayload[] = [];
      for (const s of data.sensorData) {
        sdList.push(buildSensorDataPayload(s));
      }
      payload.sensorData = sdList;
    }

    const body = JSON.stringify(payload);
    Logger.debug(TAG, `Upload request body (first 500 chars): ${body.substring(0, 500)}`);

    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        extraData: body,
        connectTimeout: HTTP_CONNECT_TIMEOUT_MS,
        readTimeout: HTTP_READ_TIMEOUT_MS,
      });

      if (response.responseCode === 201 || response.responseCode === 200) {
        Logger.debug(TAG, `Measurements uploaded: ${data.sensorData.length} samples, ${data.targetAngles.length} angles`);
      } else {
        // SRS IUC-S2-02-01 Alternative 7: V2 verification fails
        const responseBody = response.result ? String(response.result) : 'no body';
        Logger.error(TAG, `V2 rejected upload: HTTP ${response.responseCode}, body: ${responseBody}`);
        throw new Error(`V2 rejected upload: HTTP ${response.responseCode}, body: ${responseBody}`);
      }
    } catch (error) {
      // SRS IUC-S2-02-01 Alternative 3: Network transmission fails
      // Re-throw so caller (S2DataAcquisitionService) can handle error propagation
      Logger.error(TAG, `Upload measurements failed: ${String(error)}`);
      throw new Error(`Upload measurements failed: ${String(error)}`);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * End a session on V2.
   * PATCH /sessions/:id/end (Conflict 2: use PATCH, Conflict 5: no body)
   * Note: HarmonyOS http module may not have PATCH, use PUT as fallback with
   * custom header to indicate PATCH semantics.
   *
   * @param sessionId Server-generated session ID
   * @param token User auth token
   */
  async endSession(sessionId: number, token: string): Promise<void> {
    const url = `${this.baseUrl}/sessions/${sessionId}/end`;

    Logger.info(TAG, `Ending session: id=${sessionId}`);

    const httpRequest = http.createHttp();
    try {
      // Use PUT as the closest available method; V2 should accept both PATCH and PUT
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        header: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
          'X-HTTP-Method-Override': 'PATCH',
        },
        connectTimeout: HTTP_CONNECT_TIMEOUT_MS,
        readTimeout: HTTP_READ_TIMEOUT_MS,
      });

      if (response.responseCode === 200) {
        Logger.info(TAG, `Session ended successfully: id=${sessionId}`);
      } else {
        Logger.warn(TAG, `End session response: ${response.responseCode}`);
      }
    } catch (error) {
      Logger.error(TAG, `End session failed: ${String(error)}`);
      throw new Error(`End session failed: ${String(error)}`);
    } finally {
      httpRequest.destroy();
    }
  }
}
