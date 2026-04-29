/**
 * Profile page - Login functionality
 */
@ComponentV2
export struct ProfilePage {
  @Local isLoggedIn: boolean = false;
  @Local username: string = '';
  @Local password: string = '';
  @Local showPassword: boolean = false;
  @Local isLoading: boolean = false;
  @Local errorMessage: string = '';

  aboutToAppear(): void {
    this.isLoggedIn = AppStorage.get<boolean>('isLoggedIn') ?? false;
    if (this.isLoggedIn) {
      this.username = AppStorage.get<string>('registeredUser') ?? '';
    }
  }

  build() {
    Column() {
      // Title
      Text('Account')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ top: 60, bottom: 32 })

      if (this.isLoggedIn) {
        // Logged in state
        this.LoggedInView()
      } else {
        // Login form
        this.LoginForm()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_primary'))
    .padding({ left: 24, right: 24 })
  }

  /**
   * Login form
   */
  @Builder
  LoginForm() {
    Column({ space: 16 }) {
      // Username input
      Column({ space: 8 }) {
        Text('Username')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')

        TextInput({ placeholder: 'username', text: this.username })
          .width('100%')
          .height(48)
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onChange((value) => {
            this.username = value;
            this.errorMessage = '';
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // Password input
      Column({ space: 8 }) {
        Text('Password')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')

        Row() {
          TextInput({ placeholder: 'Password', text: this.password })
            .width('100%')
            .height(48)
            .borderRadius(12)
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onChange((value) => {
              this.password = value;
              this.errorMessage = '';
            })

          // Show/hide password button
          Button({ type: ButtonType.Circle }) {
            SymbolGlyph(this.showPassword ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
              .fontSize(20)
              .fontColor([$r('sys.color.icon_secondary')])
          }
          .width(40)
          .height(40)
          .backgroundColor(Color.Transparent)
          .margin({ left: -48 })
          .onClick(() => {
            this.showPassword = !this.showPassword;
          })
        }
        .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // Error message
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize($r('sys.float.Caption_M'))
          .fontColor(Color.Red)
          .width('100%')
          .margin({ top: 4 })
      }

      // Login button
      Button(this.isLoading ? 'Logging in...' : 'Log In')
        .width('100%')
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.icon_emphasize'))
        .fontColor(Color.White)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0)
        .margin({ top: 16 })
        .onClick(() => {
          this.handleLogin();
        })

      // Register link
      Row() {
        Text('No account? ')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))

        Text('Create an account')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            const nav = AppStorage.get<NavPathStack>('navPathStack');
            if (nav) {
              nav.pushPathByName('Register', null);
            }
          })
      }
      .margin({ top: 16 })
    }
    .width('100%')
    .margin({ top: 32 })
  }

  /**
   * Logged in view
   */
  @Builder
  LoggedInView() {
    Column({ space: 16 }) {
      // Avatar
      Circle({ width: 80, height: 80 })
        .fill($r('sys.color.icon_secondary'))

      // Username
      Text(this.username)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))

      // Welcome message
      Text('Welcome!')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))

      // Logout button
      Button('Logout')
        .width('100%')
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 32 })
        .onClick(() => {
          this.handleLogout();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 32 })
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
      } else {
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
}
