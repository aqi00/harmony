import { WeatherInfo } from '../entity/WeatherInfo';

export class CityInfo {
  provice_name: string // 省份名称
  city_name: string // 地市名称
  county_name: string // 县区名称
  address: string // 详细地址
  city_code?: string // 城市编码
  weather_info?: WeatherInfo // 天气信息

  constructor(provice_name: string, city_name: string, county_name: string, address: string) {
  this.provice_name = provice_name
  this.city_name = city_name
  this.county_name = county_name
  this.address = address
}

}
