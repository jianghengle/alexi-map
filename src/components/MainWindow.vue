<template>
  <div class="main-window">
    <div class="map-window">
      <gmap-map
        ref="map"
        :center="center"
        :zoom="zoom"
        :options="{scrollwheel: false}"
        style="width: 100%"
        :style="{'height': mapHeightPx}"
        @rightclick="drawRectangle"
        @bounds_changed="mapBoundsChanged"
      >
        <gmap-rectangle
          v-if="showGrid"
          v-for="(tile, idx) in allTiles"
          :key="'allTiles'+idx"
          :bounds="tile.bounds"
          :options="tileOptions"
          @rightclick="drawRectangle"
        ></gmap-rectangle>
        <gmap-rectangle
          v-if="showSelectionOnMap && rectBounds"
          :bounds="rectBounds"
          :draggable="true"
          :editable="true"
          :options="rectOptions"
          @bounds_changed="rectBoundsChanged"
        ></gmap-rectangle>
        <ground-overlay
          v-if="showTiles"
          v-for = "(t, i) in rectTileList"
          :key="t.id"
          :source="t.png"
          :bounds="t.bounds"
          :opacity="t.opacity">
        </ground-overlay>
      </gmap-map>
      <div class="map-options">
        <span class="map-option">
          <label class="map-option-label">Map Height:</label>
          <input class="input map-option-input" type="number" step="20" v-model.number="mapHeight">
        </span>
        <label class="checkbox map-option">
          <input type="checkbox" v-model="showGrid">
          Show Grid
        </label>
        <label class="checkbox map-option">
          <input type="checkbox" v-model="showSelectionOnMap" :disabled="!rectTileList.length">
          Show Selection
        </label>
        <label class="checkbox map-option">
          <input type="checkbox" v-model="showTiles" :disabled="!rectTileList.length">
          Show Tiles
        </label>
        <span class="map-option">
          <label class="map-option-label">Tile Opacity:</label>
          <input class="input map-option-input" type="number" step="0.1" v-model.number="tileOpacity" :disabled="!rectTileList.length || !showTiles">
        </span>
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

      <div v-if="rectBounds">
        <div class="image-options">
          <label class="checkbox image-checkbox">
            <input type="checkbox" v-model="showGridOnImage">
            Show Grid
          </label>
          <label class="checkbox image-checkbox">
            <input type="checkbox" v-model="showSelectionOnImage">
            Show Selection
          </label>
          <span class="image-input">
            <label class="image-input-label">Image Size</label>
            <input class="input image-input-input" type="number" step="10" v-model.number="imageSize">
          </span>
          <span class="date-inputs">
            <label class="image-input-label" v-if="pickRange">Days</label>
            <label class="image-input-label" v-if="!pickRange">Day</label>
            <datepicker
              wrapper-class="date-picker-wrapper"
              input-class="date-picker-input"
              format="yyyy-MM-dd"
              :value="dateWindow[0]"
              :disabled="dateFromDisabled"
              v-on:selected="dateFromSelected">
            </datepicker>
            <datepicker
              v-if="pickRange"
              wrapper-class="date-picker-wrapper"
              input-class="date-picker-input"
              format="yyyy-MM-dd"
              :value="dateWindow[1]"
              :disabled="dateToDisabled"
              v-on:selected="dateToSelected">
            </datepicker>
            <label class="checkbox image-checkbox">
              <input type="checkbox" v-model="pickRange">
              Range
            </label>
          </span>
        </div>
        <div v-for="(d, k) in days" :key="'d' + d">
          <div class="date-label">{{rectTileMatrix[0][0].days[d].date}}</div>
          <div class="images">
            <div v-for="(row, i) in rectTileMatrix" :key="d + 'rr' + i" class="image-row">
              <a v-for="(cell, j) in row" :key="d + 'rc' + i + '-' + j"
                :href="cell.days[d].tif"
                :id="'tile-' + d + '-' + i + '-' + j">
                <img :src="cell.days[d].png"
                  :height="imageSize"
                  :width="imageSize"
                  :class="{'tile-border': showGridOnImage}">
              </a>
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
          </div>
        </div>
        <div class="download-button">
          <a class="button is-info rectangle-button" @click="downloadAll">
            Download All {{days.length * rectTileMatrix.length * rectTileMatrix[0].length}} Tiles
          </a>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
import DateForm from 'dateformat'
import Datepicker from 'vuejs-datepicker'


function makeDays(ds, fileNum){
  var days = {}
  ds.forEach(function(d){
    var date = new Date('2017-01-01T00:00:00')
    date.setDate(date.getDate() + parseInt(d))
    var day = { date:  DateForm(date, 'isoDate')}
    day.png = 'static/data/' + d + '/FINAL_EDAY_2017' + d + '_T' + fileNum + '.png'
    day.tif = 'static/data/' + d + '/FINAL_EDAY_2017' + d + '_T' + fileNum + '.tif'
    days[d] = day
  })
  return days
}

var minDay = new Date('2017-01-01T00:00:00')
minDay.setDate(minDay.getDate() + 263)

var maxDay = new Date('2017-01-01T00:00:00')
maxDay.setDate(maxDay.getDate() + 265)

var tile00 = { bounds: {west: -15, south: 30, east: 0, north: 45}, days: makeDays(['263', '264', '265'], '060') }
var tile01 = { bounds: {west: 0, south: 30, east: 15, north: 45}, days: makeDays(['263', '264', '265'], '061') }
var tile02 = { bounds: {west: 15, south: 30, east: 30, north: 45}, days: makeDays(['263', '264', '265'], '062') }
var tile03 = { bounds: {west: 30, south: 30, east: 45, north: 45}, days: makeDays(['263', '264', '265'], '063') }
var tile04 = { bounds: {west: 45, south: 30, east: 60, north: 45}, days: makeDays(['263', '264', '265'], '064') }

var tile10 = { bounds: {west: -15, south: 15, east: 0, north: 30}, days: makeDays(['263', '264', '265'], '084') }
var tile11 = { bounds: {west: 0, south: 15, east: 15, north: 30}, days: makeDays(['263', '264', '265'], '085') }
var tile12 = { bounds: {west: 15, south: 15, east: 30, north: 30}, days: makeDays(['263', '264', '265'], '086') }
var tile13 = { bounds: {west: 30, south: 15, east: 45, north: 30}, days: makeDays(['263', '264', '265'], '087') }
var tile14 = { bounds: {west: 45, south: 15, east: 60, north: 30}, days: makeDays(['263', '264', '265'], '088') }

var tile20 = { bounds: {west: -15, south: 0, east: 0, north: 15}, days: makeDays(['263', '264', '265'], '108') }
var tile21 = { bounds: {west: 0, south: 0, east: 15, north: 15}, days: makeDays(['263', '264', '265'], '109') }
var tile22 = { bounds: {west: 15, south: 0, east: 30, north: 15}, days: makeDays(['263', '264', '265'], '110') }
var tile23 = { bounds: {west: 30, south: 0, east: 45, north: 15}, days: makeDays(['263', '264', '265'], '111') }
var tile24 = { bounds: {west: 45, south: 0, east: 60, north: 15}, days: makeDays(['263', '264', '265'], '112') }

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
  components: {
    Datepicker
  },
  data () {
    return {
      mapHeight: 600,
      center: {lat: 22.5, lng: 22.5},
      zoom: 3,
      mapSize: null,
      showGrid: false,
      showSelectionOnMap: true,
      showTiles: false,
      tileMatrix: tileMatrix,
      allTiles: allTiles,
      tileOptions: {strokeWeight: 0.5, fillOpacity: 0.2},
      tileOpacity: 0.3,
      rectBounds: null,
      rectOptions: {strokeColor: '#FF0000', fillOpacity: 0.0, zIndex: 2},
      imageSize: 300,
      showGridOnImage: true,
      showSelectionOnImage: true,
      maxWindow: [minDay, maxDay],
      pickRange: false,
      dateWindow: [minDay, minDay]
    }
  },
  computed: {
    mapHeightPx () {
      return this.mapHeight + 'px'
    },
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
    rectTileList () {
      if(!this.rectTileMatrix) return []
      var list = []
      var days = this.days
      var opacity = this.tileOpacity
      this.rectTileMatrix.forEach(function(row){
        row.forEach(function(cell){
          var t = {bounds: cell.bounds}
          t.png = cell.days[days[0]].png
          t.opacity = opacity
          t.id = t.png + opacity
          list.push(t)
        })
      })
      return list
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
      return {top: topLeftDist[1], left: topLeftDist[0], height: height, width: width}
    },
    dateFromDisabled () {
      if(!this.pickRange)
        return {to: this.maxWindow[0], from: this.maxWindow[1]}
      return {to: this.maxWindow[0], from: this.dateWindow[1]}
    },
    dateToDisabled () {
      return {to: this.dateWindow[0], from: this.maxWindow[1]}
    },
    days () {
      var from = Math.round((this.dateWindow[0] - new Date('2017-01-01T00:00:00')) / 86400000)
      var to = Math.round((this.dateWindow[1] - new Date('2017-01-01T00:00:00')) / 86400000)
      var days = []
      if(!this.pickRange){
        days = [from]
      }else{
        while(from <= to){
          days.push(from)
          from++
        }
      }
      return days
    }
  },
  methods: {
    drawRectangle (e) {
      var lat = e.latLng.lat()
      var lng = e.latLng.lng()
      this.rectBounds = {
        north: lat,
        south: lat - this.mapSize / 10,
        east: lng + this.mapSize / 10,
        west: lng
      }
    },
    newRectangle () {
      var center = this.$refs.map.center
      var latRadius = this.mapSize / 20
      var lngRadius = this.mapSize / 20
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
      this.mapSize = e.f.f - e.f.b
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
    },
    dateFromSelected (date) {
      var lastDay = this.dateWindow[1]
      this.dateWindow = [date, lastDay]
    },
    dateToSelected (date) {
      var firstDay = this.dateWindow[0]
      this.dateWindow = [firstDay, date]
    },
    downloadAll () {
      var vm = this
      var elements = []
      this.days.forEach(function(d){
        for(var i=0;i<vm.rectTileMatrix.length;i++){
          var row = vm.rectTileMatrix[i]
          for(var j=0;j<row.length;j++){
            var id = 'tile-' + d + '-' + i + '-' + j
            var el = document.getElementById(id)
            elements.push(el)
          }
        }
      })
      var i = 0
      vm.downloadOne(elements, i)
    },
    downloadOne (elements, index) {
      var vm = this
      setTimeout(function(){
        let el = elements[index]
        el.click()
        index++
        if(index < elements.length){
          setTimeout(function(){
            vm.downloadOne(elements, index)
          }, 500)
        }
      }, 500)
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>

.map-options {
  margin-top: 3px;
  margin-bottom: 10px;
  text-align: center;
}

.map-option {
  display: inline-block;
  margin-right: 20px;
  margin-top: 5px;
}

.map-option-label {
}

.map-option-input {
  width: 100px;
  display: inline-block;
  margin-top: -6px;
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
  margin-bottom: 20px;
}

.image-row {
  margin-bottom: -7px;
  padding: 0px;
  white-space: nowrap;
  overflow: auto;
}

.image-options {
  margin-left: 20px;
  margin-bottom: 2px;
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
  pointer-events: none;
}

.date-inputs {
  display: inline-block;
  margin-left: 20px;
}

.date-label {
  margin-left: 20px;
}

.download-button {
  margin-left: 20px;
  margin-bottom: 20px;
}

</style>
