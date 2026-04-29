import hilog from "@ohos:hilog";
import { BleSensorManager } from "@normalized:N&&&entry/src/main/ets/service/BleManager&";
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
    private bleManager: BleSensorManager;
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
        this.bleManager = BleSensorManager.getInstance();
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
    init(context: Context): void {
        this.bleManager.init(context);
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
     * @param exercise Exercise plan
     * @returns Whether session started successfully
     */
    async startSession(exercise: ExercisePlan): Promise<boolean> {
        if (this.sessionState === 'active') {
            hilog.warn(0x0001, 'RehabilitationService', 'Session already active');
            return false;
        }
        if (!this.bleManager.isConnected()) {
            hilog.error(0x0001, 'RehabilitationService', 'Sensor not connected');
            return false;
        }
        this.currentExercise = exercise;
        this.sessionState = 'connecting';
        this.notifySessionStateChange('connecting');
        try {
            // Create session record
            const sessionId = this.generateSessionId();
            this.currentSession = {
                sessionId: sessionId,
                exerciseId: exercise.exerciseId,
                startTime: Date.now(),
                scores: [],
            };
            // TODO: Notify backend session started (IUC-M1-04)
            // await V2Backend.startSession(exercise.exerciseId, sessionId);
            // Start data stream
            this.sessionState = 'active';
            this.notifySessionStateChange('active');
            this.startDataStream();
            hilog.info(0x0001, 'RehabilitationService', 'Session started: %{public}s', sessionId);
            return true;
        }
        catch (error) {
            hilog.error(0x0001, 'RehabilitationService', 'Failed to start session: %{public}s', String(error));
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
        hilog.info(0x0001, 'RehabilitationService', 'Session paused');
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
        hilog.info(0x0001, 'RehabilitationService', 'Session resumed');
    }
    /**
     * End session
     */
    async endSession(): Promise<SessionData | null> {
        if (this.sessionState === 'idle' || this.sessionState === 'ended') {
            return null;
        }
        const previousState = this.sessionState;
        this.sessionState = 'ended';
        this.stopDataStream();
        if (this.currentSession) {
            this.currentSession.endTime = Date.now();
            this.currentSession.duration = this.currentSession.endTime - this.currentSession.startTime;
            this.currentSession.averageScore = this.calculateAverageScore();
            // TODO: Sync to backend (IUC-M1-06)
            // await V2Backend.syncSession(this.currentSession);
            const result = this.currentSession;
            this.currentSession = null;
            this.currentExercise = null;
            this.sessionState = 'idle';
            this.notifySessionStateChange('ended', result);
            hilog.info(0x0001, 'RehabilitationService', 'Session ended: %{public}s', result.sessionId);
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
     * Get sensor connection state
     */
    isSensorConnected(): boolean {
        return this.bleManager.isConnected();
    }
    /**
     * Disconnect sensor
     */
    disconnectSensor(): void {
        this.bleManager.disconnect();
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
     * Start data stream (simulated, should fetch from V2 backend)
     * TODO: Implement real data stream connection (IUC-M1-05)
     */
    private startDataStream(): void {
        if (this.dataStreamTimer) {
            clearInterval(this.dataStreamTimer);
        }
        // Simulate 30fps data stream
        this.dataStreamTimer = setInterval(() => {
            if (this.sessionState !== 'active') {
                return;
            }
            // TODO: Receive real data from WebSocket
            // const result = await RealtimeService.receiveData();
            const result = this.generateMockRealtimeResult();
            // Send realtime data to UI
            this.realtimeCallbacks.forEach(callback => {
                callback(result);
            });
            // Record score
            if (this.currentSession && result.deviationScores) {
                this.currentSession.scores?.push(result.deviationScores.overall);
            }
            // Check if alert needed
            this.checkAlerts(result);
        }, 33); // ~30fps
    }
    /**
     * Stop data stream
     */
    private stopDataStream(): void {
        if (this.dataStreamTimer) {
            clearInterval(this.dataStreamTimer);
            this.dataStreamTimer = null;
        }
    }
    /**
     * Check alert conditions
     */
    private checkAlerts(result: RealtimeRecognitionResult): void {
        // Signal strength alert
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
        // TODO: Simulate connection lost alert
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
     * Generate session ID
     */
    private generateSessionId(): string {
        return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
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
    /**
     * Generate simulated realtime data (should fetch from backend)
     * TODO: Replace with real data reception
     */
    private generateMockRealtimeResult(): RealtimeRecognitionResult {
        const knee = 30 + Math.random() * 20 - 10; // 20-40 degrees
        const hip = 45 + Math.random() * 10 - 5; // 40-50 degrees
        const ankle = 15 + Math.random() * 10 - 5; // 10-20 degrees
        const overallDeviation = Math.random() * 30;
        return {
            jointAngles: { knee, hip, ankle },
            deviationScores: {
                knee: Math.abs(30 - knee),
                hip: Math.abs(45 - hip),
                ankle: Math.abs(15 - ankle),
                overall: Math.max(0, 100 - overallDeviation),
            },
            alertFlags: [],
            confidence: 0.85 + Math.random() * 0.15,
            timestamp: Date.now(),
        };
    }
}
