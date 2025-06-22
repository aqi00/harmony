import { ImagePart } from './ImagePart';

export interface ImageMessage {
  from: string; // 消息的发送者
  to: string; // 消息的接收者
  part: ImagePart; // 图像片段
}