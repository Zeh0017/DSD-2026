if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
import { RehabilitationService } from "@normalized:N&&&entry/src/main/ets/service/RehabilitationService&";
import type { ExercisePlan, RealtimeRecognitionResult, AlertFlag, SessionState, SessionData } from "@normalized:N&&&entry/src/main/ets/service/RehabilitationService&";
interface ScoreGrade {
    grade: string;
    color: Color;
    emoji: string;
}
export class SessionActivePage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.exercise = undefined;
        this.sessionState = 'idle';
        this.elapsedTime = 0;
        this.currentScore = 100;
        this.avgScore = 0;
        this.kneeAngle = 0;
        this.hipAngle = 0;
        this.ankleAngle = 0;
        this.targetKneeAngle = 30;
        this.targetHipAngle = 45;
        this.targetAnkleAngle = 15;
        this.currentAlerts = [];
        this.isPaused = false;
        this.confidence = 1.0;
        this.showEndConfirm = false;
        this.isEnding = false;
        this.rehabService = RehabilitationService.getInstance();
        this.timer = -1;
        this.startTime = 0;
        this.scores = [];
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.exercise = undefined;
        this.sessionState = 'idle';
        this.elapsedTime = 0;
        this.currentScore = 100;
        this.avgScore = 0;
        this.kneeAngle = 0;
        this.hipAngle = 0;
        this.ankleAngle = 0;
        this.targetKneeAngle = 30;
        this.targetHipAngle = 45;
        this.targetAnkleAngle = 15;
        this.currentAlerts = [];
        this.isPaused = false;
        this.confidence = 1.0;
        this.showEndConfirm = false;
        this.isEnding = false;
    }
    @Local
    exercise: ExercisePlan | undefined;
    @Local
    sessionState: SessionState;
    @Local
    elapsedTime: number;
    @Local
    currentScore: number;
    @Local
    avgScore: number;
    @Local
    kneeAngle: number;
    @Local
    hipAngle: number;
    @Local
    ankleAngle: number;
    @Local
    targetKneeAngle: number;
    @Local
    targetHipAngle: number;
    @Local
    targetAnkleAngle: number;
    @Local
    currentAlerts: AlertFlag[];
    @Local
    isPaused: boolean;
    @Local
    confidence: number;
    @Local
    showEndConfirm: boolean;
    @Local
    isEnding: boolean;
    private rehabService: RehabilitationService;
    private timer: number;
    private startTime: number;
    private scores: number[];
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
            }
            else if (state === 'active') {
                this.isPaused = false;
                this.startTimer();
            }
            else if (state === 'ended' && data) {
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
        this.rehabService.offSessionStateChange(() => { });
        this.rehabService.offRealtimeData(() => { });
        this.rehabService.offAlert(() => { });
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
                const exists: boolean = this.currentAlerts.some((ca: AlertFlag): boolean => ca.type === flag.type && ca.joint === flag.joint);
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
        const existingIndex: number = this.currentAlerts.findIndex((a: AlertFlag): boolean => a.type === alert.type && a.joint === alert.joint);
        if (existingIndex >= 0) {
            this.currentAlerts[existingIndex] = alert;
        }
        else {
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
        }
        else {
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            NavDestination.create(() => {
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Stack.create();
                    Stack.width('100%');
                    Stack.height('100%');
                }, Stack);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height('100%');
                    Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                }, Column);
                this.TopBar.bind(this)();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    If.create();
                    if (this.isPaused) {
                        this.ifElseBranchUpdateFunction(0, () => {
                            this.PausedOverlay.bind(this)();
                        });
                    }
                    else {
                        this.ifElseBranchUpdateFunction(1, () => {
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Column.create();
                            }, Column);
                            this.JointVisualization.bind(this)();
                            this.RealTimeData.bind(this)();
                            this.AlertArea.bind(this)();
                            this.ControlBar.bind(this)();
                            Column.pop();
                        });
                    }
                }, If);
                If.pop();
                Column.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    If.create();
                    if (this.showEndConfirm) {
                        this.ifElseBranchUpdateFunction(0, () => {
                            this.EndConfirmDialog.bind(this)();
                        });
                    }
                    else {
                        this.ifElseBranchUpdateFunction(1, () => {
                        });
                    }
                }, If);
                If.pop();
                Stack.pop();
            }, { moduleName: "entry", pagePath: "entry/src/main/ets/pages/rehabilitation/SessionActivePage" });
            NavDestination.title('');
            NavDestination.hideBackButton(true);
        }, NavDestination);
        NavDestination.pop();
    }
    TopBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.backgroundColor({ "id": 125831062, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 24, right: 24 });
            Row.height(48);
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.exercise) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.exercise.exerciseName);
                        Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontWeight(FontWeight.Bold);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 4 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.confidence >= 0.8) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SymbolGlyph.create({ "id": 125832033, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        SymbolGlyph.fontSize(14);
                        SymbolGlyph.fontColor([Color.Green]);
                    }, SymbolGlyph);
                });
            }
            else if (this.confidence >= 0.5) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SymbolGlyph.create({ "id": 125832033, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        SymbolGlyph.fontSize(14);
                        SymbolGlyph.fontColor([Color.Orange]);
                    }, SymbolGlyph);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SymbolGlyph.create({ "id": 125832925, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        SymbolGlyph.fontSize(14);
                        SymbolGlyph.fontColor([Color.Red]);
                    }, SymbolGlyph);
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.confidence >= 0.8 ? 'Good tracking' : 'Tracking uncertain');
            Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor(this.confidence >= 0.8 ? Color.Green : Color.Orange);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.margin({ left: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125832302, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(16);
            SymbolGlyph.fontColor([{ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.formatTime(this.elapsedTime));
            Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        Row.pop();
        Row.pop();
        Column.pop();
    }
    JointVisualization(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create();
            Stack.width(200);
            Stack.height(200);
            Stack.margin({ top: 24 });
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 200, height: 200 });
            Circle.fill({ "id": 125831062, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Circle.opacity(0.5);
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.position({ x: '50%', y: '30%' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 24, height: 24 });
            Circle.fill({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Hip');
            Text.fontSize(10);
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.margin({ left: 4 });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.position({ x: '50%', y: '50%' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 24, height: 24 });
            Circle.fill(this.getAngleColor(this.kneeAngle, this.targetKneeAngle));
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Knee');
            Text.fontSize(10);
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.margin({ left: 4 });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.position({ x: '50%', y: '70%' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Circle.create({ width: 24, height: 24 });
            Circle.fill(this.getAngleColor(this.ankleAngle, this.targetAnkleAngle));
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Ankle');
            Text.fontSize(10);
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.margin({ left: 4 });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(3);
            Column.height(80);
            Column.backgroundColor({ "id": 125830993, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.position({ x: 'calc(50% - 12px)', y: 'calc(35% - 40px)' });
            Column.rotate({ angle: (this.hipAngle - 90) });
        }, Column);
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width(3);
            Column.height(80);
            Column.backgroundColor({ "id": 125830993, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.position({ x: 'calc(50% - 12px)', y: 'calc(55% - 40px)' });
            Column.rotate({ angle: (this.kneeAngle - 90) });
        }, Column);
        Column.pop();
        Stack.pop();
        Column.pop();
    }
    RealTimeData(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.margin({ top: 16 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 24, right: 24 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Score');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.currentScore.toString());
            Text.fontSize({ "id": 125830964, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(this.getScoreColor(this.currentScore));
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('/100');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 16 });
            Row.width('100%');
            Row.padding({ left: 24, right: 24 });
        }, Row);
        this.JointAngleCard.bind(this)('Knee', this.kneeAngle, this.targetKneeAngle);
        this.JointAngleCard.bind(this)('Hip', this.hipAngle, this.targetHipAngle);
        this.JointAngleCard.bind(this)('Ankle', this.ankleAngle, this.targetAnkleAngle);
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 24, right: 24 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Average Score');
            Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.avgScore.toFixed(1));
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
            Text.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
    }
    JointAngleCard(jointName: string, current: number, target: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 4 });
            Column.width('30%');
            Column.padding(12);
            Column.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.borderRadius(12);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(jointName);
            Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(current.toString() + '°');
            Text.fontSize({ "id": 125830966, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(this.getAngleColor(current, target));
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Target: ' + target + '°');
            Text.fontSize(10);
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Column.pop();
    }
    AlertArea(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.currentAlerts.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create({ space: 8 });
                        Column.width('100%');
                        Column.padding({ left: 24, right: 24 });
                        Column.margin({ top: 16 });
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = _item => {
                            const alert = _item;
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Row.create({ space: 8 });
                                Row.width('100%');
                                Row.padding({ left: 12, right: 12, top: 8, bottom: 8 });
                                Row.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                Row.borderRadius(8);
                            }, Row);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                SymbolGlyph.create({ "id": 125832651, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                SymbolGlyph.fontSize(16);
                                SymbolGlyph.fontColor([this.getAlertColor(alert.severity)]);
                            }, SymbolGlyph);
                            this.observeComponentCreation2((elmtId, isInitialRender) => {
                                Text.create(alert.message);
                                Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                                Text.fontColor(this.getAlertColor(alert.severity));
                            }, Text);
                            Text.pop();
                            Row.pop();
                        };
                        this.forEachUpdateFunction(elmtId, this.currentAlerts, forEachItemGenFunction);
                    }, ForEach);
                    ForEach.pop();
                    Column.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
    }
    ControlBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.padding({ left: 24, right: 24, bottom: 24 });
            Row.justifyContent(FlexAlign.SpaceEvenly);
            Row.alignItems(VerticalAlign.Center);
            Row.margin({ top: 'auto' });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild();
            Button.type(ButtonType.Circle);
            Button.width(56);
            Button.height(56);
            Button.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.onClick(() => this.onPauseResume());
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create(this.isPaused ? { "id": 125831175, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125834191, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(24);
        }, SymbolGlyph);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('End Session');
            Button.width('60%');
            Button.height(56);
            Button.borderRadius(28);
            Button.backgroundColor(Color.Red);
            Button.fontColor(Color.White);
            Button.fontSize({ "id": 125830970, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontWeight(FontWeight.Medium);
            Button.enabled(!this.isEnding);
            Button.onClick(() => this.onEndSession());
        }, Button);
        Button.pop();
        Row.pop();
    }
    PausedOverlay(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
            Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125834191, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(80);
            SymbolGlyph.fontColor([{ "id": 125830993, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Session Paused');
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
            Text.margin({ top: 24 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Take a break. Your progress is saved.');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.margin({ top: 8 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 24 });
            Row.margin({ top: 48 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Resume');
            Button.width(140);
            Button.height(48);
            Button.borderRadius(24);
            Button.backgroundColor({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontColor(Color.White);
            Button.onClick(() => this.onPauseResume());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('End Session');
            Button.width(140);
            Button.height(48);
            Button.borderRadius(24);
            Button.backgroundColor(Color.Red);
            Button.fontColor(Color.White);
            Button.onClick(() => this.onEndSession());
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
    }
    EndConfirmDialog(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor('rgba(0, 0, 0, 0.5)');
            Column.onClick(() => this.cancelEndSession());
        }, Column);
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('80%');
            Column.padding(24);
            Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.borderRadius(24);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('End Session?');
            Text.fontSize({ "id": 125830966, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Are you sure you want to end this session? Your progress will be saved.');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Cancel');
            Button.width('45%');
            Button.height(44);
            Button.borderRadius(22);
            Button.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.onClick(() => this.cancelEndSession());
        }, Button);
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('End');
            Button.width('45%');
            Button.height(44);
            Button.borderRadius(22);
            Button.backgroundColor(Color.Red);
            Button.fontColor(Color.White);
            Button.onClick(() => this.confirmEndSession());
        }, Button);
        Button.pop();
        Row.pop();
        Column.pop();
        Column.pop();
    }
    private getAngleColor(current: number, target: number): Color {
        const deviation: number = Math.abs(current - target);
        if (deviation <= 10)
            return Color.Green;
        if (deviation <= 20)
            return Color.Orange;
        return Color.Red;
    }
    private getScoreColor(score: number): Color {
        if (score >= 80)
            return Color.Green;
        if (score >= 60)
            return Color.Orange;
        return Color.Red;
    }
    private getAlertColor(severity: string): Color {
        if (severity === 'high')
            return Color.Red;
        return Color.Orange;
    }
    rerender() {
        this.updateDirtyElements();
    }
}
