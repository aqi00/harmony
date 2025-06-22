import { VideoInfo } from './VideoInfo'

export interface QueryResponse {
  code: string // 结果代码
  desc: string // 结果描述
  videoList: VideoInfo[] // 在线视频的路径列表
}