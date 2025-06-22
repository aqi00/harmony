import { relationalStore } from '@kit.ArkData';
import { ValuesBucket } from '@kit.ArkData';
import { UserInfo } from './UserInfo'
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalThis } from '../utils/GlobalThis';

export class UserDB {
  db_store: relationalStore.RdbStore | undefined = undefined;
  db_name: string = 'user.db'
  STORE_CONFIG: relationalStore.StoreConfig = {
    name: this.db_name, // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别。安全性从低到高为：S1、S2、S3、S4
    encrypt: false // 是否加密。默认false表示不加密
  };

  table_name: string = 'user'

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
      + `name VARCHAR NOT NULL, age INTEGER NOT NULL,`
      + `stature INTEGER NOT NULL, weight FLOAT NOT NULL,`
      + `ismarried INTEGER NOT NULL, update_time VARCHAR NOT NULL`
      + `,phone VARCHAR, password VARCHAR`
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

  insert(user_info: UserInfo) {
    console.info('begin insert')
    let values: ValuesBucket = {}
    values.name = user_info.name
    values.age = user_info.age
    values.stature = user_info.stature
    values.weight = user_info.weight
    values.ismarried = user_info.ismarried ? 1 : 0
    values.phone = user_info.phone
    values.password = user_info.password
    //console.info('110 insert')
    values.update_time = new Date().toLocaleString()
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

  update(user_info: UserInfo) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('id', user_info.id);
    let values: ValuesBucket = {  }
    values.id = user_info.id
    values.name = user_info.name
    values.age = user_info.age
    values.stature = user_info.stature
    values.weight = user_info.weight
    values.ismarried = user_info.ismarried ? 1 : 0
    values.update_time = new Date().toLocaleString()
    values.phone = user_info.phone
    values.password = user_info.password
    if (this.db_store) {
      this.db_store.update(values, predicates).then((rowId: number) => {
        console.info(`Update is successful, rowId = ${rowId}`);
      }).catch((err: BusinessError) => {
        console.error(`Update is failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  delete(name: string) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('name', name);
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

  queryAll(): Array<UserInfo> {
    return this.query('1=1')
  }

  queryByPhone(phone: string): UserInfo {
    let user_info = new UserInfo()
    let userArray = this.query('phone='+phone)
    if (userArray.length > 0) {
      user_info = userArray[0]
    }
    return user_info
  }

  query(condition: string): Array<UserInfo> {
    let userArray = new Array<UserInfo>()
    if (!this.db_store) {
      return userArray
    }
    let sql = `select * from ${this.table_name} where ${condition}`
    console.info('query sql: ' + sql)
    try {
      let resultSet = this.db_store.querySqlSync(sql)
      // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
      while (resultSet.goToNextRow()) { // 把游标指向下一条记录
        let id = resultSet.getLong(resultSet.getColumnIndex('id'));
        let name = resultSet.getString(resultSet.getColumnIndex('name'));
        let age = resultSet.getLong(resultSet.getColumnIndex('age'));
        let stature = resultSet.getDouble(resultSet.getColumnIndex('stature'));
        let weight = resultSet.getDouble(resultSet.getColumnIndex('weight'));
        let ismarried = resultSet.getLong(resultSet.getColumnIndex('ismarried')) == 0 ? false : true;
        let update_time = resultSet.getString(resultSet.getColumnIndex('update_time'));
        let phone = resultSet.getString(resultSet.getColumnIndex('phone'));
        let password = resultSet.getString(resultSet.getColumnIndex('password'));
        console.info(`id=${id}, name=${name}, age=${age}, stature=${stature}, weight=${weight}, ismarried=${ismarried}, ` +
          `update_time=${update_time}, phone=${phone}, password=${password}`);
        let user_info = new UserInfo()
        user_info.id = id
        user_info.name = name
        user_info.age = age
        user_info.stature = stature
        user_info.weight = weight
        user_info.ismarried = ismarried
        user_info.update_time = update_time
        user_info.phone = phone
        user_info.password = password
        userArray.push(user_info) // 添加至结果数组
      }
      console.info('query length='+userArray.length)
      // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
      resultSet.close();
    } catch (err) {
      console.error(`Query failed, code is ${err.code},message is ${err.message}`);
    }
    return userArray
  }

  // queryAll(callback: Function) {
  //   let userArray = new Array<UserInfo>()
  //   let predicates = new relationalStore.RdbPredicates(this.table_name);
  //   //predicates.notEqualTo('id', '-1');
  //   if (!this.db_store) {
  //     return
  //   }
  //   // 数据库的查询结果异步返回
  //   this.db_store.query(predicates, (err, resultSet) => {
  //     if (err) {
  //       console.error(`Query failed, code is ${err.code},message is ${err.message}`);
  //       return;
  //     }
  //     console.info(`ResultSet column names: ${resultSet.columnNames}, column count: ${resultSet.columnCount}`);
  //     // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
  //     while (resultSet.goToNextRow()) { // 把游标指向下一条记录
  //       let id = resultSet.getLong(resultSet.getColumnIndex('id'));
  //       let name = resultSet.getString(resultSet.getColumnIndex('name'));
  //       let age = resultSet.getLong(resultSet.getColumnIndex('age'));
  //       let stature = resultSet.getDouble(resultSet.getColumnIndex('stature'));
  //       let weight = resultSet.getDouble(resultSet.getColumnIndex('weight'));
  //       let ismarried = resultSet.getLong(resultSet.getColumnIndex('ismarried'))==0 ? false : true;
  //       let update_time = resultSet.getString(resultSet.getColumnIndex('update_time'));
  //       let phone = resultSet.getString(resultSet.getColumnIndex('phone'));
  //       let password = resultSet.getString(resultSet.getColumnIndex('password'));
  //       console.info(`id=${id}, name=${name}, age=${age}, stature=${stature}, weight=${weight}, ismarried=${ismarried}, ` +
  //         `update_time=${update_time}, phone=${phone}, password=${password}`);
  //       let user_info = new UserInfo()
  //       user_info.name = name
  //       user_info.age = age
  //       user_info.stature = stature
  //       user_info.weight = weight
  //       user_info.ismarried = ismarried
  //       user_info.id = id
  //       user_info.update_time = update_time
  //       user_info.phone = phone
  //       user_info.password = password
  //       userArray.push(user_info)
  //     }
  //     // 释放数据集的内存
  //     resultSet.close();
  //     console.info('queryAll length='+userArray.length)
  //     callback(userArray);
  //   })
  // }


}