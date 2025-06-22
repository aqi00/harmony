
import { AnimationWidgets } from '../view/AnimationWidgets';
import { CountController } from '../view/CountController';
import {IconsModel} from '../viewmodel/IconsModel';

@Entry
@Component
struct PlayCardPage {
  @State quantity: number = 3; // 卡片数量
  @Provide iconModel: IconsModel = new IconsModel(this.quantity, 145);

  build() {
    Column() {
      AnimationWidgets({
        quantity: $quantity
      })
      CountController({
        quantity: $quantity
      })
    }
    .width('100%').height('100%').backgroundColor('#f1f3f5')
  }
}