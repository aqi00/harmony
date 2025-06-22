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

@Component
export default struct PhotoItem {
  private photoArr: Array<Resource> = [];
  @State currentIndex: number = 0;
  private showCount: number = 4;
  private CACHE_IMG_LIST: string[] = ['', '', '', ''];

  @Builder albumPicBuilder(img: Resource, index: number) {
    Column() {
      Image(img)
        .width('100%').height('100%') .borderRadius(12)
        .opacity(1 - (this.showCount - index - 1) * 0.2)
    }
    .padding((this.showCount - index - 1) * 8)
    .offset({ y: (this.showCount - index - 1) * 16 })
    .width('100%').height('90%')
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      ForEach(this.CACHE_IMG_LIST, (image: string, index?: number) => {
        if (index) {
          this.albumPicBuilder(this.photoArr[this.showCount - index - 1], index)
        }
      })
    }
    .width('100%') .height('100%')
  }
}