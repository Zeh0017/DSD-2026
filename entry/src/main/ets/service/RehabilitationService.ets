/**
 * Rehabilitation training service
 * Handle session creation, data stream, end logic
 * Integrates S2 Data Acquisition pipeline for real sensor data.
 */
import { Logger } from './FileLoggerService';
// [S1-REAL] Uncomment when real BLE sensor management is needed in M1:
// import { BleSensorManager, SensorConnectionState } from './BleManager';
import { S2DataAcquisitionService } from '../s2/S2DataAcquisitionService';
import { S1SensorAdapter } from '../s2/S1SensorAdapter';
import { S2V2HttpClient } from '../s2/S2V2HttpClient';
import { LocalStorageService } from './LocalStorageService';
import { FormatData, TargetAngle, ErrorEvent } from '../s2/S2DataModels';

export interface ExercisePlan {
  exerciseId: string;
  exerciseName: string;
  description: string;
  durationMinutes: number;
  targetJointAngles?: JointAngles;
}

export interface JointAngles {
  knee?: number;
  hip?: number;
  ankle?: number;
}

export interface SessionData {
  sessionId: string;
  serverSessionId?: number;
  exerciseId: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  scores?: number[];
  averageScore?: number;
}

export interface RealtimeRecognitionResult {
  jointAngles: JointAngles;
  deviationScores: DeviationScores;
  alertFlags: AlertFlag[];
  confidence: number;
  timestamp: number;
}

export interface DeviationScores {
  knee?: number;
  hip?: number;
  ankle?: number;
  overall: number;
}

export interface AlertFlag {
  type: AlertType;
  severity: 'low' | 'medium' | 'high';
  message: string;
  joint?: string;
}

export type AlertType = 'angle_deviation' | 'tracking_uncertain' | 'signal_weak' | 'connection_lost';

export type SessionState = 'idle' | 'connecting' | 'active' | 'paused' | 'ended';

export type SessionCallback = (state: SessionState, data?: SessionData) => void;
export type RealtimeDataCallback = (result: RealtimeRecognitionResult) => void;
export type AlertCallback = (alert: AlertFlag) => void;

export class RehabilitationService {
  private static instance: RehabilitationService | null = null;
  // [S1-REAL] Uncomment when real BLE sensor management is needed in M1:
  // private bleManager: BleSensorManager;
  private s1Adapter: S1SensorAdapter;
  private s2Service: S2DataAcquisitionService;
  private v2Client: S2V2HttpClient;
  private localStorage: LocalStorageService;
  private currentSession: SessionData | null = null;
  private sessionState: SessionState = 'idle';
  private currentExercise: ExercisePlan | null = null;
  private sessionCallbacks: Set<SessionCallback> = new Set();
  private realtimeCallbacks: Set<RealtimeDataCallback> = new Set();
  private alertCallbacks: Set<AlertCallback> = new Set();
  private reconnectAttempts: number = 0;
  private maxReconnectAttempts: number = 5;
  private reconnectTimer: number | null = null;
  private dataStreamTimer: number | null = null;

  private constructor() {
    // [S1-REAL] Uncomment when real BLE sensor management is needed in M1:
    // this.bleManager = BleSensorManager.getInstance();
    this.s1Adapter = S1SensorAdapter.getInstance();
    this.s2Service = S2DataAcquisitionService.getInstance();
    this.v2Client = S2V2HttpClient.getInstance();
    this.localStorage = LocalStorageService.getInstance();
  }

  static getInstance(): RehabilitationService {
    if (!RehabilitationService.instance) {
      RehabilitationService.instance = new RehabilitationService();
    }
    return RehabilitationService.instance;
  }

  /**
   * Initialize service
   */
  async init(context: Context): Promise<void> {
    Logger.debug('RehabService', 'init() called');
    // [S1-REAL] Uncomment when real BLE sensor management is needed in M1:
    // this.bleManager.init(context);
    await this.localStorage.init(context);
    Logger.debug('RehabService', 'init() done');
  }

  /**
   * Register session state callback
   */
  onSessionStateChange(callback: SessionCallback): void {
    this.sessionCallbacks.add(callback);
  }

  /**
   * Unregister session state callback
   */
  offSessionStateChange(callback: SessionCallback): void {
    this.sessionCallbacks.delete(callback);
  }

  /**
   * Register realtime data callback
   */
  onRealtimeData(callback: RealtimeDataCallback): void {
    this.realtimeCallbacks.add(callback);
  }

  /**
   * Unregister realtime data callback
   */
  offRealtimeData(callback: RealtimeDataCallback): void {
    this.realtimeCallbacks.delete(callback);
  }

  /**
   * Register alert callback
   */
  onAlert(callback: AlertCallback): void {
    this.alertCallbacks.add(callback);
  }

  /**
   * Unregister alert callback
   */
  offAlert(callback: AlertCallback): void {
    this.alertCallbacks.delete(callback);
  }

  /**
   * Start training session
   * Integrates S2: creates V2 session, starts S2 data acquisition.
   * @param exercise Exercise plan
   * @returns Whether session started successfully
   */
  async startSession(exercise: ExercisePlan): Promise<boolean> {
    Logger.debug('RehabService', `startSession() called: exerciseId=${exercise.exerciseId}, currentState=${this.sessionState}`);

    if (this.sessionState === 'active') {
      Logger.warn('RehabService', 'Session already active, returning false');
      return false;
    }

    // Sensor connection check is handled by S2→S1 chain, not M1 directly.
    // [S1-REAL] Uncomment to re-enable M1 BLE precheck:
    // if (!this.bleManager.isConnected()) {
    //   Logger.error('RehabService', 'Sensor not connected');
    //   return false;
    // }

    this.currentExercise = exercise;
    this.sessionState = 'connecting';
    this.notifySessionStateChange('connecting');
    Logger.info('RehabService', `Starting session for exercise: ${exercise.exerciseId} (${exercise.exerciseName})`);

    try {
      // [V2-TODO] Replace hardcoded userId with V2 auth response:
      // const userId = AppStorage.get<number>('userId');
      const userId: number = 1;

      // [V2-TODO] Replace empty token with V2 auth token:
      // const token = AppStorage.get<string>('authToken') ?? '';
      const token: string = '';

      Logger.debug('RehabService', `userId=${userId}, token=${token ? 'present' : 'empty'}`);

      // [V2-TODO] V2 creates session and returns server-generated ID.
      // When V2 is unavailable, use local fallback.
      let serverSessionId: number;
      try {
        serverSessionId = await this.v2Client.createSession(userId, token);
        Logger.info('RehabService', `V2 session created: id=${serverSessionId}`);
      } catch (error) {
        Logger.warn('RehabService',
          `V2 session creation failed, using local fallback: ${String(error)}`);
        serverSessionId = Math.floor(Date.now() / 1000);
      }

      // sensorJointMapping is optional per M1-S2 negotiation.
      // [S1-REAL] Build from real connected device:
      // const deviceId = this.bleManager.getConnectedDeviceId();
      // let sensorJointMapping: Record<string, string> | undefined = undefined;
      // if (deviceId) {
      //   sensorJointMapping = {};
      //   sensorJointMapping[deviceId] = 'knee';
      // }
      const sensorJointMapping: Record<string, string> | undefined = undefined;

      Logger.debug('RehabService', `Calling S2.start(sessionId=${serverSessionId}, userId=${userId}, mapping=${JSON.stringify(sensorJointMapping)}, payload=${exercise.exerciseId})`);
      // Start S2 data acquisition (IUC-S2-01-01)
      const startResult = this.s2Service.start(
        serverSessionId,
        userId,
        sensorJointMapping,
        exercise.exerciseId,
        token
      );

      Logger.debug('RehabService', `S2.start() returned: success=${startResult.success}, error=${startResult.errorMessage}`);

      if (!startResult.success) {
        Logger.error('RehabService',
          `S2 start failed: ${startResult.errorMessage ?? 'unknown'}`);
        this.sessionState = 'idle';
        this.notifySessionStateChange('idle');
        return false;
      }

      // Create local session record
      this.currentSession = {
        sessionId: serverSessionId.toString(),
        serverSessionId: serverSessionId,
        exerciseId: exercise.exerciseId,
        startTime: Date.now(),
        scores: [],
      };

      this.sessionState = 'active';
      this.notifySessionStateChange('active');
      this.startDataStream();
      Logger.info('RehabService', 'Data stream started (30fps read from S2)');

      Logger.info('RehabService',
        `Session started: server_id=${serverSessionId}, exercise=${exercise.exerciseId}`);
      return true;
    } catch (error) {
      Logger.error('RehabService', `Failed to start session: ${String(error)}`);
      this.sessionState = 'idle';
      this.notifySessionStateChange('idle');
      return false;
    }
  }

  /**
   * Pause session
   */
  pauseSession(): void {
    if (this.sessionState !== 'active') {
      return;
    }

    this.sessionState = 'paused';
    this.notifySessionStateChange('paused');
    this.stopDataStream();
    Logger.info('RehabService', 'Session paused');
  }

  /**
   * Resume session
   */
  resumeSession(): void {
    if (this.sessionState !== 'paused') {
      return;
    }

    this.sessionState = 'active';
    this.notifySessionStateChange('active');
    this.startDataStream();
    Logger.info('RehabService', 'Session resumed');
  }

  /**
   * End session
   * Calls S2 stop to flush data and end V2 session.
   */
  async endSession(): Promise<SessionData | null> {
    Logger.debug('RehabService', `endSession() called: currentState=${this.sessionState}`);

    if (this.sessionState === 'idle' || this.sessionState === 'ended') {
      Logger.debug('RehabService', 'endSession: already idle/ended, returning null');
      return null;
    }

    this.sessionState = 'ended';
    this.stopDataStream();
    Logger.info('RehabService', 'Ending session: stopping data stream');

    if (this.currentSession) {
      this.currentSession.endTime = Date.now();
      this.currentSession.duration = this.currentSession.endTime - this.currentSession.startTime;
      this.currentSession.averageScore = this.calculateAverageScore();
      Logger.info('RehabService', `Session stats: duration=${this.currentSession.duration}ms, avgScore=${this.currentSession.averageScore}, scores=${this.currentSession.scores?.length ?? 0}`);

      // Stop S2 acquisition and flush to V2 (IUC-S2-01-02)
      try {
        const summary = await this.s2Service.stop();
        Logger.info('RehabService',
          `S2 session summary: samples=${summary.sampleCount}, errors=${summary.errorCount}`);
      } catch (error) {
        Logger.error('RehabService',
          `S2 stop failed: ${String(error)}`);
      }

      // Save completed session to local storage
      await this.localStorage.saveSession(this.currentSession);
      Logger.info('RehabService', 'Session saved to local storage');

      const result = this.currentSession;
      this.currentSession = null;
      this.currentExercise = null;
      this.sessionState = 'idle';

      this.notifySessionStateChange('ended', result);
      Logger.info('RehabService', `Session ended: ${result.sessionId}`);

      return result;
    }

    this.sessionState = 'idle';
    this.notifySessionStateChange('idle');
    return null;
  }

  /**
   * Get current session state
   */
  getSessionState(): SessionState {
    return this.sessionState;
  }

  /**
   * Get current session data
   */
  getCurrentSession(): SessionData | null {
    return this.currentSession;
  }

  /**
   * Get sensor connection state via S2→S1 chain.
   */
  isSensorConnected(): boolean {
    // Query S1 adapter through S2 chain, not BLE directly.
    // [S1-REAL] Uncomment to re-enable direct BLE check:
    // return this.bleManager.isConnected();
    const connected = this.s1Adapter.status().connected;
    Logger.debug('RehabService', `isSensorConnected() = ${connected}`);
    return connected;
  }

  /**
   * Disconnect sensor
   */
  disconnectSensor(): void {
    // [S1-REAL] Uncomment when real BLE sensor management is needed:
    // this.bleManager.disconnect();
  }

  /**
   * Destroy service
   */
  destroy(): void {
    this.stopDataStream();
    this.clearReconnectTimer();
    this.sessionCallbacks.clear();
    this.realtimeCallbacks.clear();
    this.alertCallbacks.clear();
  }

  /**
   * Start data stream using S2 pipeline.
   * Reads FormatData from S2 and converts to RealtimeRecognitionResult for UI.
   */
  private startDataStream(): void {
    Logger.debug('RehabService', 'startDataStream() called');
    if (this.dataStreamTimer) {
      clearInterval(this.dataStreamTimer);
    }

    // Read from S2 at ~30fps
    this.dataStreamTimer = setInterval(() => {
      if (this.sessionState !== 'active') {
        return;
      }

      // Read formatted data from S2 (IUC-S2-02-01)
      const formatData = this.s2Service.read();

      // Convert S2 FormatData to M1 RealtimeRecognitionResult
      const result = this.convertFormatDataToResult(formatData);

      // Send realtime data to UI
      this.realtimeCallbacks.forEach(callback => {
        callback(result);
      });

      // Record score
      if (this.currentSession && result.deviationScores) {
        this.currentSession.scores?.push(result.deviationScores.overall);
      }

      // Check alerts from S2 errors and local conditions
      this.checkAlerts(result, formatData.errors);
    }, 33); // ~30fps
  }

  /**
   * Stop data stream
   */
  private stopDataStream(): void {
    Logger.debug('RehabService', 'stopDataStream() called');
    if (this.dataStreamTimer) {
      clearInterval(this.dataStreamTimer);
      this.dataStreamTimer = null;
    }
  }

  /**
   * Convert S2 FormatData to M1 RealtimeRecognitionResult.
   * Maps dynamic angleIDs from S2 to M1's hardcoded knee/hip/ankle UI model.
   */
  private convertFormatDataToResult(data: FormatData): RealtimeRecognitionResult {
    const jointAngles: JointAngles = {};
    const now = Date.now();

    // Extract joint angles from targetAngles (dynamic angleID -> fixed joint names)
    if (data.targetAngles.length > 0) {
      for (const ta of data.targetAngles) {
        const id = ta.angleID.toLowerCase();
        if (id.includes('knee')) {
          jointAngles.knee = ta.angle;
        } else if (id.includes('hip')) {
          jointAngles.hip = ta.angle;
        } else if (id.includes('ankle')) {
          jointAngles.ankle = ta.angle;
        } else {
          // Unknown angleID: default to knee for single-sensor setup
          if (jointAngles.knee === undefined) {
            jointAngles.knee = ta.angle;
          }
        }
      }
    } else if (data.sensorData.length > 0) {
      // Fallback: use raw sensor roll as knee angle
      const latestSample = data.sensorData[data.sensorData.length - 1];
      jointAngles.knee = latestSample.roll;
      jointAngles.hip = latestSample.pitch + 45; // Offset for display
      jointAngles.ankle = latestSample.yaw + 90; // Offset for display
    }

    // Use target angles from exercise plan for deviation calculation
    const targetKnee = this.currentExercise?.targetJointAngles?.knee ?? 30;
    const targetHip = this.currentExercise?.targetJointAngles?.hip ?? 45;
    const targetAnkle = this.currentExercise?.targetJointAngles?.ankle ?? 15;

    const kneeDeviation = jointAngles.knee !== undefined ? Math.abs(targetKnee - jointAngles.knee) : 0;
    const hipDeviation = jointAngles.hip !== undefined ? Math.abs(targetHip - jointAngles.hip) : 0;
    const ankleDeviation = jointAngles.ankle !== undefined ? Math.abs(targetAnkle - jointAngles.ankle) : 0;
    const overallDeviation = (kneeDeviation + hipDeviation + ankleDeviation) / 3;

    // Confidence based on error count
    let confidence = 1.0;
    if (data.errors.length > 0) {
      confidence = Math.max(0.3, 1.0 - data.errors.length * 0.2);
    }

    return {
      jointAngles: jointAngles,
      deviationScores: {
        knee: kneeDeviation,
        hip: hipDeviation,
        ankle: ankleDeviation,
        overall: Math.max(0, 100 - overallDeviation),
      },
      alertFlags: [],
      confidence: confidence,
      timestamp: now,
    };
  }

  /**
   * Check alert conditions from both local analysis and S2 error events.
   */
  private checkAlerts(result: RealtimeRecognitionResult, s2Errors: ErrorEvent[]): void {
    // Convert S2 error events to alerts
    for (const error of s2Errors) {
      let alertType: AlertType = 'signal_weak';
      let severity: 'low' | 'medium' | 'high' = 'medium';

      if (error.errorType === 'sensor_disconnected') {
        alertType = 'connection_lost';
        severity = 'high';
      } else if (error.errorType === 'validation_failure') {
        alertType = 'tracking_uncertain';
        severity = 'low';
      } else if (error.errorType === 'timeout') {
        alertType = 'signal_weak';
        severity = 'medium';
      }

      const alert: AlertFlag = {
        type: alertType,
        severity: severity,
        message: error.message,
        joint: error.sensorId ?? undefined,
      };
      this.emitAlert(alert);
    }

    // Signal strength alert based on confidence
    if (result.confidence < 0.80) {
      const alert: AlertFlag = {
        type: 'tracking_uncertain',
        severity: 'low',
        message: 'Tracking uncertain',
      };
      this.emitAlert(alert);
    }

    // Angle deviation alert
    if (result.deviationScores.knee !== undefined && result.deviationScores.knee > 20) {
      const alert: AlertFlag = {
        type: 'angle_deviation',
        severity: result.deviationScores.knee > 40 ? 'high' : 'medium',
        message: 'Bend your knee more',
        joint: 'knee',
      };
      this.emitAlert(alert);
    }
  }

  /**
   * Send alert
   */
  private emitAlert(alert: AlertFlag): void {
    this.alertCallbacks.forEach(callback => {
      callback(alert);
    });
  }

  /**
   * Calculate average score
   */
  private calculateAverageScore(): number {
    if (!this.currentSession?.scores || this.currentSession.scores.length === 0) {
      return 0;
    }

    const sum = this.currentSession.scores.reduce((a, b) => a + b, 0);
    return Math.round((sum / this.currentSession.scores.length) * 100) / 100;
  }

  /**
   * Notify session state change
   */
  private notifySessionStateChange(state: SessionState, data?: SessionData): void {
    this.sessionCallbacks.forEach(callback => {
      callback(state, data);
    });
  }

  /**
   * Clear reconnect timer
   */
  private clearReconnectTimer(): void {
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
  }
}
