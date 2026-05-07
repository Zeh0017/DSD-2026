import { AuthService } from '../service/AuthService';
import { LIMBS_TEAL } from '../designtoken/Color';

@ComponentV2
export struct ProfilePage {
  @Local userName: string = '';
  @Local userEmail: string = '';
  @Local userAge: number = 0;

  aboutToAppear(): void {
    this.userName = AppStorage.get<string>('userName') ?? '';
    this.userEmail = AppStorage.get<string>('userEmail') ?? '';
    this.userAge = AppStorage.get<number>('userAge') ?? 0;
  }

  private getInitials(): string {
    const parts: string[] = this.userName.trim().split(' ').filter((p: string) => p.length > 0);
    if (parts.length >= 2) {
      return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
    }
    if (this.userName.length >= 2) {
      return this.userName.substring(0, 2).toUpperCase();
    }
    return this.userName.toUpperCase();
  }

  build() {
    Column() {
      // Header
      Row({ space: 16 }) {
        // Avatar with initials
        Stack() {
          Circle()
            .width(60)
            .height(60)
            .fill(LIMBS_TEAL)

          Text(this.getInitials())
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }

        // User info
        Column({ space: 4 }) {
          Text(this.userName)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')

          Text(this.userEmail)
            .fontSize(13)
            .fontColor('#8A8A8A')

          if (this.userAge > 0) {
            Text(`Age: ${this.userAge} years`)
              .fontSize(13)
              .fontColor('#8A8A8A')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .padding({ top: 56, bottom: 24, left: 20, right: 20 })
      .backgroundColor(Color.White)

      // Menu items
      Scroll() {
        Column({ space: 16 }) {
          // Menu card
          Column() {
            // My Recovery
            // TODO: Navigate to My Recovery page (session history, progress charts)
            Row() {
              SymbolGlyph($r('sys.symbol.heart'))
                .fontSize(20)
                .fontColor(['#555555'])
                .margin({ right: 16 })
              Text('My Recovery')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .layoutWeight(1)
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(14)
                .fontColor(['#C0C0C0'])
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })

            Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 56 })

            // Appointments
            // TODO: Navigate to Appointments page (scheduled sessions with clinician)
            Row() {
              SymbolGlyph($r('sys.symbol.calendar'))
                .fontSize(20)
                .fontColor(['#555555'])
                .margin({ right: 16 })
              Text('Appointments')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .layoutWeight(1)
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(14)
                .fontColor(['#C0C0C0'])
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })

            Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 56 })

            // Medications
            // TODO: Navigate to Medications page (prescribed medications list)
            Row() {
              SymbolGlyph($r('sys.symbol.cross_case'))
                .fontSize(20)
                .fontColor(['#555555'])
                .margin({ right: 16 })
              Text('Medications')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .layoutWeight(1)
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(14)
                .fontColor(['#C0C0C0'])
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })

            Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 56 })

            // Settings
            // TODO: Navigate to Settings page (notifications, language, account preferences)
            Row() {
              SymbolGlyph($r('sys.symbol.gearshape'))
                .fontSize(20)
                .fontColor(['#555555'])
                .margin({ right: 16 })
              Text('Settings')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .layoutWeight(1)
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(14)
                .fontColor(['#C0C0C0'])
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })

            Divider().strokeWidth(0.5).color('#F0F0F0').margin({ left: 56 })

            // Help & Support
            // TODO: Navigate to Help & Support page (FAQ, contact, documentation)
            Row() {
              SymbolGlyph($r('sys.symbol.questionmark_circle'))
                .fontSize(20)
                .fontColor(['#555555'])
                .margin({ right: 16 })
              Text('Help & Support')
                .fontSize(16)
                .fontColor('#1A1A1A')
                .layoutWeight(1)
              SymbolGlyph($r('sys.symbol.chevron_right'))
                .fontSize(14)
                .fontColor(['#C0C0C0'])
            }
            .width('100%')
            .height(56)
            .padding({ left: 20, right: 20 })
          }
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius(16)

          // Log Out
          Row() {
            SymbolGlyph($r('sys.symbol.power'))
              .fontSize(20)
              .fontColor(['#FF3B30'])
              .margin({ right: 16 })
            Text('Log Out')
              .fontSize(16)
              .fontColor('#FF3B30')
              .layoutWeight(1)
          }
          .width('100%')
          .height(56)
          .padding({ left: 20, right: 20 })
          .backgroundColor(Color.White)
          .borderRadius(16)
          .onClick(() => {
            this.handleLogout();
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F4F7')
  }

  private handleLogout(): void {
    AppStorage.setOrCreate<boolean>('isLoggedIn', false);
    AppStorage.setOrCreate<string>('authToken', '');
    AppStorage.setOrCreate<number>('userId', 0);
    AppStorage.setOrCreate<string>('userName', '');
    AppStorage.setOrCreate<string>('userEmail', '');
    AppStorage.setOrCreate<number>('userAge', 0);
    AppStorage.setOrCreate<string>('registeredUser', '');
    AuthService.getInstance().clearSession();
  }
}
