import router from '@ohos.router'

@Entry
@Component
struct IndexPage {
  build() {
    Row() {
      Column() {

        Button('DrawerLayout 实现方式')
          .fontSize(18)
          .fontWeight(FontWeight.Bold).onClick(() => {
          router.pushUrl({
            url: 'pages/DrawerLayoutPage'
          })
        })

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