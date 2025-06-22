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

import IconItem from '../viewmodel/IconItem';

@Component
export struct IconAnimation {
  @Link activeFlag: boolean;
  @ObjectLink item: IconItem;

  build() {
    Image(this.item.image)
      .width(70).height(70).objectFit(ImageFit.Contain)
      .translate(this.activeFlag ? { x: this.item.point.x, y: this.item.point.y } : { x: 0, y: 0 })
      .rotate( {
        x: 0, y: 1, z: 0,
        angle: this.item.clicked ? 360 : 0
      } )
      .scale(this.item.clicked ? { x: 1.25, y: 1.25 } : { x: 1, y: 1 })
      .opacity(this.item.clicked ? 0.6 : 1)
      .onClick(() => {
        this.item.clicked = !this.item.clicked;
      })
      .animation( {
          delay: 10,
          duration: 1000,
          iterations: 1,
          curve: Curve.Smooth,
          playMode: PlayMode.Normal
        } )
  }
}