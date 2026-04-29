if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
import { TAB_ITEMS } from "@normalized:N&&&entry/src/main/ets/model/TabModel&";
import { HomePage } from "@normalized:N&&&entry/src/main/ets/pages/HomePage&";
import { TestPage } from "@normalized:N&&&entry/src/main/ets/pages/TestPage&";
import { RecordPage } from "@normalized:N&&&entry/src/main/ets/pages/RecordPage&";
import { ProfilePage } from "@normalized:N&&&entry/src/main/ets/pages/ProfilePage&";
import { SensorConnectionPage } from "@normalized:N&&&entry/src/main/ets/pages/rehabilitation/SensorConnectionPage&";
import { SessionSetupPage } from "@normalized:N&&&entry/src/main/ets/pages/rehabilitation/SessionSetupPage&";
import { SessionActivePage } from "@normalized:N&&&entry/src/main/ets/pages/rehabilitation/SessionActivePage&";
import { SessionResultPage } from "@normalized:N&&&entry/src/main/ets/pages/rehabilitation/SessionResultPage&";
import { RegisterPage } from "@normalized:N&&&entry/src/main/ets/pages/RegisterPage&";
class Index extends ViewV2 {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda, extraInfo) {
        super(parent, elmtId, extraInfo);
        this.currentIndex = 0;
        this.isLoggedIn = false;
        this.navStack = new NavPathStack();
        this.finalizeConstruction();
    }
    public resetStateVarsOnReuse(params: Object): void {
        this.currentIndex = 0;
        this.isLoggedIn = false;
    }
    @Local
    currentIndex: number;
    @Local
    isLoggedIn: boolean;
    private navStack: NavPathStack;
    aboutToAppear(): void {
        AppStorage.setOrCreate<NavPathStack>('navPathStack', this.navStack);
        // Monitor login state change
        AppStorage.setOrCreate<boolean>('isLoggedIn', false);
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Navigation.create(this.navStack, { moduleName: "entry", pagePath: "entry/src/main/ets/pages/Index", isUserCreateStack: true });
            Navigation.mode(NavigationMode.Stack);
            Navigation.hideTitleBar(true);
            Navigation.navDestination({ builder: this.DestinationBuilder.bind(this) });
        }, Navigation);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Tabs.create({ barPosition: BarPosition.End, index: this.currentIndex });
            Tabs.barHeight(56);
            Tabs.barMode(BarMode.Fixed);
            Tabs.scrollable(false);
            Tabs.onChange((index: number) => {
                const loggedIn: boolean = AppStorage.get<boolean>('isLoggedIn') ?? false;
                if (!loggedIn && index !== 3) {
                    // Not logged in and not on account tab, redirect back
                    this.currentIndex = 3;
                    return;
                }
                this.currentIndex = index;
            });
            Tabs.width('100%');
            Tabs.height('100%');
            Tabs.backgroundColor({ "id": 125831062, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Tabs);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new HomePage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 33, col: 11 });
                            ViewV2.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "HomePage" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, 0);
                } });
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new TestPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 38, col: 11 });
                            ViewV2.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "TestPage" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, 1);
                } });
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new RecordPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 43, col: 11 });
                            ViewV2.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "RecordPage" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, 2);
                } });
        }, TabContent);
        TabContent.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TabContent.create(() => {
                {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        if (isInitialRender) {
                            let componentCall = new ProfilePage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 48, col: 11 });
                            ViewV2.create(componentCall);
                            let paramsLambda = () => {
                                return {};
                            };
                            componentCall.paramsGenerator_ = paramsLambda;
                        }
                        else {
                            this.updateStateVarsOfChildByElmtId(elmtId, {});
                        }
                    }, { name: "ProfilePage" });
                }
            });
            TabContent.tabBar({ builder: () => {
                    this.TabBuilder.call(this, 3);
                } });
        }, TabContent);
        TabContent.pop();
        Tabs.pop();
        Navigation.pop();
    }
    DestinationBuilder(name: string, param: Object, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            if (name === 'SensorConnection') {
                this.ifElseBranchUpdateFunction(0, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new SensorConnectionPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 76, col: 7 });
                                ViewV2.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "SensorConnectionPage" });
                    }
                });
            }
            else if (name === 'SessionSetup') {
                this.ifElseBranchUpdateFunction(1, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new SessionSetupPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 78, col: 7 });
                                ViewV2.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "SessionSetupPage" });
                    }
                });
            }
            else if (name === 'SessionActive') {
                this.ifElseBranchUpdateFunction(2, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new SessionActivePage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 80, col: 7 });
                                ViewV2.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "SessionActivePage" });
                    }
                });
            }
            else if (name === 'SessionResult') {
                this.ifElseBranchUpdateFunction(3, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new SessionResultPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 82, col: 7 });
                                ViewV2.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "SessionResultPage" });
                    }
                });
            }
            else if (name === 'Register') {
                this.ifElseBranchUpdateFunction(4, () => {
                    {
                        this.observeComponentCreation2((elmtId, isInitialRender) => {
                            if (isInitialRender) {
                                let componentCall = new RegisterPage(this, {}, undefined, elmtId, () => { }, { page: "entry/src/main/ets/pages/Index.ets", line: 84, col: 7 });
                                ViewV2.create(componentCall);
                                let paramsLambda = () => {
                                    return {};
                                };
                                componentCall.paramsGenerator_ = paramsLambda;
                            }
                            else {
                                this.updateStateVarsOfChildByElmtId(elmtId, {});
                            }
                        }, { name: "RegisterPage" });
                    }
                });
            }
            else {
                this.ifElseBranchUpdateFunction(5, () => {
                });
            }
        }, If);
        If.pop();
    }
    TabBuilder(index: number, parent = null) {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create({ space: 4 });
            Column.width('100%');
            Column.height('100%');
            Column.justifyContent(FlexAlign.Center);
            Column.alignItems(HorizontalAlign.Center);
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            SymbolGlyph.create(TAB_ITEMS[index].icon);
            SymbolGlyph.fontSize(24);
            SymbolGlyph.fontColor([this.currentIndex === index ? { "id": 125830995, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125830993, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }]);
        }, SymbolGlyph);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create(TAB_ITEMS[index].title);
            Text.fontSize(12);
            Text.fontWeight(this.currentIndex === index ? FontWeight.Medium : FontWeight.Regular);
            Text.fontColor(this.currentIndex === index ? { "id": 125830986, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" } : { "id": 125830983, "type": 10001, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" });
        }, Text);
        Text.pop();
        Column.pop();
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "Index";
    }
}
registerNamedRoute(() => new Index(undefined, {}), "", { bundleName: "com.example.myapp", moduleName: "entry", pagePath: "pages/Index", pageFullPath: "entry/src/main/ets/pages/Index", integratedHsp: "false", moduleType: "followWithHap" });
