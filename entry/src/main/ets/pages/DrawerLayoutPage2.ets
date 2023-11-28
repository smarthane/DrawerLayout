import DrawerLayout from 'drawerlayout/src/main/ets/components/DrawerLayout';

@Entry
@Component
struct DrawerLayoutPage2 {
  @State model: DrawerLayout.Model = new DrawerLayout.Model()
    // 设置左侧边栏DrawerLayout.Type.LEFT 还是右侧边栏DrawerLayout.Type.RIGHT
    .setDrawerType(DrawerLayout.Type.LEFT)
      // 设置侧边栏宽度
    .setDrawerWidth(230);

  aboutToAppear() {
    this.model.setDrawerCallback((drawerType, isOpen) => {
      console.debug(`drawerType: ${drawerType}, isOpen: ${isOpen}`)
      // D 0FEFE/JsApp: drawerType: 1, isOpen: true
      // D 0FEFE/JsApp: drawerType: 1, isOpen: false
      // D 0FEFE/JsApp: drawerType: 2, isOpen: true
      // D 0FEFE/JsApp: drawerType: 2, isOpen: false
    })
  }

  // 用于判断手机的物理返回按钮
  onBackPress() {
    if (this.model.isDrawerOpen) {
      this.model.closeDrawer();
      return true;
    }
    return false;
  }

  build() {
    Column() {
      DrawerLayout({
        model: $model,
        drawerView: () => {
          this.buildDrawerView();
        },
        contentView: () => {
          this.buildContentView();
        }
      })
    }
    .height('100%')
  }

  @Builder buildContentView() {
    Column() {
      Row() {
        Button('打开左侧边栏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.model.setDrawerType(DrawerLayout.Type.LEFT);
            this.model.openOrCloseDrawer();
          })
        Button('打开右侧边栏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            this.model.setDrawerType(DrawerLayout.Type.RIGHT);
            this.model.openOrCloseDrawer();
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 10, left: 20, right: 20, bottom: 10 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder buildDrawerView() {
    Column() {
      if (this.model.drawerType == DrawerLayout.Type.LEFT) {
        Text('这是左边抽屉项\n1.可左右滑动\n2.点击遮罩层关闭')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
      } else {
        Text('这是右边抽屉项\n1.可左右滑动\n2.点击遮罩层关闭')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
      }
    }
    .backgroundColor(this.model.drawerType == DrawerLayout.Type.LEFT ? Color.Orange : Color.Green)
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
