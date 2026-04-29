/**
 * Session result page
 * UC-M1-02-04: Session ended, show score summary
 */
import { promptAction } from '@kit.ArkUI';
import { SessionData } from '../../service/RehabilitationService';

interface ScoreGrade {
  grade: string;
  color: Color;
  emoji: string;
}

@ComponentV2
export struct SessionResultPage {
  @Local sessionData: SessionData | undefined = undefined;
  @Local exerciseName: string = 'Exercise';
  @Local isSaving: boolean = false;
  @Local saveSuccess: boolean = false;

  aboutToAppear(): void {
    const data: SessionData | undefined = AppStorage.get<SessionData>('currentSessionData');
    if (data) {
      this.sessionData = data;
      this.exerciseName = this.getExerciseNameFromId(this.sessionData.exerciseId);
    }
  }

  private getExerciseNameFromId(exerciseId: string): string {
    if (exerciseId === 'ex_001') return 'Knee Flexion';
    if (exerciseId === 'ex_002') return 'Hip Extension';
    if (exerciseId === 'ex_003') return 'Ankle Rotation';
    if (exerciseId === 'ex_004') return 'Leg Raise';
    return 'Exercise';
  }

  private formatDuration(milliseconds: number): string {
    const totalSeconds: number = Math.floor(milliseconds / 1000);
    const minutes: number = Math.floor(totalSeconds / 60);
    const seconds: number = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }

  private getScoreGrade(score: number): ScoreGrade {
    if (score >= 90) {
      const result: ScoreGrade = { grade: 'Excellent', color: Color.Green, emoji: '🌟' };
      return result;
    } else if (score >= 80) {
      const result: ScoreGrade = { grade: 'Great', color: Color.Green, emoji: '👍' };
      return result;
    } else if (score >= 70) {
      const result: ScoreGrade = { grade: 'Good', color: Color.Orange, emoji: '💪' };
      return result;
    } else if (score >= 60) {
      const result: ScoreGrade = { grade: 'Fair', color: Color.Orange, emoji: '🤔' };
      return result;
    } else {
      const result: ScoreGrade = { grade: 'Keep Trying', color: Color.Red, emoji: '📈' };
      return result;
    }
  }

  private calculateImprovement(): string {
    if (!this.sessionData?.scores || this.sessionData.scores.length < 2) {
      return 'N/A';
    }

    const firstScores: number[] = this.sessionData.scores.slice(0, 5);
    const lastScores: number[] = this.sessionData.scores.slice(-5);

    let firstSum: number = 0;
    for (let i = 0; i < firstScores.length; i++) {
      firstSum += firstScores[i];
    }
    const firstAvg: number = firstSum / firstScores.length;

    let lastSum: number = 0;
    for (let i = 0; i < lastScores.length; i++) {
      lastSum += lastScores[i];
    }
    const lastAvg: number = lastSum / lastScores.length;

    const improvement: number = lastAvg - firstAvg;
    const sign: string = improvement >= 0 ? '+' : '';
    return sign + improvement.toFixed(1);
  }

  private syncToServer(): void {
    this.isSaving = true;

    setTimeout((): void => {
      this.isSaving = false;
      this.saveSuccess = true;
      promptAction.showToast({
        message: 'Progress saved',
        duration: 2000
      });
    }, 1500);
  }

  onDone(): void {
    const storage = AppStorage.get<NavPathStack>('navPathStack');
    if (storage) {
      storage.clear();
    }
  }

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 24 }) {
            this.SuccessHeader()
            this.ScoreSummaryCard()
            this.DetailedStats()
            this.Achievements()
            this.SaveStatus()
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 24, bottom: 100 })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)

        Column() {
          Button('Done')
            .width('90%')
            .height(56)
            .borderRadius(28)
            .backgroundColor($r('sys.color.icon_emphasize'))
            .fontColor(Color.White)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Medium)
            .onClick(() => this.onDone())
        }
        .width('100%')
        .padding({ bottom: 24 })
        .backgroundColor($r('sys.color.background_primary'))
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title('')
    .hideBackButton(true)
  }

  @Builder
  SuccessHeader() {
    Column({ space: 16 }) {
      Text(this.getScoreGrade(this.sessionData?.averageScore ?? 0).emoji)
        .fontSize(64)

      Text('Session Complete!')
        .fontSize($r('sys.float.Title_L'))
        .fontWeight(FontWeight.Bold)

      Text(this.exerciseName)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_secondary'))

      Text(this.getScoreGrade(this.sessionData?.averageScore ?? 0).grade)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getScoreGrade(this.sessionData?.averageScore ?? 0).color)
        .padding({ top: 4 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: 24 })
  }

  @Builder
  ScoreSummaryCard() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 8 }) {
          Text('Total Score')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))

          Row({ space: 4 }) {
            Text((this.sessionData?.averageScore ?? 0).toFixed(0))
              .fontSize(48)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getScoreGrade(this.sessionData?.averageScore ?? 0).color)
            Text('/100')
              .fontSize($r('sys.float.Title_M'))
              .fontColor($r('sys.color.font_tertiary'))
          }
        }
        .alignItems(HorizontalAlign.Center)

        Blank()

        Column({ space: 8 }) {
          Text('Duration')
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))

          Text(this.formatDuration(this.sessionData?.duration ?? 0))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(24)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(24)
  }

  @Builder
  DetailedStats() {
    Column({ space: 12 }) {
      Text('Statistics')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .width('100%')

      Row() {
        this.StatItem(
          'Total Movements',
          (this.sessionData?.scores?.length ?? 0).toString(),
          $r('sys.symbol.list_bullet')
        )
        this.StatItem(
          'Improvement',
          this.calculateImprovement(),
          $r('sys.symbol.arrow_up_circle_fill')
        )
        this.StatItem(
          'Session ID',
          (this.sessionData?.sessionId ?? 'N/A').slice(0, 8) + '...',
          $r('sys.symbol.info_circle')
        )
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
  }

  @Builder
  StatItem(label: string, value: string, icon: Resource) {
    Column({ space: 8 }) {
      SymbolGlyph(icon)
        .fontSize(24)
        .fontColor([$r('sys.color.icon_emphasize')])

      Text(value)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Bold)

      Text(label)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  Achievements() {
    if ((this.sessionData?.averageScore ?? 0) >= 80) {
      Column({ space: 12 }) {
        Text('Achievements Unlocked')
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .width('100%')

        Row({ space: 16 }) {
          if ((this.sessionData?.averageScore ?? 0) >= 90) {
            this.AchievementBadge('🌟', 'Perfect Session', 'Score 90+')
            this.AchievementBadge('🔥', 'On Fire', 'Score 80+')
          } else {
            this.AchievementBadge('💪', 'Great Start', 'Score 80+')
          }
        }
        .width('100%')
      }
      .width('100%')
      .padding(16)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .borderRadius(16)
    }
  }

  @Builder
  AchievementBadge(emoji: string, title: string, subtitle: string) {
    Column({ space: 8 }) {
      Text(emoji)
        .fontSize(32)

      Text(title)
        .fontSize($r('sys.float.Body_S'))
        .fontWeight(FontWeight.Medium)

      Text(subtitle)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .padding(16)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(16)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SaveStatus() {
    Row() {
      if (this.isSaving) {
        LoadingProgress()
          .width(16)
          .height(16)
        Text('Saving...')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
      } else if (this.saveSuccess) {
        SymbolGlyph($r('sys.symbol.checkmark_circle'))
          .fontSize(16)
          .fontColor([Color.Green])
        Text('Saved')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor(Color.Green)
      } else {
        Text('Tap Done to return')
          .fontSize($r('sys.float.Caption_M'))
          .fontColor($r('sys.color.font_tertiary'))
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }
}
