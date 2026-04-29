if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
import promptAction from "@ohos:promptAction";
export class RegisterPage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.username = '';
        this.password = '';
        this.confirmPassword = '';
        this.showPassword = false;
        this.isLoading = false;
        this.errorMessage = '';
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.username = '';
        this.password = '';
        this.confirmPassword = '';
        this.showPassword = false;
        this.isLoading = false;
        this.errorMessage = '';
    }
    @Local
    username: string;
    @Local
    password: string;
    @Local
    confirmPassword: string;
    @Local
    showPassword: boolean;
    @Local
    isLoading: boolean;
    @Local
    errorMessage: string;
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
                    Scroll.layoutWeight(1);
                    Scroll.scrollBar(BarState.Off);
                }, Scroll);
                this.observeComponentCreation2((elmtId, isInitialRender) => {
                    Column.create({ space: 24 });
                    Column.width('100%');
                    Column.padding({ left: 24, right: 24, top: 16 });
                }, Column);
                this.HeaderArea.bind(this)();
                this.RegisterForm.bind(this)();
                Column.pop();
                Scroll.pop();
                Column.pop();
            }, { moduleName: "entry", pagePath: "entry/src/main/ets/pages/RegisterPage" });
            NavDestination.title('Create Account');
            NavDestination.hideBackButton(false);
        }, NavDestination);
        NavDestination.pop();
    }
    HeaderArea(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 8 });
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
            Column.margin({ top: 16, bottom: 8 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create({ "id": 125832139, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(48);
            SymbolGlyph.fontColor([{ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Create Your Account');
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontWeight(FontWeight.Bold);
            Text.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Sign up to start your rehabilitation journey');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.textAlign(TextAlign.Center);
        }, Text);
        Text.pop();
        Column.pop();
    }
    RegisterForm(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Username
            Column.create({ space: 8 });
            // Username
            Column.width('100%');
            // Username
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Username');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.width('100%');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'At least 3 characters', text: this.username });
            TextInput.width('100%');
            TextInput.height(48);
            TextInput.borderRadius(12);
            TextInput.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            TextInput.onChange((value: string) => {
                this.username = value;
                this.errorMessage = '';
            });
        }, TextInput);
        // Username
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Password
            Column.create({ space: 8 });
            // Password
            Column.width('100%');
            // Password
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Password');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.width('100%');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create();
            Row.width('100%');
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'At least 6 characters', text: this.password });
            TextInput.width('100%');
            TextInput.height(48);
            TextInput.borderRadius(12);
            TextInput.type(this.showPassword ? InputType.Normal : InputType.Password);
            TextInput.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            TextInput.onChange((value: string) => {
                this.password = value;
                this.errorMessage = '';
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithChild({ type: ButtonType.Circle });
            Button.width(40);
            Button.height(40);
            Button.backgroundColor(Color.Transparent);
            Button.margin({ left: -48 });
            Button.onClick(() => {
                this.showPassword = !this.showPassword;
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create(this.showPassword ? { "id": 125832272, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125832271, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(20);
            SymbolGlyph.fontColor([{ "id": 125830992, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        Button.pop();
        Row.pop();
        // Password
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Confirm Password
            Column.create({ space: 8 });
            // Confirm Password
            Column.width('100%');
            // Confirm Password
            Column.alignItems(HorizontalAlign.Start);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Confirm Password');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.width('100%');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: 'Re-enter your password', text: this.confirmPassword });
            TextInput.width('100%');
            TextInput.height(48);
            TextInput.borderRadius(12);
            TextInput.type(this.showPassword ? InputType.Normal : InputType.Password);
            TextInput.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            TextInput.onChange((value: string) => {
                this.confirmPassword = value;
                this.errorMessage = '';
            });
        }, TextInput);
        // Confirm Password
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // Error message
            if (this.errorMessage) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create(this.errorMessage);
                        Text.fontSize({ "id": 125830974, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
                        Text.fontColor(Color.Red);
                        Text.width('100%');
                        Text.margin({ top: 4 });
                    }, Text);
                    Text.pop();
                });
            }
            // Register button
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Register button
            Button.createWithLabel(this.isLoading ? 'Creating...' : 'Create Account');
            // Register button
            Button.width('100%');
            // Register button
            Button.height(48);
            // Register button
            Button.borderRadius(24);
            // Register button
            Button.backgroundColor({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Register button
            Button.fontColor(Color.White);
            // Register button
            Button.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Register button
            Button.fontWeight(FontWeight.Medium);
            // Register button
            Button.enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0 && this.confirmPassword.length > 0);
            // Register button
            Button.margin({ top: 8 });
            // Register button
            Button.onClick(() => {
                this.handleRegister();
            });
        }, Button);
        // Register button
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Back to login link
            Row.create();
            // Back to login link
            Row.margin({ top: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Already have an account?  ');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Sign In');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830986, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.onClick(() => {
                this.goBack();
            });
        }, Text);
        Text.pop();
        // Back to login link
        Row.pop();
        Column.pop();
    }
    private handleRegister(): void {
        // Validate username
        if (this.username.length < 3) {
            this.errorMessage = 'Username must be at least 3 characters';
            return;
        }
        // Validate password
        if (this.password.length < 6) {
            this.errorMessage = 'Password must be at least 6 characters';
            return;
        }
        // Validate confirm password
        if (this.password !== this.confirmPassword) {
            this.errorMessage = 'Passwords do not match';
            return;
        }
        this.isLoading = true;
        // Simulate registration request
        setTimeout(() => {
            this.isLoading = false;
            // Simulate success - auto login after registration
            AppStorage.setOrCreate<boolean>('isLoggedIn', true);
            AppStorage.setOrCreate<string>('registeredUser', this.username);
            promptAction.showToast({
                message: 'Account created successfully!',
                duration: 2000
            });
            // Navigate back to ProfilePage (now logged in)
            const nav = AppStorage.get<NavPathStack>('navPathStack');
            if (nav) {
                nav.pop();
            }
        }, 1500);
    }
    private goBack(): void {
        const nav = AppStorage.get<NavPathStack>('navPathStack');
        if (nav) {
            nav.pop();
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
}
