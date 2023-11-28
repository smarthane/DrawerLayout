import router from '@ohos.router'

/**
 * *********************************************************
 * @author smarthane
 * @version v1.0.0
 * **********************************************************
 */
@Entry
@Component
struct IndexPage {
  build() {
    Row() {
      Column() {

        Button('DrawerLayout 实现方式（左或者右）')
          .fontSize(18)
          .fontWeight(FontWeight.Bold).onClick(() => {
          router.pushUrl({
            url: 'pages/DrawerLayoutPage'
          })
        })

        Button('DrawerLayout 实现方式（包含左右）')
          .fontSize(18)
          .fontWeight(FontWeight.Bold).onClick(() => {
          router.pushUrl({
            url: 'pages/DrawerLayoutPage2'
          })
        }).margin({ top: 10 })

        Button('SideBarContainer 实现方式')
          .fontSize(18)
          .fontWeight(FontWeight.Bold).onClick(() => {
          router.pushUrl({
            url: 'pages/SideBarContainerPage'
          })
        })
          .margin({ top: 10 })

      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .height('100%')
  }
}