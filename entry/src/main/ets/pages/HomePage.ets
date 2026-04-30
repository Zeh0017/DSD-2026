/**
 * Home page - Patient dashboard
 */
import { LocalStorageService } from '../service/LocalStorageService';
import { SessionData } from '../service/RehabilitationService';

@ComponentV2
export struct HomePage {
  @Local username: string = '';
  @Local latestSession: SessionData | null = null;
  @Local hasSession: boolean = false;

  private localStorage: LocalStorageService = LocalStorageService.getInstance();

  aboutToAppear(): void {
    this.username = AppStorage.get<string>('registeredUser') ?? 'Patient';
    this.loadLatestSession();
  }

  private async loadLatestSession(): Promise<void> {
    const session = await this.localStorage.getLatestSession();
    if (session) {
      this.latestSession = session;
      this.hasSession = true;
    }
  }

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const mins = date.getMinutes().toString().padStart(2, '0');
    return `${month}/${day} ${hours}:${mins}`;
  }

  private getExerciseName(exerciseId: string): string {
    if (exerciseId === 'ex_001') return 'Knee Flexion';
    if (exerciseId === 'ex_002') return 'Hip Extension';
    if (exerciseId === 'ex_003') return 'Ankle Rotation';
    if (exerciseId === 'ex_004') return 'Leg Raise';
    return 'Exercise';
  }

  build() {
    Scroll() {
      Column({ space: 24 }) {
        // Welcome area
        Column({ space: 8 }) {
          Text('Welcome back,')
            .fontSize($r('sys.float.Body_L'))
            .fontColor($r('sys.color.font_secondary'))

          Text(this.username)
            .fontSize($r('sys.float.Title_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 24 })

        // Quick start training card
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

              Text('Begin a new rehabilitation session')
                .fontSize($r('sys.float.Caption_M'))
                .fontColor($r('sys.color.font_secondary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_tertiary')])
          }
          .width('100%')
        }
        .width('100%')
        .padding(20)
        .borderRadius(16)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .onClick(() => {
          const nav = AppStorage.get<NavPathStack>('navPathStack');
          if (nav) {
            nav.pushPathByName('SessionSetup', null);
          }
        })

        // Latest session summary
        if (this.hasSession && this.latestSession) {
          Column({ space: 12 }) {
            Text('Latest Session')
              .fontSize($r('sys.float.Subtitle_M'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .width('100%')

            Row() {
              Column({ space: 4 }) {
                Text(this.getExerciseName(this.latestSession.exerciseId))
                  .fontSize($r('sys.float.Body_L'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))

                Text(this.formatDate(this.latestSession.startTime))
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 4 }) {
                Text((this.latestSession.averageScore ?? 0).toFixed(0))
                  .fontSize($r('sys.float.Title_M'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))

                Text('Score')
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text(this.formatDuration(this.latestSession.duration ?? 0))
                  .fontSize($r('sys.float.Title_M'))
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('sys.color.font_primary'))

                Text('Duration')
                  .fontSize($r('sys.float.Caption_M'))
                  .fontColor($r('sys.color.font_tertiary'))
              }
              .alignItems(HorizontalAlign.Center)
              .margin({ left: 16 })
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_list_card'))
        } else {
          // No session yet
          Column({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.list_bullet'))
              .fontSize(32)
              .fontColor([$r('sys.color.icon_tertiary')])

            Text('No training sessions yet')
              .fontSize($r('sys.float.Body_M'))
              .fontColor($r('sys.color.font_tertiary'))

            Text('Start your first session to see results here')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_tertiary'))
          }
          .width('100%')
          .padding(32)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .alignItems(HorizontalAlign.Center)
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }
}
