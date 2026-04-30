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
  new TabItem($r('sys.symbol.house_fill'), 'main', 0),
  new TabItem($r('sys.symbol.plus_circle'), 'test', 1),
  new TabItem($r('sys.symbol.doc'), 'record', 2),
  new TabItem($r('sys.symbol.person'), 'account', 3),
];
