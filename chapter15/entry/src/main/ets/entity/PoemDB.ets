import { relationalStore } from '@kit.ArkData';
import { ValuesBucket } from '@kit.ArkData';
import { PoemInfo } from './PoemInfo'
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalThis } from '../utils/GlobalThis';

export class PoemDB {
  db_store: relationalStore.RdbStore | undefined = undefined;
  db_name: string = 'poem.db'
  STORE_CONFIG: relationalStore.StoreConfig = {
    name: this.db_name, // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别。安全性从低到高为：S1、S2、S3、S4
    encrypt: false // 是否加密。默认false表示不加密
  };

  table_name: string = 'poem'

  constructor() {
    let context = GlobalThis.getInstance().getContext('context')
    relationalStore.getRdbStore(context, this.STORE_CONFIG)
      .then((rdbStore: relationalStore.RdbStore) => {
        this.db_store = rdbStore;
        console.info('Get RdbStore successfully.')
        this.create()
      }).catch((err: BusinessError) => {
      console.error(`Get RdbStore failed, title is ${err.code},message is ${err.message}`);
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
      + `title VARCHAR NOT NULL, author VARCHAR NOT NULL,`
      + `dynasty VARCHAR NOT NULL, content VARCHAR NOT NULL,`
      + `pinyin VARCHAR NOT NULL`
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

  insert(poem_info: PoemInfo) {
    console.info(`begin insert title=${poem_info.title},author=${poem_info.author},dynasty=${poem_info.dynasty},content=${poem_info.content},pinyin=${poem_info.pinyin}`)
    let values: ValuesBucket = {}
    values.title = poem_info.title
    values.author = poem_info.author
    values.dynasty = poem_info.dynasty
    values.content = poem_info.content
    values.pinyin = poem_info.pinyin
    //console.info('110 insert')
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

  insertPoemList(poem_list: PoemInfo[]) {
    for (let poem_info of poem_list) {
      this.insert(poem_info)
    }
  }

  update(poem_info: PoemInfo) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('id', poem_info.id);
    let values: ValuesBucket = {  }
    values.id = poem_info.id
    values.title = poem_info.title
    values.author = poem_info.author
    values.dynasty = poem_info.dynasty
    values.content = poem_info.content
    values.pinyin = poem_info.pinyin
    if (this.db_store) {
      this.db_store.update(values, predicates).then((rowId: number) => {
        console.info(`Update is successful, rowId = ${rowId}`);
      }).catch((err: BusinessError) => {
        console.error(`Update is failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  delete(title: string) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('title', title);
    if (this.db_store) {
      this.db_store.delete(predicates).then((rows: Number) => {
        console.info(`Delete rows: ${rows}`);
      }).catch((err: BusinessError) => {
        console.error(`Delete failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  deleteAll() {
    let delete_sql = `delete from ${this.table_name} where 1=1`
    if (this.db_store) {
      this.db_store.executeSql(delete_sql).then(() => {
        console.info('Delete table done.');
      }).catch((err: BusinessError) => {
        console.error(`ExecuteSql failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  queryAll(): Array<PoemInfo> {
    return this.query('1=1')
  }

  query(condition: string): Array<PoemInfo> {
    let poemArray = new Array<PoemInfo>()
    if (!this.db_store) {
      return poemArray
    }
    let sql = `select * from ${this.table_name} where ${condition}`
    console.info('query sql: ' + sql)
    try {
      let resultSet = this.db_store.querySqlSync(sql)
      // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
      while (resultSet.goToNextRow()) { // 把游标指向下一条记录
        let id = resultSet.getLong(resultSet.getColumnIndex('id'));
        let title = resultSet.getString(resultSet.getColumnIndex('title'));
        let author = resultSet.getString(resultSet.getColumnIndex('author'));
        let dynasty = resultSet.getString(resultSet.getColumnIndex('dynasty'));
        let content = resultSet.getString(resultSet.getColumnIndex('content'));
        let pinyin = resultSet.getString(resultSet.getColumnIndex('pinyin'))
        console.info(`id=${id}, title=${title}, title=${title}, dynasty=${dynasty}, content=${content}, pinyin=${pinyin}`);
        let poem_info = new PoemInfo('' ,'' ,'' ,'')
        poem_info.id = id
        poem_info.title = title
        poem_info.author = author
        poem_info.dynasty = dynasty
        poem_info.content = content
        poem_info.pinyin = pinyin
        poemArray.push(poem_info) // 添加至结果数组
      }
      console.info('query length='+poemArray.length)
      // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
      resultSet.close();
    } catch (err) {
      console.error(`Query failed, code is ${err.code},message is ${err.message}`);
    }
    return poemArray
  }

}