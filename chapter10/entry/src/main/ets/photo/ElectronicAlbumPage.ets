/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { router } from '@kit.ArkUI';
import PhotoItem from '../view/PhotoItem';

@Entry
@Component
struct ElectronicAlbumPage {
  router = this.getUIContext().getRouter();

  private BANNER_IMG_LIST: Array<Resource> = [
    $r('app.media.ic_scene_1'), $r('app.media.ic_food_0'), $r('app.media.ic_life_0'), $r('app.media.ic_men_0') ];
  private SCENE_LIST: Array<Resource> = [ $r('app.media.ic_scene_1'), $r('app.media.ic_scene_2'), $r('app.media.ic_scene_0') ];
  private MEN_LIST: Array<Resource> = [ $r('app.media.ic_men_0'), $r('app.media.ic_men_2'), $r('app.media.ic_men_3') ];
  private FOOD_LIST: Array<Resource> = [ $r('app.media.ic_food_1'), $r('app.media.ic_food_0') ];
  private LIFE_LIST: Array<Resource> = [
    $r('app.media.ic_life_1'), $r('app.media.ic_life_0'), $r('app.media.ic_life_2'),
    $r('app.media.ic_life_3'), $r('app.media.ic_life_4'), $r('app.media.ic_life_5')
  ];
  private IMG_ARR: Resource[][] = [
    new Array<Resource>().concat(this.SCENE_LIST, this.LIFE_LIST, this.MEN_LIST),
    new Array<Resource>().concat(this.MEN_LIST, this.LIFE_LIST, this.SCENE_LIST),
    new Array<Resource>().concat(this.FOOD_LIST, this.SCENE_LIST, this.SCENE_LIST),
    new Array<Resource>().concat(this.LIFE_LIST, this.FOOD_LIST, this.MEN_LIST)
  ];

  build() {
    Column() {
      Row() {
        Text('电子相册').fontSize(30)
      }
      .width('100%').height(56).margin({ top: 12 }).padding({ left: 24 })

      Swiper() {
        ForEach(this.BANNER_IMG_LIST, (item: Resource) => {
          Row() {
            Image(item).width('100%').height('100%')
          }
          .width('100%').aspectRatio(1.5) // 宽高比为1.5
        })
      }
      .margin(12).autoPlay(true).loop(true).duration(300)
      .borderRadius(12).indicator(true).displayArrow(true)

      Grid() {
        ForEach(this.IMG_ARR, (photoArr: Array<Resource>) => {
          GridItem() {
            PhotoItem({ photoArr })
          }
          .width('100%').aspectRatio(0.7) // 宽高比为0.7
          .onClick(() => {
            this.router.pushUrl({
              url: 'photo/PhotoListPage',
              params: { photoArr: photoArr }
            });
          })
        })
      }
      .width('100%').layoutWeight(1).padding({ left: 12, right: 12 })
      .columnsGap(12).rowsGap(12).columnsTemplate('1fr 1fr')
    }
    .width('100%').height('100%')
  }
}