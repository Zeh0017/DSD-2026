import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { RehabilitationService } from '../service/RehabilitationService';
import { Logger } from '../service/FileLoggerService';
import { AuthService } from '../service/AuthService';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // Initialize file logger first so all subsequent logs are captured
    Logger.init(this.context);
    Logger.info('EntryAbility', 'onCreate');

    // Initialize services that need application context
    RehabilitationService.getInstance().init(this.context);
  }

  onDestroy(): void {
    Logger.info('EntryAbility', 'onDestroy');
    Logger.close();
  }

  onForeground(): void {
    Logger.info('EntryAbility', 'onForeground');
  }

  onBackground(): void {
    Logger.info('EntryAbility', 'onBackground');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    Logger.info('EntryAbility', 'onWindowStageCreate');

    // Restore persisted session BEFORE loading the UI so Index.ets receives
    // the correct isLoggedIn value on its very first render.
    AuthService.getInstance().init(this.context).then(() => {
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          Logger.error('EntryAbility', 'Failed to load content: ' + JSON.stringify(err));
          return;
        }
        Logger.info('EntryAbility', 'Content loaded successfully');
      });
    });
  }

  onWindowStageDestroy(): void {
    Logger.info('EntryAbility', 'onWindowStageDestroy');
  }
}
