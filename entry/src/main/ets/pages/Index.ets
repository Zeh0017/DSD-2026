/**
 * Main page - Bottom 4-tab navigation
 * Integrated rehabilitation training module (UC-M1-02)
 */
import { TAB_ITEMS } from '../model/TabModel';
import { HomePage } from './HomePage';
import { TestPage } from './TestPage';
import { RecordPage } from './RecordPage';
import { ProfilePage } from './ProfilePage';
import { SensorConnectionPage } from './rehabilitation/SensorConnectionPage';
import { SessionSetupPage } from './rehabilitation/SessionSetupPage';
import { SessionActivePage } from './rehabilitation/SessionActivePage';
import { SessionResultPage } from './rehabilitation/SessionResultPage';
import { RegisterPage } from './RegisterPage';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State currentIndex: number = 3;
  @StorageLink('isLoggedIn') @Watch('onLoginStateChange') isLoggedIn: boolean = false;
  private navStack: NavPathStack = new NavPathStack();

  onLoginStateChange(propName: string): void {
    if (!this.isLoggedIn) {
      this.currentIndex = 3;
    }
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate<NavPathStack>('navPathStack', this.navStack);
    AppStorage.setOrCreate<boolean>('isLoggedIn', false);
  }

  build() {
    Navigation(this.navStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
              HomePage();
        }
        .tabBar(this.TabBuilder(0))

        TabContent() {
            TestPage();
        }
        .tabBar(this.TabBuilder(1))

        TabContent() {
            RecordPage();
        }
        .tabBar(this.TabBuilder(2))

        TabContent() {
            ProfilePage();
        }
        .tabBar(this.TabBuilder(3))
      }
      .barHeight(this.isLoggedIn ? 56 : 0)
      .barMode(BarMode.Fixed)
      .scrollable(false)
      .animationDuration(300)
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.background_secondary'))

    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .navDestination(this.DestinationBuilder)
  }

  @Builder
  DestinationBuilder(name: string, param: Object) {
    if (name === 'SensorConnection') {
      SensorConnectionPage()
    } else if (name === 'SessionSetup') {
      SessionSetupPage()
    } else if (name === 'SessionActive') {
      SessionActivePage()
    } else if (name === 'SessionResult') {
      SessionResultPage()
    } else if (name === 'Register') {
      RegisterPage()
    }
  }

  @Builder
  TabBuilder(index: number) {
    Column({ space: 4 }) {
      SymbolGlyph(TAB_ITEMS[index].icon)
        .fontSize(24)
        .fontColor([this.currentIndex === index ?
          $r('sys.color.icon_emphasize') :
          $r('sys.color.icon_tertiary')])

      Text(TAB_ITEMS[index].title)
        .fontSize(12)
        .fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular)
        .fontColor(this.currentIndex === index ?
          $r('sys.color.font_emphasize') :
          $r('sys.color.font_secondary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      const loggedIn = AppStorage.get<boolean>('isLoggedIn') ?? false;
      if (!loggedIn && index !== 3) {
        promptAction.showToast({
          message: 'Please log in first!',
          duration: 2000
        });
        return;
      }
      this.currentIndex = index;
    })
  }
}
