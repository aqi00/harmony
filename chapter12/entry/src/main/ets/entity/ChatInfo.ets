export interface ChatInfo {
  type: number // 消息类型。0 提示消息；1 文本消息；2 图片消息
  source: number // 消息来源。0 系统消息；1 自己消息；2 别人消息
  name?: string // 昵称
  portrait?: Resource // 头像
  content?: string // 消息内容
  pixelMap?: PixelMap // 消息图片
  aspect?: number // 宽高比
  isGroup?: boolean // 是否群消息
}