/**
 * Record page - Training history
 * [V2-TODO] When V2 is available, replace local storage reads with V2 API:
 *   GET /sessions?userId=...&sort=desc
 */
import { LocalStorageService } from '../service/LocalStorageService';
import { SessionData } from '../service/RehabilitationService';

@ComponentV2
export struct RecordPage {
  @Local sessions: SessionData[] = [];
  @Local isLoading: boolean = true;

  private localStorage: LocalStorageService = LocalStorageService.getInstance();

  aboutToAppear(): void {
    this.loadSessions();
  }

  private async loadSessions(): Promise<void> {
    this.isLoading = true;
    this.sessions = await this.localStorage.getSessions();
    this.isLoading = false;
  }

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}m ${seconds}s`;
  }

  private formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const hours = date.getHours().toString().padStart(2, '0');
    const mins = date.getMinutes().toString().padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${mins}`;
  }

  private getExerciseName(exerciseId: string): string {
    if (exerciseId === 'ex_001') return 'Knee Flexion';
    if (exerciseId === 'ex_002') return 'Hip Extension';
    if (exerciseId === 'ex_003') return 'Ankle Rotation';
    if (exerciseId === 'ex_004') return 'Leg Raise';
    return 'Exercise';
  }

  private getScoreColor(score: number): Color {
    if (score >= 80) return Color.Green;
    if (score >= 60) return Color.Orange;
    return Color.Red;
  }

  build() {
    Column() {
      // Title
      Text('Training Records')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .padding({ left: 24, top: 24, bottom: 16 })

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(48)
            .height(48)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.sessions.length === 0) {
        this.EmptyStateView()
      } else {
        this.SessionListView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  EmptyStateView() {
    Column({ space: 16 }) {
      SymbolGlyph($r('sys.symbol.list_bullet'))
        .fontSize(64)
        .fontColor([$r('sys.color.icon_tertiary')])

      Text('No Records Yet')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_secondary'))

      Text('Complete a training session to see your history here.')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_tertiary'))
        .textAlign(TextAlign.Center)
        .padding({ left: 32, right: 32 })

      Button('Start Training')
        .width('60%')
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.icon_emphasize'))
        .fontColor(Color.White)
        .margin({ top: 16 })
        .onClick(() => {
          const nav = AppStorage.get<NavPathStack>('navPathStack');
          if (nav) {
            nav.pushPathByName('SessionSetup', null);
          }
        })
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SessionListView() {
    List() {
      ForEach(this.sessions, (session: SessionData) => {
        ListItem() {
          this.SessionCard(session)
        }
      })
    }
    .width('100%')
    .layoutWeight(1)
    .padding({ left: 24, right: 24 })
  }

  @Builder
  SessionCard(session: SessionData) {
    Column({ space: 8 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.getExerciseName(session.exerciseId))
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))

          Text(this.formatDate(session.startTime))
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_tertiary'))
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Text((session.averageScore ?? 0).toFixed(0))
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getScoreColor(session.averageScore ?? 0))
      }
      .width('100%')

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.clock'))
            .fontSize(14)
            .fontColor([$r('sys.color.font_tertiary')])
          Text(this.formatDuration(session.duration ?? 0))
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_tertiary'))
        }

        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.list_bullet'))
            .fontSize(14)
            .fontColor([$r('sys.color.font_tertiary')])
          Text((session.scores?.length ?? 0).toString() + ' movements')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_tertiary'))
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .margin({ bottom: 12 })
  }
}
