export class Constants {
  private static IP = '192.168.2.145'
  public static URL_PREFIX = `http://${Constants.IP}:8080/HttpServer/`
  public static WEBSOCKET_PREFIX = `ws://${Constants.IP}:8080/HttpServer/testWebSocket`
  public static SOCKET_SIMPLE_URL = `http://${Constants.IP}:9010/`
  public static SOCKET_CHAT_URL = `http://${Constants.IP}:9011/`
}