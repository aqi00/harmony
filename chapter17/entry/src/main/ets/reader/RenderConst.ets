/**
 * 渲染相关常量（对应 Android DecodeServiceBase.PAGE_POOL_SIZE 等）。
 */
export class RenderConst {
  /** 页面句柄 LRU 缓存上限（对齐 Android DecodeServiceBase.PAGE_POOL_SIZE）。 */
  static readonly PAGE_POOL_SIZE: number = 16;
  /** 工具栏高度（vp）。 */
  static readonly TOOLBAR_HEIGHT: number = 50;
  /** 工具栏背景色（对齐 Android colors.xml blue_light #aaaaff）。 */
  static readonly TOOLBAR_BG: string = '#FFAAAAFF';
  /** 标题颜色。 */
  static readonly TITLE_COLOR: string = '#FFFFFFFF';
  /** 首屏预渲染页数（对齐 DjvuRenderActivity.doNext 的 mIndex<2 分支）。 */
  static readonly PRELOAD_PAGES: number = 2;
  /** 默认缩放（对齐 DjvuRenderActivity 调 decodePage(...,1,...) 的 zoom=1）。 */
  static readonly DEFAULT_ZOOM: number = 1;
}
