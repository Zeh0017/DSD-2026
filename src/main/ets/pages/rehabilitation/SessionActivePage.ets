/**
 * Session active page
 * UC-M1-02-03: Realtime motion feedback
 */
import {
  RehabilitationService,
  ExercisePlan,
  RealtimeRecognitionResult,
  AlertFlag,
  SessionState,
  SessionData
} from '../../service/RehabilitationService';

interface ScoreGrade {
  grade: string;
  color: Color;
  emoji: string;
}

@ComponentV2
export struct SessionActivePage {
  @Local exercise: ExercisePlan | undefined = undefined;
  @Local sessionState: SessionState = 'idle';
  @Local elapsedTime: number = 0;
  @Local currentScore: number = 100;
  @Local avgScore: number = 0;
  @Local kneeAngle: number = 0;
  @Local hipAngle: number = 0;
  @Local ankleAngle: number = 0;
  @Local targetKneeAngle: number = 30;
  @Local targetHipAngle: number = 45;
  @Local targetAnkleAngle: number = 15;
  @Local currentAlerts: AlertFlag[] = [];
  @Local isPaused: boolean = false;
  @Local confidence: number = 1.0;
  @Local showEndConfirm: boolean = false;
  @Local isEnding: boolean = false;

  private rehabService: RehabilitationService = RehabilitationService.getInstance();
  private timer: number = -1;
  private startTime: number = 0;
  private scores: number[] = [];

  aboutToAppear(): void {
    const exerciseParam: ExercisePlan | undefined = AppStorage.get<ExercisePlan>('currentExercise');
    if (exerciseParam) {
      this.exercise = exerciseParam;
      if (this.exercise.targetJointAngles) {
        this.targetKneeAngle = this.exercise.targetJointAngles.knee ?? this.targetKneeAngle;
        this.targetHipAngle = this.exercise.targetJointAngles.hip ?? this.targetHipAngle;
        this.targetAnkleAngle = this.exercise.targetJointAngles.ankle ?? this.targetAnkleAngle;
      }
    }

    this.startTimer();
    this.registerCallbacks();
  }

  aboutToDisappear(): void {
    this.stopTimer();
    this.unregisterCallbacks();
  }

  private registerCallbacks(): void {
    this.rehabService.onSessionStateChange((state: SessionState, data?: SessionData): void => {
      this.sessionState = state;

      if (state === 'paused') {
        this.isPaused = true;
        this.stopTimer();
      } else if (state === 'active') {
        this.isPaused = false;
        this.startTimer();
      } else if (state === 'ended' && data) {
        this.navigateToResult(data);
      }
    });

    this.rehabService.onRealtimeData((result: RealtimeRecognitionResult): void => {
      this.updateDisplay(result);
    });

    this.rehabService.onAlert((alert: AlertFlag): void => {
      this.handleAlert(alert);
    });
  }

  private unregisterCallbacks(): void {
    this.rehabService.offSessionStateChange(() => {});
    this.rehabService.offRealtimeData(() => {});
    this.rehabService.offAlert(() => {});
  }

  private updateDisplay(result: RealtimeRecognitionResult): void {
    if (result.jointAngles) {
      this.kneeAngle = Math.round(result.jointAngles.knee ?? 0);
      this.hipAngle = Math.round(result.jointAngles.hip ?? 0);
      this.ankleAngle = Math.round(result.jointAngles.ankle ?? 0);
    }

    if (result.deviationScores) {
      this.currentScore = Math.round(result.deviationScores.overall);
      this.updateAverageScore(result.deviationScores.overall);
    }

    this.confidence = result.confidence;

    if (result.alertFlags.length > 0) {
      const newAlerts: AlertFlag[] = [];
      for (let i = 0; i < result.alertFlags.length; i++) {
        const flag: AlertFlag = result.alertFlags[i];
        const exists: boolean = this.currentAlerts.some((ca: AlertFlag): boolean =>
          ca.type === flag.type && ca.joint === flag.joint
        );
        if (!exists) {
          newAlerts.push(flag);
        }
      }
      if (newAlerts.length > 0) {
        const combined: AlertFlag[] = this.currentAlerts.concat(newAlerts);
        this.currentAlerts = combined.length > 3 ? combined.slice(combined.length - 3) : combined;
      }
    }
  }

  private updateAverageScore(score: number): void {
    this.scores.push(score);
    if (this.scores.length > 100) {
      this.scores = this.scores.slice(-100);
    }
    let sum: number = 0;
    for (let i = 0; i < this.scores.length; i++) {
      sum += this.scores[i];
    }
    this.avgScore = Math.round((sum / this.scores.length) * 10) / 10;
  }

  private handleAlert(alert: AlertFlag): void {
    const existingIndex: number = this.currentAlerts.findIndex((a: AlertFlag): boolean =>
      a.type === alert.type && a.joint === alert.joint
    );

    if (existingIndex >= 0) {
      this.currentAlerts[existingIndex] = alert;
    } else {
      this.currentAlerts.push(alert);
    }

    if (this.currentAlerts.length > 3) {
      this.currentAlerts = this.currentAlerts.slice(-3);
    }
  }

  private startTimer(): void {
    this.startTime = Date.now();
    this.timer = setInterval((): void => {
      if (!this.isPaused) {
        this.elapsedTime = Math.floor((Date.now() - this.startTime) / 1000);
      }
    }, 1000) as number;
  }

  private stopTimer(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  onPauseResume(): void {
    if (this.isPaused) {
      this.rehabService.resumeSession();
    } else {
      this.rehabService.pauseSession();
    }
  }

  onEndSession(): void {
    this.showEndConfirm = true;
  }

  confirmEndSession(): void {
    this.isEnding = true;
    this.rehabService.endSession();
  }

  cancelEndSession(): void {
    this.showEndConfirm = false;
  }

  private navigateToResult(data: SessionData): void {
    AppStorage.setOrCreate<SessionData>('currentSessionData', data);
    const storage = AppStorage.get<NavPathStack>('navPathStack');
    if (storage) {
      storage.pop();
      storage.pushPathByName('SessionResult', undefined);
    }
  }

  private formatTime(seconds: number): string {
    const mins: number = Math.floor(seconds / 60);
    const secs: number = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          this.TopBar()

          if (this.isPaused) {
            this.PausedOverlay()
          } else {
            Column() {
              this.JointVisualization()
              this.RealTimeData()
              this.AlertArea()
              this.ControlBar()
            }
          }
        }
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.background_primary'))

        if (this.showEndConfirm) {
          this.EndConfirmDialog()
        }
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .hideBackButton(true)
  }

  @Builder
  TopBar() {
    Column() {
      Row() {
        if (this.exercise) {
          Text(this.exercise.exerciseName)
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Bold)
        }

        Blank()

        Row({ space: 4 }) {
          if (this.confidence >= 0.8) {
            SymbolGlyph($r('sys.symbol.wifi'))
              .fontSize(14)
              .fontColor([Color.Green])
          } else if (this.confidence >= 0.5) {
            SymbolGlyph($r('sys.symbol.wifi'))
              .fontSize(14)
              .fontColor([Color.Orange])
          } else {
            SymbolGlyph($r('sys.symbol.wifi_slash'))
              .fontSize(14)
              .fontColor([Color.Red])
          }
          Text(this.confidence >= 0.8 ? 'Good tracking' : 'Tracking uncertain')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor(this.confidence >= 0.8 ? Color.Green : Color.Orange)
        }

        Row({ space: 8 }) {
          SymbolGlyph($r('sys.symbol.clock'))
            .fontSize(16)
            .fontColor([$r('sys.color.font_primary')])
          Text(this.formatTime(this.elapsedTime))
            .fontSize($r('sys.float.Subtitle_M'))
            .fontWeight(FontWeight.Bold)
        }
        .margin({ left: 16 })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .height(48)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }

  @Builder
  JointVisualization() {
    Column() {
      Stack() {
        Circle({ width: 200, height: 200 })
          .fill($r('sys.color.background_secondary'))
          .opacity(0.5)

        Row() {
          Circle({ width: 24, height: 24 })
            .fill($r('sys.color.icon_emphasize'))
          Text('Hip')
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 4 })
        }
        .position({ x: '50%', y: '30%' })

        Row() {
          Circle({ width: 24, height: 24 })
            .fill(this.getAngleColor(this.kneeAngle, this.targetKneeAngle))
          Text('Knee')
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 4 })
        }
        .position({ x: '50%', y: '50%' })

        Row() {
          Circle({ width: 24, height: 24 })
            .fill(this.getAngleColor(this.ankleAngle, this.targetAnkleAngle))
          Text('Ankle')
            .fontSize(10)
            .fontColor($r('sys.color.font_secondary'))
            .margin({ left: 4 })
        }
        .position({ x: '50%', y: '70%' })

        Column()
          .width(3)
          .height(80)
          .backgroundColor($r('sys.color.icon_tertiary'))
          .position({ x: 'calc(50% - 12px)', y: 'calc(35% - 40px)' })
          .rotate({ angle: (this.hipAngle - 90) })

        Column()
          .width(3)
          .height(80)
          .backgroundColor($r('sys.color.icon_tertiary'))
          .position({ x: 'calc(50% - 12px)', y: 'calc(55% - 40px)' })
          .rotate({ angle: (this.kneeAngle - 90) })
      }
      .width(200)
      .height(200)
      .margin({ top: 24 })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  RealTimeData() {
    Column({ space: 16 }) {
      Row() {
        Text('Score')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
        Blank()
        Text(this.currentScore.toString())
          .fontSize($r('sys.float.Title_L'))
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getScoreColor(this.currentScore))
        Text('/100')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_tertiary'))
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      Row({ space: 16 }) {
        this.JointAngleCard('Knee', this.kneeAngle, this.targetKneeAngle)
        this.JointAngleCard('Hip', this.hipAngle, this.targetHipAngle)
        this.JointAngleCard('Ankle', this.ankleAngle, this.targetAnkleAngle)
      }
      .width('100%')
      .padding({ left: 24, right: 24 })

      Row() {
        Text('Average Score')
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'))
        Blank()
        Text(this.avgScore.toFixed(1))
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
    }
    .margin({ top: 16 })
  }

  @Builder
  JointAngleCard(jointName: string, current: number, target: number) {
    Column({ space: 4 }) {
      Text(jointName)
        .fontSize($r('sys.float.Caption_M'))
        .fontColor($r('sys.color.font_tertiary'))

      Text(current.toString() + '°')
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getAngleColor(current, target))

      Text('Target: ' + target + '°')
        .fontSize(10)
        .fontColor($r('sys.color.font_tertiary'))
    }
    .width('30%')
    .padding(12)
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .borderRadius(12)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  AlertArea() {
    if (this.currentAlerts.length > 0) {
      Column({ space: 8 }) {
        ForEach(this.currentAlerts, (alert: AlertFlag) => {
          Row({ space: 8 }) {
            SymbolGlyph($r('sys.symbol.exclamationmark_circle_fill'))
              .fontSize(16)
              .fontColor([this.getAlertColor(alert.severity)])

            Text(alert.message)
              .fontSize($r('sys.float.Body_S'))
              .fontColor(this.getAlertColor(alert.severity))
          }
          .width('100%')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .borderRadius(8)
        })
      }
      .width('100%')
      .padding({ left: 24, right: 24 })
      .margin({ top: 16 })
    }
  }

  @Builder
  ControlBar() {
    Row() {
      Button() {
        SymbolGlyph(this.isPaused ? $r('sys.symbol.play_fill') : $r('sys.symbol.pause_fill'))
          .fontSize(24)
      }
      .type(ButtonType.Circle)
      .width(56)
      .height(56)
      .backgroundColor($r('sys.color.comp_background_list_card'))
      .onClick(() => this.onPauseResume())

      Button('End Session')
        .width('60%')
        .height(56)
        .borderRadius(28)
        .backgroundColor(Color.Red)
        .fontColor(Color.White)
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .enabled(!this.isEnding)
        .onClick(() => this.onEndSession())
    }
    .width('100%')
    .padding({ left: 24, right: 24, bottom: 24 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .margin({ top: 'auto' })
  }

  @Builder
  PausedOverlay() {
    Column() {
      SymbolGlyph($r('sys.symbol.pause_fill'))
        .fontSize(80)
        .fontColor([$r('sys.color.icon_tertiary')])

      Text('Session Paused')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .margin({ top: 24 })

      Text('Take a break. Your progress is saved.')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 8 })

      Row({ space: 24 }) {
        Button('Resume')
          .width(140)
          .height(48)
          .borderRadius(24)
          .backgroundColor($r('sys.color.icon_emphasize'))
          .fontColor(Color.White)
          .onClick(() => this.onPauseResume())

        Button('End Session')
          .width(140)
          .height(48)
          .borderRadius(24)
          .backgroundColor(Color.Red)
          .fontColor(Color.White)
          .onClick(() => this.onEndSession())
      }
      .margin({ top: 48 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.background_primary'))
  }

  @Builder
  EndConfirmDialog() {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.5)')
        .onClick(() => this.cancelEndSession())

      Column({ space: 16 }) {
        Text('End Session?')
          .fontSize($r('sys.float.Title_S'))
          .fontWeight(FontWeight.Bold)

        Text('Are you sure you want to end this session? Your progress will be saved.')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .textAlign(TextAlign.Center)

        Row({ space: 16 }) {
          Button('Cancel')
            .width('45%')
            .height(44)
            .borderRadius(22)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .fontColor($r('sys.color.font_primary'))
            .onClick(() => this.cancelEndSession())

          Button('End')
            .width('45%')
            .height(44)
            .borderRadius(22)
            .backgroundColor(Color.Red)
            .fontColor(Color.White)
            .onClick(() => this.confirmEndSession())
        }
      }
      .width('80%')
      .padding(24)
      .backgroundColor($r('sys.color.background_primary'))
      .borderRadius(24)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  private getAngleColor(current: number, target: number): Color {
    const deviation: number = Math.abs(current - target);
    if (deviation <= 10) return Color.Green;
    if (deviation <= 20) return Color.Orange;
    return Color.Red;
  }

  private getScoreColor(score: number): Color {
    if (score >= 80) return Color.Green;
    if (score >= 60) return Color.Orange;
    return Color.Red;
  }

  private getAlertColor(severity: string): Color {
    if (severity === 'high') return Color.Red;
    return Color.Orange;
  }
}
