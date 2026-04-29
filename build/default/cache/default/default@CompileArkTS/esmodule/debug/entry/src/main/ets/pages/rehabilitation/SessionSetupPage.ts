if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
import { RehabilitationService } from "@normalized:N&&&entry/src/main/ets/service/RehabilitationService&";
import type { ExercisePlan, SessionState, SessionData } from "@normalized:N&&&entry/src/main/ets/service/RehabilitationService&";
export class SessionSetupPage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.exercises = [];
        this.selectedExerciseId = '';
        this.isLoading = false;
        this.isSensorConnected = false;
        this.errorMessage = '';
        this.rehabService = RehabilitationService.getInstance();
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.exercises = [];
        this.selectedExerciseId = '';
        this.isLoading = false;
        this.isSensorConnected = false;
        this.errorMessage = '';
    }
    @Local
    exercises: ExercisePlan[];
    @Local
    selectedExerciseId: string;
    @Local
    isLoading: boolean;
    @Local
    isSensorConnected: boolean;
    @Local
    errorMessage: string;
    private rehabService: RehabilitationService;
    aboutToAppear(): void {
        this.checkSensorConnection();
        this.loadExercises();
    }
    aboutToDisappear(): void {
        this.rehabService.offSessionStateChange(() => { });
    }
    private checkSensorConnection(): void {
        this.isSensorConnected = this.rehabService.isSensorConnected();
    }
    private loadExercises(): void {
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
        }, 500);
    }
    onConnectSensor(): void {
        const storage = AppStorage.get<NavPathStack>('navPathStack');
        if (storage) {
            storage.pushPathByName('SensorConnection', undefined);
        }
    }
    onStartSession(): void {
        if (this.selectedExerciseId.length === 0) {
            this.errorMessage = 'Please select an exercise';
            return;
        }
        if (!this.isSensorConnected) {
            this.errorMessage = 'Please connect the sensor first';
            return;
        }
        const selected: ExercisePlan | undefined = this.exercises.find((item: ExercisePlan): boolean => item.exerciseId === this.selectedExerciseId);
        if (!selected) {
            this.errorMessage = 'Invalid exercise selection';
            return;
        }
        this.isLoading = true;
        this.errorMessage = '';
        this.rehabService.onSessionStateChange((state: SessionState, data?: SessionData): void => {
            if (state === 'active') {
                AppStorage.setOrCreate<ExercisePlan>('currentExercise', selected);
                const storage = AppStorage.get<NavPathStack>('navPathStack');
                if (storage) {
                    storage.pushPathByName('SessionActive', undefined);
                }
                this.isLoading = false;
            }
            else if (state === 'idle' || state === 'ended') {
                this.isLoading = false;
            }
        });
        this.rehabService.startSession(selected).then((success: boolean): void => {
            if (!success) {
                this.errorMessage = 'Unable to start session. Please check your connection.';
                this.isLoading = false;
            }
        });
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
                this.TitleBar.bind(this)();
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    If.create();
                    if (this.isLoading) {
                        this.ifElseBranchUpdateFunction(0, () => {
                            this.LoadingView.bind(this)();
                        });
                    }
                    else if (!this.isSensorConnected) {
                        this.ifElseBranchUpdateFunction(1, () => {
                            this.SensorWarningView.bind(this)();
                        });
                    }
                    else {
                        this.ifElseBranchUpdateFunction(2, () => {
                            this.ExerciseListView.bind(this)();
                        });
                    }
                }, If);
                If.pop();
                Column.pop();
            }, { moduleName: "entry", pagePath: "entry/src/main/ets/pages/rehabilitation/SessionSetupPage" });
            NavDestination.title('Start Session');
            NavDestination.onBackPressed(() => {
                this.onBack();
                return true;
            });
        }, NavDestination);
        NavDestination.pop();
    }
    TitleBar(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
            Row.height(56);
            Row.padding({ left: 12 });
            Row.alignItems(VerticalAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild();
            Button.type(ButtonType.Circle);
            Button.width(40);
            Button.height(40);
            Button.backgroundColor(Color.Transparent);
            Button.onClick(() => this.onBack());
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125832663, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(24);
        }, SymbolGlyph);
        Button.pop();
        Row.pop();
    }
    LoadingView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            LoadingProgress.create();
            LoadingProgress.width(48);
            LoadingProgress.height(48);
        }, LoadingProgress);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Loading...');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.margin({ top: 16 });
        }, Text);
        Text.pop();
        Column.pop();
    }
    SensorWarningView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 24 });
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125832652, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(64);
            SymbolGlyph.fontColor([Color.Orange]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Sensor Not Connected');
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Please connect your sensor before starting a session.');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.textAlign(TextAlign.Center);
            Text.padding({ left: 24, right: 24 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Connect Sensor');
            Button.width('80%');
            Button.height(48);
            Button.borderRadius(24);
            Button.backgroundColor({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontColor(Color.White);
            Button.onClick(() => this.onConnectSensor());
        }, Button);
        Button.pop();
        Column.pop();
    }
    ExerciseListView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 8 });
            Row.width('100%');
            Row.padding({ left: 24 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125831492, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(16);
            SymbolGlyph.fontColor([Color.Green]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Sensor Connected');
            Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor(Color.Green);
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.errorMessage) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.errorMessage);
                        Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor(Color.Red);
                        Text.padding({ left: 24, right: 24 });
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
            Text.create('Select an Exercise');
            Text.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
            Text.width('100%');
            Text.padding({ left: 24 });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            List.create();
            List.width('100%');
            List.layoutWeight(1);
            List.padding({ left: 24, right: 24 });
        }, List);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            ForEach.create();
            const forEachItemGenFunction = _item => {
                const exercise = _item;
                {
                    const itemCreation = (elmtId, isInitialRender) => {
                        ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                        ListItem.create(deepRenderFunction, true);
                        if (!isInitialRender) {
                            ListItem.pop();
                        }
                        ViewStackProcessor.StopGetAccessRecording();
                    };
                    const itemCreation2 = (elmtId, isInitialRender) => {
                        ListItem.create(deepRenderFunction, true);
                    };
                    const deepRenderFunction = (elmtId, isInitialRender) => {
                        itemCreation(elmtId, isInitialRender);
                        this.ExerciseCard.bind(this)(exercise);
                        ListItem.pop();
                    };
                    this.observeComponentCreation2(itemCreation2, ListItem);
                    ListItem.pop();
                }
            };
            this.forEachUpdateFunction(elmtId, this.exercises, forEachItemGenFunction);
        }, ForEach);
        ForEach.pop();
        List.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Start Session');
            Button.width('90%');
            Button.height(56);
            Button.borderRadius(28);
            Button.backgroundColor(this.selectedExerciseId.length > 0 ? { "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontColor(Color.White);
            Button.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontWeight(FontWeight.Medium);
            Button.enabled(this.selectedExerciseId.length > 0 && !this.isLoading);
            Button.onClick(() => this.onStartSession());
            Button.margin({ bottom: 24 });
        }, Button);
        Button.pop();
        Column.pop();
    }
    ExerciseCard(exercise: ExercisePlan, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 12 });
            Column.width('100%');
            Column.padding(16);
            Column.backgroundColor(this.selectedExerciseId === exercise.exerciseId
                ? { "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.borderRadius(16);
            Column.borderWidth(this.selectedExerciseId === exercise.exerciseId ? 2 : 0);
            Column.borderColor(this.selectedExerciseId === exercise.exerciseId ? { "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : Color.Transparent);
            Column.onClick(() => {
                this.selectedExerciseId = exercise.exerciseId;
                this.errorMessage = '';
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 4 });
            Column.alignItems(HorizontalAlign.Start);
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(exercise.exerciseName);
            Text.fontSize({ "id": 125830970, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(exercise.description);
            Text.fontSize({ "id": 125830972, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.maxLines(2);
            Text.textOverflow({ overflow: TextOverflow.Ellipsis });
        }, Text);
        Text.pop();
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.selectedExerciseId === exercise.exerciseId) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SymbolGlyph.create({ "id": 125831492, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        SymbolGlyph.fontSize(24);
                        SymbolGlyph.fontColor([{ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
                    }, SymbolGlyph);
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 4 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125832302, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(14);
            SymbolGlyph.fontColor([{ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(exercise.durationMinutes + ' min');
            Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (exercise.targetJointAngles) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Row.create({ space: 4 });
                    }, Row);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        SymbolGlyph.create({ "id": 125832135, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        SymbolGlyph.fontSize(14);
                        SymbolGlyph.fontColor([{ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
                    }, SymbolGlyph);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('With guidance');
                        Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor({ "id": 125830984, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                    }, Text);
                    Text.pop();
                    Row.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        Row.pop();
        Column.pop();
    }
    onBack(): void {
        const storage = AppStorage.get<NavPathStack>('navPathStack');
        if (storage) {
            storage.pop();
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
}
