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
        @rightclick="drawSelection"
        @bounds_changed="mapBoundsChanged"
      >
        <gmap-rectangle
          v-if="showGrids"
          v-for="(tile, idx) in tilesList"
          :key="'tiles'+idx"
          :bounds="tile.bounds"
          :options="gridOptions"
          @rightclick="drawSelection"
        ></gmap-rectangle>
        <gmap-rectangle
          v-if="showSelection && selectionBounds"
          :bounds="selectionBounds"
          :draggable="true"
          :editable="true"
          :options="selectionOptions"
          @bounds_changed="selectionBoundsChanged"
        ></gmap-rectangle>
        <ground-overlay
          v-if="showTiles"
          v-for = "(t, i) in selectionTileList"
          :key="t.id"
          :source="t.png"
          :bounds="t.bounds"
          :opacity="t.opacity">
        </ground-overlay>
      </gmap-map>
      <div class="map-options columns">
        <div class="column">
          <label class="checkbox map-option">
            <input type="checkbox" v-model="showGrids">
            Grids
          </label>
          &nbsp;&nbsp;
          <label class="checkbox map-option" v-show="selectionTileList.length">
            <input type="checkbox" v-model="showSelection">
            Selection
          </label>
          &nbsp;
          <label class="map-option" v-show="selectionTileList.length">
            Tiles
          </label>
          <input class="input map-option-input opacity-input" type="number" step="0.1" v-model.number="tileOpacity"
              :disabled="!showTiles"
              v-show="selectionTileList.length">
        </div>
        <div class="column date-picker-column">
          <span v-show="selectionTileList.length">
            <a class="button" :disabled="!showTiles || day==263" @click="dayChanged(day-1)">
              <span class="icon is-small">
                <icon name="chevron-left"></icon>
              </span>
            </a>
            <datepicker
              wrapper-class="date-picker-wrapper"
              input-class="date-picker-input"
              format="yyyy-MM-dd"
              :value="date"
              :disabled="dateDisabled"
              v-on:selected="dateSelected"
              :disabled-picker="!showTiles">
            </datepicker>
            <a class="button" :disabled="!showTiles || day==265" @click="dayChanged(day+1)">
              <span class="icon is-small">
                <icon name="chevron-right"></icon>
              </span>
            </a>
          </span>
        </div>
        <div class="column">
          <label>Map Height</label>
          <input class="input map-option-input" type="number" step="20" v-model.number="mapHeight">
        </div>
      </div>
    </div>

    <div class="alexi-window">
      <div class="buttons-row columns">
        <div class="column is-one-quarter">
          <a class="button is-info" @click="newSelection">
            New Selection
          </a>
        </div>
        <div class="column">
          <span class="field" v-if="selectionBounds">
            <span class="coordinate">
              <label class="coordinate-label">N</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.north">
            </span>
            <span class="coordinate">
              <label class="coordinate-label">S</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.south">
            </span>
            <span class="coordinate">
              <label class="coordinate-label">E</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.east">
            </span>
            <span class="coordinate">
              <label class="coordinate-label">W</label>
              <input class="input coordinate-input" type="number" v-model.number="selectionBounds.west">
            </span>
          </span>
        </div>
        <div class="column is-one-quarter">
          <a class="button" @click="clearSelection">
            Clear Selection
          </a>
        </div>
      </div>

      <div v-if="selectionBounds">
        <image-box v-for="(box, i) in boxes" :key="'box-'+i"
          :idx="i"
          :selection-tiles="selectionTiles"
          :day="box.day"
          :show-grids="showGrids"
          :show-selection="showSelection"
          :max-date-window="maxDateWindow"
          @box-day-changed="boxDayChanged"
          @box-deleted="imageBoxDeleted">
        </image-box>
      </div>

      <div class="buttons-row columns" v-if="selectionBounds">
        <div class="column">
          <a class="button is-info" @click="addImageBox">
            Add Image Box
          </a>
        </div>
      </div>

    </div>

  </div>
</template>

<script>
import DateForm from 'dateformat'
import Datepicker from 'vuejs-datepicker'
import ImageBox from './ImageBox'


function makeDays(ds, fileNum){
  var days = {}
  ds.forEach(function(d){
    var date = new Date('2017-01-01T00:00:00')
    date.setDate(date.getDate() + parseInt(d))
    var day = { date:  DateForm(date, 'isoDate')}
    day.id = day.date + '-' + fileNum
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

var tiles = [
  [tile00, tile01, tile02, tile03, tile04],
  [tile10, tile11, tile12, tile13, tile14],
  [tile20, tile21, tile22, tile23, tile24]
]

var tilesList = []
tiles.forEach(function(row){
  tilesList = tilesList.concat(row)
})




export default {
  name: 'main-window',
  components: {
    Datepicker,
    ImageBox
  },
  data () {
    return {
      mapHeight: 600,
      center: {lat: 22.5, lng: 22.5},
      zoom: 3,
      mapSize: null,
      showGrids: false,
      gridOptions: {strokeWeight: 0.4, fillOpacity: 0.1},
      showSelection: false,
      selectionBounds: {north: 40, south: 5, east: 55, west: -10},
      selectionOptions: {strokeColor: '#FF0000', fillOpacity: 0.0, zIndex: 2},
      showTiles: true,
      tileOpacity: 0.6,
      tiles: tiles,
      tilesList: tilesList,
      maxDateWindow: [minDay, maxDay],
      boxes: [{day: 263}]
    }
  },
  computed: {
    mapHeightPx () {
      return this.mapHeight + 'px'
    },
    selectionTiles () {
      if(!this.selectionBounds)
        return null
      var selectTiles = []
      for(var i=0;i<this.tiles.length;i++){
        var row = this.tiles[i]
        var selectionRow = []
        for(var j=0;j<row.length;j++){
          var tile = row[j]
          var overlap = this.rectangleOverlap(tile.bounds, this.selectionBounds)
          if(overlap){
            var selectionTile = Object.assign({}, tile)
            selectionTile.overlap = overlap
            selectionRow.push(selectionTile)
          }
        }
        if(selectionRow.length){
          selectTiles.push(selectionRow)
        }
      }
      return selectTiles
    },
    selectionTileList () {
      if(!this.selectionTiles) return []
      if(!this.boxes.length) return []
      var day = this.boxes[0].day
      var list = []
      var opacity = this.tileOpacity
      this.selectionTiles.forEach(function(row){
        row.forEach(function(cell){
          var t = {bounds: cell.bounds}
          t.png = cell.days[day].png
          t.opacity = opacity
          t.id = t.png + opacity
          list.push(t)
        })
      })
      return list
    },
    day () {
      if(!this.boxes.length) return null
      return this.boxes[0].day
    },
    date () {
      if(!this.boxes.length) return null
      var date = new Date('2017-01-01T00:00:00')
      date.setDate(date.getDate() + parseInt(this.day))
      return date
    },
    dateDisabled () {
      return {to: this.maxDateWindow[0], from: this.maxDateWindow[1]}
    }
  },
  methods: {
    drawSelection (e) {
      var lat = e.latLng.lat()
      var lng = e.latLng.lng()
      this.selectionBounds = {
        north: lat,
        south: lat - this.mapSize / 10,
        east: lng + this.mapSize / 10,
        west: lng
      }
    },
    newSelection () {
      var center = this.$refs.map.center
      var latRadius = this.mapSize / 20
      var lngRadius = this.mapSize / 20
      this.selectionBounds = {
        north: center.lat + latRadius,
        south: center.lat - latRadius,
        east: center.lng + lngRadius,
        west: center.lng - lngRadius
      }
    },
    clearSelection () {
      this.selectionBounds = null
    },
    mapBoundsChanged (e) {
      this.mapSize = e.f.f - e.f.b
    },
    selectionBoundsChanged (e) {
      this.selectionBounds = {
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
    dateSelected (date) {
      var day = Math.round((date - new Date('2017-01-01T00:00:00')) / 86400000)
      this.boxDayChanged({idx: 0, day: day})
    },
    boxDayChanged (boxDay) {
      var idx = boxDay.idx
      if(idx < this.boxes.length)
        this.boxes[idx].day = boxDay.day
    },
    dayChanged (day) {
      if(this.showTiles && this.boxes.length){
        this.boxes[0].day = day
      }
    },
    addImageBox () {
      this.boxes.push({day: 263})
    },
    imageBoxDeleted (idx) {
      this.boxes.splice(idx, 1)
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.map-options {
  margin-top: 0px;
  text-align: center;
}

.map-option-input {
  width: 80px;
  display: inline-block;
  margin-top: -6px;
}

.opacity-input {
  width: 60px;
}

.buttons-row {
  text-align: center;
}

.coordinate {
  display: inline-block;
  margin-right: 20px;

  .coordinate-label {
    position: relative;
    top: 6px;
  }

  .coordinate-input {
    width: 66px;
    display: inline-block;
  }
}

.date-picker-column {
  padding-top: 6px;
}

.alexi-window {
  margin-bottom: 100px;
}

</style>
