export interface VideoInfo{
  id?: number // 编号
  title?: string // 标题
  duration?: number // 播放时长
  size?: number // 文件大小
  date?: string // 拍摄日期
  address?: string // 拍摄地址
  label?: string // 视频标签
  desc?: string // 视频描述
  cover?: string // 视频封面
  video: string // 视频链接
}