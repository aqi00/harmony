/**
 * RTF 解析器（ArkTS 版）
 *
 * 由 Android 工程 rtftet2 的 rtfparserkit 解析链路改写而来，保留了原实现的语义：
 *   RawRtfParser（词法/事件） + StandardRtfParser（编码、Unicode、字体字符集）
 *   + AbstractTextConverter（destination 过滤） + RtfExtract（HTML / 图片提取）
 *
 * 与原实现的差异（已在迁移说明中记录）：
 *   1. \wmetafile（WMF 矢量图）依赖 Java SE 的 org.w3c.dom / javax.xml.transform，
 *      ArkTS 无对应实现，因此优雅跳过并记录日志；
 *   2. 断字（HypenUtils）在原工程需要 AppSP/BookCSS 配置，默认关闭，这里不做断字；
 *   3. 无效的十六进制字符不再抛异常，按 0 处理，避免整篇解析被中断；
 *   4. 粗体/斜体/下划线按分组作用域状态输出（原实现的裸 \b/\i 被当作关闭导致粗体丢失）；
 *   5. \field/\fldinst HYPERLINK 字段生成 <a href> 超链接（原实现仅输出纯文本）。
 */
import { util } from '@kit.ArkTS';

/** 图片写出回调：把图片字节落盘，返回相对 HTML 的文件名（失败返回空串）。 */
export interface IRtfImageWriter {
  writeImage(data: Uint8Array, declaredFormat: string): string;
}

/** RTF 的 destination（目标）控制字，其内容不属于正文。由 Command.java 的 Destination 类型抽取。 */
const DEST_NAMES: string =
  'aftncn,aftnsep,aftnsepc,annotation,atnauthor,atndate,atnicn,atnid,atnparent,atnref,atntime,' +
  'atrfend,atrfstart,author,background,bkmkend,bkmkstart,blipuid,buptim,category,colorschememapping,' +
  'colortbl,comment,company,creatim,datafield,datastore,defchp,defpap,do,doccomm,docvar,dptxbxtext,' +
  'ebcend,ebcstart,factoidname,falt,fchars,ffdeftext,ffentrymcr,ffexitmcr,ffformat,ffhelptext,ffl,' +
  'ffname,ffstattext,field,file,filetbl,fldinst,fldrslt,fldtype,fname,fontemb,fontfile,fonttbl,footer,' +
  'footerf,footerl,footerr,footnote,formfield,ftncn,ftnsep,ftnsepc,g,generator,gridtbl,header,headerf,' +
  'headerl,headerr,hl,hlfr,hlinkbase,hlloc,hlsrc,hsv,htmltag,info,keycode,keywords,latentstyles,lchars,' +
  'levelnumbers,leveltext,lfolevel,linkval,list,listlevel,listname,listoverride,listoverridetable,' +
  'listpicture,liststylename,listtable,listtext,lsdlockedexcept,macc,maccPr,mailmerge,maln,malnScr,' +
  'manager,margPr,mbar,mbarPr,mbaseJc,mbegChr,mborderBox,mborderBoxPr,mbox,mboxPr,mchr,mcount,mctrlPr,' +
  'md,mdeg,mdegHide,mden,mdiff,mdPr,me,mendChr,meqArr,meqArrPr,mf,mfName,mfPr,mfunc,mfuncPr,mgroupChr,' +
  'mgroupChrPr,mgrow,mhideBot,mhideLeft,mhideRight,mhideTop,mhtmltag,mlim,mlimloc,mlimlow,mlimlowPr,' +
  'mlimupp,mlimuppPr,mm,mmaddfieldname,mmath,mmathPict,mmathPr,mmaxdist,mmc,mmcJc,mmconnectstr,' +
  'mmconnectstrdata,mmcPr,mmcs,mmdatasource,mmheadersource,mmmailsubject,mmodso,mmodsofilter,' +
  'mmodsofldmpdata,mmodsomappedname,mmodsoname,mmodsorecipdata,mmodsosort,mmodsosrc,mmodsotable,' +
  'mmodsoudl,mmodsoudldata,mmodsouniquetag,mmPr,mmquery,mmr,mnary,mnaryPr,mnoBreak,mnum,mobjDist,' +
  'moMath,moMathPara,moMathParaPr,mopEmu,mphant,mphantPr,mplcHide,mpos,mr,mrad,mradPr,mrPr,msepChr,' +
  'mshow,mshp,msPre,msPrePr,msSub,msSubPr,msSubSup,msSubSupPr,msSup,msSupPr,mstrikeBLTR,mstrikeH,' +
  'mstrikeTLBR,mstrikeV,msub,msubHide,msup,msupHide,mtransp,mtype,mvertJc,mvfmf,mvfml,mvtof,mvtol,' +
  'mzeroAsc,mzeroDesc,mzeroWid,nesttableprops,nextfile,nonesttables,objalias,objclass,objdata,object,' +
  'objname,objsect,objtime,oldcprops,oldpprops,oldsprops,oldtprops,oleclsid,operator,panose,password,' +
  'passwordhash,pgp,pgptbl,picprop,pict,pn,pnseclvl,pntext,pntxta,pntxtb,printim,private,propname,' +
  'protend,protstart,protusertbl,pxe,result,revtbl,revtim,rsidtbl,rtf,rxe,shp,shpgrp,shpinst,shppict,' +
  'shprslt,shptxt,sn,sp,staticval,stylesheet,subject,sv,svb,tc,template,themedata,title,txe,ud,upr,' +
  'userprops,wgrffmtfilter,windowcaption,writereservation,writerreservhash,xe,xform,xmlattrname,' +
  'xmlattrvalue,xmlclose,xmlname,xmlnstbl,xmlopen';

const DEST_SET: Set<string> = new Set<string>(DEST_NAMES.split(','));

/** 与 ParserState.java 对应的解析状态（按分组作用域拷贝/还原）。 */
class ParserState {
  fontExplicit: boolean = false;
  font: number = 0;
  encoding: string = 'Cp1252';
  fontEncoding: string | null = null;
  ucSkip: number = 1;
  /** 字符样式：\b/\i/\ul 开启，\b0/\i0/\ul0 关闭，随分组自动还原。 */
  bold: boolean = false;
  italic: boolean = false;
  underline: boolean = false;

  static copy(source: ParserState): ParserState {
    const target = new ParserState();
    target.fontExplicit = source.fontExplicit;
    target.font = source.font;
    target.encoding = source.encoding;
    target.fontEncoding = source.fontEncoding;
    target.ucSkip = source.ucSkip;
    target.bold = source.bold;
    target.italic = source.italic;
    target.underline = source.underline;
    return target;
  }
}

export class RtfParser {
  private bytes: Uint8Array = new Uint8Array(0);
  private pos: number = 0;
  private buffer: number[] = [];
  private parsingHex: boolean = false;
  private state: ParserState = new ParserState();
  private stateStack: ParserState[] = [];
  private fontEncodings: Map<number, string> = new Map<number, string>();
  private decoders: Map<string, util.TextDecoder> = new Map<string, util.TextDecoder>();
  private skipBytes: number = 0;
  /** 当前 destination（对应 AbstractTextConverter#currentDestination）。 */
  private dest: string = 'rtf';
  private destStack: string[] = [];
  /** 样式/命令栈（对应 RtfExtract 的 stack）。 */
  private stack: Set<string> = new Set<string>();
  /** 图片状态（对应 RtfExtract 的 isImage / isBlipUid / format）。 */
  private isImage: boolean = false;
  private isBlipUid: boolean = false;
  private imageFormat: string = 'png';
  private counter: number = 0;
  private body: string = '';
  private writer: IRtfImageWriter;
  /** {\*\fldinst ...} 组内累积的指令文本，用于提取 HYPERLINK URL。 */
  private fldinstText: string = '';
  /** 当前 \field 的超链接 URL（空串表示非超链接字段）。 */
  private hyperlinkUrl: string = '';

  constructor(writer: IRtfImageWriter) {
    this.writer = writer;
  }

  /** 解析 RTF 字节，返回 HTML 的 body 片段。 */
  parse(bytes: Uint8Array): string {
    this.bytes = bytes;
    this.pos = 0;
    this.buffer = [];
    this.body = '';
    this.stack = new Set<string>();
    this.dest = 'rtf';
    this.destStack = [];
    this.state = new ParserState();
    this.stateStack = [];
    this.fontEncodings = new Map<number, string>();
    this.parsingHex = false;
    this.skipBytes = 0;
    this.fldinstText = '';
    this.hyperlinkUrl = '';

    const len = bytes.length;
    while (this.pos < len) {
      const ch = bytes[this.pos];
      this.pos++;
      if (ch === 0x7B) {
        this.groupStart(); // {
      } else if (ch === 0x7D) {
        this.groupEnd(); // }
      } else if (ch === 0x5C) {
        this.readCommand(); // \
      } else if (ch === 0x0D || ch === 0x0A) {
        // 忽略回车换行
      } else if (ch === 0x09) {
        this.flush();
        this.processCommandName('tab', 0, false);
      } else {
        this.characterByte(ch);
      }
    }
    return this.body;
  }

  // ------------------------------------------------------------------ 词法

  private groupStart(): void {
    this.flush();
    this.destStack.push(this.dest);
    this.stateStack.push(this.state);
    this.state = ParserState.copy(this.state);
  }

  private groupEnd(): void {
    this.flush();
    if (this.destStack.length > 0) {
      this.dest = this.destStack.pop() as string;
    }
    if (this.stateStack.length > 0) {
      this.state = this.stateStack.pop() as ParserState;
    }
    // {\field{\*\fldinst HYPERLINK "url"}{\fldrslt 文本}}：
    // fldinst 组结束时从指令文本中解析 URL，供随后 fldrslt 文本包裹 <a>；
    // 离开 field 相关 destination 后清除，避免影响后续正文。
    if (this.dest === 'field') {
      this.hyperlinkUrl = parseHyperlinkUrl(this.fldinstText);
      this.fldinstText = '';
    } else if (this.dest !== 'fldinst' && this.dest !== 'fldrslt') {
      this.hyperlinkUrl = '';
      this.fldinstText = '';
    }
  }

  /** 单个字符字节（或 \'hh 的第二位十六进制）。 */
  private characterByte(ch: number): void {
    if (this.parsingHex) {
      let value = hexDigit(ch) << 4;
      if (this.pos >= this.bytes.length) {
        this.buffer.push(value >> 4);
        this.parsingHex = false;
        return;
      }
      const next = this.bytes[this.pos];
      if (next === 0x5C) {
        // 畸形 RTF：只有一个十六进制位就遇到 '\'，退格保留该位
        value = value >> 4;
      } else {
        value += hexDigit(next);
        this.pos++;
      }
      this.buffer.push(value);
      this.parsingHex = false;
    } else {
      this.buffer.push(ch);
    }
  }

  /** 读取一个控制字（对应 RawRtfParser#handleCommand）。 */
  private readCommand(): void {
    const len = this.bytes.length;
    if (this.pos >= len) {
      return;
    }
    let i = this.pos;
    const first = this.bytes[i];
    i++;
    if (!isAsciiLetter(first)) {
      this.pos = i;
      this.handleCommandToken(String.fromCharCode(first), 0, false);
      return;
    }

    let name = String.fromCharCode(first);
    while (i < len) {
      const ch = this.bytes[i];
      if (!isAsciiLetter(ch)) {
        break;
      }
      name += String.fromCharCode(ch);
      i++;
      if (name.length > 30) {
        break;
      }
    }

    let hasParameter = false;
    let parameter = 0;
    let ch = i < len ? this.bytes[i] : -1;
    let negative = false;
    if (ch === 0x2D) {
      negative = true;
      i++;
      ch = i < len ? this.bytes[i] : -1;
    }
    if (ch >= 0x30 && ch <= 0x39) {
      hasParameter = true;
      let digits = '';
      while (i < len) {
        const d = this.bytes[i];
        if (d < 0x30 || d > 0x39) {
          break;
        }
        digits += String.fromCharCode(d);
        i++;
        if (digits.length > 20) {
          break;
        }
      }
      const parsed = Number.parseInt(digits.length > 0 ? digits : '0', 10);
      parameter = Number.isNaN(parsed) ? 0 : parsed;
      if (negative) {
        parameter = -parameter;
      }
      ch = i < len ? this.bytes[i] : -1;
    }
    // 与 RawRtfParser 一致：控制字后的分隔空格被消费；其余分隔字符留给主循环重新读取
    if (ch === 0x20) {
      i++;
    }
    this.pos = i;
    this.handleCommandToken(name, parameter, hasParameter);
  }

  /**
   * 对应 RawRtfParser#handleCommand：除 \' 外都要先输出已累积的字符数据。
   */
  private handleCommandToken(name: string, parameter: number, hasParameter: boolean): void {
    if (name !== "'") {
      this.flush();
    }
    if (name === "'") {
      this.parsingHex = true;
      return;
    }
    if (name === 'bin') {
      // 二进制图片数据：原实现同样不消费（listener 无 binary 处理），这里跳过
      const skip = parameter > 0 ? parameter : 0;
      this.pos = Math.min(this.pos + skip, this.bytes.length);
      return;
    }
    this.processCommandName(name, parameter, hasParameter);
  }

  /** 把已累积的字节交给字符处理（对应 handleCharacterData）。 */
  private flush(): void {
    if (this.buffer.length === 0) {
      return;
    }
    const data = new Uint8Array(this.buffer.length);
    for (let i = 0; i < this.buffer.length; i++) {
      data[i] = this.buffer[i];
    }
    this.buffer = [];
    this.processCharacterBytes(data);
  }

  // ------------------------------------------------------------------ 编码

  private processCharacterBytes(data: Uint8Array): void {
    if (data.length === 0) {
      return;
    }
    if (this.skipBytes < data.length) {
      const text = this.decodeBytes(data, this.skipBytes, data.length);
      this.processString(text);
    }
    this.skipBytes = 0;
  }

  private decodeBytes(data: Uint8Array, from: number, to: number): string {
    const decoder = this.getDecoder(mapEncodingLabel(this.currentEncodingName()));
    try {
      return decoder.decodeToString(data.subarray(from, to));
    } catch (e) {
      return this.getDecoder('utf-8').decodeToString(data.subarray(from, to));
    }
  }

  private getDecoder(label: string): util.TextDecoder {
    const cached = this.decoders.get(label);
    if (cached !== undefined) {
      return cached;
    }
    let decoder: util.TextDecoder;
    try {
      decoder = util.TextDecoder.create(label);
    } catch (e) {
      decoder = util.TextDecoder.create('utf-8');
    }
    this.decoders.set(label, decoder);
    return decoder;
  }

  /** 对应 StandardRtfParser#currentEncoding。 */
  private currentEncodingName(): string {
    if (!this.state.fontExplicit) {
      this.state.fontExplicit = true;
      const fromMap = this.fontEncodings.get(0);
      this.state.fontEncoding = fromMap === undefined ? null : fromMap;
    }
    const fontEncoding = this.state.fontEncoding;
    return fontEncoding === null ? this.state.encoding : fontEncoding;
  }

  /**
   * 对应 StandardRtfParser#processCommand：
   * 先处理编码类命令和特殊字符，其余交给 handleGenericCommand。
   */
  private processCommandName(name: string, parameter: number, hasParameter: boolean): void {
    switch (name) {
      case 'ansi':
        this.state.encoding = 'Cp1252';
        return;
      case 'mac':
        this.state.encoding = 'MacRoman';
        return;
      case 'pc':
        this.state.encoding = 'Cp437';
        return;
      case 'pca':
        this.state.encoding = 'Cp850';
        return;
      case 'ansicpg':
        if (hasParameter) {
          this.state.encoding = codePageToCharset(unsignedValue(parameter));
        }
        return;
      case 'u':
        this.processCharacter(String.fromCharCode(unsignedValue(parameter)));
        this.skipBytes = this.state.ucSkip;
        return;
      case 'uc':
        this.state.ucSkip = parameter;
        return;
      case 'f':
        this.state.fontExplicit = true;
        this.state.font = parameter;
        const fromMap = this.fontEncodings.get(parameter);
        this.state.fontEncoding = fromMap === undefined ? null : fromMap;
        this.handleGenericCommand(name, parameter, hasParameter);
        return;
      case 'fcharset':
        this.setFontEncoding(fontCharsetToCharset(parameter));
        this.handleGenericCommand(name, parameter, hasParameter);
        return;
      case 'cpg':
        this.setFontEncoding(codePageToCharset(unsignedValue(parameter)));
        this.handleGenericCommand(name, parameter, hasParameter);
        return;
      case 'emdash':
        this.processCharacter('\u2014');
        return;
      case 'endash':
        this.processCharacter('\u2013');
        return;
      case 'emspace':
        this.processCharacter('\u2003');
        return;
      case 'enspace':
        this.processCharacter('\u2002');
        return;
      case 'qmspace':
        this.processCharacter('\u2005');
        return;
      case 'bullet':
        this.processCharacter('\u2022');
        return;
      case 'lquote':
        this.processCharacter('\u2018');
        return;
      case 'rquote':
        this.processCharacter('\u2019');
        return;
      case 'ldblquote':
        this.processCharacter('\u201c');
        return;
      case 'rdblquote':
        this.processCharacter('\u201d');
        return;
      case 'backslash':
        this.processCharacter('\\');
        return;
      case 'opencurly':
        this.processCharacter('{');
        return;
      case 'closecurly':
        this.processCharacter('}');
        return;
      default:
        this.handleGenericCommand(name, parameter, hasParameter);
        return;
    }
  }

  private setFontEncoding(charset: string | null): void {
    if (charset !== null) {
      this.fontEncodings.set(this.state.font, charset);
    }
  }

  private processCharacter(c: string): void {
    this.processString(c);
  }

  // ------------------------------------------------------- 事件 → HTML / 图片

  /** 对应 AbstractTextConverter#processCommand + RtfExtract#processCommand。 */
  private handleGenericCommand(name: string, parameter: number, hasParameter: boolean): void {
    // —— AbstractTextConverter：destination 过滤与段落/制表符 ——
    if (DEST_SET.has(name)) {
      this.dest = name;
    }
    if (name === 'par' || name === 'line' || name === 'row') {
      this.processExtractedText('\n');
    }
    if (name === 'tab' || name === 'cell') {
      this.processExtractedText('\t');
    }

    // —— RtfExtract：样式栈与图片识别 ——
    if (name === 'cbpat' || name === 'line') {
      this.body += '<br/>';
    }
    // 字符样式：裸 \b/\i/\ul 为开启，\b0/\i0/\ul0（带 0 参数）为关闭。
    // 样式保存在 ParserState 中随分组自动还原；
    // 原实现把裸 \b（parameter==0）当作关闭跳过，导致 Word 生成的粗体全部丢失。
    if (name === 'b' || name === 'i' || name === 'ul') {
      const off = hasParameter && parameter === 0;
      if (name === 'b') {
        this.state.bold = !off;
      } else if (name === 'i') {
        this.state.italic = !off;
      } else {
        this.state.underline = !off;
      }
    } else if (name === 'ulnone') {
      this.state.underline = false;
    } else if (name === 'plain') {
      // \plain 清除全部字符样式
      this.state.bold = false;
      this.state.italic = false;
      this.state.underline = false;
    } else {
      this.stack.add(name);
    }
    if (name === 'blipuid') {
      this.isBlipUid = true;
    }
    if (name === 'pngblip') {
      this.isImage = true;
      this.imageFormat = 'png';
    }
    if (name === 'jpegblip') {
      this.isImage = true;
      this.imageFormat = 'jpg';
    }
    if (name === 'wmetafile') {
      this.isImage = true;
      this.imageFormat = 'wmf';
    }
  }

  /** 对应 AbstractTextConverter#processString + RtfExtract#processString。 */
  private processString(text: string): void {
    // {\*\fldinst ...} 内是指令文本（如 HYPERLINK "url"），累积后在组结束时解析
    if (this.dest === 'fldinst') {
      this.fldinstText += text;
    }

    // 文本：仅正文 destination 输出；fldrslt 且带超链接 URL 时包裹 <a>
    if (this.dest === 'rtf' || this.dest === 'pntext' || this.dest === 'fldrslt') {
      const linkUrl = this.dest === 'fldrslt' ? this.hyperlinkUrl : '';
      this.processExtractedText(text, linkUrl);
    }

    // 图片：{\*\blipuid ...} 是图片 UID（32 位十六进制），跳过并保持 isImage
    if (this.isBlipUid) {
      this.isBlipUid = false;
      return;
    }
    if (this.isImage) {
      this.isImage = false;
      this.writeImage(text);
    }
  }

  private writeImage(hex: string): void {
    try {
      if (this.imageFormat === 'wmf') {
        // WMF 需要 Java SE 的 DOM/XML 栈，ArkTS 无法移植，优雅跳过
        console.warn('RtfParser: skip \\wmetafile image (unsupported on ArkTS)');
        return;
      }
      const data = hexToBytes(hex);
      if (data.length === 0) {
        return;
      }
      const name = this.writer.writeImage(data, this.imageFormat);
      if (name !== '') {
        this.body += "<img src='" + name + "' />";
      }
      this.counter++;
    } catch (e) {
      console.error('RtfParser: image extract failed, ' + JSON.stringify(e));
    }
  }

  /** 对应 RtfExtract#processExtractedText；linkUrl 非空时把文本包裹为超链接。 */
  private processExtractedText(text: string, linkUrl: string = ''): void {
    let encoded = htmlEncode(text);
    if (linkUrl !== '') {
      encoded = '<a href="' + htmlEncode(linkUrl) + '">' + encoded + '</a>';
    }
    this.printText(encoded);
    this.body += ' ';
  }

  /** 对应 RtfExtract#printText；粗体/斜体/下划线改为分组作用域状态驱动。 */
  private printText(txt: string): void {
    if (this.stack.has('par')) {
      this.body += '<p></p>';
    }
    if (this.stack.has('sub')) {
      this.body += '<sub>';
    }
    if (this.stack.has('supercmd')) {
      this.body += '<sup>';
    }
    if (this.state.bold) {
      this.body += '<b>';
    }
    if (this.state.italic) {
      this.body += '<i>';
    }
    if (this.state.underline) {
      this.body += '<u>';
    }

    this.body += txt;

    if (this.state.underline) {
      this.body += '</u>';
    }
    if (this.state.italic) {
      this.body += '</i>';
    }
    if (this.state.bold) {
      this.body += '</b>';
    }
    if (this.stack.has('par')) {
      // 原实现中 </p> 被注释掉，这里保持一致
      this.stack.delete('par');
    }
    if (this.stack.has('sub')) {
      this.body += '</sub>';
      this.stack.delete('sub');
    }
    if (this.stack.has('supercmd')) {
      this.body += '</sup>';
      this.stack.delete('supercmd');
    }
  }
}

// -------------------------------------------------------------------- 工具函数

function isAsciiLetter(c: number): boolean {
  return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
}

/** 从 {\*\fldinst ...} 的指令文本中提取 HYPERLINK "url" 的 URL，非超链接字段返回空串。 */
function parseHyperlinkUrl(instruction: string): string {
  const key = 'HYPERLINK';
  const keyIdx = instruction.indexOf(key);
  if (keyIdx < 0) {
    return '';
  }
  const quoteStart = instruction.indexOf('"', keyIdx + key.length);
  if (quoteStart < 0) {
    return '';
  }
  const quoteEnd = instruction.indexOf('"', quoteStart + 1);
  if (quoteEnd < 0) {
    return '';
  }
  return instruction.substring(quoteStart + 1, quoteEnd);
}

function unsignedValue(parameter: number): number {
  return parameter < 0 ? parameter + 65536 : parameter;
}

function hexDigit(c: number): number {
  if (c >= 0x30 && c <= 0x39) {
    return c - 0x30;
  }
  if (c >= 0x41 && c <= 0x46) {
    return c - 0x41 + 10;
  }
  if (c >= 0x61 && c <= 0x66) {
    return c - 0x61 + 10;
  }
  return 0;
}

/** 十六进制字符串 → 字节（对应 HexUtils.parseHexString，非法字符按 0 处理）。 */
function hexToBytes(hex: string): Uint8Array {
  const pairs = Math.floor(hex.length / 2);
  const out = new Uint8Array(pairs);
  for (let i = 0; i < pairs; i++) {
    const hi = hexDigit(hex.charCodeAt(i * 2));
    const lo = hexDigit(hex.charCodeAt(i * 2 + 1));
    out[i] = (hi << 4) | lo;
  }
  return out;
}

/** 对应 android.text.TextUtils.htmlEncode。 */
function htmlEncode(text: string): string {
  let out = '';
  for (let i = 0; i < text.length; i++) {
    const c = text.charAt(i);
    switch (c) {
      case '&':
        out += '&amp;';
        break;
      case '<':
        out += '&lt;';
        break;
      case '>':
        out += '&gt;';
        break;
      case '"':
        out += '&quot;';
        break;
      case '\'':
        out += '&#39;';
        break;
      default:
        out += c;
        break;
    }
  }
  return out;
}

/**
 * Java 字符集名 → HarmonyOS TextDecoder 支持的编码名（ICU/WHATWG 标签）。
 * rtfparserkit 的 Encoding/FontCharset 使用的是 Java 字符集名（Cp936、Cp1252…）。
 */
function mapEncodingLabel(javaCharset: string): string {
  switch (javaCharset) {
    case 'Cp936':
    case 'Cp10008':
      return 'gbk';
    case 'Cp950':
    case 'Cp10002':
      return 'big5';
    case 'MS932':
    case 'SJIS':
    case 'Cp932':
    case 'Cp10001':
      return 'shift_jis';
    case 'Cp949':
    case 'Cp1361':
    case 'Cp10003':
      return 'euc-kr';
    case 'Cp1250':
    case 'Cp10029':
      return 'windows-1250';
    case 'Cp1251':
    case 'Cp10007':
      return 'windows-1251';
    case 'Cp1253':
    case 'Cp10006':
      return 'windows-1253';
    case 'Cp1254':
    case 'Cp10081':
      return 'windows-1254';
    case 'Cp1255':
    case 'Cp10005':
      return 'windows-1255';
    case 'Cp1256':
    case 'Cp10004':
      return 'windows-1256';
    case 'Cp1257':
      return 'windows-1257';
    case 'Cp1258':
      return 'windows-1258';
    case 'Cp874':
    case 'Cp10021':
      return 'windows-874';
    case 'MacRoman':
    case 'Cp10000':
      return 'macintosh';
    case 'Cp437':
    case 'Cp850':
      // ICU 无对应 WHATWG 标签，退化为西文单字节编码
      return 'windows-1252';
    default:
      return 'windows-1252';
  }
}

/** 对应 Encoding.LOCALEID_MAPPING 中常用的代码页（\ansicpgN）。 */
function codePageToCharset(codePage: number): string {
  switch (codePage) {
    case 936:
      return 'Cp936';
    case 950:
      return 'Cp950';
    case 932:
      return 'MS932';
    case 949:
      return 'Cp949';
    case 874:
      return 'Cp874';
    case 437:
      return 'Cp437';
    case 850:
      return 'Cp850';
    case 1250:
    case 1251:
    case 1252:
    case 1253:
    case 1254:
    case 1255:
    case 1256:
    case 1257:
    case 1258:
      return 'Cp' + codePage;
    case 10000:
      return 'MacRoman';
    default:
      return 'Cp1252';
  }
}

/** 对应 FontCharset.getCharset（\fcharsetN）→ LOCALEID_MAPPING 的代码页键。 */
function fontCharsetToCharset(charset: number): string | null {
  switch (charset) {
    case 0:
    case 2:
      return 'Cp1252';
    case 1:
      return null;
    case 77:
      return 'MacRoman';
    case 78:
      return 'MS932';
    case 79:
      return 'Cp949';
    case 80:
      return 'Cp936';
    case 81:
      return 'Cp950';
    case 83:
      return 'Cp1255';
    case 84:
      return 'Cp1256';
    case 85:
      return 'Cp1253';
    case 86:
      return 'Cp1254';
    case 87:
      return 'Cp874';
    case 88:
      return 'Cp1250';
    case 89:
      return 'Cp1251';
    case 128:
      return 'MS932';
    case 129:
      return 'Cp949';
    case 130:
      return 'Cp1361';
    case 134:
      return 'Cp936';
    case 136:
      return 'Cp950';
    case 161:
      return 'Cp1253';
    case 162:
      return 'Cp1254';
    case 163:
      return 'Cp1258';
    case 177:
      return 'Cp1255';
    case 178:
      return 'Cp1256';
    case 186:
      return 'Cp1257';
    case 204:
      return 'Cp1251';
    case 222:
      return 'Cp874';
    case 238:
      return 'Cp1250';
    case 254:
      return 'Cp437';
    case 255:
      return 'Cp850';
    default:
      return null;
  }
}
