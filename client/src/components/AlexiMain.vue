<template>
  <div class="main-window">
    <alexi-introduction></alexi-introduction>
    <div class="map-options columns">
      <div class="column">
        <div v-if="token">
          <label>Map Height</label>
          <input class="input map-option-input" type="number" step="20" v-model.number="mapHeight">
        </div>
      </div>
      <div class="column date-picker-column">
        <a class="button" :disabled="!preDate" @click="selectPreDate">
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
          v-on:selected="dateSelected">
        </datepicker>
        <a class="button" :disabled="!nextDate" @click="selectNextDate">
          <span class="icon is-small">
            <icon name="chevron-right"></icon>
          </span>
        </a>
      </div>
      <div class="column dropdown-column dropdown-center">
        <div v-if="token" class="dropdown is-hoverable is-right">
          <div class="dropdown-trigger">
            <a class="dropdown-name">Settings</a>
          </div>
          <div class="dropdown-menu" role="menu">
            <div class="dropdown-content settings-dropdown-content">
              <a class="dropdown-item" v-for="(s, i) in userSettings"
                @click="loadSetting(s)">
                {{s.name}}&nbsp;
                <span v-if="s.isDefault">(default)</span>
              </a>
              <hr class="dropdown-divider">
              <a class="dropdown-item" @click="openSaveSettingModal">
                Save
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="map-window" v-if="ready">
      <gmap-map
        ref="map"
        :center="mapCenter"
        :zoom="mapZoom"
        :options="{scrollwheel: false}"
        style="width: 100%"
        :style="{'height': mapHeightPx}"
        @rightclick="drawSelection"
        @bounds_changed="mapBoundsChanged"
        @center_changed="mapCenterChanged"
        @zoom_changed="mapZoomChanged"
      >
        <gmap-rectangle
          v-if="mapOption.includes('Grids')"
          v-for="(bs, idx) in gridBounds"
          :key="'bs'+idx"
          :bounds="bs"
          :options="gridOptions"
          @rightclick="drawSelection">
        </gmap-rectangle>
        <gmap-rectangle
          v-for="(t, idx) in emptyTiles"
          v-if="mapOption.includes('All Grids')"
          :key="'empty'+idx"
          :bounds="t.bounds"
          :options="emptyGridOptions"
          @rightclick="drawSelection">
        </gmap-rectangle>
        <gmap-rectangle
          v-if="mapOption.includes('Selection')"
          :bounds="selectionBounds"
          :draggable="true"
          :editable="true"
          :options="selectionOptions"
          @bounds_changed="selectionBoundsChanged"
          @dragend="selectionBoundsChanged"
          ref="myRect">
        </gmap-rectangle>
        <ground-overlay
          v-for = "(t, i) in tileList"
          v-if="t.png"
          :key="t.id + tileOpacity"
          :source="t.png"
          :bounds="t.bounds"
          :opacity="tileOpacity">
        </ground-overlay>
        <ground-overlay
          v-for = "(t, i) in emptyTiles"
          v-if="mapOption.includes('All Grids')"
          :key="'emptyImage' + i"
          :source="t.src"
          :bounds="t.bounds">
        </ground-overlay>
      </gmap-map>
    </div>
    <div class="map-options columns">
      <div class="column">
        <div v-if="newSelectionBounds" class="columns">
          <div class="column">
            <div class="select">
              <select v-model="mapOption">
                <option>All Grids + Selection</option>
                <option>Available Grids + Selection</option>
                <option>Selection</option>
                <option>None</option>
              </select>
            </div>
          </div>
          <div class="column">
            <div class="field is-horizontal">
              <div class="field-label is-normal opacity-label-div">
                <label class="label opacity-label">Opacity</label>
              </div>
              <div class="field-body">
                <div class="field">
                  <div class="control">
                    <input class="input opacity-input" type="number" step="0.1" v-model.number="tileOpacity">
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="column">
        <span class="field" v-if="newSelectionBounds">
          <span class="coordinate">
            <label class="coordinate-label">W</label>
            <input class="input coordinate-input" type="number" v-model.number="newSelectionBounds.west">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">N</label>
            <input class="input coordinate-input" type="number" v-model.number="newSelectionBounds.north">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">E</label>
            <input class="input coordinate-input" type="number" v-model.number="newSelectionBounds.east">
          </span>
          <span class="coordinate">
            <label class="coordinate-label">S</label>
            <input class="input coordinate-input" type="number" v-model.number="newSelectionBounds.south">
          </span>
        </span>
      </div>
      <div class="column dropdown-column dropdown-top">
        <div v-if="token" class="dropdown is-hoverable">
          <div class="dropdown-trigger">
            <a class="dropdown-name">Selection</a>
          </div>
          <div class="dropdown-menu" role="menu">
            <div class="dropdown-content selection-dropdown-content">
              <a class="dropdown-item"  @click="newSelection">
                New
              </a>
              <a class="dropdown-item" @click="clearSelection">
                Clear
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="alexi-window">
      <div v-if="tileMatrix" v-show="token">
        <tile-window v-for="wid in tileWindows" :key="'tile-window-'+wid"
          :wid="wid"
          :main-date="date"
          :tile-matrix="tileMatrix"
          :date-disabled="dateDisabled"
          :main-tile-size="tileSize"
          :main-image-option="imageOption"
          :selection-bounds="newSelectionBounds"
          @tile-window-date-changed="tileWindowDateChanged"
          @tile-window-deleted="tileWindowDeleted"
          @tile-window-tile-size-changed="tileWindowTileSizeChanged"
          @tile-window-image-option-changed="tileWindowImageOptionChanged">
        </tile-window>
      </div>
      <div class="buttons-row columns" v-if="tileMatrix && token">
        <div class="column">
          <a class="button is-primary" @click="addTileWindow">
            Add Window
          </a>
        </div>
      </div>
    </div>

    <save-setting-modal
      :opened="saveSettingModal.opened"
      :settings="userSettings"
      :setting="saveSettingModal.setting"
      @close-save-setting-modal="closeSaveSettingModal">
    </save-setting-modal>

  </div>
</template>

<script>
import DateForm from 'dateformat'
import Datepicker from 'vuejs-datepicker'
import TileWindow from './TileWindow'
import SaveSettingModal from './modals/SaveSettingModal'
import AlexiIntroduction from './AlexiIntroduction'

function makeTileNums (start, end) {
  var ret = []
  for(var i=start;i<=end;i++){
    ret.push(i)
  }
  return ret
}

var allTileNums = []
allTileNums = allTileNums.concat(makeTileNums(1, 24))
allTileNums = allTileNums.concat(makeTileNums(26, 33))
allTileNums = allTileNums.concat(makeTileNums(36, 47))
allTileNums = allTileNums.concat(makeTileNums(52, 56))
allTileNums = allTileNums.concat(makeTileNums(60, 70))
allTileNums = allTileNums.concat(makeTileNums(77, 80))
allTileNums = allTileNums.concat(makeTileNums(83, 93))
allTileNums = allTileNums.concat(makeTileNums(103, 105))
allTileNums = allTileNums.concat(makeTileNums(107, 112))
allTileNums = allTileNums.concat(makeTileNums(114, 117))
allTileNums = allTileNums.concat(makeTileNums(127, 130))
allTileNums = allTileNums.concat(makeTileNums(133, 136))
allTileNums = allTileNums.concat(makeTileNums(139, 143))
allTileNums = allTileNums.concat(makeTileNums(152, 154))
allTileNums = allTileNums.concat(makeTileNums(157, 160))
allTileNums = allTileNums.concat(makeTileNums(164, 167))
allTileNums = allTileNums.concat(makeTileNums(176, 177))
allTileNums = allTileNums.concat(makeTileNums(182, 182))
allTileNums = allTileNums.concat(makeTileNums(188, 192))
allTileNums = allTileNums.concat(makeTileNums(200, 200))
allTileNums = allTileNums.concat(makeTileNums(216, 216))

var allTiles = {}
allTileNums.forEach(function(i){
  var tile = {
    num: i,
    bounds: tileNumToBounds(i),
    src: tileNumToImage(i)
  }
  allTiles[i] = tile
})

function tileNumToBounds (tileNum) {
  var x = (tileNum - 1) % 24
  var y = Math.floor((tileNum - 1) / 24)
  var north = 75 - (y * 15)
  var south = north - 15
  var west = -180 + (x * 15)
  var east = west + 15
  if(west == -180){
    west = -179.999
  }
  return {north: north, south: south, east: east, west: west}
}

function tileNumToImage (tileNum) {
  var canvas = document.createElement('canvas')
  canvas.width  = 200
  if(tileNum >=1 && tileNum <=24){
    canvas.height = 500
  }else if(tileNum >= 25 && tileNum <= 48){
    canvas.height = 260
  }else if(tileNum >= 193 && tileNum <= 216){
    canvas.height = 260
  }else{
    canvas.height = 200
  }

  var ctx=canvas.getContext("2d")
  ctx.font="20px Arial"
  ctx.fillText(tileNum.toString(), 20, 40)
  return canvas.toDataURL("image/png")
}

export default {
  name: 'alexi-main',
  components: {
    Datepicker,
    TileWindow,
    SaveSettingModal,
    AlexiIntroduction
  },
  data () {
    return {
      ready: false,
      mapHeight: 600,
      mapCenter: {lat: 22.5, lng: 22.5},
      newMapCenter: {lat: 22.5, lng: 22.5},
      mapZoom: 3,
      mapSize: null,
      gridOptions: {strokeWeight: 0.4, fillOpacity: 0.1},
      emptyGridOptions : {strokeWeight: 0.2, fillOpacity: 0},
      selectionBounds: {north: 25, south: 20, east: 25, west: 20},
      newSelectionBounds: {north: 25, south: 20, east: 25, west: 20},
      selectionOptions: {strokeColor: '#FF0000', fillColor: '#FF0000', fillOpacity: 0.1, zIndex: 2},
      tileOpacity: 0.6,
      tileSize: 200,
      mapOption: 'Available Grids + Selection',
      imageOption: 'Grids + Selection',
      date: new Date(),
      tileWindows: [],
      userSettings: [],
      saveSettingModal: {
        opened: false,
        setting: null
      },
    }
  },
  computed: {
    token () {
      return this.$store.state.user.token
    },
    mapHeightPx () {
      return this.mapHeight + 'px'
    },
    yearRange () {
      return this.$store.state.tiles.yearRange
    },
    daysInYears () {
      return this.$store.state.tiles.daysInYears
    },
    tilesInDays () {
      return this.$store.state.tiles.tilesInDays
    },
    dateDisabled () {
      if(!this.yearRange || !this.daysInYears)
        return {}
      var to = new Date(this.yearRange[0], 0, 1)
      var from = new Date(this.yearRange[1]+1, 0, 1)
      var dates = []
      var years = Object.keys(this.daysInYears)
      var dms = 86400000
      for(var i=0;i<years.length;i++){
        var year = years[i]
        var days = {}
        this.daysInYears[year].forEach(function(d){
          days[d] = true
        })
        var count = year % 4 ? 366 : 365
        var start = (new Date(year, 0, 1, 12)).getTime()
        for(var j=0;j<count;j++){
          if(!days[j+1]){
            dates.push(new Date(start + dms * j))
          }
        }
      }
      return {to: to, from: from, dates: dates}
    },
    year () {
      return this.date.getFullYear()
    },
    day () {
      return Math.ceil((this.date - new Date(this.year, 0, 1)) / 86400000)
    },
    dateCode () {
      return this.year.toString() + '_' + this.day.toString()
    },
    days () {
      return this.daysInYears[this.year]
    },
    preDate () {
      if(!this.yearRange || !this.daysInYears || !this.days)
        return null
      var index = this.days.indexOf(this.day)
      if(index <= 0)
        return null
      var day = this.days[index - 1]
      var ms = (new Date(this.year, 0, 1, 12)).getTime() + 86400000*(day-1)
      return new Date(ms)
    },
    nextDate () {
      if(!this.yearRange || !this.daysInYears || !this.days)
        return null
      var index = this.days.indexOf(this.day)
      if(index < 0 || index == this.days.length-1)
        return null
      var day = this.days[index + 1]
      var ms = (new Date(this.year, 0, 1, 12)).getTime() + 86400000*(day-1)
      return new Date(ms)
    },
    gridBounds () {
      if(!this.tilesInDays || !this.tilesInDays[this.dateCode])
        return []
      var tileNums = this.tilesInDays[this.dateCode]
      return tileNums.map(tileNumToBounds)
    },
    emptyTiles () {
      var emptyTiles = Object.assign({}, allTiles)
      if(this.tilesInDays && this.tilesInDays[this.dateCode]){
        var tileNums = this.tilesInDays[this.dateCode]
        tileNums.forEach(function(n){
          delete emptyTiles[n]
        })
      }
      return emptyTiles
    },
    tileMatrix () {
      if(!this.newSelectionBounds)
        return null
      var north = this.newSelectionBounds.north
      var south = this.newSelectionBounds.south
      var west = this.newSelectionBounds.west
      var east = this.newSelectionBounds.east
      if(west < east){
        var indexMatrix = this.getTileIndexMatrix(this.newSelectionBounds)
      }else{
        var b1 = {north: north, south: south, west: west, east: 180}
        var b2 = {north: north, south: south, west: -180, east: east}
        var m1 = this.getTileIndexMatrix(b1)
        var m2 = this.getTileIndexMatrix(b2)
        var indexMatrix = []
        for(var i=0;i<m1.length;i++){
          var row = m1[i].concat(m2[i])
          indexMatrix.push(row)
        }
      }
      var matrix = []
      for(var i=0;i<indexMatrix.length;i++){
        var row = indexMatrix[i]
        var newRow = []
        for(var j=0;j<row.length;j++){
          var tileIndex = row[j]
          var tile = {tileIndex: tileIndex}
          tile.tileNum = this.tileIndexToTileNum(tileIndex)
          tile.bounds = this.tileIndexToBounds(tileIndex)
          newRow.push(tile)
        }
        matrix.push(newRow)
      }
      return matrix
    },
    tileList () {
      if(!this.tileMatrix)
        return null
      var list = []
      for(var i=0;i<this.tileMatrix.length;i++){
        var row = this.tileMatrix[i]
        for(var j=0;j<row.length;j++){
          var tile = row[j]
          if(tile.tileNum){
            var tileCode = this.year + '_' + this.day + '_' + tile.tileNum
            list.push({
              id: tileCode,
              bounds: tile.bounds,
              png: this.$store.state.tiles.pngs[tileCode]
            })
          }
        }
      }
      return list
    }
  },
  methods: {
    mapCenterChanged (center) {
      this.newMapCenter = {lat: center.lat(), lng: center.lng()}
    },
    mapZoomChanged (zoom) {
      this.mapZoom = zoom
    },
    dateSelected (newDate) {
      this.date = newDate
      this.requestDays(newDate)
    },
    requestDays (date) {
      var year = date.getFullYear()
      var day = Math.ceil((date - new Date(year, 0, 1)) / 86400000)
      var dateCode = year + '_' + day
      if(!this.daysInYears[year]) {
        this.$http.get(xHTTPx + '/get_days_in_year/' + year).then((response) => {
          var obj = {year: year, days: response.body}
          this.$store.commit('tiles/setDaysInYear', obj)
        }, (response) => {
          console.log('failed to get days in year ' + year)
        })
      }
      if(!this.tilesInDays[dateCode]) {
        this.$http.get(xHTTPx + '/get_tiles_in_day/' + year + '/' + day).then((response) => {
          var obj = {dateCode: dateCode, tiles: response.body}
          this.$store.commit('tiles/setTilesInDay', obj)
        }, (response) => {
          console.log('failed to get days in year ' + year)
        })
      }
    },
    selectPreDate () {
      if(this.preDate){
        this.dateSelected(this.preDate)
      }
    },
    selectNextDate () {
      if(this.nextDate){
        this.dateSelected(this.nextDate)
      }
    },
    drawSelection (e) {
      var lat = e.latLng.lat()
      var lng = e.latLng.lng()
      this.selectionBounds = {
        north: lat,
        south: lat - this.mapSize / 10,
        east: lng + this.mapSize / 10,
        west: lng
      }
      this.newSelectionBounds = {
        north: lat,
        south: lat - this.mapSize / 10,
        east: lng + this.mapSize / 10,
        west: lng
      }
    },
    newSelection () {
      var center = this.newMapCenter
      var latRadius = this.mapSize / 20
      var lngRadius = this.mapSize / 20
      this.selectionBounds = {
        north: center.lat + latRadius,
        south: center.lat - latRadius,
        east: center.lng + lngRadius,
        west: center.lng - lngRadius
      }
      this.newSelectionBounds = {
        north: center.lat + latRadius,
        south: center.lat - latRadius,
        east: center.lng + lngRadius,
        west: center.lng - lngRadius
      }
    },
    clearSelection () {
      this.selectionBounds = null
      this.newSelectionBounds = null
    },
    mapBoundsChanged (e) {
      var bounds = this.$refs.map.$mapObject.getBounds()
      if(bounds){
        var north = bounds.getNorthEast().lat()
        var south = bounds.getSouthWest().lat()
        this.mapSize = north - south
      }
    },
    selectionBoundsChanged (e) {
      var bounds = this.$refs.myRect.$rectangleObject.getBounds()
      if(bounds){
        var north = bounds.getNorthEast().lat()
        var south = bounds.getSouthWest().lat()
        var east = bounds.getNorthEast().lng()
        var west = bounds.getSouthWest().lng()
        this.newSelectionBounds = {
          north: north,
          south: south,
          east: east,
          west: west
        }
      }
    },
    getTileIndexMatrix (bounds) {
      var northWest = {lat: bounds.north, lng: bounds.west}
      var southEast = {lat: bounds.south, lng: bounds.east}
      var nw = this.getTileIndexOfPoint(northWest)
      var se = this.getTileIndexOfPoint(southEast)
      var x1 = nw[0]
      var x2 = se[0]
      var y1 = nw[1]
      var y2 = se[1]
      var matrix = []
      for(var y=y1;y<=y2;y++){
        var row = []
        for(var x=x1;x<=x2;x++){
          row.push([x, y])
        }
        matrix.push(row)
      }
      return matrix
    },
    getTileIndexOfPoint (point) {
      var lat = point.lat
      var lng = point.lng
      if(lat > 75){
        var y = -1
      }else{
        var y = Math.floor((75 - lat) / 15)
      }
      var x = Math.floor((lng + 180) / 15)
      return [x, y]
    },
    tileIndexToBounds (tileIndex) {
      var x = tileIndex[0]
      var y = tileIndex[1]
      var north = 75 - (y * 15)
      var south = north - 15
      var west = -180 + x * 15
      var east = west + 15
      return {north: north, south: south, west: west, east: east}
    },
    tileIndexToTileNum (tileIndex) {
      var x = tileIndex[0]
      var y = tileIndex[1]
      if(y < 0 || y > 8)
        return null
      return y * 24 + x + 1
    },
    tileWindowDateChanged (obj) {
      if(obj.wid == 0){
        this.dateSelected(obj.date)
      }
      this.requestDays(obj.date)
    },
    addTileWindow () {
      var last = this.tileWindows[this.tileWindows.length - 1]
      this.tileWindows.push(last + 1)
    },
    tileWindowDeleted (wid) {
      var index = this.tileWindows.indexOf(wid)
      this.tileWindows.splice(index, 1)
    },
    tileWindowTileSizeChanged (tileSize) {
      this.tileSize = tileSize
    },
    tileWindowImageOptionChanged (imageOption) {
      this.imageOption = imageOption
    },
    applySetting (setting) {
      this.mapHeight = setting.mapHeight
      var latlng = setting.mapCenter.split(',').map(parseFloat)
      this.mapCenter = {lat: latlng[0], lng: latlng[1]}
      this.newMapCenter = {lat: latlng[0], lng: latlng[1]}
      this.mapZoom = setting.mapZoom
      this.tileOpacity = setting.tileOpacity
      if(setting.selection){
        var nsew = setting.selection.split(',').map(parseFloat)
        this.selectionBounds = {north: nsew[0], south: nsew[1], east: nsew[2], west: nsew[3]}
        this.newSelectionBounds = {north: nsew[0], south: nsew[1], east: nsew[2], west: nsew[3]}
      }else{
        this.selectionBounds = null
        this.newSelectionBounds = null
      }
      this.tileSize = setting.tileSize
      if(setting.date){
        this.date = setting.date
      }
      this.mapOption = setting.mapOption
      this.imageOption = setting.imageOption
    },
    collectSetting () {
      var setting = {}
      setting.mapHeight = this.mapHeight
      setting.mapCenter = [this.newMapCenter.lat, this.newMapCenter.lng].join(', ')
      setting.mapZoom = this.mapZoom
      setting.tileOpacity = this.tileOpacity
      var b = this.newSelectionBounds
      if(b){
        setting.selection = [b.north, b.south, b.east, b.west].join(', ')
      }else{
        setting.selection = ''
      }
      setting.tileSize = this.tileSize
      setting.date = this.date
      setting.mapOption = this.mapOption
      setting.imageOption = this.imageOption
      return setting
    },
    loadSetting (setting) {
      this.ready = false
      this.$nextTick(function(){
        this.applySetting(setting)
        this.ready = true
      })
    },
    openSaveSettingModal () {
      this.saveSettingModal.setting = this.collectSetting()
      this.saveSettingModal.opened = true
    },
    closeSaveSettingModal (result) {
      this.saveSettingModal.opened = false
      this.saveSettingModal.setting = null
      if(result){
        this.$http.get(xHTTPx + '/get_user_settings').then((response) => {
          this.userSettings = response.body
        }, (response) => {
          console.log('failed to get user settings')
        })
      }
    }
  },
  mounted () {
    this.$http.get(xHTTPx + '/get_latest_tiles').then((response) => {
      var resp = response.body
      this.$store.commit('tiles/setLatestTiles', resp.slice(1))
      var savedSetting = this.$store.state.tiles.setting
      this.userSettings = resp[0]
      if(savedSetting){
        this.applySetting(savedSetting)
      }else{
        if(this.userSettings.length){
          this.applySetting(this.userSettings[0])
        }
        var year = resp[1][1]
        var day = resp[2][resp[2].length-1]
        var ms = (new Date(year, 0, 1, 12)).getTime() + 86400000*(day-1)
        this.date = new Date(ms)
      }
      this.tileWindows = [0]
      this.ready = true
    }, (response) => {
      console.log('failed to get latest tiles')
      this.ready = true
    })
  },
  beforeDestroy () {
    var setting = this.collectSetting()
    this.$store.commit('tiles/setSetting', setting)
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.main-window {
  padding-top: 20px;
  padding-bottom: 20px;
  padding-left: 0px;
  padding-right: 0px;
}

.introduction {
  margin-bottom: 20px;
}

.map-options {
  margin: 0px;
  text-align: center;
}

.map-options-column {
  padding-top: 16px;
}

.map-option-input {
  width: 80px;
  display: inline-block;
  margin-top: -6px;
}

.opacity-label-div {
  margin-right: 5px;

  .opacity-label {
    font-weight: normal;
  }
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

.dropdown-column {
  padding: 0px;
  text-align: center;
}

.dropdown-center {
  margin: auto;
}

.dropdown-top {
  margin-top: 15px;
}

.dropdown-name {
  color: #0e485a;
}

.settings-dropdown-content {
  text-align: center;
}

.selection-dropdown-content {
  width: 100px;
  text-align: left;
}

.map-window {
  margin-top: -5px;
  margin-bottom: 0px;
  margin-left: -20px;
  margin-right: -20px;
}

.alexi-window {
  margin-top: 20px;
  margin-bottom: 20px;
}

</style>
