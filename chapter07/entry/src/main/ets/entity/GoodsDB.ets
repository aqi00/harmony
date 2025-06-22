import { relationalStore } from '@kit.ArkData';
import { ValuesBucket } from '@kit.ArkData';
import { GoodsInfo } from './GoodsInfo'
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalThis } from '../utils/GlobalThis';

export class GoodsDB {
  db_store: relationalStore.RdbStore | undefined = undefined;
  db_name: string = 'cart.db'
  STORE_CONFIG: relationalStore.StoreConfig = {
    name: this.db_name, // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别。安全性从低到高为：S1、S2、S3、S4
    encrypt: false // 是否加密。默认false表示不加密
  };

  table_name: string = 'goods_info'

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
      + `name VARCHAR NOT NULL, desc VARCHAR NOT NULL,`
      + `price INTEGER NOT NULL, picPath VARCHAR NOT NULL`
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

  insert(goods_info: GoodsInfo) {
    console.info('begin insert')
    let values: ValuesBucket = {}
    values.name = goods_info.name
    values.desc = goods_info.desc
    values.price = goods_info.price
    //console.info('110 insert')
    values.picPath = goods_info.picPath
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

  update(goods_info: GoodsInfo) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('id', goods_info.id);
    let values: ValuesBucket = {  }
    values.id = goods_info.id
    values.name = goods_info.name
    values.desc = goods_info.desc
    values.price = goods_info.price
    values.picPath = goods_info.picPath
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

  queryAll(): Array<GoodsInfo> {
    return this.query('1=1')
  }

  queryGoodsById(id: number): GoodsInfo {
    let goods_info = new GoodsInfo()
    let goodsArray = this.query('id='+id)
    if (goodsArray.length > 0) {
      goods_info = goodsArray[0]
    }
    return goods_info
  }

  query(condition: string): Array<GoodsInfo> {
    let GoodsArray = new Array<GoodsInfo>()
    if (!this.db_store) {
      return GoodsArray
    }
    let sql = `select * from ${this.table_name} where ${condition}`
    console.info('query sql: ' + sql)
    try {
      let resultSet = this.db_store.querySqlSync(sql)
      // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
      while (resultSet.goToNextRow()) { // 把游标指向下一条记录
        const id = resultSet.getLong(resultSet.getColumnIndex('id'));
        const name = resultSet.getString(resultSet.getColumnIndex('name'));
        const desc = resultSet.getString(resultSet.getColumnIndex('desc'));
        const price = resultSet.getLong(resultSet.getColumnIndex('price'));
        const picPath = resultSet.getString(resultSet.getColumnIndex('picPath'));
        console.info(`id=${id}, name=${name}, desc=${desc}, price=${price}, picPath=${picPath}`);
        let goods_info = new GoodsInfo()
        goods_info.id = id
        goods_info.name = name
        goods_info.desc = desc
        goods_info.price = price
        goods_info.picPath = picPath
        GoodsArray.push(goods_info) // 添加至结果数组
      }
      console.info('query length='+GoodsArray.length)
      // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
      resultSet.close();
    } catch (err) {
      console.error(`Query failed, code is ${err.code},message is ${err.message}`);
    }
    return GoodsArray
  }


}