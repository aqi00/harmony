import { client_socket } from '@ohos/socketio';

// 构造单例对象
export class GlobalThis {
  private constructor() {}
  private static instance: GlobalThis; // 单个实例
  private client: client_socket = new client_socket();

  // 获取单例对象
  public static getInstance(): GlobalThis {
    if (!GlobalThis.instance) {
      GlobalThis.instance = new GlobalThis();
    }
    return GlobalThis.instance;
  }

  public getSocket(): client_socket {
    return this.client;
  }

}
