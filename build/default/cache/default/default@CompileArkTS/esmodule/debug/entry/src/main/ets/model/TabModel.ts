/**
 * Bottom tab data model
 */
export class TabItem {
    icon: Resource;
    title: string;
    index: number;
    constructor(icon: Resource, title: string, index: number) {
        this.icon = icon;
        this.title = title;
        this.index = index;
    }
}
/**
 * Bottom tab configuration
 */
export const TAB_ITEMS: TabItem[] = [
    new TabItem({ "id": 125831534, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }, 'main', 0),
    new TabItem({ "id": 125831482, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }, 'test', 1),
    new TabItem({ "id": 125831909, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }, 'record', 2),
    new TabItem({ "id": 125832135, "type": 40000, params: [], "bundleName": "com.example.myapp", "moduleName": "entry" }, 'account', 3),
];
