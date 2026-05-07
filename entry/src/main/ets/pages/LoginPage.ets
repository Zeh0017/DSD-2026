import { AuthService } from '../service/AuthService';
import { http } from '@kit.NetworkKit';
import { Logger } from '../service/FileLoggerService';
import { LIMBS_TEAL } from '../designtoken/Color';

const TAG = 'LoginPage';
const V2_BASE_URL = 'http://113.44.220.94:3000';

@ComponentV2
export struct LoginPage {
  @Local email: string = '';
  @Local password: string = '';
  @Local showPassword: boolean = false;
  @Local isLoading: boolean = false;
  @Local errorMessage: string = '';

  build() {
    Scroll() {
      Column() {
        // Logo
        Column({ space: 6 }) {
          Image($r('app.media.app_icon'))
            .width(80)
            .height(80)
            .borderRadius(20)
            .margin({ top: 60, bottom: 4 })

          Text('LIMBS')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text('Limb & Mobility')
            .fontSize(13)
            .fontColor('#8A8A8A')

          Text('Clinical Assistant')
            .fontSize(13)
            .fontColor('#8A8A8A')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 32 })

        // Welcome
        Column({ space: 6 }) {
          Text('Welcome back!')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text('Please sign in to continue')
            .fontSize(14)
            .fontColor('#8A8A8A')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 28 })

        // Form
        Column({ space: 16 }) {
          // Email
          Column({ space: 6 }) {
            Text('Email')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .width('100%')

            TextInput({ placeholder: 'Your email', text: this.email })
              .width('100%')
              .height(50)
              .borderRadius(12)
              .backgroundColor('#F5F7FA')
              .border({ width: 1, color: '#E8EBF0', radius: 12 })
              .type(InputType.Email)
              .onChange((value: string) => {
                this.email = value;
                this.errorMessage = '';
              })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // Password
          Column({ space: 6 }) {
            Text('Password')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1A1A1A')
              .width('100%')

            Stack({ alignContent: Alignment.End }) {
              TextInput({ placeholder: '••••••••••', text: this.password })
                .width('100%')
                .height(50)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .border({ width: 1, color: '#E8EBF0', radius: 12 })
                .type(this.showPassword ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                  this.errorMessage = '';
                })

              Button({ type: ButtonType.Circle }) {
                SymbolGlyph(this.showPassword ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
                  .fontSize(18)
                  .fontColor(['#8A8A8A'])
              }
              .width(40)
              .height(40)
              .backgroundColor(Color.Transparent)
              .margin({ right: 6 })
              .onClick(() => {
                this.showPassword = !this.showPassword;
              })
            }
            .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // Forgot password
          Text('Forgot password?')
            .fontSize(13)
            .fontColor(LIMBS_TEAL)
            .width('100%')
            .textAlign(TextAlign.End)

          // Error
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(13)
              .fontColor(Color.Red)
              .width('100%')
          }

          // Sign In button
          Button(this.isLoading ? 'Signing in...' : 'Sign In')
            .width('100%')
            .height(50)
            .borderRadius(25)
            .backgroundColor(LIMBS_TEAL)
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .enabled(!this.isLoading && this.email.length > 0 && this.password.length > 0)
            .margin({ top: 8 })
            .onClick(() => {
              this.handleLogin();
            })
        }
        .width('100%')

        // Sign up link
        Row() {
          Text("Don't have an account?  ")
            .fontSize(14)
            .fontColor('#8A8A8A')

          Text('Sign up')
            .fontSize(14)
            .fontColor(LIMBS_TEAL)
            .onClick(() => {
              const nav = AppStorage.get<NavPathStack>('navPathStack');
              if (nav) {
                nav.pushPathByName('Register', null);
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24, bottom: 32 })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(Color.White)
  }

  private handleLogin(): void {
    if (this.email.length === 0) {
      this.errorMessage = 'Please enter your email';
      return;
    }
    if (this.password.length === 0) {
      this.errorMessage = 'Please enter your password';
      return;
    }
    this.isLoading = true;
    this.doLogin();
  }

  private async doLogin(): Promise<void> {
    const httpReq = http.createHttp();
    try {
      const response = await httpReq.request(`${V2_BASE_URL}/auth/login`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify({ email: this.email, password: this.password }),
        connectTimeout: 10000,
        readTimeout: 10000,
      });

      if (response.responseCode === 200) {
        const body = JSON.parse(response.result as string) as Record<string, Object>;
        const token = body['token'] as string;
        const userObj = body['user'] as Record<string, Object>;
        const userId = userObj['id'] as number;
        const name = userObj['name'] as string;
        const userEmail = userObj['email'] as string;
        const ageRaw = userObj['age'];
        const age = (ageRaw !== null && ageRaw !== undefined) ? ageRaw as number : 0;

        await AuthService.getInstance().saveSession(token, userId, name, userEmail, age);
        AppStorage.setOrCreate<boolean>('isLoggedIn', true);
        this.errorMessage = '';
      } else {
        const body = JSON.parse(response.result as string) as Record<string, Object>;
        this.errorMessage = (body['error'] as string) || 'Invalid credentials';
      }
    } catch (error) {
      Logger.error(TAG, `Login failed: ${String(error)}`);
      this.errorMessage = 'Network error. Please try again.';
    } finally {
      httpReq.destroy();
      this.isLoading = false;
    }
  }
}
