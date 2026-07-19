interface DistrictInfo {
  citycode: string
  adcode: string
  name: string
  center: string
  level: string
  districts: DistrictInfo[]
}

export interface CityResp {
  status: string
  count: string
  info: string
  infocode: string
  districts: DistrictInfo[]
}