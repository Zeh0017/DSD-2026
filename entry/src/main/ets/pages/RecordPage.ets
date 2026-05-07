/**
 * Progress page - Training progress & analytics
 * [TODO] Implement progress charts, session history, and performance trends
 *        using data from V2 API: GET /sessions?userId=... and GET /measurements/:sessionId
 */
import { LIMBS_TEAL } from '../designtoken/Color';

@ComponentV2
export struct RecordPage {
  build() {
    Column({ space: 16 }) {
      SymbolGlyph($r('sys.symbol.list_bullet'))
        .fontSize(64)
        .fontColor([LIMBS_TEAL])

      Text('Work in Progress')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')

      Text('Progress tracking is coming soon.\nSession history, charts, and performance\nanalysis will be available here.')
        .fontSize(14)
        .fontColor('#8A8A8A')
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F2F4F7')
  }
}
