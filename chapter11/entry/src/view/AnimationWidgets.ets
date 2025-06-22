/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IconsModel } from '../viewmodel/IconsModel';
import { IconAnimation } from './IconAnimation';
import IconItem from '../viewmodel/IconItem';

@Component
export struct AnimationWidgets {
  @State clickText: string = '点击按钮甩出卡片';
  @State activeFlag: boolean = false;
  @Link @Watch('onQuantityChange') quantity: number;
  @Consume iconModel: IconsModel;

  onQuantityChange() {
    // changeImage不仅改变图标的数量，还调整各图标的坐标
    this.iconModel.changeImage(this.quantity);
  }

  aboutToAppear() {
    this.onQuantityChange();
  }

  animate() {
    animateTo( {
        delay: 10,
        tempo: 0.68,
        iterations: 1,
        duration: 500,
        curve: Curve.Smooth,
        playMode: PlayMode.Normal
      }, () => {
        this.activeFlag = !this.activeFlag;
    } )
  }

  build() {
    Stack() {
      Stack() {
        // 这里的ForEach设置了keyGenerator，增删图标时才会播放动画
        ForEach(this.iconModel.imagerArr, (item: IconItem) => {
          IconAnimation({ item: item, activeFlag: $activeFlag })
        //})
        }, (item: IconItem) => JSON.stringify(item.index))
        //}, (item: IconItem, index: number) => index + '__' + JSON.stringify(item.index))
      }
      .width('100%').height('100%')
      .rotate({
        x: 0, y: 0, z: 1,
        angle: this.activeFlag ? 360 : 0 // 控制甩出礼物时的360度旋转效果
      })

      Image(this.activeFlag ? $r('app.media.imgActive') : $r('app.media.imgInit'))
        .width(70).height(70).objectFit(ImageFit.Contain)
        .scale({
          x: this.activeFlag ? 0.75 : 1,
          y: this.activeFlag ? 0.75 : 1
        })
        .onClick(() => {
          this.iconModel.reset();
          this.animate();
        })

      Text(this.activeFlag ? '点击按钮收回卡片' : '点击按钮甩出卡片')
        .fontSize(18).margin({ top: 100 })
    }
    .width('100%').layoutWeight(1)
  }
}