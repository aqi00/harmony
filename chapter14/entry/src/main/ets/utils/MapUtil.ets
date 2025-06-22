import { mapCommon, map } from '@kit.MapKit';

export class MapUtil {

  public static convertPosition(latitude: number, longitude: number): mapCommon.LatLng {
    let wgs84Position: mapCommon.LatLng = {
      latitude: latitude,
      longitude: longitude
    };
    // 转换经纬度坐标
    let gcj02Position: mapCommon.LatLng =
      map.convertCoordinateSync(mapCommon.CoordinateType.WGS84, mapCommon.CoordinateType.GCJ02, wgs84Position);
    return gcj02Position
  }

}
