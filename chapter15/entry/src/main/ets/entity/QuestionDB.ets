import { relationalStore } from '@kit.ArkData';
import { ValuesBucket } from '@kit.ArkData';
import { QuestionInfo } from './QuestionInfo'
import { BusinessError } from '@kit.BasicServicesKit';
import { GlobalThis } from '../utils/GlobalThis';

export class QuestionDB {
  db_store: relationalStore.RdbStore | undefined = undefined;
  db_name: string = 'question.db'
  STORE_CONFIG: relationalStore.StoreConfig = {
    name: this.db_name, // 数据库文件名
    securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别。安全性从低到高为：S1、S2、S3、S4
    encrypt: false // 是否加密。默认false表示不加密
  };

  table_name: string = 'question'

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
      + `question VARCHAR NOT NULL, answer VARCHAR NOT NULL,`
      + `type INTEGER NOT NULL`
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

  insert(question_info: QuestionInfo) {
    console.info(`begin insert question=${question_info.question},answer=${question_info.answer},type=${question_info.type}`)
    let values: ValuesBucket = {}
    values.question = question_info.question
    values.answer = question_info.answer
    values.type = question_info.type
    //console.info('111 insert')
    if (this.db_store) {
      this.db_store.insert(this.table_name, values).then((rowId: number) => {
        console.info(`Insert is successful, rowId = ${rowId}`);
      }).catch((err: BusinessError) => {
        // 返回14800021有三种可能：1、操作的表不存在；2、操作的列不存在；操作的函数不存在
        console.error(`Insert is failed, code is ${err.code},message is ${err.message}`);
      })
      //console.info('end insert')
    }
  }

  insertQuestionList(question_list: QuestionInfo[]) {
    for (let question_info of question_list) {
      this.insert(question_info)
    }
  }

  update(question_info: QuestionInfo) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('id', question_info.id);
    let values: ValuesBucket = {  }
    values.id = question_info.id
    values.question = question_info.question
    values.answer = question_info.answer
    values.type = question_info.type
    if (this.db_store) {
      this.db_store.update(values, predicates).then((rowId: number) => {
        console.info(`Update is successful, rowId = ${rowId}`);
      }).catch((err: BusinessError) => {
        console.error(`Update is failed, code is ${err.code},message is ${err.message}`);
      })
    }
  }

  delete(question: string) {
    let predicates = new relationalStore.RdbPredicates(this.table_name);
    predicates.equalTo('question', question);
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

  queryAllCustomQuestion(): Array<QuestionInfo> {
    return this.query('type=1')
  }

  queryQuestionById(id: number): QuestionInfo {
    let questionArray = this.query('id='+id)
    return questionArray[0]
  }

  queryAll(): Array<QuestionInfo> {
    return this.query('1=1')
  }

  query(condition: string): Array<QuestionInfo> {
    let questionArray = new Array<QuestionInfo>()
    if (!this.db_store) {
      return questionArray
    }
    let sql = `select * from ${this.table_name} where ${condition}`
    console.info('query sql: ' + sql)
    try {
      let resultSet = this.db_store.querySqlSync(sql)
      // resultSet是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始。
      while (resultSet.goToNextRow()) { // 把游标指向下一条记录
        let id = resultSet.getLong(resultSet.getColumnIndex('id'));
        let question = resultSet.getString(resultSet.getColumnIndex('question'));
        let answer = resultSet.getString(resultSet.getColumnIndex('answer'));
        let type = resultSet.getLong(resultSet.getColumnIndex('type'));
        console.info(`id=${id}, question=${question}, answer=${answer}, type=${type}`);
        let question_info = new QuestionInfo('', '', -1)
        question_info.id = id
        question_info.question = question
        question_info.answer = answer
        question_info.type = type
        questionArray.push(question_info) // 添加至结果数组
      }
      console.info('query length='+questionArray.length)
      // 释放数据集的内存，若不释放可能会引起fd泄露与内存泄露
      resultSet.close();
    } catch (err) {
      console.error(`Query failed, code is ${err.code},message is ${err.message}`);
    }
    return questionArray
  }

}