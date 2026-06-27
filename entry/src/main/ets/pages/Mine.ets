@Component
export struct Mine {
  build() {
    Column() {
      Stack({ alignContent: Alignment.Bottom }) {
        Image($r('app.media.kun'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)

        Image($r('app.media.logo'))
          .width(100)
          .height(100)
          .margin({ bottom: -50 })
      }
      .width('100%')
      .height('70%')

      Column({ space: 12 }) {
        Row({ space: 8 }) {
          Text('黑马云音乐')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Image($r('app.media.ic_vip'))
            .width(40)
        }

        Row({ space: 12 }) {
          Image($r('app.media.ic_boy'))
            .width(14)
            .height(14)
            .fillColor('#4A90E2')
          Text('00后')
            .fontSize(14)
            .fontColor('#888888')
          Text('双子座')
            .fontSize(14)
            .fontColor('#888888')
          Text('北京')
            .fontSize(14)
            .fontColor('#888888')
          Text('歌龄·18年')
            .fontSize(14)
            .fontColor('#888888')
        }

        Row({ space: 12 }) {
          Text('1 关注')
            .fontSize(14)
            .fontColor('#888888')
          Text('100万 粉丝')
            .fontSize(14)
            .fontColor('#888888')
          Text('1.67亿 赞')
            .fontSize(14)
            .fontColor('#888888')
        }
      }
      .width('100%')
      .height('30%')
      .backgroundColor('#121212')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 50 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
