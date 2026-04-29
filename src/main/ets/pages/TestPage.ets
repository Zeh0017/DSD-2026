/**
 * Test page - Rehab training entry
 */
@ComponentV2
export struct TestPage {
  private navStack: NavPathStack = AppStorage.get<NavPathStack>('navPathStack') as NavPathStack;

  build() {
    Scroll() {
      Column({ space: 24 }) {
        // Title area
        Column({ space: 8 }) {
          Text('Rehab Training')
            .fontSize($r('sys.float.Title_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))

          Text('Connect sensors and start your rehab training')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 24 })

        // Start training card
        Column({ space: 16 }) {
          Row({ space: 12 }) {
            SymbolGlyph($r('sys.symbol.heart_circle_fill'))
              .fontSize(32)
              .fontColor([$r('sys.color.icon_emphasize')])

            Column({ space: 4 }) {
              Text('Start Training')
                .fontSize($r('sys.float.Subtitle_L'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))

              Text('Connect BLE sensor for real-time rehab training')
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')

          Button('Connect Sensor')
            .width('100%')
            .height(48)
            .borderRadius(24)
            .backgroundColor($r('sys.color.icon_emphasize'))
            .fontColor(Color.White)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => {
              this.navStack.pushPathByName('SensorConnection', null);
            })
        }
        .width('100%')
        .padding(20)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_list_card'))
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }
}
