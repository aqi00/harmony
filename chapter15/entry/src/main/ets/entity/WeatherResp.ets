import { WeatherInfo } from '../entity/WeatherInfo';

export interface WeatherResp {
  status: string
  count: string
  info: string
  infocode: string
  lives: WeatherInfo[]
}
