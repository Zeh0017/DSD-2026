/**
 * Home page
 */
@ComponentV2
export struct HomePage {
  build() {
    Column() {
      Text('Main')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
  }
}
