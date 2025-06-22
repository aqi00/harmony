import { relationalStore } from '@kit.ArkData';
import { ValuesBucket } from '@kit.ArkData';
import { CartInfo } from './CartInfo'
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalThis } from '../utils/GlobalThis';

export class CartDB {
  db_store: relationalStore.RdbStore | undefined = undefined;
  db_name: string = 'cart.db'
  STORE_CONFIG: relationalStore.StoreConfig = {
    name: this.db_name, // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别。安全性从低到高为：S1、S2、S3、S4
    encrypt: false // 是否加密。默认false表示不加密
  };

  table_name: string = 'cart_info'

  constructor() {
    let context = GlobalThis.getInstance().getContext('context')
    relationalStore.getRdbStore(context, this.STORE_CONFIG)
      .then((rdbStore: relationalStore.RdbStore) => {
        this.db_store = rdbStore;
        console.info('Get RdbStore successfully.')
        this.create()
      }).catch((err: BusinessError) => {
      console.error(`Get RdbStore failed, name is ${err.code},message is ${err.message}`);
    })
  }

  create() {
    // let dropSQL = `DROP TABLE ${this.table_name}`
    // console.info('dropSQL: '+dropSQL)
    // this.db_store?.executeSql(dropSQL, (err) => {
    //   if (err) {
    //     console.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
    //     return;
    //   }
    //   console.info(`dropSQL executeSql table done.`);
    // })
    let createSQL = `CREATE TABLE IF NOT EXISTS ${this.table_name} (`
      + `id INTEGER PRIMARY KEY  AUTOINCREMENT NOT NULL,`
      + `goodsId INTEGER NOT NULL, count INTEGER NOT NULL,`
      + `updateTime VARCHAR NOT NULL`
      + `)`
    console.info('createSQL: '+createSQL)
    if (this.db_store) {
      this.db_store.executeSql(createSQL, (err) => {
        if (err) {
          console.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
          return;
        }
        console.info(`createSQL executeSql table done.`);
      })
      console.info('Create Table successfully.')
    }
  }

  insert(cart_info: CartInfo) {
    console.info('begin insert')
    let values: ValuesBucket = {}
    values.goodsId = cart_info.goodsId
    values.count = cart_info.count
    //console.info('110 insert')
    values.updateTime = new Date().toLocaleString()
    //console.info('111 insert')
    if (this.db_store) {
      this.db_store.insert(this.table_name, values).then((rowId: number) => {
        console.info(`Insert is successful, rowId = ${rowId}`);
      }).catch((err: BusinessError) => {
        // 返回14800021有三种可能：1、操作的表不存在；2、操作的列不存在；操作的函数不存在
        console.error(`Insert is failed, code is ${err.code},message is ${err.message}`);
      })
      console.info('end insert')
    }
  }

  update(cart_info: CartInfo) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('id', cart_info.id);
    let values: ValuesBucket = {  }
    values.id = cart_info.id
    values.goodsId = cart_info.goodsId
    values.count = cart_info.count
    values.updateTime = new Date().toLocaleString()
    if (this.db_store) {
      this.db_store.update(values, predicates).then((rowId: number) => {
        console.info(`Update is successful, rowId = ${rowId}`);
      }).catch((err: BusinessError) => {
        console.error(`Update is failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  delete(id: number) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('id', id);
    if (this.db_store) {
      this.db_store.delete(predicates).then((rows: Number) => {
        console.info(`Delete rows: ${rows}`);
      }).catch((err: BusinessError) => {
        console.error(`Delete failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  deleteAll() {
    const delete_sql = `delete from ${this.table_name} where 1=1`
    if (this.db_store) {
      this.db_store.executeSql(delete_sql).then(() => {
        console.info('Delete table done.');
      }).catch((err: BusinessError) => {
        console.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  queryAll(): Array<CartInfo> {
    return this.query('1=1')
  }

  query(condition: string): Array<CartInfo> {
    let cartArray = new Array<CartInfo>()
    if (!this.db_store) {
      return cartArray
    }
    let sql = `select * from ${this.table_name} where ${condition}`
    console.info('query sql: ' + sql)
    try {
      let resultSet = this.db_store.querySqlSync(sql)
      // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
      while (resultSet.goToNextRow()) { // 把游标指向下一条记录
        const id = resultSet.getLong(resultSet.getColumnIndex('id'));
        const goodsId = resultSet.getLong(resultSet.getColumnIndex('goodsId'));
        const count = resultSet.getLong(resultSet.getColumnIndex('count'));
        const updateTime = resultSet.getString(resultSet.getColumnIndex('updateTime'));
        console.info(`id=${id}, goodsId=${goodsId}, count=${count}, updateTime=${updateTime}`);
        let cart_info = new CartInfo()
        cart_info.id = id
        cart_info.goodsId = goodsId
        cart_info.count = count
        cart_info.updateTime = updateTime
        cartArray.push(cart_info) // 添加至结果数组
      }
      console.info('query length='+cartArray.length)
      // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
      resultSet.close();
    } catch (err) {
      console.error(`Query failed, code is ${err.code},message is ${err.message}`);
    }
    return cartArray
  }

  queryCartByGoodsId(goodsId: number): CartInfo|undefined {
    let cart_info: CartInfo|undefined = undefined
    let cartArray = this.query('goodsId='+goodsId)
    if (cartArray.length > 0) {
      cart_info = cartArray[0]
    }
    return cart_info
  }

  save(goodsId: number) {
    let cart_info = this.queryCartByGoodsId(goodsId)
    if (cart_info == undefined) {
      cart_info = new CartInfo()
      cart_info.goodsId = goodsId
      cart_info.count = 1
      this.insert(cart_info)
    } else {
      cart_info.count++
      this.update(cart_info)
    }
  }

}