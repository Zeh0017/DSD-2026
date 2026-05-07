import { http } from '@kit.NetworkKit';
import { Logger } from '../service/FileLoggerService';
import { promptAction } from '@kit.ArkUI';
import { LIMBS_TEAL } from '../designtoken/Color';

const TAG = 'RegisterPage';
const V2_BASE_URL = 'http://113.44.220.94:3000';

class RegisterPayload {
  name: string = '';
  email: string = '';
  password: string = '';
  role: string = 'patient';
}

class RegisterPayloadWithAge extends RegisterPayload {
  age: number = 0;
}

@ComponentV2
export struct RegisterPage {
  @Local name: string = '';
  @Local email: string = '';
  @Local age: string = '';
  @Local password: string = '';
  @Local confirmPassword: string = '';
  @Local showPassword: boolean = false;
  @Local showConfirmPassword: boolean = false;
  @Local isLoading: boolean = false;
  @Local errorMessage: string = '';

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // Logo
          Column({ space: 6 }) {
            Image($r('app.media.app_icon'))
              .width(80)
              .height(80)
              .borderRadius(20)
              .margin({ top: 32, bottom: 4 })

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
          .margin({ bottom: 24 })

          // Title
          Column({ space: 6 }) {
            Text('Create Account')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')

            Text('Join to start your rehabilitation journey')
              .fontSize(14)
              .fontColor('#8A8A8A')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 24 })

          // Form
          Column({ space: 16 }) {
            // Name
            Column({ space: 6 }) {
              Text('Name')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .width('100%')

              TextInput({ placeholder: 'Insert name', text: this.name })
                .width('100%')
                .height(50)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .border({ width: 1, color: '#E8EBF0', radius: 12 })
                .onChange((value: string) => {
                  this.name = value;
                  this.errorMessage = '';
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // Email
            Column({ space: 6 }) {
              Text('Email')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .width('100%')

              TextInput({ placeholder: 'Insert email', text: this.email })
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

            // Age
            Column({ space: 6 }) {
              Text('Age')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .width('100%')

              TextInput({ placeholder: 'e.g. 35', text: this.age })
                .width('100%')
                .height(50)
                .borderRadius(12)
                .backgroundColor('#F5F7FA')
                .border({ width: 1, color: '#E8EBF0', radius: 12 })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.age = value;
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

            // Confirm Password
            Column({ space: 6 }) {
              Text('Confirm Password')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1A1A1A')
                .width('100%')

              Stack({ alignContent: Alignment.End }) {
                TextInput({ placeholder: '••••••••••', text: this.confirmPassword })
                  .width('100%')
                  .height(50)
                  .borderRadius(12)
                  .backgroundColor('#F5F7FA')
                  .border({ width: 1, color: '#E8EBF0', radius: 12 })
                  .type(this.showConfirmPassword ? InputType.Normal : InputType.Password)
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                    this.errorMessage = '';
                  })

                Button({ type: ButtonType.Circle }) {
                  SymbolGlyph(this.showConfirmPassword ? $r('sys.symbol.eye_slash') : $r('sys.symbol.eye'))
                    .fontSize(18)
                    .fontColor(['#8A8A8A'])
                }
                .width(40)
                .height(40)
                .backgroundColor(Color.Transparent)
                .margin({ right: 6 })
                .onClick(() => {
                  this.showConfirmPassword = !this.showConfirmPassword;
                })
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            // Error
            if (this.errorMessage) {
              Text(this.errorMessage)
                .fontSize(13)
                .fontColor(Color.Red)
                .width('100%')
            }

            // Sign Up button
            Button(this.isLoading ? 'Creating account...' : 'Sign Up')
              .width('100%')
              .height(50)
              .borderRadius(25)
              .backgroundColor(LIMBS_TEAL)
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .enabled(!this.isLoading &&
                this.name.length > 0 &&
                this.email.length > 0 &&
                this.password.length > 0 &&
                this.confirmPassword.length > 0)
              .margin({ top: 8 })
              .onClick(() => {
                this.handleRegister();
              })
          }
          .width('100%')

          // Sign in link
          Row() {
            Text('Already have an account?  ')
              .fontSize(14)
              .fontColor('#8A8A8A')

            Text('Sign In')
              .fontSize(14)
              .fontColor(LIMBS_TEAL)
              .onClick(() => {
                this.goBack();
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
    }
    .backgroundColor(Color.White)
    .hideTitleBar(true)
  }

  private handleRegister(): void {
    if (this.name.trim().length === 0) {
      this.errorMessage = 'Please enter your name';
      return;
    }
    if (this.email.length === 0) {
      this.errorMessage = 'Please enter your email';
      return;
    }
    if (this.password.length < 6) {
      this.errorMessage = 'Password must be at least 6 characters';
      return;
    }
    if (this.password !== this.confirmPassword) {
      this.errorMessage = 'Passwords do not match';
      return;
    }
    this.isLoading = true;
    this.doRegister();
  }

  private async doRegister(): Promise<void> {
    const httpReq = http.createHttp();
    try {
      let bodyStr: string;
      const parsedAge = parseInt(this.age);
      if (this.age.length > 0 && !isNaN(parsedAge)) {
        const payload = new RegisterPayloadWithAge();
        payload.name = this.name.trim();
        payload.email = this.email;
        payload.password = this.password;
        payload.age = parsedAge;
        bodyStr = JSON.stringify(payload);
      } else {
        const payload = new RegisterPayload();
        payload.name = this.name.trim();
        payload.email = this.email;
        payload.password = this.password;
        bodyStr = JSON.stringify(payload);
      }

      const response = await httpReq.request(`${V2_BASE_URL}/auth/register`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: bodyStr,
        connectTimeout: 10000,
        readTimeout: 10000,
      });

      if (response.responseCode === 201 || response.responseCode === 200) {
        promptAction.showToast({ message: 'Account created! Please sign in.', duration: 2500 });
        this.goBack();
      } else {
        const body = JSON.parse(response.result as string) as Record<string, Object>;
        this.errorMessage = (body['error'] as string) || 'Registration failed. Please try again.';
      }
    } catch (error) {
      Logger.error(TAG, `Register failed: ${String(error)}`);
      this.errorMessage = 'Network error. Please try again.';
    } finally {
      httpReq.destroy();
      this.isLoading = false;
    }
  }

  private goBack(): void {
    const nav = AppStorage.get<NavPathStack>('navPathStack');
    if (nav) {
      nav.pop();
    }
  }
}
