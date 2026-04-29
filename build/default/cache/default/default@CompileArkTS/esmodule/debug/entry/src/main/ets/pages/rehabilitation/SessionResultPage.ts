if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
import promptAction from "@ohos:promptAction";
import type { SessionData } from '../../service/RehabilitationService';
interface ScoreGrade {
    grade: string;
    color: Color;
    emoji: string;
}
export class SessionResultPage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.sessionData = undefined;
        this.exerciseName = 'Exercise';
        this.isSaving = false;
        this.saveSuccess = false;
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.sessionData = undefined;
        this.exerciseName = 'Exercise';
        this.isSaving = false;
        this.saveSuccess = false;
    }
    @Local
    sessionData: SessionData | undefined;
    @Local
    exerciseName: string;
    @Local
    isSaving: boolean;
    @Local
    saveSuccess: boolean;
    aboutToAppear(): void {
        const data: SessionData | undefined = AppStorage.get<SessionData>('currentSessionData');
        if (data) {
            this.sessionData = data;
            this.exerciseName = this.getExerciseNameFromId(this.sessionData.exerciseId);
        }
    }
    private getExerciseNameFromId(exerciseId: string): string {
        if (exerciseId === 'ex_001')
            return 'Knee Flexion';
        if (exerciseId === 'ex_002')
            return 'Hip Extension';
        if (exerciseId === 'ex_003')
            return 'Ankle Rotation';
        if (exerciseId === 'ex_004')
            return 'Leg Raise';
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
        }
        else if (score >= 80) {
            const result: ScoreGrade = { grade: 'Great', color: Color.Green, emoji: '👍' };
            return result;
        }
        else if (score >= 70) {
            const result: ScoreGrade = { grade: 'Good', color: Color.Orange, emoji: '💪' };
            return result;
        }
        else if (score >= 60) {
            const result: ScoreGrade = { grade: 'Fair', color: Color.Orange, emoji: '🤔' };
            return result;
        }
        else {
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
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            NavDestination.create(() => {
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.height('100%');
                    Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Scroll.create();
                    Scroll.width('100%');
                    Scroll.height('100%');
                    Scroll.scrollBar(BarState.Off);
                }, Scroll);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create({ space: 24 });
                    Column.width('100%');
                    Column.padding({ left: 24, right: 24, top: 24, bottom: 100 });
                }, Column);
                this.SuccessHeader.bind(this)();
                this.ScoreSummaryCard.bind(this)();
                this.DetailedStats.bind(this)();
                this.Achievements.bind(this)();
                this.SaveStatus.bind(this)();
                Column.pop();
                Scroll.pop();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create();
                    Column.width('100%');
                    Column.padding({ bottom: 24 });
                    Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                }, Column);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Button.createWithLabel('Done');
                    Button.width('90%');
                    Button.height(56);
                    Button.borderRadius(28);
                    Button.backgroundColor({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                    Button.fontColor(Color.White);
                    Button.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                    Button.fontWeight(FontWeight.Medium);
                    Button.onClick(() => this.onDone());
                }, Button);
                Button.pop();
                Column.pop();
                Column.pop();
            }, { moduleName: "entry", pagePath: "entry/src/main/ets/pages/rehabilitation/SessionResultPage" });
            NavDestination.title('');
            NavDestination.hideBackButton(true);
        }, NavDestination);
        NavDestination.pop();
    }
    SuccessHeader(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
            Column.padding({ top: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getScoreGrade(this.sessionData?.averageScore ?? 0).emoji);
            Text.fontSize(64);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Session Complete!');
            Text.fontSize({ "id": 125830964, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.exerciseName);
            Text.fontSize({ "id": 125830970, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.getScoreGrade(this.sessionData?.averageScore ?? 0).grade);
            Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
            Text.fontColor(this.getScoreGrade(this.sessionData?.averageScore ?? 0).color);
            Text.padding({ top: 4 });
        }, Text);
        Text.pop();
        Column.pop();
    }
    ScoreSummaryCard(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
            Column.padding(24);
            Column.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.borderRadius(24);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 8 });
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Total Score');
            Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 4 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create((this.sessionData?.averageScore ?? 0).toFixed(0));
            Text.fontSize(48);
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor(this.getScoreGrade(this.sessionData?.averageScore ?? 0).color);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('/100');
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Row.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Blank.create();
        }, Blank);
        Blank.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 8 });
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Duration');
            Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(this.formatDuration(this.sessionData?.duration ?? 0));
            Text.fontSize(32);
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        Column.pop();
    }
    DetailedStats(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.borderRadius(16);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Statistics');
            Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
            Text.width('100%');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.SpaceEvenly);
        }, Row);
        this.StatItem.bind(this)('Total Movements', (this.sessionData?.scores?.length ?? 0).toString(), { "id": 125831650, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        this.StatItem.bind(this)('Improvement', this.calculateImprovement(), { "id": 125832673, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        this.StatItem.bind(this)('Session ID', (this.sessionData?.sessionId ?? 'N/A').slice(0, 8) + '...', { "id": 125832646, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        Row.pop();
        Column.pop();
    }
    StatItem(label: string, value: string, icon: Resource, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 8 });
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create(icon);
            SymbolGlyph.fontSize(24);
            SymbolGlyph.fontColor([{ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(value);
            Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(label);
            Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Column.pop();
    }
    Achievements(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if ((this.sessionData?.averageScore ?? 0) >= 80) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Column.create({ space: 12 });
                        Column.width('100%');
                        Column.padding(16);
                        Column.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Column.borderRadius(16);
                    }, Column);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Achievements Unlocked');
                        Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontWeight(FontWeight.Medium);
                        Text.width('100%');
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create({ space: 16 });
                        Row.width('100%');
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        If.create();
                        if ((this.sessionData?.averageScore ?? 0) >= 90) {
                            this.ifElseBranchUpdateFunction(0, () => {
                                this.AchievementBadge.bind(this)('🌟', 'Perfect Session', 'Score 90+');
                                this.AchievementBadge.bind(this)('🔥', 'On Fire', 'Score 80+');
                            });
                        }
                        else {
                            this.ifElseBranchUpdateFunction(1, () => {
                                this.AchievementBadge.bind(this)('💪', 'Great Start', 'Score 80+');
                            });
                        }
                    }, If);
                    If.pop();
                    Row.pop();
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
    AchievementBadge(emoji: string, title: string, subtitle: string, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 8 });
            Column.padding(16);
            Column.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.borderRadius(16);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(emoji);
            Text.fontSize(32);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(title);
            Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(subtitle);
            Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Column.pop();
    }
    SaveStatus(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isSaving) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        LoadingProgress.create();
                        LoadingProgress.width(16);
                        LoadingProgress.height(16);
                    }, LoadingProgress);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Saving...');
                        Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                    }, Text);
                    Text.pop();
                });
            }
            else if (this.saveSuccess) {
                this.ifElseBranchUpdateFunction(1, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SymbolGlyph.create({ "id": 125831133, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        SymbolGlyph.fontSize(16);
                        SymbolGlyph.fontColor([Color.Green]);
                    }, SymbolGlyph);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Saved');
                        Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor(Color.Green);
                    }, Text);
                    Text.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(2, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('Tap Done to return');
                        Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                    }, Text);
                    Text.pop();
                });
            }
        }, If);
        If.pop();
        Row.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
