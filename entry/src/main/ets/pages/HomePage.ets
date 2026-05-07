/**
 * Home page - Patient dashboard
 */
import { LocalStorageService } from '../service/LocalStorageService';
import { SessionData } from '../service/RehabilitationService';
import { LIMBS_TEAL } from '../designtoken/Color';

const BG: string = '#EEF9F6';
const TEXT_PRIMARY: string = '#1A1A2E';
const TEXT_SECONDARY: string = '#8A8FA8';
const CARD_BG: string = '#FFFFFF';
const ICON_BG: string = '#DCF5EF';

@ComponentV2
export struct HomePage {
  @Local username: string = '';
  @Local latestSession: SessionData | null = null;
  @Local hasSession: boolean = false;
  @Local selectedPainLevel: number = -1;

  private localStorage: LocalStorageService = LocalStorageService.getInstance();
  private painLevels: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  private getPainColor(level: number): string {
    if (level <= 2) return '#4CAF50';
    if (level <= 4) return '#8BC34A';
    if (level <= 6) return '#FFC107';
    if (level <= 8) return '#FF9800';
    return '#F44336';
  }

  private getPainLabel(level: number): string {
    if (level === 0) return 'No Pain';
    if (level <= 2) return 'Mild';
    if (level <= 4) return 'Moderate';
    if (level <= 6) return 'Significant';
    if (level <= 8) return 'Severe';
    return 'Worst Pain';
  }

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
      Column({ space: 22 }) {

        // ── Header ──────────────────────────────────────────────
        Row() {
          // Logo
          Row({ space: 10 }) {
            Image($r('app.media.app_icon'))
              .width(46)
              .height(46)
              .borderRadius(12)

            Column({ space: 1 }) {
              Text('LIMBS')
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor(TEXT_PRIMARY)
              Text('Motion')
                .fontSize(12)
                .fontColor(TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.Start)
          }

          Blank()

          // Notification bell
          Stack({ alignContent: Alignment.Center }) {
            Circle({ width: 42, height: 42 })
              .fill(CARD_BG)
            SymbolGlyph($r('sys.symbol.bell'))
              .fontSize(20)
              .fontColor([TEXT_PRIMARY])
          }
        }
        .width('100%')
        .padding({ top: 20 })

        // ── Welcome ─────────────────────────────────────────────
        Column({ space: 5 }) {
          Text('Welcome back,')
            .fontSize(15)
            .fontColor(TEXT_SECONDARY)

          Text(`Hello, ${this.username}!`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(TEXT_PRIMARY)

          Text("Keep going, you're making progress.")
            .fontSize(14)
            .fontColor(TEXT_SECONDARY)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // ── Start Training card ──────────────────────────────────
        Row({ space: 16 }) {
          Stack({ alignContent: Alignment.Center }) {
            Circle({ width: 52, height: 52 })
              .fill(ICON_BG)
            SymbolGlyph($r('sys.symbol.heart_circle_fill'))
              .fontSize(26)
              .fontColor([LIMBS_TEAL])
          }

          Column({ space: 5 }) {
            Text('Start Training')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)
            Text('Begin a new rehabilitation session')
              .fontSize(13)
              .fontColor(TEXT_SECONDARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Stack({ alignContent: Alignment.Center }) {
            Circle({ width: 36, height: 36 })
              .fill(ICON_BG)
            SymbolGlyph($r('sys.symbol.chevron_right'))
              .fontSize(16)
              .fontColor([LIMBS_TEAL])
          }
        }
        .width('100%')
        .padding(20)
        .borderRadius(20)
        .backgroundColor(CARD_BG)
        .shadow({ radius: 12, color: 'rgba(58,91,219,0.08)', offsetX: 0, offsetY: 4 })
        .onClick(() => {
          const nav = AppStorage.get<NavPathStack>('navPathStack');
          if (nav) {
            nav.pushPathByName('SessionSetup', null);
          }
        })

        // ── Stats row ────────────────────────────────────────────
        Row({ space: 12 }) {
          // Sessions Today
          Column({ space: 10 }) {
            Text('Sessions Today')
              .fontSize(13)
              .fontColor(TEXT_SECONDARY)

            Text('3/4')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)

            Stack({ alignContent: Alignment.Start }) {
              Row()
                .width('100%')
                .height(4)
                .backgroundColor('#E4E8F0')
                .borderRadius(2)
              Row()
                .width('75%')
                .height(4)
                .backgroundColor(LIMBS_TEAL)
                .borderRadius(2)
            }
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .padding({ left: 18, right: 18, top: 18, bottom: 18 })
          .borderRadius(20)
          .backgroundColor(CARD_BG)
          .shadow({ radius: 12, color: 'rgba(58,91,219,0.08)', offsetX: 0, offsetY: 4 })

          // Daily Goal
          Column({ space: 10 }) {
            Text('Daily Goal')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.75)')

            Text('75%')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.White)

            Stack({ alignContent: Alignment.Start }) {
              Row()
                .width('100%')
                .height(4)
                .backgroundColor('rgba(255,255,255,0.25)')
                .borderRadius(2)
              Row()
                .width('75%')
                .height(4)
                .backgroundColor(Color.White)
                .borderRadius(2)
            }
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          .padding({ left: 18, right: 18, top: 18, bottom: 18 })
          .borderRadius(20)
          .backgroundColor(LIMBS_TEAL)
          .shadow({ radius: 12, color: 'rgba(58,91,219,0.2)', offsetX: 0, offsetY: 4 })
        }
        .width('100%')

        // ── Latest Session or Appointment ────────────────────────
        if (this.hasSession && this.latestSession) {
          Column({ space: 14 }) {
            Text('Latest Session')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)
              .width('100%')

            Row() {
              Column({ space: 4 }) {
                Text(this.getExerciseName(this.latestSession.exerciseId))
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(TEXT_PRIMARY)
                Text(this.formatDate(this.latestSession.startTime))
                  .fontSize(12)
                  .fontColor(TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Column({ space: 4 }) {
                Text((this.latestSession.averageScore ?? 0).toFixed(0))
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(TEXT_PRIMARY)
                Text('Score')
                  .fontSize(12)
                  .fontColor(TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Center)

              Column({ space: 4 }) {
                Text(this.formatDuration(this.latestSession.duration ?? 0))
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(TEXT_PRIMARY)
                Text('Duration')
                  .fontSize(12)
                  .fontColor(TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Center)
              .margin({ left: 16 })
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .borderRadius(20)
          .backgroundColor(CARD_BG)
          .shadow({ radius: 12, color: 'rgba(58,91,219,0.08)', offsetX: 0, offsetY: 4 })

        } else {
          // Next Appointment placeholder
          Column({ space: 14 }) {
            Text('Next Appointment')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(TEXT_PRIMARY)
              .width('100%')

            Row({ space: 14 }) {
              Column({ space: 2 }) {
                SymbolGlyph($r('sys.symbol.calendar'))
                  .fontSize(18)
                  .fontColor([LIMBS_TEAL])
                Text('25')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(TEXT_PRIMARY)
                Text('Apr')
                  .fontSize(11)
                  .fontColor(TEXT_SECONDARY)
              }
              .width(56)
              .height(56)
              .borderRadius(14)
              .backgroundColor(ICON_BG)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              Column({ space: 5 }) {
                Text('Dr. Ana Rodrigues')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(TEXT_PRIMARY)
                Row({ space: 4 }) {
                  Text('10:30')
                    .fontSize(13)
                    .fontColor(TEXT_SECONDARY)
                  Text('•')
                    .fontSize(13)
                    .fontColor(TEXT_SECONDARY)
                  Text('In Clinic')
                    .fontSize(13)
                    .fontColor(LIMBS_TEAL)
                    .fontWeight(FontWeight.Medium)
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('View >')
                .fontSize(14)
                .fontColor(LIMBS_TEAL)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .borderRadius(20)
          .backgroundColor(CARD_BG)
          .shadow({ radius: 12, color: 'rgba(58,91,219,0.08)', offsetX: 0, offsetY: 4 })
        }

        // ── Pain Check In ────────────────────────────────────────
        this.PainCheckInCard()

      }
      .width('100%')
      .padding({ left: 24, right: 24, bottom: 36 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG)
  }

  @Builder
  PainCheckInCard() {
    Column({ space: 14 }) {
      // Header
      Column({ space: 3 }) {
        Text('Pain Check In')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(TEXT_PRIMARY)
        Text('How is your pain level today?')
          .fontSize(13)
          .fontColor(TEXT_SECONDARY)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // Scale 0–10
      Row() {
        ForEach(this.painLevels, (level: number) => {
          Column() {
            Stack({ alignContent: Alignment.Center }) {
              Circle()
                .width(26)
                .height(26)
                .fill(this.selectedPainLevel === level ? this.getPainColor(level) : '#F0F2F5')
              Text(level.toString())
                .fontSize(10)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.selectedPainLevel === level ? Color.White : TEXT_SECONDARY)
            }
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.selectedPainLevel = level;
          })
        }, (level: number) => level.toString())
      }
      .width('100%')

      // Min / Max labels
      Row() {
        Text('No Pain')
          .fontSize(11)
          .fontColor(TEXT_SECONDARY)
        Blank()
        Text('Worst Pain')
          .fontSize(11)
          .fontColor(TEXT_SECONDARY)
      }
      .width('100%')

      // Selected feedback
      if (this.selectedPainLevel >= 0) {
        Text(`Level ${this.selectedPainLevel} — ${this.getPainLabel(this.selectedPainLevel)}`)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getPainColor(this.selectedPainLevel))
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(20)
    .borderRadius(20)
    .backgroundColor(CARD_BG)
    .shadow({ radius: 12, color: 'rgba(61,201,167,0.08)', offsetX: 0, offsetY: 4 })
  }
}
