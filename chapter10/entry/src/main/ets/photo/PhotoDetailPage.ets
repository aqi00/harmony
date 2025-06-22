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

import { router, display } from '@kit.ArkUI';

@Entry
@Component
struct PhotoDetailPage {
  router = this.getUIContext().getRouter();
  private scroller: Scroller = new Scroller();
  private photoArr: Array<Resource> = (this.router.getParams() as Record<string, Array<Resource>>)['photoArr'];
  private currentScale: number = 1;
  private currentRotate: number = 0;
  private preOffsetX: number = 0;
  private preOffsetY: number = 0;
  @State deviceWidth: number = 360;
  @State smallImgWidth: number = (360 - 2 * (7)) / 8;
  @State imageWidth: number = this.deviceWidth + this.smallImgWidth;
  @StorageLink('selectedIndex') selectedIndex: number = 0;
  @State isScaling: boolean = true;
  @State imgScale: number = 1;
  @State imgRotate: number = 0;
  @State imgOffSetX: number = 0;
  @State imgOffSetY: number = 0;
  @State bgOpacity: number = 0;

  aboutToAppear() {
    let displayClass: display.Display = display.getDefaultDisplaySync();
    let width = displayClass?.width / displayClass.densityPixels ?? 360;
    this.deviceWidth = width;
    this.smallImgWidth = (width - 2 * 7) / 8;
    this.imageWidth = this.deviceWidth + this.smallImgWidth;
  }

  resetImg(): void {
    this.imgScale = 1;
    this.currentScale = 1;
    this.preOffsetX = 0;
    this.preOffsetY = 0;
  }

  handlePanEnd(): void {
    let initOffsetX = (this.imgScale - 1) * this.imageWidth + this.smallImgWidth;
    if (Math.abs(this.imgOffSetX) > initOffsetX) {
      if (this.imgOffSetX > initOffsetX && this.selectedIndex > 0) {
        this.selectedIndex -= 1;
      } else if (this.imgOffSetX < -initOffsetX && this.selectedIndex < (this.photoArr.length - 1)) {
        this.selectedIndex += 1;
      }
      this.isScaling = false;
      this.resetImg();
      this.scroller.scrollTo({ xOffset: this.selectedIndex * this.imageWidth, yOffset: 0 });
    }
  }

  build() {
    Stack() {
      List({ scroller: this.scroller, initialIndex: this.selectedIndex }) {
        ForEach(this.photoArr, (img: Resource) => {
          ListItem() {
            Image(img).objectFit(ImageFit.Contain)
              .onClick(() => this.router.back())
          }
          .gesture(GestureGroup(GestureMode.Exclusive,
            PinchGesture({ fingers: 2 })
              .onActionStart(() => {
                this.resetImg();
                this.isScaling = true;
                this.imgOffSetX = 0;
                this.imgOffSetY = 0;
              })
              .onActionUpdate((event?: GestureEvent) => {
                if (event) {
                  this.imgScale = this.currentScale * event.scale;
                }
              })
              .onActionEnd(() => {
                if (this.imgScale < 1) {
                  this.resetImg();
                  this.imgOffSetX = 0;
                  this.imgOffSetY = 0;
                } else {
                  this.currentScale = this.imgScale;
                }
              }), PanGesture()
              .onActionStart(() => {
                this.resetImg();
                this.isScaling = true;
              })
              .onActionUpdate((event?: GestureEvent) => {
                if (event) {
                  this.imgOffSetX = this.preOffsetX + event.offsetX;
                  this.imgOffSetY = this.preOffsetY + event.offsetY;
                }
              })
          ))
          .padding({
            left: this.smallImgWidth / 2,
            right: this.smallImgWidth / 2
          })
          .width(this.imageWidth)
        })
      }
      .onScrollStop(() => {
        let currentIndex = Math.round(((this.scroller.currentOffset().xOffset as number) +
          (this.imageWidth / 2)) / this.imageWidth);
        this.selectedIndex = currentIndex;
        this.scroller.scrollTo({ xOffset: currentIndex * this.imageWidth, yOffset: 0 });
      })
      .width('100%').height('100%').listDirection(Axis.Horizontal)
      .visibility(this.isScaling ? Visibility.Hidden : Visibility.Visible)

      Row() {
        Image(this.photoArr[this.selectedIndex])
          .position({ x: this.imgOffSetX, y: this.imgOffSetY })
          .scale({ x: this.imgScale, y: this.imgScale })
          .objectFit(ImageFit.Contain)
          .onClick(() => this.router.back())
      }
      .gesture(GestureGroup(GestureMode.Exclusive,
        PinchGesture({ fingers: 2 })
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              this.imgScale = this.currentScale * event.scale;
            }
          })
          .onActionEnd(() => {
            if (this.imgScale < 1) {
              this.resetImg();
              this.imgOffSetX = 0;
              this.imgOffSetY = 0;
            } else {
              this.currentScale = this.imgScale;
            }
          }),
        PanGesture()
          .onActionStart(() => {
            this.preOffsetX = this.imgOffSetX;
            this.preOffsetY = this.imgOffSetY;
          })
          .onActionUpdate((event?: GestureEvent) => {
            if (event) {
              this.imgOffSetX = this.preOffsetX + event.offsetX;
              this.imgOffSetY = this.preOffsetY + event.offsetY;
            }
          })
          .onActionEnd(() => this.handlePanEnd())
      ))
      .padding({
        left: this.smallImgWidth / 2,
        right: this.smallImgWidth / 2
      })
      .width(this.imageWidth).height('100%')
      .visibility(this.isScaling ? Visibility.Visible : Visibility.Hidden)
    }
    .offset({ x: -(this.smallImgWidth / 2) })
    .width(this.imageWidth).height('100%')
    .backgroundColor(Color.Black)
  }
}