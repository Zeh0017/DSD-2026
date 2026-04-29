if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
import { BleSensorManager } from "@normalized:N&&&entry/src/main/ets/service/BleManager&";
import type { SensorDevice, SensorConnectionState } from "@normalized:N&&&entry/src/main/ets/service/BleManager&";
import promptAction from "@ohos:promptAction";
export class SensorConnectionPage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.isScanning = false;
        this.isConnecting = false;
        this.devices = [];
        this.connectionState = { connected: false, deviceId: '', deviceName: '' };
        this.errorMessage = '';
        this.bleEnabled = true;
        this.bleManager = BleSensorManager.getInstance();
        this.scanInterval = -1;
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.isScanning = false;
        this.isConnecting = false;
        this.devices = [];
        this.connectionState = { connected: false, deviceId: '', deviceName: '' };
        this.errorMessage = '';
        this.bleEnabled = true;
    }
    @Local
    isScanning: boolean;
    @Local
    isConnecting: boolean;
    @Local
    devices: SensorDevice[];
    @Local
    connectionState: SensorConnectionState;
    @Local
    errorMessage: string;
    @Local
    bleEnabled: boolean;
    private bleManager: BleSensorManager;
    private scanInterval: number;
    aboutToAppear(): void {
        this.initBle();
    }
    aboutToDisappear(): void {
        this.stopScan();
        this.bleManager.setOnScanResult(() => { });
        this.bleManager.setOnStateChange(() => { });
    }
    private initBle(): void {
        this.bleManager.setOnStateChange((state: SensorConnectionState) => {
            this.connectionState = state;
            this.isConnecting = false;
            if (state.connected) {
                promptAction.showToast({
                    message: 'Sensor connected: ' + state.deviceName,
                    duration: 2000
                });
                setTimeout(() => {
                    const nav = AppStorage.get<NavPathStack>('navPathStack');
                    if (nav) {
                        nav.replacePathByName('SessionSetup', null);
                    }
                }, 1000);
            }
            else {
                promptAction.showToast({
                    message: 'Sensor disconnected',
                    duration: 2000
                });
            }
        });
        this.bleManager.setOnScanResult((devices: SensorDevice[]) => {
            this.devices = devices;
        });
    }
    startScan(): void {
        this.isScanning = true;
        this.devices = [];
        this.errorMessage = '';
        this.bleManager.startScan();
        this.scanInterval = setTimeout(() => {
            this.stopScan();
            if (this.devices.length === 0) {
                this.errorMessage = 'No sensors found. Check that the sensor is powered on and nearby.';
            }
        }, 10000) as number;
    }
    stopScan(): void {
        this.isScanning = false;
        this.bleManager.stopScan();
        if (this.scanInterval !== -1) {
            clearTimeout(this.scanInterval);
            this.scanInterval = -1;
        }
    }
    connectSensor(device: SensorDevice): void {
        this.isConnecting = true;
        this.errorMessage = '';
        this.bleManager.connect(device.deviceId).then(() => {
            // Connection success callback already handled in initBle
        }).catch(() => {
            this.isConnecting = false;
            this.errorMessage = 'Connection failed. Make sure the sensor is in pairing mode.';
            promptAction.showToast({
                message: 'Connection failed',
                duration: 2000
            });
        });
    }
    disconnectSensor(): void {
        this.bleManager.disconnect();
        this.connectionState = { connected: false, deviceId: '', deviceName: '' };
    }
    onBack(): void {
        const storage = AppStorage.get<NavPathStack>('navPathStack');
        if (storage) {
            storage.pop();
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            NavDestination.create(() => {
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height('100%');
                    Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                }, Column);
                this.TitleBar.bind(this)();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    If.create();
                    if (this.connectionState.connected) {
                        this.ifElseBranchUpdateFunction(0, () => {
                            this.ConnectedView.bind(this)();
                        });
                    }
                    else {
                        this.ifElseBranchUpdateFunction(1, () => {
                            this.ScanView.bind(this)();
                        });
                    }
                }, If);
                If.pop();
                Column.pop();
            }, { moduleName: "entry", pagePath: "entry/src/main/ets/pages/rehabilitation/SensorConnectionPage" });
            NavDestination.title('Connect Sensor');
            NavDestination.onBackPressed(() => {
                this.onBack();
                return true;
            });
        }, NavDestination);
        NavDestination.pop();
    }
    TitleBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(56);
            Row.padding({ left: 12 });
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild();
            Button.type(ButtonType.Circle);
            Button.width(40);
            Button.height(40);
            Button.backgroundColor(Color.Transparent);
            Button.onClick(() => this.onBack());
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125832663, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(24);
        }, SymbolGlyph);
        Button.pop();
        Row.pop();
    }
    ConnectedView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 24 });
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125831492, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(64);
            SymbolGlyph.fontColor([Color.Green]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Sensor Connected');
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.connectionState.deviceName) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.connectionState.deviceName);
                        Text.fontSize({ "id": 125830970, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Disconnect');
            Button.width('80%');
            Button.height(48);
            Button.borderRadius(24);
            Button.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.onClick(() => this.disconnectSensor());
        }, Button);
        Button.pop();
        Column.pop();
    }
    ScanView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
            Column.padding({ top: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Make sure your sensor is turned on and nearby.');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.textAlign(TextAlign.Center);
            Text.padding({ left: 24, right: 24 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild();
            Button.width('80%');
            Button.height(48);
            Button.borderRadius(24);
            Button.backgroundColor(this.isScanning ? { "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.enabled(!this.isConnecting);
            Button.onClick(() => {
                if (this.isScanning) {
                    this.stopScan();
                }
                else {
                    this.startScan();
                }
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125831681, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(20);
            SymbolGlyph.fontColor([Color.White]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isScanning) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Scanning...');
                        Text.fontColor(Color.White);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Scan for Sensors');
                        Text.fontColor(Color.White);
                    }, Text);
                    Text.pop();
                });
            }
        }, If);
        If.pop();
        Row.pop();
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.devices.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create({ space: 12 });
                        Column.padding({ left: 24, right: 24 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Available Sensors');
                        Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontWeight(FontWeight.Medium);
                        Text.width('100%');
                        Text.padding({ left: 24 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const device = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Row.create();
                                Row.width('100%');
                                Row.padding(16);
                                Row.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                Row.borderRadius(12);
                                Row.onClick(() => {
                                    if (!this.isConnecting) {
                                        this.connectSensor(device);
                                    }
                                });
                            }, Row);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Column.create({ space: 4 });
                                Column.alignItems(HorizontalAlign.Start);
                            }, Column);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Text.create(device.deviceName);
                                Text.fontSize({ "id": 125830970, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                Text.fontWeight(FontWeight.Medium);
                            }, Text);
                            Text.pop();
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Text.create('Signal: ' + device.rssi + ' dBm');
                                Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                            }, Text);
                            Text.pop();
                            Column.pop();
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Blank.create();
                            }, Blank);
                            Blank.pop();
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                If.create();
                                if (this.isConnecting) {
                                    this.ifElseBranchUpdateFunction(0, () => {
                                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                                            LoadingProgress.create();
                                            LoadingProgress.width(24);
                                            LoadingProgress.height(24);
                                        }, LoadingProgress);
                                    });
                                }
                                else {
                                    this.ifElseBranchUpdateFunction(1, () => {
                                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                                            SymbolGlyph.create({ "id": 125831482, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                            SymbolGlyph.fontSize(24);
                                            SymbolGlyph.fontColor([{ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
                                        }, SymbolGlyph);
                                    });
                                }
                            }, If);
                            If.pop();
                            Row.pop();
                        };
                        this.forEachUpdateFunction(elmtId, this.devices, forEachItemGenFunction);
                    }, ForEach);
                    ForEach.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.errorMessage) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.errorMessage);
                        Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor(Color.Red);
                        Text.textAlign(TextAlign.Center);
                        Text.padding({ left: 24, right: 24 });
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
