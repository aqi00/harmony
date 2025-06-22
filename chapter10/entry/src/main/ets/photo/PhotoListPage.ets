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

@Entry
@Component
struct PhotoListPage {
  router = this.getUIContext().getRouter();
  photoArr: Array<Resource> = (this.router.getParams() as Record<string, Array<Resource>>)['photoArr'];
  @StorageLink('selectedIndex') selectedIndex: number = 0;

  build() {
    Navigation() {
      Grid() {
        ForEach(this.photoArr, (img: Resource, index?: number) => {
          GridItem() {
            Image(img).width('100%').height('100%').objectFit(ImageFit.Cover)
              .onClick(() => {
                if (!index) {
                  index = 0;
                }
                this.selectedIndex = index;
                this.router.pushUrl({
                  url: 'photo/PhotoPreviewPage',
                  params: {
                    photoArr: this.photoArr,
                  }
                });
              })
          }
          .width('100%').aspectRatio(1) // 宽高比为
        })
      }
      .columnsGap(2).rowsGap(2).columnsTemplate('1fr 1fr 1fr 1fr')
      .layoutWeight(1)
    }
    .title('电子相册')
    .hideBackButton(false)
    .titleMode(NavigationTitleMode.Mini)
  }
}