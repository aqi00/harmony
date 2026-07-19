import { ValueType } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';
import { UIContext } from '@kit.ArkUI';
import { QuestionDB } from '../entity/QuestionDB';

// 构造单例对象
export class GlobalThis {
  private constructor() {}
  private static instance: GlobalThis; // 单个实例
  private values: Record<string, ValueType> = {} // 键值对映射
  private context?: common.Context;
  private ui_context?: UIContext;
  private questionDao?: QuestionDB;

  // 获取单例对象
  public static getInstance(): GlobalThis {
    if (!GlobalThis.instance) {
      GlobalThis.instance = new GlobalThis();
    }
    return GlobalThis.instance;
  }

  // 获取所有数据的键值对映射
  public getAll(): Record<string, ValueType> {
    return this.values;
  }

  // 获取指定键名的键值
  public getValue(key: string): ValueType {
    return this.values[key];
  }

  // 更新指定键名的键值
  public setValue(key: string, value: ValueType): void {
    this.values[key] = value;
  }

  // 获取指定键名的上下文
  public getContext(key: string): common.Context {
    return this.context!;
  }

  // 更新指定键名的上下文
  public setContext(key: string, value: common.Context): void {
    this.context = value;
  }

  // 获取指定键名的UI上下文
  public getUIContext(key: string): UIContext {
    return this.ui_context!;
  }

  // 更新指定键名的UI上下文
  public setUIContext(key: string, value: UIContext): void {
    this.ui_context = value;
  }

  // 获取指定数据库的实例
  public getQuestionDB(): QuestionDB {
    return this.questionDao!;
  }

  // 更新指定数据库的实例
  public setQuestionDB(value: QuestionDB): void {
    this.questionDao = value;
  }

  // 其他需要传递的内容依此扩展
}
