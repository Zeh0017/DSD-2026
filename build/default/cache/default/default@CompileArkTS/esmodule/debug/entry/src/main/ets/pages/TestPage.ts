if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
export class TestPage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.navStack = AppStorage.get<NavPathStack>('navPathStack') as NavPathStack;
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
    }
    private navStack: NavPathStack;
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Scroll.create();
            Scroll.width('100%');
            Scroll.height('100%');
            Scroll.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Scroll);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 24 });
            Column.width('100%');
            Column.padding({ left: 24, right: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Title area
            Column.create({ space: 8 });
            // Title area
            Column.width('100%');
            // Title area
            Column.alignItems(HorizontalAlign.Start);
            // Title area
            Column.margin({ top: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Rehab Training');
            Text.fontSize({ "id": 125830964, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Connect sensors and start your rehab training');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        // Title area
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Start training card
            Column.create({ space: 16 });
            // Start training card
            Column.width('100%');
            // Start training card
            Column.padding(20);
            // Start training card
            Column.borderRadius(16);
            // Start training card
            Column.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 12 });
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125831546, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(32);
            SymbolGlyph.fontColor([{ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 4 });
            Column.alignItems(HorizontalAlign.Start);
            Column.layoutWeight(1);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Start Training');
            Text.fontSize({ "id": 125830967, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Medium);
            Text.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Connect BLE sensor for real-time rehab training');
            Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Column.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('Connect Sensor');
            Button.width('100%');
            Button.height(48);
            Button.borderRadius(24);
            Button.backgroundColor({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontColor(Color.White);
            Button.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Button.fontWeight(FontWeight.Medium);
            Button.onClick(() => {
                this.navStack.pushPathByName('SensorConnection', null);
            });
        }, Button);
        Button.pop();
        // Start training card
        Column.pop();
        Column.pop();
        Scroll.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
}
