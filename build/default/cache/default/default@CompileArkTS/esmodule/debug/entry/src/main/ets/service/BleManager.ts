import ble from "@ohos:bluetooth.ble";
import type { BusinessError } from "@ohos:base";
export interface SensorDevice {
    deviceId: string;
    deviceName: string;
    rssi: number;
}
export interface SensorConnectionState {
    connected: boolean;
    deviceId: string;
    deviceName: string;
}
export type SensorStateChangeCallback = (state: SensorConnectionState) => void;
export type ScanResultCallback = (devices: SensorDevice[]) => void;
export class BleSensorManager {
    private static instance: BleSensorManager | null = null;
    private context: Context | null = null;
    private scanState: boolean = false;
    private connectedDeviceId: string = '';
    private onStateChange: SensorStateChangeCallback | null = null;
    private onScanResult: ScanResultCallback | null = null;
    private discoveredDevices: Map<string, SensorDevice> = new Map();
    private gattClient: ble.GattClientDevice | null = null;
    private constructor() { }
    static getInstance(): BleSensorManager {
        if (!BleSensorManager.instance) {
            BleSensorManager.instance = new BleSensorManager();
        }
        return BleSensorManager.instance;
    }
    /**
     * Initialize BLE manager
     */
    init(context: Context): void {
        this.context = context;
    }
    /**
     * Set state change callback
     */
    setOnStateChange(callback: SensorStateChangeCallback): void {
        this.onStateChange = callback;
    }
    /**
     * Set scan result callback
     */
    setOnScanResult(callback: ScanResultCallback): void {
        this.onScanResult = callback;
    }
    /**
     * Start scanning sensors
     */
    startScan(): void {
        if (this.scanState) {
            return;
        }
        try {
            const scanOptions: ble.ScanOptions = {
                interval: 500,
                dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
                matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE,
            };
            ble.on('BLEDeviceFind', (results: Array<ble.ScanResult>) => {
                for (let i = 0; i < results.length; i++) {
                    const result: ble.ScanResult = results[i];
                    const deviceId: string = result.deviceId;
                    const deviceName: string = result.deviceName ?? 'Unknown Sensor';
                    const rssi: number = result.rssi ?? -100;
                    if (!this.discoveredDevices.has(deviceId)) {
                        const device: SensorDevice = {
                            deviceId: deviceId,
                            deviceName: deviceName,
                            rssi: rssi,
                        };
                        this.discoveredDevices.set(deviceId, device);
                        if (this.onScanResult) {
                            this.onScanResult(Array.from(this.discoveredDevices.values()));
                        }
                    }
                }
            });
            ble.startBLEScan(undefined, scanOptions);
            this.scanState = true;
        }
        catch (error) {
            const err: BusinessError = error as BusinessError;
            console.error('Start scan failed: ' + err.code + ', message: ' + err.message);
        }
    }
    /**
     * Stop scanning
     */
    stopScan(): void {
        if (!this.scanState) {
            return;
        }
        try {
            ble.off('BLEDeviceFind');
            ble.stopBLEScan();
            this.scanState = false;
        }
        catch (error) {
            const err: BusinessError = error as BusinessError;
            console.error('Stop scan failed: ' + err.code + ', message: ' + err.message);
        }
    }
    /**
     * Connect sensor
     */
    connect(deviceId: string): Promise<SensorConnectionState> {
        return new Promise((resolve, reject) => {
            try {
                this.gattClient = ble.createGattClientDevice(deviceId);
                this.gattClient.on('BLEConnectionStateChange', (state: ble.BLEConnectionChangeState) => {
                    if (state.state === 2) {
                        this.connectedDeviceId = deviceId;
                        const deviceName: string = this.discoveredDevices.get(deviceId)?.deviceName ?? 'Sensor';
                        const connState: SensorConnectionState = {
                            connected: true,
                            deviceId: deviceId,
                            deviceName: deviceName,
                        };
                        if (this.onStateChange) {
                            this.onStateChange(connState);
                        }
                        resolve(connState);
                    }
                    else if (state.state === 0) {
                        this.connectedDeviceId = '';
                        const connState: SensorConnectionState = {
                            connected: false,
                            deviceId: '',
                            deviceName: '',
                        };
                        if (this.onStateChange) {
                            this.onStateChange(connState);
                        }
                        reject(new Error('Disconnected'));
                    }
                });
                this.gattClient.connect();
            }
            catch (error) {
                const err: BusinessError = error as BusinessError;
                reject(new Error('Connection failed: ' + err.message));
            }
        });
    }
    /**
     * Disconnect
     */
    disconnect(): void {
        if (this.connectedDeviceId && this.gattClient) {
            try {
                this.gattClient.disconnect();
                this.connectedDeviceId = '';
            }
            catch (error) {
                const err: BusinessError = error as BusinessError;
                console.error('Disconnect failed: ' + err.code + ', message: ' + err.message);
            }
        }
    }
    /**
     * Get connection state
     */
    isConnected(): boolean {
        return this.connectedDeviceId !== '';
    }
    /**
     * Get connected device ID
     */
    getConnectedDeviceId(): string {
        return this.connectedDeviceId;
    }
    /**
     * Destroy BLE manager
     */
    destroy(): void {
        this.stopScan();
        this.disconnect();
        if (this.gattClient) {
            this.gattClient.off('BLEConnectionStateChange');
            this.gattClient.close();
            this.gattClient = null;
        }
        this.onStateChange = null;
        this.onScanResult = null;
        this.discoveredDevices.clear();
    }
}
