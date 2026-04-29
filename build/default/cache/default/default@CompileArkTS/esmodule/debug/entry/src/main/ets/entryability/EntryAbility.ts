import type AbilityConstant from "@ohos:app.ability.AbilityConstant";
import UIAbility from "@ohos:app.ability.UIAbility";
import type Want from "@ohos:app.ability.Want";
import type window from "@ohos:window";
export default class EntryAbility extends UIAbility {
    onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
        console.info('EntryAbility onCreate');
    }
    onDestroy(): void {
        console.info('EntryAbility onDestroy');
    }
    onForeground(): void {
        console.info('EntryAbility onForeground');
    }
    onBackground(): void {
        console.info('EntryAbility onBackground');
    }
    onWindowStageCreate(windowStage: window.WindowStage): void {
        console.info('EntryAbility onWindowStageCreate');
        windowStage.loadContent('pages/Index', (err) => {
            if (err.code) {
                console.error('Failed to load content. Cause: ' + JSON.stringify(err));
                return;
            }
            console.info('Succeeded in loading content.');
        });
    }
    onWindowStageDestroy(): void {
        console.info('EntryAbility onWindowStageDestroy');
    }
}
