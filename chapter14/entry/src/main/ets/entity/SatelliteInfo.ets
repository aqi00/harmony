export class SatelliteInfo {
  id: number
  constellation: number
  altitudes: number
  azimuths: number
  frequencies: number
  noiseDensitys: number

  constructor(id: number, constellation: number, altitudes: number, azimuths: number, frequencies: number, noiseDensitys: number) {
    this.id = id
    this.constellation = constellation
    this.altitudes = altitudes
    this.azimuths = azimuths
    this.frequencies = frequencies
    this.noiseDensitys = noiseDensitys
  }

}