import display from '@ohos.display';
import mediaquery from '@ohos.mediaquery'
import window from '@ohos.window';

/**
 * ***********************************************
 * @author smarthane
 * DrawerLayout 左右抽屉布局，侧边栏布局
 * 提供侧边栏可以显示和隐藏的侧边栏容器，通过子组件定义侧边栏和内容区。
 * https://gitee.com/smarthane/drawerlayout
 * ************************************************
 */
@Component
export struct DrawerLayout {
  @Link model: DrawerLayout.Model
  @BuilderParam drawerView?: () => any
  @BuilderParam contentView?: () => any

  // 当设备横屏时条件成立
  private mediaqueryListener = mediaquery.matchMediaSync('(orientation: landscape)');

  aboutToAppear() {
    // 获取状态栏高度
    window.getLastWindow(getContext(this)).then((data: window.Window) => {
      // 状态栏高度
      this.model.statusBarHeight = DrawerLayout.Utils.toVp(data.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM)
        .topRect
        .height);
      // 初始化数据
      this.initData();
      // 绑定回调函数 绑定当前应用实例
      this.mediaqueryListener.on('change', this.onPortrait.bind(this));
    })
  }

  aboutToDisappear() {
    this.mediaqueryListener.off('change')
  }

  // 当满足媒体查询条件时，触发回调
  private onPortrait(mediaQueryResult) {
    this.model.isScreenPortrait = !mediaQueryResult.matches;
    if (this.model.onScreenPortraitCallback) {
      this.model.onScreenPortraitCallback(!mediaQueryResult.matches)
    }
    this.initData();
  }

  private initData() {
    this.model.displayWidth = DrawerLayout.Utils.getDeviceWidth(this.model.deviceDpi) - (this.model.isScreenPortrait ? 0 : this.model.statusBarHeight);
    this.model.displayHeight = DrawerLayout.Utils.getDeviceHeight(this.model.deviceDpi);
    // 设置侧边栏的宽度 [0,displayWidth]
    if (this.model.drawerWidth > this.model.displayWidth) {
      this.model.drawerWidth = this.model.displayWidth;
    }
    if (this.model.drawerWidth < 0) {
      this.model.drawerWidth = 0;
    }
    // 设置屏幕宽度与侧边栏宽度的差值
    this.model.drawerOffsetWidth = this.model.displayWidth - this.model.drawerWidth;
    switch (this.model.drawerType) {
      case DrawerLayout.Type.LEFT:
        this.model.drawerOffsetX = -1 * this.model.drawerWidth / 3;
        break;
      case DrawerLayout.Type.RIGHT:
        this.model.drawerOffsetX = this.model.displayWidth;
      // 右边侧边栏需要特殊处理 横竖屏切换时
        if (this.model.isDrawerOpen) {
          this.model.drawerPositionX = this.model.drawerOffsetWidth;
        }
        break;
    }
  }

  build() {
    Stack({ alignContent: this.model.drawerType == DrawerLayout.Type.LEFT ? Alignment.TopStart : Alignment.TopEnd }) {
      // 内容项目
      Column() {
        /*****************************************
         * 编写内容组件 自定义组件
         ****************************************/
        this.contentView()
        /* ****************************************/
      }
      .width(DrawerLayout.Utils.MATCH_PARENT)
      .height(DrawerLayout.Utils.MATCH_PARENT)

      // 透明背景遮罩层
      if (this.model.isDrawerOpen) {
        Column() {
        }
        .height(DrawerLayout.Utils.MATCH_PARENT)
        .width(DrawerLayout.Utils.MATCH_PARENT)
        .backgroundColor(this.model.maskColor)
        .opacity(this.model.maskOpacity)
        .onClick(() => {
          this.model.closeDrawer();
        })
        .animation({
          duration: 200,
          curve: Curve.EaseIn,
          iterations: 1,
          playMode: PlayMode.Normal,
        })
      }

      // 抽屉项
      Column() {
        /* ****************************************
         * 编写侧边抽屉组件 自定组件
         *******************************************/
        this.drawerView()
        /* ****************************************/
      }
      .width(this.model.isDrawerViewVisible ? this.model.drawerWidth : 0)
      .height('100%')
      .position({ x: this.model.drawerPositionX, y: 0 })
      .animation({
        duration: this.model.drawerAnimDuration,
        curve: Curve.Linear,
        iterations: 1,
        playMode: PlayMode.Normal,
        onFinish: () => {
          // 动画结束
          this.model.isDrawerViewVisible = this.model.isDrawerOpen;
        }
      })
      // 手势 左右拖动侧边栏
      .gesture(
        PanGesture({ direction: PanDirection.Left | PanDirection.Right })
          .onActionStart(() => {
            switch (this.model.drawerType) {
              case DrawerLayout.Type.LEFT:
                this.model.drawerPositionX = 0;
                break;
              case DrawerLayout.Type.RIGHT:
                break;
            }
          })
          .onActionUpdate((event: GestureEvent) => {
            switch (this.model.drawerType) {
              case DrawerLayout.Type.LEFT:
                if (event.offsetX > 0) {
                  this.model.drawerPositionX = 0;
                } else {
                  this.model.drawerPositionX = event.offsetX;
                }
                break;
              case DrawerLayout.Type.RIGHT:
                let tempO = this.model.isScreenPortrait ? 1.188 : 1.101;
                let tempS = (this.model.drawerPositionX + event.offsetX) / tempO;
                if (tempS < this.model.drawerOffsetWidth) {
                  this.model.drawerPositionX = this.model.drawerOffsetWidth;
                } else if (this.model.drawerOffsetWidth <= tempS && tempS <= this.model.displayWidth) {
                  this.model.drawerPositionX = tempS;
                } else {
                  this.model.drawerPositionX = this.model.displayWidth;
                }
                break;
            }
          })
          .onActionEnd(() => {
            switch (this.model.drawerType) {
              case DrawerLayout.Type.LEFT:
                if (this.model.drawerPositionX <= this.model.drawerOffsetX) {
                  this.model.closeDrawer();
                } else {
                  this.model.openDrawer();
                }
                break;
              case DrawerLayout.Type.RIGHT:
                if (this.model.drawerPositionX >= this.model.drawerOffsetWidth + 100) {
                  this.model.closeDrawer();
                } else {
                  this.model.openDrawer();
                }
                break;
            }
          })
      )
    }
    .width(DrawerLayout.Utils.MATCH_PARENT)
    .height(DrawerLayout.Utils.MATCH_PARENT)
  }
}

export namespace DrawerLayout {

/**
 * 抽屉类型 左 右
 */
  export enum Type {
    LEFT = 1,
    RIGHT = 2,
  }

  /**
   * 抽屉控制模型
   */
  export class Model {

    // 设备宽度
    displayWidth: number = 0;
    // 设备高度
    displayHeight: number = 0;
    // 设备DPI
    deviceDpi: number = Utils.DEVICE_DPI;
    // 设备状态栏高度
    statusBarHeight: number = 0;

    // 抽屉类型枚举
    drawerType: Type = Type.LEFT;
    // 侧边栏的宽度
    drawerWidth: number = 260;
    // 滑动多少距离触发动画
    drawerOffsetX: number = -1 * this.drawerWidth / 3;
    // 滑动动画时长
    drawerAnimDuration: number = 160;
    // 侧边栏是否显示 解决首次打开时会加载显示侧边栏问题
    isDrawerViewVisible: boolean = false;
    // 侧边栏是否打开
    isDrawerOpen: boolean = false;
    // 侧边栏X坐标
    drawerPositionX: number = this.drawerWidth * -1;
    // 侧边栏和屏幕宽度的差值
    drawerOffsetWidth: number = 0;

    // 遮罩层透明度 默认为 0.68
    maskOpacity: number = 0.68;
    // 遮罩层颜色
    maskColor: Color | string | number = Color.Black;

    // 屏幕是否为竖屏
    isScreenPortrait: boolean = true;

    // 侧边栏打开关闭状态回调函数
    drawerCallback: (drawerType: Type, isOpen: boolean) => void = () => {
    };
    // 屏幕横竖屏切换 竖屏为true,横屏为false
    onScreenPortraitCallback: (isPortrait: boolean) => void = () => {
    };

    setDrawerType(mDrawerType: Type): Model {
      this.drawerType = mDrawerType;
      return this;
    }

    setDrawerWidth(mDrawerWidth: number): Model {
      this.drawerWidth = mDrawerWidth;
      return this;
    }

    setDrawerOffsetX(mDrawerOffsetX: number): Model {
      this.drawerOffsetX = mDrawerOffsetX;
      return this;
    }

    setDrawerPositionX(mDrawerPositionX: number): Model {
      this.drawerPositionX = mDrawerPositionX;
      return this;
    }

    setDrawerAnimDuration(mDrawerAnimDuration: number): Model {
      this.drawerAnimDuration = mDrawerAnimDuration;
      return this;
    }

    setDrawerViewVisible(mDrawerViewVisible: boolean): Model {
      this.isDrawerViewVisible = mDrawerViewVisible;
      return this;
    }

    setDrawerOpen(mDrawerOpen: boolean): Model {
      this.isDrawerOpen = mDrawerOpen;
      return this;
    }

    setDeviceDpi(mDeviceDpi: number): Model {
      this.deviceDpi = mDeviceDpi;
      return this;
    }

    setDisplayWidth(mDisplayWidth: number): Model {
      this.displayWidth = mDisplayWidth;
      return this;
    }

    setDisplayHeight(mDisplayHeight: number): Model {
      this.displayHeight = mDisplayHeight;
      return this;
    }

    setMaskOpacity(mMaskOpacity: number): Model {
      this.maskOpacity = mMaskOpacity;
      return this;
    }

    setMaskColor(mMaskColor: Color | string | number): Model {
      this.maskColor = mMaskColor;
      return this;
    }

    setDrawerCallback(callback: (drawerType: Type, isOpen: boolean) => void): Model {
      this.drawerCallback = callback
      return this
    }

    setScreenPortraitCallback(callback: (isPortrait: boolean) => void): Model {
      this.onScreenPortraitCallback = callback
      return this
    }

    /**
     * 打开抽屉
     */
    openDrawer() {
      switch (this.drawerType) {
        case Type.LEFT:
          this.drawerPositionX = 0;
          break;
        case Type.RIGHT:
          this.drawerPositionX = this.drawerOffsetWidth;
          break;
      }
      this.isDrawerOpen = true;
      if (this.drawerCallback) {
        this.drawerCallback(this.drawerType, true);
      }
    }

    /**
     * 关闭抽屉
     */
    closeDrawer() {
      switch (this.drawerType) {
        case Type.LEFT:
          this.drawerPositionX = this.drawerWidth * -1;
          break;
        case Type.RIGHT:
          this.drawerPositionX = this.displayWidth;
          break;
      }
      this.isDrawerOpen = false;
      if (this.drawerCallback) {
        this.drawerCallback(this.drawerType, false);
      }
    }

    /**
     * 打开或者关闭抽屉
     */
    openOrCloseDrawer() {
      switch (this.drawerType) {
        case Type.LEFT:
          this.drawerPositionX = this.drawerPositionX === 0 ? this.drawerWidth * -1 : 0;
          this.isDrawerOpen = this.drawerPositionX === 0
          break;
        case Type.RIGHT:
          this.drawerPositionX = this.drawerPositionX === this.drawerOffsetWidth ? this.displayWidth : this.drawerOffsetWidth;
          this.isDrawerOpen = this.drawerPositionX === this.drawerOffsetWidth
          break;
      }
      if (this.drawerCallback) {
        this.drawerCallback(this.drawerType, this.isDrawerOpen);
      }
    }
  }

  /**
   * 工具类
   */
  export class Utils {

    /**
     * 100%
     */
    static readonly MATCH_PARENT: string = '100%';

    /**
     * 设备 dpi.
     */
    static readonly DEVICE_DPI: number = 160;

    /**
     * 获取屏幕高度
     * @param dpi
     * @returns
     */
    public static getDeviceHeight(dpi?: number): number {
      let displayObject = display.getDefaultDisplaySync();
      let screenPixelHeight = displayObject.height;
      let screenDensityDPI = displayObject.densityDPI;
      return screenPixelHeight * ((dpi == null ? this.DEVICE_DPI : dpi) / screenDensityDPI);
    }

    /**
     * 获取屏幕宽度
     * @param dpi
     * @returns
     */
    public static getDeviceWidth(dpi?: number): number {
      let displayObject = display.getDefaultDisplaySync();
      let screenPixelWidth = displayObject.width;
      let screenDensityDPI = displayObject.densityDPI;
      return screenPixelWidth * ((dpi == null ? this.DEVICE_DPI : dpi) / screenDensityDPI);
    }

    /**
     * 转换VP
     * @param width
     * @param dpi
     * @returns
     */
    public static toVp(width: number, dpi?: number): number {
      let displayObject = display.getDefaultDisplaySync();
      let screenDensityDPI = displayObject.densityDPI;
      return width * ((dpi == null ? this.DEVICE_DPI : dpi) / screenDensityDPI);
    }
  }
}

export default DrawerLayout

