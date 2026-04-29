if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
export class ProfilePage extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.isLoggedIn = false;
        this.username = '';
        this.password = '';
        this.showPassword = false;
        this.isLoading = false;
        this.errorMessage = '';
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.isLoggedIn = false;
        this.username = '';
        this.password = '';
        this.showPassword = false;
        this.isLoading = false;
        this.errorMessage = '';
    }
    @Local
    isLoggedIn: boolean;
    @Local
    username: string;
    @Local
    password: string;
    @Local
    showPassword: boolean;
    @Local
    isLoading: boolean;
    @Local
    errorMessage: string;
    aboutToAppear(): void {
        this.isLoggedIn = AppStorage.get<boolean>('isLoggedIn') ?? false;
        if (this.isLoggedIn) {
            this.username = AppStorage.get<string>('registeredUser') ?? '';
        }
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.width('100%');
            Column.height('100%');
            Column.backgroundColor({ "id": 125831061, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Column.padding({ left: 24, right: 24 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Title
            Text.create('Account');
            // Title
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Title
            Text.fontWeight(FontWeight.Bold);
            // Title
            Text.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Title
            Text.margin({ top: 60, bottom: 32 });
        }, Text);
        // Title
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (this.isLoggedIn) {
                this.ifElseBranchUpdateFunction(0, () => {
                    // Logged in state
                    this.LoggedInView.bind(this)();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                    // Login form
                    this.LoginForm.bind(this)();
                });
            }
        }, If);
        If.pop();
        Column.pop();
    }
    /**
     * Login form
     */
    LoginForm(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
            Column.margin({ top: 32 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Username input
            Column.create({ space: 8 });
            // Username input
            Column.width('100%');
            // Username input
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
            TextInput.create({ placeholder: 'username', text: this.username });
            TextInput.width('100%');
            TextInput.height(48);
            TextInput.borderRadius(12);
            TextInput.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            TextInput.onChange((value) => {
                this.username = value;
                this.errorMessage = '';
            });
        }, TextInput);
        // Username input
        Column.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Password input
            Column.create({ space: 8 });
            // Password input
            Column.width('100%');
            // Password input
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
            TextInput.create({ placeholder: 'Password', text: this.password });
            TextInput.width('100%');
            TextInput.height(48);
            TextInput.borderRadius(12);
            TextInput.type(this.showPassword ? InputType.Normal : InputType.Password);
            TextInput.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            TextInput.onChange((value) => {
                this.password = value;
                this.errorMessage = '';
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Show/hide password button
            Button.createWithChild({ type: ButtonType.Circle });
            // Show/hide password button
            Button.width(40);
            // Show/hide password button
            Button.height(40);
            // Show/hide password button
            Button.backgroundColor(Color.Transparent);
            // Show/hide password button
            Button.margin({ left: -48 });
            // Show/hide password button
            Button.onClick(() => {
                this.showPassword = !this.showPassword;
            });
        }, Button);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create(this.showPassword ? { "id": 125832272, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125832271, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            SymbolGlyph.fontSize(20);
            SymbolGlyph.fontColor([{ "id": 125830992, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        // Show/hide password button
        Button.pop();
        Row.pop();
        // Password input
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
            // Login button
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Login button
            Button.createWithLabel(this.isLoading ? 'Logging in...' : 'Log In');
            // Login button
            Button.width('100%');
            // Login button
            Button.height(48);
            // Login button
            Button.borderRadius(24);
            // Login button
            Button.backgroundColor({ "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Login button
            Button.fontColor(Color.White);
            // Login button
            Button.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Login button
            Button.fontWeight(FontWeight.Medium);
            // Login button
            Button.enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0);
            // Login button
            Button.margin({ top: 16 });
            // Login button
            Button.onClick(() => {
                this.handleLogin();
            });
        }, Button);
        // Login button
        Button.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Register link
            Row.create();
            // Register link
            Row.margin({ top: 16 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('No account? ');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('Create an account');
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.fontColor({ "id": 125830986, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            Text.onClick(() => {
                const nav = AppStorage.get<NavPathStack>('navPathStack');
                if (nav) {
                    nav.pushPathByName('Register', null);
                }
            });
        }, Text);
        Text.pop();
        // Register link
        Row.pop();
        Column.pop();
    }
    /**
     * Logged in view
     */
    LoggedInView(parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 16 });
            Column.width('100%');
            Column.alignItems(HorizontalAlign.Center);
            Column.margin({ top: 32 });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Avatar
            Circle.create({ width: 80, height: 80 });
            // Avatar
            Circle.fill({ "id": 125830992, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Circle);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Username
            Text.create(this.username);
            // Username
            Text.fontSize({ "id": 125830965, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Username
            Text.fontWeight(FontWeight.Bold);
            // Username
            Text.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        // Username
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Welcome message
            Text.create('Welcome!');
            // Welcome message
            Text.fontSize({ "id": 125830971, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Welcome message
            Text.fontColor({ "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        // Welcome message
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // Logout button
            Button.createWithLabel('Logout');
            // Logout button
            Button.width('100%');
            // Logout button
            Button.height(48);
            // Logout button
            Button.borderRadius(24);
            // Logout button
            Button.backgroundColor({ "id": 125831127, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Logout button
            Button.fontColor({ "id": 125830982, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Logout button
            Button.fontSize({ "id": 125830968, "type": 10002, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
            // Logout button
            Button.fontWeight(FontWeight.Medium);
            // Logout button
            Button.margin({ top: 32 });
            // Logout button
            Button.onClick(() => {
                this.handleLogout();
            });
        }, Button);
        // Logout button
        Button.pop();
        Column.pop();
    }
    /**
     * Handle login
     */
    private handleLogin(): void {
        if (this.username.length === 0) {
            this.errorMessage = 'Please enter your username';
            return;
        }
        if (this.password.length === 0) {
            this.errorMessage = 'Please enter your password';
            return;
        }
        this.isLoading = true;
        // Simulate login request
        setTimeout(() => {
            this.isLoading = false;
            // Simple validation: non-empty username and password = login success
            if (this.username.length >= 3 && this.password.length >= 6) {
                this.isLoggedIn = true;
                AppStorage.setOrCreate<boolean>('isLoggedIn', true);
                AppStorage.setOrCreate<string>('registeredUser', this.username);
                this.errorMessage = '';
            }
            else {
                this.errorMessage = 'Username needs 3+ chars, Password needs 6+ chars';
            }
        }, 1000);
    }
    /**
     * Handle logout
     */
    private handleLogout(): void {
        this.isLoggedIn = false;
        AppStorage.setOrCreate<boolean>('isLoggedIn', false);
        this.username = '';
        this.password = '';
        this.errorMessage = '';
    }
    rerender() {
        this.updateDirtyElements();
    }
}
