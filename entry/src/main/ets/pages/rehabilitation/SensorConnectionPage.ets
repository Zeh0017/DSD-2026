/**
 * Sensor connection page
 * UC-M1-02-01: Connect sensor
 */
import { BleSensorManager, SensorDevice, SensorConnectionState } from '../../service/BleManager';
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct SensorConnectionPage {
  @Local isScanning: boolean = false;
  @Local isConnecting: boolean = false;
  @Local devices: SensorDevice[] = [];
  @Local connectionState: SensorConnectionState = { connected: false, deviceId: '', deviceName: '' };
  @Local errorMessage: string = '';
  @Local bleEnabled: boolean = true;
  private bleManager: BleSensorManager = BleSensorManager.getInstance();
  private scanInterval: number = -1;

  aboutToAppear(): void {
    this.initBle();
  }

  aboutToDisappear(): void {
    this.stopScan();
    this.bleManager.setOnScanResult(() => {
    });
    this.bleManager.setOnStateChange(() => {
    });
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
      } else {
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
    //Test code start
    this.devices = [
      { deviceId: "1", deviceName: "1", rssi: 1 },
      { deviceId: "2", deviceName: "2", rssi: 2 },
      { deviceId: "3", deviceName: "3", rssi: 3 },
      { deviceId: "1", deviceName: "1", rssi: 1 },
      { deviceId: "2", deviceName: "2", rssi: 2 },
      { deviceId: "3", deviceName: "3", rssi: 3 },
      { deviceId: "1", deviceName: "1", rssi: 1 },
      { deviceId: "2", deviceName: "2", rssi: 2 },
      { deviceId: "3", deviceName: "3", rssi: 3 },
      { deviceId: "1", deviceName: "1", rssi: 1 },
      { deviceId: "2", deviceName: "2", rssi: 2 },
      { deviceId: "3", deviceName: "3", rssi: 3 },
      { deviceId: "1", deviceName: "1", rssi: 1 },
      { deviceId: "2", deviceName: "2", rssi: 2 },
      { deviceId: "3", deviceName: "3", rssi: 3 }
    ];
    //Test code end
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

  build() {
    NavDestination() {
      Column() {
        if (this.connectionState.connected) {
          this.ConnectedView()
        } else {
          this.ScanView()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title('Connect Sensor')
    .onBackPressed(() => {
      this.onBack();
      return true;
    })
  }

  @Builder
  ConnectedView() {
    Column({ space: 24 }) {
      SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
        .fontSize(64)
        .fontColor([Color.Green])

      Text('Sensor Connected')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)

      if (this.connectionState.deviceName) {
        Text(this.connectionState.deviceName)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_secondary'))
      }

      Button('Disconnect')
        .width('80%')
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .fontColor($r('sys.color.font_primary'))
        .onClick(() => this.disconnectSensor())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ScanView() {
    Column({ space: 16 }) {
      Text('Make sure your sensor is turned on and nearby.')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .padding({ left: 24, right: 24 })

      Button() {
        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.dot_circle'))
            .fontSize(20)
            .fontColor([Color.White])
          if (this.isScanning) {
            Text('Scanning...')
              .fontColor(Color.White)
          } else {
            Text('Scan for Sensors')
              .fontColor(Color.White)
          }
        }
      }
      .width('80%')
      .height(48)
      .borderRadius(24)
      .backgroundColor(this.isScanning ? $r('sys.color.font_tertiary') : $r('sys.color.icon_emphasize'))
      .enabled(!this.isConnecting)
      .onClick(() => {
        if (this.isScanning) {
          this.stopScan();
        } else {
          this.startScan();
        }
      })

      if (this.devices.length > 0) {
        Column({ space: 12 }) {
          Text('Available Sensors')
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .width('100%')
            .padding({ left: 24 })
          List({ space: 12 }) {
            ForEach(this.devices, (device: SensorDevice) => {
              ListItem() {
                Row() {
                  Column({ space: 4 }) {
                    Text(device.deviceName)
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                    Text('Signal: ' + device.rssi + ' dBm')
                      .fontSize($r('sys.float.Caption_M'))
                      .fontColor($r('sys.color.font_tertiary'))
                  }
                  .alignItems(HorizontalAlign.Start)

                  Blank()
                  if (this.isConnecting) {
                    LoadingProgress()
                      .width(24)
                      .height(24)
                  } else {
                    SymbolGlyph($r('sys.symbol.plus_circle'))
                      .fontSize(24)
                      .fontColor([$r('sys.color.icon_emphasize')])
                  }
                }
                .width('100%')
                .padding(16)
                .backgroundColor($r('sys.color.comp_background_list_card'))
                .borderRadius(12)
              }
              .onClick(() => {
                if (!this.isConnecting) {
                  this.connectSensor(device);
                }
              })
            })
          }
          .width('100%')
          .padding({ left: 24, right: 24 })
          .layoutWeight(1) // 修改②：占据剩余空间，超出部分自动滚动
          .edgeEffect(EdgeEffect.Spring) // 弹性边缘效果
          .scrollBar(BarState.Auto)
        }

        if (this.errorMessage) {
          Text(this.errorMessage)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.Red)
            .textAlign(TextAlign.Center)
            .padding({ left: 24, right: 24 })
        }
      }
    }
    .width('100%')
    .padding({ top: 24 })
  }
}