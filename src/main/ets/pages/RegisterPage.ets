/**
 * Registration page
 */
import { promptAction } from '@kit.ArkUI';

@ComponentV2
export struct RegisterPage {
  @Local username: string = '';
  @Local password: string = '';
  @Local confirmPassword: string = '';
  @Local showPassword: boolean = false;
  @Local isLoading: boolean = false;
  @Local errorMessage: string = '';

  build() {
    NavDestination() {
      Column() {
        Scroll() {
          Column({ space: 24 }) {
            this.HeaderArea()
            this.RegisterForm()
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_primary'))
    }
    .title('Create Account')
    .hideBackButton(false)
  }

  @Builder
  HeaderArea() {
    Column({ space: 8 }) {
      SymbolGlyph($r('sys.symbol.person_badge_plus'))
        .fontSize(48)
        .fontColor([$r('sys.color.icon_emphasize')])

      Text('Create Your Account')
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))

      Text('Sign up to start your rehabilitation journey')
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 16, bottom: 8 })
  }

  @Builder
  RegisterForm() {
    Column({ space: 16 }) {
      // Username
      Column({ space: 8 }) {
        Text('Username')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')

        TextInput({ placeholder: 'At least 3 characters', text: this.username })
          .width('100%')
          .height(48)
          .borderRadius(12)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onChange((value: string) => {
            this.username = value;
            this.errorMessage = '';
          })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)

      // Password
      Column({ space: 8 }) {
        Text('Password')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')

        Row() {
          TextInput({ placeholder: 'At least 6 characters', text: this.password })
            .width('100%')
            .height(48)
            .borderRadius(12)
            .type(this.showPassword ? InputType.Normal : InputType.Password)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .onChange((value: string) => {
              this.password = value;
              this.errorMessage = '';
            })

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

      // Confirm Password
      Column({ space: 8 }) {
        Text('Confirm Password')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))
          .width('100%')

        TextInput({ placeholder: 'Re-enter your password', text: this.confirmPassword })
          .width('100%')
          .height(48)
          .borderRadius(12)
          .type(this.showPassword ? InputType.Normal : InputType.Password)
          .backgroundColor($r('sys.color.comp_background_list_card'))
          .onChange((value: string) => {
            this.confirmPassword = value;
            this.errorMessage = '';
          })
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

      // Register button
      Button(this.isLoading ? 'Creating...' : 'Create Account')
        .width('100%')
        .height(48)
        .borderRadius(24)
        .backgroundColor($r('sys.color.icon_emphasize'))
        .fontColor(Color.White)
        .fontSize($r('sys.float.Subtitle_M'))
        .fontWeight(FontWeight.Medium)
        .enabled(!this.isLoading && this.username.length > 0 && this.password.length > 0 && this.confirmPassword.length > 0)
        .margin({ top: 8 })
        .onClick(() => {
          this.handleRegister();
        })

      // Back to login link
      Row() {
        Text('Already have an account?  ')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_secondary'))

        Text('Sign In')
          .fontSize($r('sys.float.Body_M'))
          .fontColor($r('sys.color.font_emphasize'))
          .onClick(() => {
            this.goBack();
          })
      }
      .margin({ top: 16 })
    }
    .width('100%')
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
}
