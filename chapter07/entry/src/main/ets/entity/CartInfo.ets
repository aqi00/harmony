import { GoodsInfo } from './GoodsInfo'

export class CartInfo {
  id: number
  goodsId: number
  count: number
  updateTime: string
  goods_info: GoodsInfo

  constructor() {
    this.id = -1
    this.goodsId = 0
    this.count = 0
    this.updateTime = ''
    this.goods_info = new GoodsInfo()
  }

}