/**
 * Start rehabilitation session page
 * UC-M1-02-02: Start rehabilitation session
 */
import { promptAction } from '@kit.ArkUI';
import { RehabilitationService, ExercisePlan, SessionState, SessionData, SessionCallback } from '../../service/RehabilitationService';
import { Logger } from '../../service/FileLoggerService';

const TAG = 'SessionSetup';

@ComponentV2
export struct SessionSetupPage {
  @Local exercises: ExercisePlan[] = [];
  @Local selectedExerciseId: string = '';
  @Local isLoading: boolean = false;
  @Local isSensorConnected: boolean = false;
  @Local errorMessage: string = '';

  private rehabService: RehabilitationService = RehabilitationService.getInstance();

  aboutToAppear(): void {
    console.error('===== SessionSetupPage aboutToAppear CALLED =====');
    Logger.debug(TAG, 'aboutToAppear called');
    this.checkSensorConnection();
    this.loadExercises();
  }

  aboutToDisappear(): void {
    Logger.debug(TAG, 'aboutToDisappear called');
    this.rehabService.offSessionStateChange(() => {});
  }

  private checkSensorConnection(): void {
    this.isSensorConnected = this.rehabService.isSensorConnected();
    Logger.debug(TAG, `checkSensorConnection: result=${this.isSensorConnected}`);
  }

  // [V2-TODO] Replace hardcoded exercises with V2 API: GET /exercises
  private loadExercises(): void {
    Logger.debug(TAG, 'loadExercises called');
    this.isLoading = true;

    setTimeout(() => {
      const ex1: ExercisePlan = {
        exerciseId: 'ex_001',
        exerciseName: 'Knee Flexion',
        description: 'Bend your knee slowly while keeping your back straight.',
        durationMinutes: 10,
        targetJointAngles: { knee: 30, hip: 45, ankle: 15 }
      };
      const ex2: ExercisePlan = {
        exerciseId: 'ex_002',
        exerciseName: 'Hip Extension',
        description: 'Extend your hip while keeping your knee straight.',
        durationMinutes: 8,
        targetJointAngles: { hip: 30, knee: 0, ankle: 10 }
      };
      const ex3: ExercisePlan = {
        exerciseId: 'ex_003',
        exerciseName: 'Ankle Rotation',
        description: 'Rotate your ankle in a circular motion.',
        durationMinutes: 5,
        targetJointAngles: { ankle: 20 }
      };
      const ex4: ExercisePlan = {
        exerciseId: 'ex_004',
        exerciseName: 'Leg Raise',
        description: 'Raise your leg while keeping it straight.',
        durationMinutes: 12,
        targetJointAngles: { knee: 0, hip: 60, ankle: 0 }
      };
      this.exercises = [ex1, ex2, ex3, ex4];
      this.isLoading = false;
      Logger.debug(TAG, `loadExercises done: ${this.exercises.length} exercises loaded`);
    }, 500);
  }

  onConnectSensor(): void {
    Logger.debug(TAG, 'onConnectSensor called');
    const storage = AppStorage.get<NavPathStack>('navPathStack');
    if (storage) {
      storage.pushPathByName('SensorConnection', undefined);
    }
  }

  onStartSession(): void {
    console.error('===== SessionSetupPage onStartSession CALLED =====');
    Logger.debug(TAG, `onStartSession called: selectedId=${this.selectedExerciseId}, sensorConnected=${this.isSensorConnected}`);

    if (this.selectedExerciseId.length === 0) {
      Logger.debug(TAG, 'onStartSession: no exercise selected, returning');
      this.errorMessage = 'Please select an exercise';
      return;
    }

    if (!this.isSensorConnected) {
      Logger.warn(TAG, 'onStartSession: sensor not connected, returning');
      this.errorMessage = 'Please connect the sensor first';
      return;
    }

    const selected: ExercisePlan | undefined = this.exercises.find((item: ExercisePlan): boolean =>
      item.exerciseId === this.selectedExerciseId
    );
    if (!selected) {
      Logger.error(TAG, `onStartSession: exercise not found for id=${this.selectedExerciseId}`);
      this.errorMessage = 'Invalid exercise selection';
      return;
    }

    Logger.info(TAG, `Starting session with exercise: ${selected.exerciseId} (${selected.exerciseName})`);
    this.isLoading = true;
    this.errorMessage = '';

    this.rehabService.onSessionStateChange((state: SessionState, data?: SessionData): void => {
      Logger.debug(TAG, `sessionStateChange callback: state=${state}`);
      if (state === 'active') {
        AppStorage.setOrCreate<ExercisePlan>('currentExercise', selected);
        const storage = AppStorage.get<NavPathStack>('navPathStack');
        if (storage) {
          Logger.debug(TAG, 'Navigating to SessionActive');
          storage.pushPathByName('SessionActive', undefined);
        }
        this.isLoading = false;
      } else if (state === 'idle' || state === 'ended') {
        Logger.debug(TAG, `Session state changed to ${state}, stopping loading`);
        this.isLoading = false;
      }
    });

    Logger.debug(TAG, 'Calling rehabService.startSession()');
    this.rehabService.startSession(selected).then((success: boolean): void => {
      Logger.debug(TAG, `startSession returned: success=${success}`);
      if (!success) {
        this.errorMessage = 'Unable to start session. Please check your connection.';
        this.isLoading = false;
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        if (this.isLoading) {
          this.LoadingView()
        } else if (!this.isSensorConnected) {
          this.SensorWarningView()
        } else {
          this.ExerciseListView()
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title('Start Session')
    .onBackPressed(() => {
      this.onBack();
      return true;
    })
  }

  @Builder
  LoadingView() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)

      Text('Loading...')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  SensorWarningView() {
    Column({ space: 24 }) {
      SymbolGlyph($r('sys.symbol.exclamationmark_triangle'))
        .fontSize(64)
        .fontColor([Color.Orange])

      Text('Sensor Not Connected')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)

      Text('Please connect your sensor before starting a session.')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
        .padding({ left: 24, right: 24 })

      Button('Connect Sensor')
        .width('80%')
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.icon_emphasize'))
        .fontColor(Color.White)
        .onClick(() => this.onConnectSensor())
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ExerciseListView() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
          .fontSize(16)
          .fontColor([Color.Green])
        Text('Sensor Connected')
          .fontSize($r('sys.float.Body_S'))
          .fontColor(Color.Green)
      }
      .width('100%')
      .padding({ left: 24 })

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(Color.Red)
          .padding({ left: 24, right: 24 })
      }

      Text('Select an Exercise')
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .padding({ left: 24 })

      List() {
        ForEach(this.exercises, (exercise: ExercisePlan) => {
          ListItem() {
            this.ExerciseCard(exercise)
          }
        })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .padding({ left: 24, right: 24 })

      Button('Start Session')
        .width('90%')
        .height(56)
        .borderRadius(28)
        .backgroundColor(this.selectedExerciseId.length > 0 ? $r('sys.color.icon_emphasize') : $r('sys.color.font_tertiary'))
        .fontColor(Color.White)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .enabled(this.selectedExerciseId.length > 0 && !this.isLoading)
        .onClick(() => this.onStartSession())
        .margin({ bottom: 10 })
    }
    .width('100%')
  }

  @Builder
  ExerciseCard(exercise: ExercisePlan) {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text(exercise.exerciseName)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium)

          Text(exercise.description)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.font_secondary'))
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        if (this.selectedExerciseId === exercise.exerciseId) {
          SymbolGlyph($r('sys.symbol.checkmark_circle_fill'))
            .fontSize(24)
            .fontColor([$r('sys.color.icon_emphasize')])
        }
      }

      Row({ space: 16 }) {
        Row({ space: 4 }) {
          SymbolGlyph($r('sys.symbol.clock'))
            .fontSize(14)
            .fontColor([$r('sys.color.font_tertiary')])
          Text(exercise.durationMinutes + ' min')
            .fontSize($r('sys.float.Caption_M'))
            .fontColor($r('sys.color.font_tertiary'))
        }

        if (exercise.targetJointAngles) {
          Row({ space: 4 }) {
            SymbolGlyph($r('sys.symbol.person'))
              .fontSize(14)
              .fontColor([$r('sys.color.font_tertiary')])
            Text('With guidance')
              .fontSize($r('sys.float.Caption_M'))
              .fontColor($r('sys.color.font_tertiary'))
          }
        }
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor(
      this.selectedExerciseId === exercise.exerciseId
        ? $r('sys.color.comp_background_list_card')
        : $r('sys.color.comp_background_list_card')
    )
    .borderRadius(16)
    .borderWidth(this.selectedExerciseId === exercise.exerciseId ? 2 : 0)
    .borderColor(this.selectedExerciseId === exercise.exerciseId ? $r('sys.color.icon_emphasize') : Color.Transparent)
    .onClick(() => {
      this.selectedExerciseId = exercise.exerciseId;
      this.errorMessage = '';
    })
  }

  onBack(): void {
    Logger.debug(TAG, 'onBack called');
    const storage = AppStorage.get<NavPathStack>('navPathStack');
    if (storage) {
      storage.pop();
    }
  }
}
