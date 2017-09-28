<template>
  <div class="main-window">
    <div class="map-window">
      <gmap-map
        ref="map"
        :center="center"
        :zoom="zoom"
        style="width: 100%; height: 600px"
        @rightclick="drawRectangle"
        @bounds_changed="mapBoundsChanged"
      >
        <gmap-rectangle
          v-if="showTiles"
          v-for="(tile, idx) in allTiles"
          :key="'allTiles'+idx"
          :bounds="tile.bounds"
          :options="tileOptions"
          @rightclick="drawRectangle"
        ></gmap-rectangle>
        <gmap-rectangle
          v-if="rectBounds"
          :bounds="rectBounds"
          :draggable="true"
          :editable="true"
          :options="rectOptions"
          @bounds_changed="rectBoundsChanged"
        ></gmap-rectangle>
      </gmap-map>
      <div class="map-options">
        <label class="checkbox">
          <input type="checkbox" v-model="showTiles">
          Show Tiles
        </label>
      </div>
    </div>

    <div class="alexi-window">
      <div class="field is-grouped buttons-row">
        <a class="button is-info rectangle-button" @click="newRectangle">
          New Selection
        </a>
        <a class="button rectangle-button" @click="clearRectangle">
          Clear
        </a>
        <span class="field buttons-row" v-if="rectBounds">
          <span class="coordinate selection-label">
            Selection:
          </span>
          <span class="coordinate">
            <label class="coordinate-label">North</label>
            <input class="input coordinate-input" type="number" v-model.number="rectBounds.north">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">South</label>
            <input class="input coordinate-input" type="number" v-model.number="rectBounds.south">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">East</label>
            <input class="input coordinate-input" type="number" v-model.number="rectBounds.east">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">West</label>
            <input class="input coordinate-input" type="number" v-model.number="rectBounds.west">
          </span>
        </span>
      </div>

      <div v-if="rectBounds" class="images">
        <div v-for="(row, i) in rectTileMatrix" :key="'rr' + i" class="image-row">
          <img v-for="(cell, j) in row"
            :key="'rc' + i + '-' + j"
            :src="cell.png"
            :height="imageSize"
            :width="imageSize"
            :class="{'tile-border': showTilesOnImage}">
        </div>
        <div class="selection-on-image"
          v-show="showSelectionOnImage"
          :style="{
            'top': selectionOnImage.top + 'px',
            'left': selectionOnImage.left + 'px',
            'height': selectionOnImage.height + 'px',
            'width': selectionOnImage.width + 'px'
          }">
        </div>
        <div class="image-options">
          <label class="checkbox image-checkbox">
            <input type="checkbox" v-model="showTilesOnImage">
            Show Tiles
          </label>
          <label class="checkbox image-checkbox">
            <input type="checkbox" v-model="showSelectionOnImage">
            Show Selection
          </label>
          <span class="image-input">
            <label class="image-input-label">Width</label>
            <input class="input image-input-input" type="number" v-model.number="windowWidth">
          </span>
        </div>
        <div class="data-file-table">
          <div class="label">Tile files</div>
          <table class="table is-bordered">
            <tbody>
              <tr v-for="(row, i) in rectTileMatrix" :key="'rtr' + i">
                <td v-for="(cell, j) in row" :key="'rtc-' + i + '-' + j">
                  <a class="button is-link" :href="cell.tiff">{{cell.file}}</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

  </div>
</template>

<script>

var prefix = 'static/data/263/FINAL_EDAY_2017263_T'
var filePrefix = '263/FINAL_EDAY_2017263_T'

var tile00 = { file: filePrefix + '060.tif', tiff: prefix+'060.tif', png: prefix+'060.png', bounds: {west: -15, south: 30, east: 0, north: 45} }
var tile01 = { file: filePrefix + '061.tif', tiff: prefix+'061.tif', png: prefix+'061.png', bounds: {west: 0, south: 30, east: 15, north: 45} }
var tile02 = { file: filePrefix + '062.tif', tiff: prefix+'062.tif', png: prefix+'062.png', bounds: {west: 15, south: 30, east: 30, north: 45} }
var tile03 = { file: filePrefix + '063.tif', tiff: prefix+'063.tif', png: prefix+'063.png', bounds: {west: 30, south: 30, east: 45, north: 45} }
var tile04 = { file: filePrefix + '064.tif', tiff: prefix+'064.tif', png: prefix+'064.png', bounds: {west: 45, south: 30, east: 60, north: 45} }

var tile10 = { file: filePrefix + '084.tif', tiff: prefix+'084.tif', png: prefix+'084.png', bounds: {west: -15, south: 15, east: 0, north: 30} }
var tile11 = { file: filePrefix + '085.tif', tiff: prefix+'085.tif', png: prefix+'085.png', bounds: {west: 0, south: 15, east: 15, north: 30} }
var tile12 = { file: filePrefix + '086.tif', tiff: prefix+'086.tif', png: prefix+'086.png', bounds: {west: 15, south: 15, east: 30, north: 30} }
var tile13 = { file: filePrefix + '087.tif', tiff: prefix+'087.tif', png: prefix+'087.png', bounds: {west: 30, south: 15, east: 45, north: 30} }
var tile14 = { file: filePrefix + '088.tif', tiff: prefix+'088.tif', png: prefix+'088.png', bounds: {west: 45, south: 15, east: 60, north: 30} }

var tile20 = { file: filePrefix + '108.tif', tiff: prefix+'108.tif', png: prefix+'108.png', bounds: {west: -15, south: 0, east: 0, north: 15} }
var tile21 = { file: filePrefix + '109.tif', tiff: prefix+'109.tif', png: prefix+'109.png', bounds: {west: 0, south: 0, east: 15, north: 15} }
var tile22 = { file: filePrefix + '110.tif', tiff: prefix+'110.tif', png: prefix+'110.png', bounds: {west: 15, south: 0, east: 30, north: 15} }
var tile23 = { file: filePrefix + '111.tif', tiff: prefix+'111.tif', png: prefix+'111.png', bounds: {west: 30, south: 0, east: 45, north: 15} }
var tile24 = { file: filePrefix + '112.tif', tiff: prefix+'112.tif', png: prefix+'112.png', bounds: {west: 45, south: 0, east: 60, north: 15} }

var tileMatrix = [
  [tile00, tile01, tile02, tile03, tile04],
  [tile10, tile11, tile12, tile13, tile14],
  [tile20, tile21, tile22, tile23, tile24]
]

var allTiles = []
tileMatrix.forEach(function(row){
  allTiles = allTiles.concat(row)
})


export default {
  name: 'main-window',
  data () {
    return {
      center: {lat: 22.5, lng: 22.5},
      zoom: 3,
      mapSize: null,
      showTiles: false,
      tileMatrix: tileMatrix,
      allTiles: allTiles,
      tileOptions: {strokeWeight: 0.5, fillOpacity: 0.2},
      rectBounds: null,
      rectOptions: {strokeColor: '#FF0000', fillColor: '#FF0000'},
      windowWidth: 1000,
      showTilesOnImage: true,
      showSelectionOnImage: true
    }
  },
  computed: {
    rectTileMatrix () {
      if(!this.rectBounds)
        return null
      var rm = []
      for(var i=0;i<this.tileMatrix.length;i++){
        var row = this.tileMatrix[i]
        var rr = []
        for(var j=0;j<row.length;j++){
          var tile = row[j]
          var overlap = this.rectangleOverlap(tile.bounds, this.rectBounds)
          if(overlap){
            var rt = Object.assign({}, tile)
            rt.overlap = overlap
            rr.push(rt)
          }
        }
        if(rr.length){
          rm.push(rr)
        }
      }
      return rm
    },
    imageSize () {
      if(!this.rectTileMatrix || !this.rectTileMatrix[0] || !this.rectTileMatrix[0].length){
        return 0
      }
      return Math.round(this.windowWidth / this.rectTileMatrix[0].length)
    },
    selectionOnImage () {
      if(!this.imageSize)
        return {top: 0, left: 0, height: 0, width: 0}
      var topLeftTile = this.rectTileMatrix[0][0]
      var tlp2 = [topLeftTile.bounds.north, topLeftTile.bounds.west]
      var tlp1 = [topLeftTile.overlap.north, topLeftTile.overlap.west]
      var topLeftDist = this.distanceInPixel(topLeftTile, tlp1, tlp2)

      var lastRow = this.rectTileMatrix[this.rectTileMatrix.length - 1]
      var bottomRightTile = lastRow[lastRow.length - 1]
      var brp1 = [bottomRightTile.overlap.south, bottomRightTile.overlap.east]
      var brp2 = [bottomRightTile.bounds.south, bottomRightTile.bounds.east]
      var bottomRightDist = this.distanceInPixel(bottomRightTile, brp1, brp2)

      var wholeHeight = this.rectTileMatrix.length * this.imageSize
      var height = wholeHeight - topLeftDist[1] - bottomRightDist[1]
      var wholeWidth = lastRow.length * this.imageSize
      var width = wholeWidth - topLeftDist[0] - bottomRightDist[0]
      console.log({top: topLeftDist[1], left: topLeftDist[0], height: height, width: width})
      return {top: topLeftDist[1], left: topLeftDist[0], height: height, width: width}
    }
  },
  methods: {
    drawRectangle (e) {
      var lat = e.latLng.lat()
      var lng = e.latLng.lng()
      this.rectBounds = {
        north: lat,
        south: lat - this.mapSize.lat / 10,
        east: lng + this.mapSize.lng / 10,
        west: lng
      }
    },
    newRectangle () {
      var center = this.$refs.map.center
      var latRadius = this.mapSize.lat / 20
      var lngRadius = this.mapSize.lng / 20
      this.rectBounds = {
        north: center.lat + latRadius,
        south: center.lat - latRadius,
        east: center.lng + lngRadius,
        west: center.lng - lngRadius
      }
    },
    clearRectangle () {
      this.rectBounds = null
    },
    mapBoundsChanged (e) {
      this.mapSize = {
        lng: e.b.f - e.b.b,
        lat: e.f.f - e.f.b
      }
    },
    rectBoundsChanged (e) {
      this.rectBounds = {
        north: e.f.f,
        south: e.f.b,
        east: e.b.f,
        west: e.b.b
      }
    },
    lineOverlap (l1, l2) {
      if(l1[0] >= l2[1] || l2[0] >= l1[1])
        return null
      return [Math.max(l1[0], l2[0]), Math.min(l1[1], l2[1])]
    },
    rectangleOverlap (rect1, rect2) {
      var lat1 = [rect1.south, rect1.north]
      var lat2 = [rect2.south, rect2.north]
      var latOverlap = this.lineOverlap(lat1, lat2)
      var lng1 = [rect1.west, rect1.east]
      var lng2 = [rect2.west, rect2.east]
      var lngOverlap = this.lineOverlap(lng1, lng2)
      if(!latOverlap || !lngOverlap)
        return null
      return {north: latOverlap[1], south: latOverlap[0], east: lngOverlap[1], west: lngOverlap[0]}
    },
    distanceInPixel (tile, p1, p2) {
      var pixelPerLat = this.imageSize / (tile.bounds.north - tile.bounds.south)
      var pixelPerLng = this.imageSize / (tile.bounds.east - tile.bounds.west)
      var distX = Math.round((Math.abs(p2[1] - p1[1])) * pixelPerLng)
      var distY = Math.round((Math.abs(p2[0] - p1[0])) * pixelPerLat)
      return [distX, distY]
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.map-options {
  margin-top: 3px;
  margin-bottom: 5px;
  text-align: center;
}

.buttons-row {
  padding-left: 20px;
}

.rectangle-button {
  margin-right: 20px;
}

.coordinate {
  display: inline-block;
  margin-right: 20px;
}

.selection-label {
  position: relative;
  top: 6px;
  font-weight: bold;
}

.coordinate-label {
  position: relative;
  top: 6px;
}

.coordinate-input {
  width: 100px;
  display: inline-block;
}

.images {
  position: relative;
  left: 20px;
}

.image-row {
  margin-bottom: -7px;
  padding: 0px;
  white-space: nowrap;
  overflow: auto;
}

.image-options {
  text-align: center;
}

.image-checkbox {
  margin-top: 12px;
  margin-right: 20px;
}

.image-input {
  margin-top: 2px;
}

.image-input-input {
  width: 100px;
  display: inline-block;
  margin-top: 2px;
}

.tile-border {
  border: 1px solid gray;
}

.selection-on-image {
  position: absolute;
  border: 2px solid red;
}

</style>
