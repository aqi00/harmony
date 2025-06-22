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

enum scrollTypeEnum {
  STOP = 'onScrollStop',
  SCROLL = 'onScroll'
};

@Entry
@Component
struct PhotoPreviewPage { // 该页面需要在真机上验证，在预览器上不显示图片
  router = this.getUIContext().getRouter();
  private CACHE_IMG_LIST: string[] = ['', '', '', ''];
  private smallScroller: Scroller = new Scroller();
  private bigScroller: Scroller = new Scroller();
  @State deviceWidth: number = 360;
  @State smallImgWidth: number = (this.deviceWidth - 2 * 7) / 8;
  @State imageWidth: number = this.deviceWidth + this.smallImgWidth;
  private photoArr: Array<Resource | string> = (this.router.getParams() as Record<string, Array<Resource | string>>)['photoArr'];
  private smallPhotoArr: Array<Resource | string> = new Array<Resource | string>().concat(this.CACHE_IMG_LIST,
    (this.router.getParams() as Record<string, Array<Resource | string>>)['photoArr'], this.CACHE_IMG_LIST)
  @StorageLink('selectedIndex') selectedIndex: number = 0;

  @Builder SmallImgItemBuilder(img: Resource, index?: number) {
    if (index && index > (4 - 1) && index < (this.smallPhotoArr.length - 4)) {
      Image(img).onClick(() => this.smallImgClickAction(index))
    }
  }

  aboutToAppear() {
    let displayClass: display.Display = display.getDefaultDisplaySync();
    let width = displayClass?.width / displayClass.densityPixels ?? 360;
    this.deviceWidth = width;
    this.smallImgWidth = (width - 2 * 7) / 8;
    this.imageWidth = this.deviceWidth + this.smallImgWidth;
  }

  onPageShow() {
    this.smallScroller.scrollToIndex(this.selectedIndex);
    this.bigScroller.scrollToIndex(this.selectedIndex);
  }

  goDetailPage(): void {
    this.router.pushUrl({
      url: 'photo/PhotoDetailPage',
      params: { photoArr: this.photoArr }
    });
  }

  smallImgClickAction(index: number): void {
    this.selectedIndex = index - 4;
    this.smallScroller.scrollToIndex(this.selectedIndex);
    this.bigScroller.scrollToIndex(this.selectedIndex);
  }

  smallScrollAction(type: scrollTypeEnum): void {
    this.selectedIndex = Math.round(((this.smallScroller.currentOffset().xOffset as number) +
    this.smallImgWidth / 2) / (this.smallImgWidth + 2));
    if (type === scrollTypeEnum.SCROLL) {
      this.bigScroller.scrollTo({ xOffset: this.selectedIndex * this.imageWidth, yOffset: 0 });
    } else {
      this.smallScroller.scrollTo({ xOffset: this.selectedIndex * this.smallImgWidth, yOffset: 0 });
    }
  }

  bigScrollAction(type: scrollTypeEnum): void {
    let smallWidth = this.smallImgWidth + 2;
    this.selectedIndex = Math.round(((this.bigScroller.currentOffset().xOffset as number) +
      smallWidth / 2) / this.imageWidth);
    if (type === scrollTypeEnum.SCROLL) {
      this.smallScroller.scrollTo({ xOffset: this.selectedIndex * smallWidth, yOffset: 0 });
    } else {
      this.bigScroller.scrollTo({ xOffset: this.selectedIndex * this.imageWidth, yOffset: 0 });
    }
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        List({ scroller: this.bigScroller, initialIndex: this.selectedIndex }) {
          ForEach(this.photoArr, (img: Resource) => {
            ListItem() {
              Image(img)
                .width('100%').height('100%').objectFit(ImageFit.Contain)
                .gesture(PinchGesture({ fingers: 2 })
                  .onActionStart(() => this.goDetailPage()))
                .onClick(() => this.goDetailPage())
            }
            .padding({
              left: this.smallImgWidth / 2,
              right: this.smallImgWidth / 2
            })
            .width(this.imageWidth)
          })
        }
        .onDidScroll((scrollOffset, scrollState) => {
          if (scrollState === ScrollState.Fling) {
            this.bigScrollAction(scrollTypeEnum.SCROLL);
          }
        })
        .onScrollStop(() => this.bigScrollAction(scrollTypeEnum.STOP))
        .width('100%').height('100%')
        .padding({ bottom: this.smallImgWidth * 2 })
        .listDirection(Axis.Horizontal)

        List({
          scroller: this.smallScroller,
          space: 2,
          initialIndex: this.selectedIndex
        }) {
          ForEach(this.smallPhotoArr, (img: Resource, index?: number) => {
            ListItem() {
              this.SmallImgItemBuilder(img, index)
            }
            .width(this.smallImgWidth).aspectRatio(1)
          })
        }
        .listDirection(Axis.Horizontal)
        .onDidScroll((scrollOffset, scrollState) => {
          if (scrollState === ScrollState.Fling) {
            this.smallScrollAction(scrollTypeEnum.SCROLL);
          }
        })
        .onScrollStop(() => this.smallScrollAction(scrollTypeEnum.STOP))
        .width('100%').height(this.smallImgWidth).margin({ top: 20, bottom: 20 })
      }
      .width(this.imageWidth).height('100%')
    }
    .title('电子相册')
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
  }
}