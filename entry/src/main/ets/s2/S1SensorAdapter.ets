/**
 * S1 Sensor Adapter
 * Implements IF-S1-S2 interface. Currently provides mock/simulated IMU data.
 * When S1 firmware is ready, replace this file with the real S1 SDK integration.
 */
// [S1-REAL] Uncomment when real S1 SDK is available:
// import { BleSensorManager } from '../service/BleManager';
import { SensorSample, SensorStatus, SessionContext } from './S2DataModels';
import { Logger } from '../service/FileLoggerService';

const TAG = 'S1Adapter';

export class S1SensorAdapter {
  private static instance: S1SensorAdapter | null = null;
  // [S1-REAL] Uncomment when real S1 SDK is available:
  // private bleManager: BleSensorManager;
  private buffer: SensorSample[] = [];
  private generationTimer: number | null = null;
  private active: boolean = false;
  private phaseOffset: number = 0;     // For smooth sinusoidal simulation
  private startTimeMs: number = 0;

  private constructor() {
    // [S1-REAL] Uncomment when real S1 SDK is available:
    // this.bleManager = BleSensorManager.getInstance();
  }

  static getInstance(): S1SensorAdapter {
    if (!S1SensorAdapter.instance) {
      S1SensorAdapter.instance = new S1SensorAdapter();
    }
    return S1SensorAdapter.instance;
  }

  /**
   * Start a session's raw data collecting work.
   * (SRS IUC-S2-03-01: S2 calls S1's session start method, passing session meta data.
   *  S1 initializes and returns a confirmation signal.)
   * @param metaData Session meta data including sessionId, userId, payloadStatus, etc.
   * @returns true if initialization succeeded, false otherwise
   */
  startSession(metaData: SessionContext): boolean {
    Logger.debug(TAG, `startSession() called: sessionId=${metaData.sessionId}, payloadStatus=${metaData.payloadStatus}`);
    // [S1-MOCK] Mock S1 always initializes successfully.
    // [S1-REAL] Replace with real S1 SDK session initialization:
    // return this.s1Sdk.initSession(metaData);
    this.startAcquisition();
    Logger.debug(TAG, 'startSession() returning true');
    return true;
  }

  /**
   * End a session's raw data collecting work.
   * (SRS IUC-S2-03-02: S2 calls S1's session end method.
   *  S1 completes finalization and returns a confirmation signal.)
   * @returns true if finalization succeeded, false otherwise
   */
  stopSession(): boolean {
    Logger.debug(TAG, 'stopSession() called');
    // [S1-MOCK] Mock S1 always finalizes successfully.
    // [S1-REAL] Replace with real S1 SDK session finalization:
    // return this.s1Sdk.endSession();
    this.stopAcquisition();
    Logger.debug(TAG, 'stopSession() returning true');
    return true;
  }

  /**
   * Start generating simulated sensor data at ~30Hz.
   * Internal method; called by startSession().
   */
  private startAcquisition(): void {
    if (this.active) {
      return;
    }
    this.active = true;
    this.startTimeMs = Date.now();
    this.phaseOffset = Math.random() * Math.PI * 2;
    this.buffer = [];

    this.generationTimer = setInterval(() => {
      if (!this.active) {
        return;
      }
      const sample = this.generateSample();
      this.buffer.push(sample);
    }, 33); // ~30Hz
  }

  /**
   * Stop generating sensor data.
   * Internal method; called by stopSession().
   */
  private stopAcquisition(): void {
    this.active = false;
    if (this.generationTimer !== null) {
      clearInterval(this.generationTimer);
      this.generationTimer = null;
    }
  }

  /**
   * Read a batch of IMU samples collected since the last call.
   * (IF-S1-S2, Section 3.2.1)
   */
  read(): SensorSample[] {
    const samples = this.buffer;
    this.buffer = [];
    return samples;
  }

  /**
   * Query the current status of the sensor hardware connection.
   * (IF-S1-S2, Section 3.2.2)
   */
  status(): SensorStatus {
    const st = new SensorStatus();
    // [S1-MOCK] Mock S1 always reports connected.
    // [S1-REAL] Replace with real S1 SDK connection check:
    // st.connected = this.bleManager.isConnected();
    // if (!st.connected) {
    //   st.errorMessage = 'sensor_disconnected';
    // }
    st.connected = true;
    // status() is called at 30Hz — only log to hilog via DETAIL, not file
    return st;
  }

  /**
   * Generate a single realistic IMU sample with smooth sinusoidal motion.
   * Simulates a rehabilitation exercise (e.g., knee flexion/extension cycle).
   */
  private generateSample(): SensorSample {
    const now = Date.now();
    const elapsed = (now - this.startTimeMs) / 1000.0; // seconds
    // [S1-REAL] Replace with real S1 SDK device ID:
    // const deviceId = this.bleManager.getConnectedDeviceId() || 'mock-sensor-001';
    const deviceId = 'mock-sensor-001';

    const sample = new SensorSample();
    sample.timestamp = now;
    sample.deviceId = deviceId;
    sample.deviceName = 'IMU-Sensor';

    // Sinusoidal joint motion: period ~4 seconds (0.25 Hz)
    const freq = 0.25;
    const phase = this.phaseOffset + 2 * Math.PI * freq * elapsed;

    // Roll: simulates primary joint angle (e.g., knee flexion 10-50 degrees)
    sample.roll = 30 + 20 * Math.sin(phase) + this.noise(0.5);
    // Pitch: secondary motion (-10 to 10 degrees)
    sample.pitch = 5 * Math.sin(phase * 0.7 + 1.0) + this.noise(0.3);
    // Yaw: drift simulation
    sample.yaw = -90 + 10 * Math.sin(phase * 0.3 + 2.0) + this.noise(0.2);

    // Accelerometer: gravity-based with slight motion artifacts
    sample.accX = Math.sin(sample.roll * Math.PI / 180) + this.noise(0.02);
    sample.accY = Math.sin(sample.pitch * Math.PI / 180) + this.noise(0.02);
    sample.accZ = Math.cos(sample.roll * Math.PI / 180) * Math.cos(sample.pitch * Math.PI / 180) + this.noise(0.02);

    // Gyroscope: angular velocity (derivative of angles, roughly)
    const angularVelocity = 20 * Math.PI * freq * Math.cos(phase);
    sample.gyroX = angularVelocity + this.noise(0.5);
    sample.gyroY = 5 * 0.7 * Math.PI * freq * Math.cos(phase * 0.7 + 1.0) + this.noise(0.3);
    sample.gyroZ = this.noise(1.0);

    return sample;
  }

  private noise(amplitude: number): number {
    return (Math.random() - 0.5) * 2 * amplitude;
  }
}
